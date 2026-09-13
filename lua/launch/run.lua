-- Output buffers and jobs for lua/launch.
--
-- Every command writes into a named out buffer (launch://*compilation*,
-- launch://*run*, ...): one buffer per name, one job per buffer. Starting a
-- command stops whatever was still writing to its buffer.
--
-- Jobs run on a PTY so the program line-buffers its stdout. On a pipe libc
-- block-buffers it and a GUI app shows nothing until it exits. The output
-- still lands in a plain buffer, not a terminal, so it can be edited, yanked
-- and searched.

local M = {}

local HEIGHT = 15

-- Wide, so compilers that wrap diagnostics to the terminal width do not.
local PTY_WIDTH = 500

-- One errorformat for every compiler, 4coder style: any command's output is
-- parsed the same way, whichever buffer it was started from.
local ERRORFORMAT = table.concat({
  '%Dlaunch-root: %f', -- errors() prepends this so relative paths resolve against the root
  '%f:%l\\,%c: %m', -- Jai
  '%f:%l:%c: %m', -- clang, gcc, zig
  '%f:%l: %m', -- gcc/ld, Jai without a column
  '%f(%l\\,%c): %m', -- MSVC /diagnostics:column, tsc
  '%f(%l): %m', -- MSVC
  '%f(%l) : %m', -- older MSVC
  '%f(%l:%c) %m', -- Odin
  '%.%#--> %f:%l:%c', -- Rust
  'CMake Error at %f:%l %m',
  '%f:%l:%c - %m', -- ESLint
  '%-G%.%#',
}, ',')

---out name -> { buf, job, key, cmd, root, partial }
---@type table<string, table>
local outs = {}

local pane_win = nil
local last_out = nil

-- The quickfix list launch owns, by id, 0 until a command first reports
-- errors. The error marks are drawn from it. Diagnostics are switched off
-- globally (lua/config/lsp.lua), so the marks are plain extmarks.
local qf_id = 0
local marks_ns = vim.api.nvim_create_namespace('launch_errors')

---Quickfix items for the error locations in `lines`. Only locations whose
---file exists count: the formats are broad enough that a log line like
---`12:34:56: started` parses as file `12`.
---@param root string
---@param lines string[]
---@return table[]
local function errors(root, lines)
  -- Every format has a `:<digit>` or `(<digit>`. Dropping the other lines
  -- first keeps a long log from paying for every pattern on every line.
  local candidates = { 'launch-root: ' .. root }
  for _, line in ipairs(lines) do
    if line:find('[:(]%d') then candidates[#candidates + 1] = line end
  end
  local items = vim.fn.getqflist({ lines = candidates, efm = ERRORFORMAT }).items
  return vim.tbl_filter(function(item)
    return item.valid == 1 and vim.uv.fs_stat(vim.api.nvim_buf_get_name(item.bufnr)) ~= nil
  end, items)
end

---The launch list's items. Guarded because id 0 means the current list; a
---list that fell out of the quickfix history comes back empty.
---@return table[]
local function launch_items()
  if qf_id == 0 then return {} end
  return vim.fn.getqflist({ id = qf_id, items = 0 }).items
end

---Draw the `items` that belong to `buf`: error lines get a red tint and the
---message at the end of the line, warnings only the message. Extmarks follow
---edits, so a mark stays on its line until the next build.
---@param buf integer
---@param items table[]
local function mark_errors(buf, items)
  vim.api.nvim_buf_clear_namespace(buf, marks_ns, 0, -1)
  local line_count = vim.api.nvim_buf_line_count(buf)
  for _, item in ipairs(items) do
    if item.bufnr == buf and item.lnum <= line_count then
      local warning = item.text:lower():match('^warning') ~= nil
      vim.api.nvim_buf_set_extmark(buf, marks_ns, item.lnum - 1, 0, {
        line_hl_group = not warning and 'LaunchErrorLine' or nil,
        virt_text = { { '  ' .. item.text, warning and 'DiagnosticWarn' or 'ErrorMsg' } },
        virt_text_pos = 'eol',
      })
    end
  end
end

---Put this output's errors in the launch list and redraw the marks. New
---errors become the current list; a clean run empties the launch list in
---place and leaves whatever list you are on (a grep) alone.
---@return integer count
local function to_quickfix(o)
  local items = errors(o.root, vim.api.nvim_buf_get_lines(o.buf, 0, -1, false))
  local what = { items = items, title = 'launch: ' .. o.key }
  if #items > 0 and (qf_id == 0 or vim.fn.getqflist({ id = 0 }).id ~= qf_id) then
    vim.fn.setqflist({}, ' ', what)
    qf_id = vim.fn.getqflist({ id = 0 }).id
  elseif qf_id ~= 0 then
    what.id = qf_id
    vim.fn.setqflist({}, 'r', what)
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then mark_errors(buf, items) end
  end
  return #items
end

---A PTY line as plain text: no colour codes, no CRLF, and only the final
---frame of a `\r` progress redraw.
---@param line string
---@return string
local function clean(line)
  line = line:gsub('\27%[[0-9;?]*[ -/]*[@-~]', ''):gsub('\r$', '')
  return (line:match('[^\r]*$'))
end

---Write a jobstart chunk into the output buffer. The buffer's last line is
---always the unfinished line, so each chunk replaces it. Windows showing the
---end keep following it.
local function write(o, data)
  data[1] = o.partial .. data[1]
  -- Only the last `\r` frame can still show (see clean), and keeping just that
  -- stops a status line that is redrawn forever from growing without end.
  o.partial = data[#data]:match('[^\r]*\r?$')
  local last = vim.api.nvim_buf_line_count(o.buf)
  local following = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_cursor(win)[1] == last
  end, vim.fn.win_findbuf(o.buf))
  vim.api.nvim_buf_set_lines(o.buf, -2, -1, false, vim.tbl_map(clean, data))
  for _, win in ipairs(following) do
    vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(o.buf), 0 })
  end
end

---@return boolean
local function pane_valid()
  return pane_win ~= nil and vim.api.nvim_win_is_valid(pane_win)
end

---Show `buf` in the shared bottom pane, at its end, without taking focus.
---@param buf integer
local function show(buf)
  if pane_valid() then
    vim.api.nvim_win_set_buf(pane_win, buf)
  else
    pane_win = vim.api.nvim_open_win(buf, false, { split = 'below', win = -1, height = HEIGHT })
    local wo = vim.wo[pane_win]
    wo.winfixheight = true
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = 'no'
    wo.spell = false
    wo.list = false
  end
  vim.api.nvim_win_set_cursor(pane_win, { vim.api.nvim_buf_line_count(buf), 0 })
end

---Open the error on the cursor line in the window you came from, and make it
---the launch list's current entry so <M-n> continues from there.
---@param out string
local function jump(out)
  local item = errors(outs[out].root, { vim.api.nvim_get_current_line() })[1]
  if item then
    for i, entry in ipairs(launch_items()) do
      if entry.bufnr == item.bufnr and entry.lnum == item.lnum and entry.col == item.col then
        vim.fn.setqflist({}, 'a', { id = qf_id, idx = i })
        break
      end
    end
    -- Like lsp.lua's jump_to: leave a jumplist entry, and list the buffer
    -- (quickfix parsing creates it unlisted).
    vim.cmd.wincmd('p')
    vim.cmd("normal! m'")
    vim.bo[item.bufnr].buflisted = true
    vim.api.nvim_set_current_buf(item.bufnr)
    vim.fn.cursor(item.lnum, math.max(item.col, 1))
    vim.cmd('normal! zz')
  end
end

---@param out string
---@return integer buf
local function new_buf(out)
  local buf = vim.api.nvim_create_buf(true, true)
  -- A bare `*run*` would be expanded to a path under cwd; a URL-like name is not.
  vim.api.nvim_buf_set_name(buf, 'launch://' .. out)
  vim.keymap.set('n', '<CR>', function() jump(out) end,
    { buffer = buf, desc = 'launch: jump to the error on this line' })
  vim.keymap.set('n', 'q', '<cmd>close<CR>',
    { buffer = buf, desc = 'launch: close the window, the job keeps running' })
  vim.keymap.set('n', '<C-c>', function() M.stop(out) end,
    { buffer = buf, desc = 'launch: stop this job' })
  -- Deleting the buffer stops its job and frees the name for the next run.
  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = buf,
    once = true,
    callback = function()
      local o = outs[out]
      outs[out] = nil
      if o.job then vim.fn.jobstop(o.job) end
      o.job = nil
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
      end)
    end,
  })
  return buf
end

---Run `entry.cmd` in `root`, writing into the buffer named `entry.out`.
---@param entry { key: string, cmd: string, out: string }
---@param root string
function M.start(entry, root)
  M.stop(entry.out)
  local o = outs[entry.out] or { buf = new_buf(entry.out) }
  outs[entry.out] = o
  o.key, o.cmd, o.root, o.partial = entry.key, entry.cmd, root, ''
  vim.api.nvim_buf_set_lines(o.buf, 0, -1, false, {})
  last_out = entry.out
  show(o.buf)

  -- Callbacks from a job this buffer no longer belongs to (it was restarted
  -- or stopped) are dropped.
  local job = vim.fn.jobstart(entry.cmd, {
    pty = true,
    width = PTY_WIDTH,
    cwd = root,
    on_stdout = function(id, data)
      if id == o.job then write(o, data) end
    end,
    on_exit = function(id, code)
      if id == o.job then
        o.job = nil
        write(o, { '', ('[exited %d]'):format(code) })
        vim.notify(('launch: %s exited %d, %d error(s)'):format(o.key, code, to_quickfix(o)),
          code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
      end
    end,
  })
  if job <= 0 then
    vim.notify('launch: could not start ' .. entry.cmd, vim.log.levels.ERROR)
  else
    o.job = job
  end
end

---@param out string
---@return boolean stopped
function M.stop(out)
  local o = outs[out]
  local running = o ~= nil and o.job ~= nil
  if running then
    -- Hanging up the PTY reaches the whole process group, so a `build && app`
    -- chain dies with its shell.
    vim.fn.jobstop(o.job)
    o.job = nil
    write(o, { '', '[stopped]' })
  end
  return running
end

---@return integer count
function M.stop_all()
  local n = 0
  for out in pairs(outs) do
    if M.stop(out) then n = n + 1 end
  end
  return n
end

---@return table[] rows  { out, cmd } of the jobs still running
function M.list()
  local rows = {}
  for out, o in pairs(outs) do
    if o.job then rows[#rows + 1] = { out = out, cmd = o.cmd } end
  end
  table.sort(rows, function(a, b) return a.out < b.out end)
  return rows
end

---Show or hide the last output. Hiding never stops the job.
function M.toggle_pane()
  if pane_valid() then
    vim.api.nvim_win_close(pane_win, false)
  elseif outs[last_out] then
    show(outs[last_out].buf)
  else
    vim.notify('launch: no output to show', vim.log.levels.WARN)
  end
end

---Re-parse the last output's errors into quickfix, e.g. while an app runs.
function M.quickfix()
  local o = outs[last_out]
  if o then
    vim.notify(('launch: %d error(s) in %s'):format(to_quickfix(o), last_out), vim.log.levels.INFO)
  else
    vim.notify('launch: no output', vim.log.levels.WARN)
  end
end

local function set_highlights()
  -- ll's error rose at about a quarter strength over its background.
  vim.api.nvim_set_hl(0, 'LaunchErrorLine', { bg = '#3d2a30' })
end

function M.setup()
  local group = vim.api.nvim_create_augroup('launch_run', { clear = true })

  -- A running app must not outlive the editor.
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function() M.stop_all() end,
    desc = 'Stop all launch jobs before quitting',
  })

  -- A file opened after the build gets its marks as it loads.
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    callback = function(ev) mark_errors(ev.buf, launch_items()) end,
    desc = 'Draw the launch errors into the file',
  })

  -- Plain hex, so a colorscheme's `hi clear` wipes it: set it now and again
  -- after every :colorscheme.
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_highlights })
  set_highlights()
end

return M
