-- Job registry + terminal output pane for lua/launch.
--
-- Two execution kinds, because a build and a run want opposite things:
--
--   build  buffered jobstart -> errorformat -> quickfix + inline diagnostics.
--          You do not want to watch a compile scroll past; you want the errors.
--
--   run    PTY terminal buffer, streaming.
--          You DO want to watch this. The PTY is the point: a program whose
--          stdout is a pipe gets libc's 4KB block buffering, so a long-running
--          app produces nothing observable until it exits or fills the block.
--          On a tty it line-buffers instead, and you also get ANSI colour and
--          a working stdin for an interactive CLI.
--
-- Every job is registered by target name so a re-run can kill the previous
-- instance. Without that, pressing the run key twice left two GUI processes
-- alive with no way to reach either one.

local M = {}

M.DEFAULT_HEIGHT = 15

---name -> { job, bufnr, cmd, kind, started }
---@type table<string, table>
local jobs = {}

-- The single shared output window. Reused across targets so a project with
-- four run targets doesn't end up with four splits.
local pane_win = nil
local last_shown = nil

local build_diag_ns = vim.api.nvim_create_namespace('launch_build')

---@return boolean
local function pane_valid()
  return pane_win ~= nil and vim.api.nvim_win_is_valid(pane_win)
end

---@param bufnr integer
---@param height integer|nil
local function open_pane(bufnr, height)
  if pane_valid() then
    vim.api.nvim_win_set_buf(pane_win, bufnr)
  else
    -- botright, so the pane spans the full width under everything rather than
    -- splitting whichever window happened to be focused.
    vim.cmd('botright ' .. (height or M.DEFAULT_HEIGHT) .. 'split')
    pane_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(pane_win, bufnr)
  end
  local wo = vim.wo[pane_win]
  wo.winfixheight = true
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = 'no'
  wo.spell = false
  wo.list = false
end

---@param name string
---@return boolean
function M.is_running(name)
  local e = jobs[name]
  return e ~= nil and e.job ~= nil and vim.fn.jobwait({ e.job }, 0)[1] == -1
end

---Stop one target's job. Safe to call when nothing is running.
---@param name string
---@return boolean stopped
function M.stop(name)
  local e = jobs[name]
  if not e or not e.job then return false end
  local running = M.is_running(name)
  -- jobstop signals the whole process group for a PTY job, which is what
  -- kills a shell-wrapped `cmd &&  cmd` chain rather than orphaning the tail.
  pcall(vim.fn.jobstop, e.job)
  e.job = nil
  return running
end

---@return integer count
function M.stop_all()
  local n = 0
  for name in pairs(jobs) do
    if M.stop(name) then n = n + 1 end
  end
  return n
end

---@return table[] rows  { name, kind, cmd, running }
function M.list()
  local out = {}
  for name, e in pairs(jobs) do
    out[#out + 1] = {
      name = name, kind = e.kind, cmd = e.cmd, running = M.is_running(name),
    }
  end
  table.sort(out, function(a, b) return a.name < b.name end)
  return out
end

---Drop a dead target's terminal buffer.
---Buffer names are unique, so a stale `launch://run` would make the rename of
---the next run's buffer fail silently and leave it as `term://...`.
---@param name string
local function wipe_buf(name)
  local e = jobs[name]
  if not e or not e.bufnr then return end
  if vim.api.nvim_buf_is_valid(e.bufnr) then
    pcall(vim.api.nvim_buf_delete, e.bufnr, { force = true })
  end
  e.bufnr = nil
end

--------------------------------------------------------------------------------
-- run: streaming PTY terminal
--------------------------------------------------------------------------------

---@param target table  { name, cmd, height? }
---@param root string
---@param opts table|nil { focus?: boolean }
function M.run_term(target, root, opts)
  opts = opts or {}
  local name = target.name

  -- Kill the previous instance before starting another. This is the whole
  -- reason the registry exists: a GUI app started twice used to leave an
  -- unreachable orphan behind.
  if M.is_running(name) then
    M.stop(name)
    vim.notify(('launch: restarted %s'):format(name), vim.log.levels.INFO)
  end
  wipe_buf(name)

  local buf = vim.api.nvim_create_buf(false, true)
  local prev_win = vim.api.nvim_get_current_win()

  -- The buffer has to be current in a REAL window before jobstart, not just
  -- current via nvim_buf_call: the PTY takes its rows/cols from the window it
  -- is created in, and buf_call's scratch window has the wrong geometry, so
  -- anything that draws to width (progress bars, tables) wraps wrong.
  open_pane(buf, target.height)
  vim.api.nvim_set_current_win(pane_win)

  local job = vim.fn.jobstart(target.cmd, {
    term = true,
    cwd = root,
    on_exit = function(_, code)
      vim.schedule(function()
        local level = code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(('launch: %s exited (%d)'):format(name, code), level)
      end)
    end,
  })

  if job <= 0 then
    vim.api.nvim_set_current_win(prev_win)
    vim.notify(('launch: could not start %s (%s)'):format(name, target.cmd),
      vim.log.levels.ERROR)
    return
  end

  -- jobstart(term=true) renames the buffer to term://<cwd>//<pid>:<cmd>.
  -- Rename after, so the pane reads as the target rather than a pid.
  pcall(vim.api.nvim_buf_set_name, buf, 'launch://' .. name)

  jobs[name] = { job = job, bufnr = buf, cmd = target.cmd, kind = 'run', started = true }
  last_shown = name

  -- Park the cursor on the last line. Neovim tail-follows a terminal window
  -- only while the cursor is at the bottom, so this gives live follow for free
  -- AND gives up follow the moment you scroll up to read something — which is
  -- the behaviour you want and costs no code.
  pcall(vim.api.nvim_win_set_cursor, pane_win, { vim.api.nvim_buf_line_count(buf), 0 })

  local function map(lhs, fn, desc)
    vim.keymap.set('n', lhs, fn, { buffer = buf, silent = true, desc = desc })
  end
  map('q', function() M.hide_pane() end, 'launch: hide output pane (job keeps running)')
  map('<C-c>', function()
    if M.stop(name) then
      vim.notify('launch: stopped ' .. name, vim.log.levels.INFO)
    end
  end, 'launch: stop this job')

  if not opts.focus then
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_set_current_win(prev_win)
    end
  end
end

--------------------------------------------------------------------------------
-- build: buffered, errorformat -> quickfix + diagnostics
--------------------------------------------------------------------------------

---@param target table  { name, cmd }
---@param root string
---@param on_done fun(code: integer)|nil
function M.run_build(target, root, on_done)
  local name = target.name
  if M.is_running(name) then
    M.stop(name)
  end

  local lines = {}
  vim.notify(('launch: %s'):format(target.cmd), vim.log.levels.INFO)

  -- Snapshot the errorformat NOW, from the buffer that started the build.
  -- make_detect sets it buffer-locally per (cwd, filetype); by the time the
  -- job exits, the current buffer can easily be the quickfix window or a
  -- terminal pane, whose filetype resolves to a different — wrong — format.
  require('utils.make_detect').apply()
  local efm = vim.bo.errorformat

  local job = vim.fn.jobstart(target.cmd, {
    cwd = root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data) if data then vim.list_extend(lines, data) end end,
    on_stderr = function(_, data) if data then vim.list_extend(lines, data) end end,
    on_exit = function(_, code)
      vim.schedule(function()
        vim.diagnostic.reset(build_diag_ns)

        -- NOTE: when a {what} dict is passed, setqflist IGNORES the {list}
        -- argument — items have to travel inside the dict. Passing them
        -- positionally alongside a dict silently does nothing.
        if code == 0 then
          vim.fn.setqflist({}, 'r', { items = {}, title = name .. ': SUCCESS' })
          vim.cmd('cclose')
          vim.notify(('launch: %s ok'):format(name), vim.log.levels.INFO)
          if on_done then on_done(code) end
          return
        end

        -- One setqflist call, not one per line. The old version appended each
        -- output line with a separate setqflist(..., 'a'), which rebuilds the
        -- whole list every time — quadratic on a chatty failing build.
        vim.fn.setqflist({}, 'r', {
          lines = lines,
          efm = efm,
          title = ('%s: %s'):format(name, target.cmd),
        })

        local qf = vim.fn.getqflist()
        local errors = 0
        for _, item in ipairs(qf) do
          if item.valid == 1 then errors = errors + 1 end
        end

        if errors > 0 then
          local by_buf = {}
          for _, d in ipairs(vim.diagnostic.fromqflist(qf, { merge_lines = true })) do
            if d.bufnr and d.bufnr > 0 then
              by_buf[d.bufnr] = by_buf[d.bufnr] or {}
              table.insert(by_buf[d.bufnr], d)
            end
          end
          for bufnr, diags in pairs(by_buf) do
            vim.diagnostic.set(build_diag_ns, bufnr, diags)
          end
          vim.notify(('launch: %s failed — %d error(s)'):format(name, errors),
            vim.log.levels.ERROR)
        else
          -- Nothing matched the errorformat, so show the raw output rather
          -- than an empty quickfix list.
          local raw = {}
          for _, l in ipairs(lines) do
            if l ~= '' then raw[#raw + 1] = { text = l } end
          end
          vim.fn.setqflist({}, 'r', {
            items = raw,
            title = ('%s: exit %d'):format(name, code),
          })
          vim.notify(('launch: %s failed (exit %d)'):format(name, code),
            vim.log.levels.ERROR)
        end
        vim.cmd('copen')
        if on_done then on_done(code) end
      end)
    end,
  })

  if job <= 0 then
    vim.notify(('launch: could not start %s (%s)'):format(name, target.cmd),
      vim.log.levels.ERROR)
    return
  end
  jobs[name] = { job = job, cmd = target.cmd, kind = 'build', started = true }
end

--------------------------------------------------------------------------------
-- pane control
--------------------------------------------------------------------------------

function M.hide_pane()
  if pane_valid() then
    vim.api.nvim_win_close(pane_win, false)
  end
  pane_win = nil
end

---Show/hide the most recent run target's output. The job is untouched either
---way — hiding a pane must not kill what it is showing.
function M.toggle_pane()
  if pane_valid() then
    M.hide_pane()
    return
  end
  local e = last_shown and jobs[last_shown]
  if not e or not e.bufnr or not vim.api.nvim_buf_is_valid(e.bufnr) then
    vim.notify('launch: no output to show', vim.log.levels.WARN)
    return
  end
  local cur = vim.api.nvim_get_current_win()
  open_pane(e.bufnr)
  vim.api.nvim_set_current_win(cur)
end

---@return integer|nil bufnr  the visible output buffer, if any
function M.pane_buf()
  if pane_valid() then
    return vim.api.nvim_win_get_buf(pane_win)
  end
  local e = last_shown and jobs[last_shown]
  if e and e.bufnr and vim.api.nvim_buf_is_valid(e.bufnr) then return e.bufnr end
  return nil
end

---Push the output pane through 'errorformat' into the quickfix list, so a RUN
---that happens to print compiler-style diagnostics still gets jump-to-line.
---
---Deliberately not `:cbuffer`. That takes 'errorformat' from whatever buffer
---is current — which, called from inside the pane, is the terminal — and it
---ingests the terminal's blank screen padding as a wall of invalid entries
---(one per unused row). Reading the lines out and filtering first gives a
---quickfix list containing only real matches.
function M.to_quickfix()
  local buf = M.pane_buf()
  if not buf then
    vim.notify('launch: no output buffer', vim.log.levels.WARN)
    return
  end

  local lines = {}
  for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if l:match('%S') then lines[#lines + 1] = l end
  end

  require('utils.make_detect').apply()
  vim.fn.setqflist({}, 'r', {
    lines = lines,
    efm = vim.bo.errorformat,
    title = 'launch: ' .. (last_shown or 'output'),
  })

  -- Keep only entries the errorformat actually resolved to a location.
  local valid = {}
  for _, item in ipairs(vim.fn.getqflist()) do
    if item.valid == 1 then valid[#valid + 1] = item end
  end

  if #valid == 0 then
    vim.fn.setqflist({}, 'r', { items = {} })
    vim.notify('launch: no errorformat matches in output', vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, 'r', {
    items = valid,
    title = ('launch: %s (%d)'):format(last_shown or 'output', #valid),
  })
  vim.cmd('copen')
end

---@return string|nil
function M.last() return last_shown end

function M.setup()
  -- A run target must not outlive the editor. Nothing stopped these before,
  -- so quitting nvim left a GUI app running with its parent gone.
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('launch_run_cleanup', { clear = true }),
    callback = function() M.stop_all() end,
    desc = 'Stop all launch jobs before quitting',
  })
end

return M
