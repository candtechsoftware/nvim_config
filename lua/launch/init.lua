-- Per-project build/run targets, read from <root>/launch.json.
--
--   <leader>b   build target 1        N<leader>b   build target N
--   <leader>r   run target 1          N<leader>r   run target N
--   <leader>o   toggle output pane    <leader>x    stop the running job
--   <leader>ft  pick a target
--
-- The count prefix rather than <leader>b1/<leader>b2: a bare <leader>b that is
-- also the prefix of a longer mapping has to wait out 'timeoutlen' (400ms here)
-- before it can fire. Counts are free, and there are 4 mappings instead of 20.
--
-- Execution lives in launch/run.lua. This file is config: find the root, read
-- and normalize launch.json, resolve a target, bind keys.

local M = {}

local run = require('launch.run')
local find_project_root = require('utils.project_root').find

local function get_os()
  local uname = vim.uv.os_uname().sysname:lower()
  if uname == 'darwin' then return 'mac'
  elseif uname == 'linux' then return 'linux'
  else return 'windows'
  end
end

local OS = get_os()

local active_keymaps = {}
local current_launch_root = nil

-- Root lookups cached per buffer directory. BufEnter fires on every buffer
-- switch and find_project_root scandirs each ancestor directory — repeating
-- that disk walk for a directory already resolved is pure waste. DirChanged
-- and :LaunchReset/:LaunchReload clear the cache (a launch.json appearing in
-- an already-visited dir needs the same :LaunchReload it always did).
local root_by_dir = {}

local function buffer_root()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.fs.dirname(name) or vim.fs.normalize(vim.uv.cwd())
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

---Read and parse <root>/launch.json.
---
---pcall'd: this is reached from a BufEnter autocmd, and a malformed file would
---otherwise throw on every buffer switch. Report once per root.
---@param root string
---@return table?
local function load_launch_json(root)
  local path = root .. '/launch.json'
  if vim.fn.filereadable(path) ~= 1 then return nil end

  local joined = table.concat(vim.fn.readfile(path), '\n')
  local ok, config = pcall(vim.json.decode, strip_jsonc(joined))
  if not ok then
    if not reported_bad_json[root] then
      reported_bad_json[root] = true
      vim.notify(('launch.json: could not parse %s\n%s'):format(path, config),
        vim.log.levels.WARN)
    end
    return nil
  end
  reported_bad_json[root] = nil
  return config
end

---Resolve an OS-keyed table to this platform's value, passing anything else
---through. Shared by key_map (which has always supported this) and by the
---build/run arrays.
---@param spec any
---@return any
local function os_pick(spec)
  if type(spec) ~= 'table' then return spec end
  if spec.mac or spec.linux or spec.windows then return spec[OS] end
  return spec
end

---Normalize one kind's spec into a flat target list.
---Accepts "cmd", ["cmd", ...], {name=,cmd=,...}, [{...}, ...], or an OS-keyed
---table wrapping any of those — all collapse to one internal shape so there is
---a single execution path.
---@param spec any
---@param kind "build"|"run"
---@return table[]
local function normalize(spec, kind)
  spec = os_pick(spec)
  if spec == nil then return {} end
  if type(spec) == 'string' then spec = { spec } end
  if type(spec) ~= 'table' then return {} end

  local out = {}
  for i, t in ipairs(spec) do
    if type(t) == 'string' then t = { cmd = t } end
    if type(t) == 'table' and type(t.cmd) == 'string' then
      out[#out + 1] = {
        name = t.name or (i == 1 and kind or (kind .. i)),
        cmd = t.cmd,
        kind = kind,
        depends = t.depends,
        height = tonumber(t.height),
        index = i,
      }
    end
  end
  return out
end

-- Parsed targets for the active root: { build = {...}, run = {...} }
local targets = { build = {}, run = {} }

--------------------------------------------------------------------------------
-- legacy key_map
--------------------------------------------------------------------------------

-- Mappings that existed before launch.json overrode them, keyed by lhs, so
-- clear_keymaps can put them back. Without this, a launch.json binding a key
-- the config already owns (<leader>t, <F5>, ...) would silently clobber it,
-- and the vim.keymap.del on the next project switch would then delete it
-- outright — gone until restart.
local shadowed = {}

local function clear_keymaps()
  for _, key in ipairs(active_keymaps) do
    pcall(vim.keymap.del, 'n', key)
    local prev = shadowed[key]
    if prev then
      -- maparg(..., true) gives a dict restorable by mapset.
      pcall(vim.fn.mapset, prev)
      shadowed[key] = nil
    end
  end
  active_keymaps = {}
end

---@param key_map table<string, string>
local function bind_legacy(key_map)
  for key, cmd in pairs(key_map) do
    table.insert(active_keymaps, key)
    local prev = vim.fn.maparg(key, 'n', false, true)
    if prev and not vim.tbl_isempty(prev) then
      shadowed[key] = prev
    end
    vim.keymap.set('n', key, function()
      run.run_build({ name = 'launch:' .. key, cmd = cmd }, find_project_root())
    end, { noremap = true, silent = true, desc = 'launch.json: ' .. cmd })
  end
end

--------------------------------------------------------------------------------
-- applying a project
--------------------------------------------------------------------------------

---@param root string
local function apply_launch(root)
  if root == current_launch_root then return end

  clear_keymaps()
  current_launch_root = root
  targets = { build = {}, run = {} }

  local config = load_launch_json(root)
  if not config then return end

  targets.build = normalize(config.build, 'build')
  targets.run = normalize(config.run, 'run')

  local key_map = os_pick(config.key_map)
  if type(key_map) == 'table' then bind_legacy(key_map) end
end

--------------------------------------------------------------------------------
-- target resolution + dispatch
--------------------------------------------------------------------------------

---Fall back to the detected makeprg when a project has no launch.json. Means
---<leader>b builds any Makefile/Cargo/zig project with no config at all.
---@return table
local function implicit_build()
  require('utils.make_detect').apply()
  return { name = 'make', cmd = vim.bo.makeprg, kind = 'build', index = 1 }
end

---@param kind "build"|"run"
---@param n integer|nil  1-based; 0/nil mean "the default target"
---@return table|nil
function M.target(kind, n)
  local list = targets[kind]
  local idx = (n and n > 0) and n or 1
  local t = list[idx]
  if t then return t end

  if #list > 0 then
    vim.notify(('launch: no %s target %d (have %d)'):format(kind, idx, #list),
      vim.log.levels.WARN)
    return nil
  end
  if kind == 'build' then return implicit_build() end

  vim.notify('launch: no run targets — :LaunchInit writes a starter launch.json',
    vim.log.levels.WARN)
  return nil
end

---@param target table|nil  nil when M.target() already reported why
function M.start(target)
  if not target then return end
  local root = current_launch_root or find_project_root()

  local function go()
    if target.kind == 'run' then
      run.run_term(target, root)
    else
      run.run_build(target, root)
    end
  end

  -- "depends": "build" — chain, and only launch when the dependency succeeds.
  if target.depends then
    local dep = M.by_name(target.depends)
    if not dep then
      vim.notify(('launch: %s depends on unknown target %s')
        :format(target.name, target.depends), vim.log.levels.ERROR)
      return
    end
    run.run_build(dep, root, function(code)
      if code == 0 then go() end
    end)
    return
  end

  go()
end

---@param name string
---@return table|nil
function M.by_name(name)
  for _, kind in ipairs({ 'build', 'run' }) do
    for _, t in ipairs(targets[kind]) do
      if t.name == name then return t end
    end
  end
  return nil
end

---@return table[]
function M.all()
  local out = {}
  vim.list_extend(out, targets.build)
  vim.list_extend(out, targets.run)
  return out
end

--------------------------------------------------------------------------------
-- commands
--------------------------------------------------------------------------------

local STARTER = [[
{
  // Targets are ordered. <leader>b runs build #1, 2<leader>b runs build #2;
  // <leader>r runs run #1, 2<leader>r runs run #2. Comments and trailing
  // commas are fine — this file is parsed as JSONC.

  "build": [
    "make -j",
    "make -j RELEASE=1"
  ],

  "run": [
    "./bin/tool --verbose",

    // Long form, when a target needs options:
    //   depends  build target to run first; only launches on success
    //   height   output pane height, in lines
    { "name": "game", "cmd": "./build/game", "depends": "build", "height": 20 }
  ]

  // Platform-specific variants are supported on any of the above:
  //   "run": { "mac": ["./build/app.app/Contents/MacOS/app"], "linux": ["./build/app"] }
}
]]

function M.reset_cache()
  current_launch_root = nil
  root_by_dir = {}
  reported_bad_json = {}
  vim.notify('Launch root cache cleared', vim.log.levels.INFO)
end

function M.show_root()
  vim.notify('Current launch root: ' .. find_project_root(), vim.log.levels.INFO)
end

function M.info()
  local root = current_launch_root or find_project_root()
  local lines = { 'root  ' .. vim.fn.fnamemodify(root, ':~') }
  local running = {}
  for _, r in ipairs(run.list()) do
    if r.running then running[r.name] = true end
  end

  for _, kind in ipairs({ 'build', 'run' }) do
    for i, t in ipairs(targets[kind]) do
      lines[#lines + 1] = ('%-5s %d  %-12s %s%s'):format(
        kind, i, t.name, t.cmd, running[t.name] and '   [running]' or '')
    end
  end
  if #lines == 1 then
    lines[#lines + 1] = 'no launch.json — :LaunchInit to create one'
    lines[#lines + 1] = 'implicit build: ' .. implicit_build().cmd
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

function M.init_file()
  local root = find_project_root()
  local path = root .. '/launch.json'
  if vim.fn.filereadable(path) == 1 then
    vim.notify('launch.json already exists at ' .. path, vim.log.levels.WARN)
    vim.cmd.edit(path)
    return
  end
  vim.fn.writefile(vim.split(vim.trim(STARTER), '\n'), path)
  M.reset_cache()
  apply_launch(find_project_root())
  vim.cmd.edit(path)
  vim.notify('Wrote ' .. path, vim.log.levels.INFO)
end

---Pick a target. vim.ui.select rather than a hand-built telescope picker:
---telescope-ui-select is not installed, the list is a handful of items, and
---0.13's built-in select is already a popup — a picker here would mean pulling
---telescope in on a keypress to fuzzy-match four lines.
function M.pick()
  local list = M.all()
  if #list == 0 then
    vim.notify('launch: no targets — :LaunchInit to create launch.json',
      vim.log.levels.WARN)
    return
  end
  vim.ui.select(list, {
    prompt = 'Launch target',
    format_item = function(t)
      return ('%-5s %-12s %s'):format(t.kind, t.name, t.cmd)
    end,
  }, function(choice)
    if choice then M.start(choice) end
  end)
end

--------------------------------------------------------------------------------
-- setup
--------------------------------------------------------------------------------

function M.setup()
  run.setup()
  apply_launch(find_project_root())

  local group = vim.api.nvim_create_augroup('launch_auto', { clear = true })

  -- Re-evaluate keymaps when project context changes (cached per directory).
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function() apply_launch(buffer_root()) end,
  })

  -- A cwd change invalidates every unnamed-buffer entry and any root that
  -- fell back to cwd, so drop the whole cache — DirChanged is rare.
  vim.api.nvim_create_autocmd('DirChanged', {
    group = group,
    callback = function()
      root_by_dir = {}
      apply_launch(buffer_root())
    end,
  })

  vim.keymap.set('n', '<leader>b', function()
    M.start(M.target('build', vim.v.count))
  end, { desc = 'Build (count picks target)' })

  vim.keymap.set('n', '<leader>r', function()
    M.start(M.target('run', vim.v.count))
  end, { desc = 'Run (count picks target)' })

  vim.keymap.set('n', '<leader>o', run.toggle_pane,
    { desc = 'Toggle launch output pane' })

  vim.keymap.set('n', '<leader>x', function()
    local n = run.stop_all()
    vim.notify(n > 0 and ('launch: stopped %d job(s)'):format(n)
      or 'launch: nothing running', vim.log.levels.INFO)
  end, { desc = 'Stop running launch jobs' })

  vim.keymap.set('n', '<leader>ft', M.pick, { desc = 'Pick a launch target' })

  local cmd = vim.api.nvim_create_user_command
  cmd('Launch', function(o)
    if o.args == '' then M.start(M.target('run')) return end
    local t = M.by_name(o.args) or M.all()[tonumber(o.args) or -1]
    if not t then
      vim.notify('launch: no such target: ' .. o.args, vim.log.levels.ERROR)
      return
    end
    M.start(t)
  end, {
    nargs = '?',
    desc = 'Run a launch target by name or index',
    complete = function()
      return vim.tbl_map(function(t) return t.name end, M.all())
    end,
  })

  cmd('LaunchStop', function(o)
    if o.args ~= '' then
      vim.notify(run.stop(o.args) and ('launch: stopped ' .. o.args)
        or ('launch: ' .. o.args .. ' was not running'), vim.log.levels.INFO)
      return
    end
    local n = run.stop_all()
    vim.notify(('launch: stopped %d job(s)'):format(n), vim.log.levels.INFO)
  end, {
    nargs = '?',
    desc = 'Stop one launch job, or all',
    complete = function()
      return vim.tbl_map(function(r) return r.name end, run.list())
    end,
  })

  cmd('LaunchList', M.info, { desc = 'List launch targets and running jobs' })
  cmd('LaunchQF', run.to_quickfix,
    { desc = 'Send the launch output pane through errorformat to quickfix' })
  cmd('LaunchInit', M.init_file, { desc = 'Write a starter launch.json' })
  cmd('LaunchReset', M.reset_cache, { desc = 'Reset launch root cache' })
  cmd('LaunchInfo', M.show_root, { desc = 'Show current launch root' })
  cmd('LaunchReload', function()
    M.reset_cache()
    apply_launch(find_project_root())
  end, { desc = 'Reload launch configuration' })
end

return M
