-- Per-project commands, read from <root>/launch.json (JSONC):
--
--   {
--     "<F1>": "./build.sh",
--     "<F4>": { "cmd": "./build.sh && ./build/game", "out": "*run*" },
--     "linux": { "<F1>": "./build_linux.sh" }
--   }
--
-- Each key is a normal-mode mapping, bound while a file from the project is
-- current. `out` names the output buffer, *compilation* by default. A
-- mac/linux/windows table overrides the top-level entries on that platform.
-- Without a launch.json, :Make and <leader>b run the detected build command.
local M = {}

local run = require('launch.run')
local project = require('config.project')
local detect_build = require('launch.make').detect

local DEFAULT_OUT = '*compilation*'

local sysname = vim.uv.os_uname().sysname:lower()
local OS = sysname == 'darwin' and 'mac' or sysname == 'linux' and 'linux' or 'windows'
local PLATFORMS = { mac = true, linux = true, windows = true }

local current_root = nil
-- The current root's entries, each { key, cmd, out, prev }. prev is the
-- mapping the key shadowed, restored when the project changes.
local entries = {}
-- BufEnter fires on every buffer switch, so roots are cached per directory.
local root_by_dir = {}
local reported_bad_json = {}

-- Output buffers, quickfix and help keep the current project, so a build key
-- pressed in the output pane rebuilds the same project.
local function buffer_root()
  if vim.bo.buftype ~= '' and current_root then
    return current_root
  end
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.fs.dirname(name) or vim.fs.normalize(vim.uv.cwd() or '')
  if root_by_dir[dir] == nil then
    root_by_dir[dir] = project.root()
  end
  return root_by_dir[dir]
end

-- JSONC to JSON: drop comments and trailing commas. A character scan, since a
-- pattern cannot tell a trailing comma from one inside a command string.
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

-- Problems are reported once per root; a clean read re-arms the report.
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

local function apply_launch(root)
  if root == current_root then return end

  for _, entry in ipairs(entries) do
    pcall(vim.keymap.del, 'n', entry.key)
    if entry.prev then pcall(vim.fn.mapset, entry.prev) end
  end

  current_root = root
  entries = load_entries(root)

  -- Keep the shadowed mapping (<leader>b, <F5>, ...) so it comes back.
  for _, entry in ipairs(entries) do
    local prev = vim.fn.maparg(entry.key, 'n', false, true)
    entry.prev = not vim.tbl_isempty(prev) and prev or nil
    vim.keymap.set('n', entry.key, function() run.start(entry, root) end,
      { silent = true, desc = 'launch.json: ' .. entry.cmd })
  end
end

local function reload()
  root_by_dir, reported_bad_json = {}, {}
  local root = buffer_root()
  current_root = nil
  apply_launch(root)
end

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

local function describe(entry)
  return ('%-12s %-15s %s'):format(entry.key, entry.out, entry.cmd)
end

local function info()
  local lines = { 'root  ' .. vim.fn.fnamemodify(current_root, ':~') }
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
    if entry then run.start(entry, current_root) end
  end)
end

local function stop_all()
  local n = run.stop_all()
  vim.notify(n > 0 and ('launch: stopped %d job(s)'):format(n)
    or 'launch: nothing running', vim.log.levels.INFO)
end

local function make(o)
  local cmd = detect_build(current_root, vim.bo.filetype)
  if o.args ~= '' then cmd = cmd .. ' ' .. o.args end
  -- The command runs in the root, so `%` expands to an absolute path.
  cmd = cmd:gsub('%%', vim.fn.expand('%:p'))
  run.start({ key = ':Make', cmd = cmd, out = DEFAULT_OUT }, current_root)
end

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
        run.start(entry, current_root)
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
