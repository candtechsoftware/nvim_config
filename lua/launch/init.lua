-- Per-project commands, read from <root>/launch.json:
--
--   {
--     "<F1>": "./build.sh",
--     "<F4>": { "cmd": "./build.sh && ./build/game", "out": "*run*" },
--     "linux": { "<F1>": "./build_linux.sh" }
--   }
--
-- Each key is a normal-mode mapping, bound while a file from the project is
-- current. `out` names the buffer the output goes to, *compilation* by
-- default. A mac/linux/windows table overrides the top-level entries there.
-- Without a launch.json, :Make and <leader>b run the build command that
-- utils/make_detect.lua detects.
--
-- Execution lives in launch/run.lua. This file is config: find the root, read
-- launch.json, bind keys.

local M = {}

local run = require('launch.run')
local find_project_root = require('utils.project_root').find
local detect_build = require('utils.make_detect').detect

local DEFAULT_OUT = '*compilation*'

local function get_os()
  local uname = vim.uv.os_uname().sysname:lower()
  if uname == 'darwin' then return 'mac'
  elseif uname == 'linux' then return 'linux'
  else return 'windows'
  end
end

local OS = get_os()
local PLATFORMS = { mac = true, linux = true, windows = true }

local current_launch_root = nil

-- The active root's launch.json entries, each { key, cmd, out, prev }. prev is
-- the mapping the key shadowed, put back when the project changes.
local entries = {}

-- Root lookups cached per buffer directory. BufEnter fires on every buffer
-- switch and find_project_root scandirs each ancestor directory, so a
-- directory already resolved is not walked again. DirChanged and
-- :LaunchReload clear the cache.
local root_by_dir = {}

---The project the current buffer belongs to. Output buffers, quickfix and
---help are not project files, so they keep the current project: a build key
---pressed in the output pane rebuilds the same project.
---@return string
local function buffer_root()
  if vim.bo.buftype ~= '' and current_launch_root then
    return current_launch_root
  end
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.fs.dirname(name) or vim.fs.normalize(vim.uv.cwd() or '')
  local root = root_by_dir[dir]
  if root == nil then
    root = find_project_root()
    root_by_dir[dir] = root
  end
  return root
end

--------------------------------------------------------------------------------
-- launch.json
--------------------------------------------------------------------------------

---Strip JSONC down to JSON: `//` and `/* */` comments, and trailing commas.
---
---launch.json is canonically JSONC — VS Code permits both — and vim.json.decode
---accepts neither, so a perfectly ordinary hand-written file used to fail to
---parse and silently produce no targets at all.
---
---Done as a single character scan tracking string state, not as a gsub. A
---regex for trailing commas cannot tell `[1,]` from the literal text `","` in
---a command string like `awk -F, '{print}'`, and would corrupt the second.
---@param s string
---@return string
local function strip_jsonc(s)
  local out = {}
  local i, n = 1, #s
  local in_str, esc = false, false

  while i <= n do
    local ch = s:sub(i, i)
    if in_str then
      out[#out + 1] = ch
      if esc then esc = false
      elseif ch == '\\' then esc = true
      elseif ch == '"' then in_str = false end
      i = i + 1
    elseif ch == '"' then
      in_str = true
      out[#out + 1] = ch
      i = i + 1
    elseif ch == '/' and s:sub(i + 1, i + 1) == '/' then
      while i <= n and s:sub(i, i) ~= '\n' do i = i + 1 end
    elseif ch == '/' and s:sub(i + 1, i + 1) == '*' then
      i = i + 2
      while i <= n and not (s:sub(i, i) == '*' and s:sub(i + 1, i + 1) == '/') do
        i = i + 1
      end
      i = i + 2
    elseif ch == ']' or ch == '}' then
      -- Drop a trailing comma: walk back over emitted whitespace and remove a
      -- comma if that is what precedes this closer.
      local k = #out
      while k > 0 and out[k]:match('%s') do k = k - 1 end
      if k > 0 and out[k] == ',' then table.remove(out, k) end
      out[#out + 1] = ch
      i = i + 1
    else
      out[#out + 1] = ch
      i = i + 1
    end
  end

  return table.concat(out)
end

local reported_bad_json = {}

---Read <root>/launch.json into a list of { key, cmd, out }, sorted by key.
---Reached from BufEnter, so problems are reported once per root rather than
---on every buffer switch; a clean read re-arms the report.
---@param root string
---@return table[]
local function load_entries(root)
  local path = root .. '/launch.json'
  if vim.fn.filereadable(path) ~= 1 then return {} end

  local ok, config = pcall(vim.json.decode, strip_jsonc(table.concat(vim.fn.readfile(path), '\n')))
  if ok and type(config) ~= 'table' then
    ok, config = false, 'expected an object of "<key>": command'
  end

  local loaded, problems = {}, {}
  if ok then
    local merged = {}
    for key, value in pairs(config) do
      if not PLATFORMS[key] then merged[key] = value end
    end
    for key, value in pairs(type(config[OS]) == 'table' and config[OS] or {}) do
      merged[key] = value
    end
    for key, value in pairs(merged) do
      if type(value) == 'string' then value = { cmd = value } end
      if type(key) == 'string' and type(value) == 'table' and type(value.cmd) == 'string'
          and (value.out == nil or type(value.out) == 'string') then
        loaded[#loaded + 1] = { key = key, cmd = value.cmd, out = value.out or DEFAULT_OUT }
      else
        problems[#problems + 1] =
          ('%s: expected "command" or { "cmd": "command", "out": "*name*" }'):format(key)
      end
    end
    table.sort(loaded, function(a, b) return a.key < b.key end)
  else
    problems[1] = config
  end

  if #problems == 0 then
    reported_bad_json[root] = nil
  elseif not reported_bad_json[root] then
    reported_bad_json[root] = true
    vim.notify(('launch.json: %s\n%s'):format(path, table.concat(problems, '\n')),
      vim.log.levels.WARN)
  end
  return loaded
end

--------------------------------------------------------------------------------
-- keys
--------------------------------------------------------------------------------

local function clear_keymaps()
  for _, entry in ipairs(entries) do
    pcall(vim.keymap.del, 'n', entry.key)
    if entry.prev then
      pcall(vim.fn.mapset, entry.prev)
    end
  end
end

---Bind each entry's key, keeping the mapping it shadows (<leader>b, <F5>, ...)
---in entry.prev. Without that the next project switch would delete the
---config's own mapping outright, gone until restart.
---@param root string
local function bind_keys(root)
  for _, entry in ipairs(entries) do
    local prev = vim.fn.maparg(entry.key, 'n', false, true)
    entry.prev = not vim.tbl_isempty(prev) and prev or nil
    vim.keymap.set('n', entry.key, function() run.start(entry, root) end,
      { silent = true, desc = 'launch.json: ' .. entry.cmd })
  end
end

---@param root string
local function apply_launch(root)
  if root == current_launch_root then return end
  clear_keymaps()
  current_launch_root = root
  entries = load_entries(root)
  bind_keys(root)
end

---Re-read launch.json and rebind, e.g. after editing it.
local function reload()
  root_by_dir, reported_bad_json = {}, {}
  local root = buffer_root()
  current_launch_root = nil
  apply_launch(root)
end

--------------------------------------------------------------------------------
-- commands
--------------------------------------------------------------------------------

local STARTER = [[
{
  // Each key is a normal-mode mapping, bound while you are in this project.
  // The value is a shell command, or { "cmd": ..., "out": ... } where out
  // names the buffer the output goes to (default "*compilation*").
  // Errors in the output go to quickfix: <M-n>/<M-N> step, <CR> jumps.
  // Comments and trailing commas are fine, this is parsed as JSONC.

  "<F1>": "make -j",
  "<F4>": { "cmd": "make -j && ./build/app", "out": "*run*" },

  // Entries under mac/linux/windows override the ones above on that platform.
  "linux": { "<F1>": "make -j LINUX=1" }
}
]]

---@param entry table
---@return string
local function describe(entry)
  return ('%-12s %-15s %s'):format(entry.key, entry.out, entry.cmd)
end

local function info()
  local lines = { 'root  ' .. vim.fn.fnamemodify(current_launch_root, ':~') }
  for _, entry in ipairs(entries) do
    lines[#lines + 1] = describe(entry)
  end
  if #entries == 0 then
    lines[#lines + 1] = 'no launch.json, :LaunchInit writes one; <leader>b runs :Make'
  end
  for _, row in ipairs(run.list()) do
    lines[#lines + 1] = ('running  %-15s %s'):format(row.out, row.cmd)
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

local function init_file()
  local path = buffer_root() .. '/launch.json'
  if vim.fn.filereadable(path) ~= 1 then
    vim.fn.writefile(vim.split(vim.trim(STARTER), '\n'), path)
    reload()
  end
  vim.cmd.edit(path)
end

local function pick()
  if #entries == 0 then
    vim.notify('launch: no launch.json here, :LaunchInit writes one', vim.log.levels.WARN)
    return
  end
  vim.ui.select(entries, { prompt = 'Launch', format_item = describe }, function(entry)
    if entry then run.start(entry, current_launch_root) end
  end)
end

local function stop_all()
  local n = run.stop_all()
  vim.notify(n > 0 and ('launch: stopped %d job(s)'):format(n)
    or 'launch: nothing running', vim.log.levels.INFO)
end

---:Make [args]: the detected build command, for a project without a
---launch.json, into the same buffer launch.json builds use.
local function make(o)
  local cmd = detect_build(current_launch_root, vim.bo.filetype)
  if o.args ~= '' then cmd = cmd .. ' ' .. o.args end
  -- The Jai fallback compiles `%`. Expand it as :make would, to an absolute
  -- path since the command runs in the root.
  cmd = cmd:gsub('%%', vim.fn.expand('%:p'))
  run.start({ key = ':Make', cmd = cmd, out = DEFAULT_OUT }, current_launch_root)
end

--------------------------------------------------------------------------------
-- setup
--------------------------------------------------------------------------------

function M.setup()
  run.setup()

  local cmd = vim.api.nvim_create_user_command

  -- Before the first project is applied, so a launch.json key can shadow
  -- <leader>b and give it back.
  cmd('Make', make, { nargs = '*', desc = 'Build with the detected build command' })
  vim.keymap.set('n', '<leader>b', '<cmd>Make<cr>', { desc = 'Build with the detected build command' })

  apply_launch(buffer_root())

  local group = vim.api.nvim_create_augroup('launch_auto', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function() apply_launch(buffer_root()) end,
  })

  -- A cwd change invalidates every unnamed-buffer entry and any root that
  -- fell back to cwd, so drop the whole cache. DirChanged is rare.
  vim.api.nvim_create_autocmd('DirChanged', {
    group = group,
    callback = function()
      root_by_dir = {}
      apply_launch(buffer_root())
    end,
  })

  vim.keymap.set('n', '<leader>o', run.toggle_pane, { desc = 'Toggle launch output pane' })
  vim.keymap.set('n', '<leader>x', stop_all, { desc = 'Stop running launch jobs' })
  vim.keymap.set('n', '<leader>ft', pick, { desc = 'Pick a launch.json command' })

  cmd('Launch', function(o)
    if o.args == '' then
      pick()
      return
    end
    for _, entry in ipairs(entries) do
      if entry.key == o.args then
        run.start(entry, current_launch_root)
        return
      end
    end
    vim.notify('launch: no such key: ' .. o.args, vim.log.levels.ERROR)
  end, {
    nargs = '?',
    desc = 'Run a launch.json command by key',
    complete = function()
      return vim.tbl_map(function(entry) return entry.key end, entries)
    end,
  })

  cmd('LaunchStop', function(o)
    if o.args == '' then
      stop_all()
    else
      vim.notify(run.stop(o.args) and ('launch: stopped ' .. o.args)
        or ('launch: ' .. o.args .. ' was not running'), vim.log.levels.INFO)
    end
  end, {
    nargs = '?',
    desc = "Stop one output buffer's job, or all",
    complete = function()
      return vim.tbl_map(function(row) return row.out end, run.list())
    end,
  })

  cmd('LaunchList', info, { desc = 'List launch.json commands and running jobs' })
  cmd('LaunchQF', run.quickfix, { desc = "Re-parse the last output buffer's errors into quickfix" })
  cmd('LaunchInit', init_file, { desc = 'Write a starter launch.json, or open the existing one' })
  cmd('LaunchReload', reload, { desc = 'Re-read launch.json after editing it' })
end

return M
