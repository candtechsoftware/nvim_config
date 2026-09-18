-- 4coder-style project #define highlighting plus the yg_*/type keyword
-- patterns. A colorscheme opts in with `require('hh.macros').setup()`.
local M = {}

local C_FT = { c = true, cpp = true, objc = true, objcpp = true }
local SOURCE_GLOBS = { '*.h', '*.c', '*.hpp', '*.cpp', '*.cc', '*.hh', '*.m', '*.mm' }
local SKIP_DIRS = require('config.project').SKIP_DIRS

-- matchadd patterns run on every displayed line of every redraw. Past this
-- many names that costs more than the highlighting is worth.
local MAX_MACROS = 4000

-- [root] = { 'MACRO_NAME', ... }
local macro_cache = {}
-- [root] = { done_cb, ... } while a scan is in flight, so N windows spawn one
-- scan and all of them get painted when it lands.
local scan_waiters = {}
-- [winid] = { match id, ... }
local match_ids = {}

local function project_root(buf)
  return vim.fs.root(buf, { '.git', 'compile_commands.json', '.clangd' })
end

local function parse_defines(out)
  local names, seen = {}, {}
  for line in out:gmatch('[^\r\n]+') do
    local name = line:match('#%s*define%s+([A-Za-z_][A-Za-z0-9_]*)')
    if name and not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  return names
end

local function scan_cmd(root)
  if vim.fn.executable('rg') == 1 then
    local cmd = { 'rg', '--no-heading', '--no-line-number', '-N', '-I',
      '-e', '^\\s*#\\s*define\\s+[A-Za-z_][A-Za-z0-9_]*' }
    for _, g in ipairs(SOURCE_GLOBS) do
      vim.list_extend(cmd, { '-g', g })
    end
    -- rg is last-match-wins, so the excludes come after the includes.
    for _, d in ipairs(SKIP_DIRS) do
      vim.list_extend(cmd, { '-g', '!**/' .. d .. '/**' })
    end
    cmd[#cmd + 1] = root
    return cmd
  end
  local cmd = { 'grep', '-rhE',
    '^[[:space:]]*#[[:space:]]*define[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' }
  for _, g in ipairs(SOURCE_GLOBS) do
    cmd[#cmd + 1] = '--include=' .. g
  end
  for _, d in ipairs(SKIP_DIRS) do
    cmd[#cmd + 1] = '--exclude-dir=' .. d
  end
  cmd[#cmd + 1] = root
  return cmd
end

-- Calls `done(names)` on the main loop. Cached per root.
local function scan_macros(root, done)
  if macro_cache[root] then
    done(macro_cache[root])
    return
  end
  if scan_waiters[root] then
    table.insert(scan_waiters[root], done)
    return
  end
  scan_waiters[root] = { done }

  vim.system(scan_cmd(root), { text = true }, vim.schedule_wrap(function(res)
    local callbacks = scan_waiters[root] or {}
    scan_waiters[root] = nil
    -- rg exits 1 when it finds nothing, which is a valid empty result.
    local names = parse_defines(res.stdout or '')
    if #names > MAX_MACROS then
      vim.notify(
        ('hh.macros: %d #define names under %s, over the %d limit, so project macro\n'
          .. 'highlighting is OFF here. A count this high usually means a vendored tree\n'
          .. 'is missing from SKIP_DIRS in lua/config/project.lua. :HHMacroDump shows what was found.'
        ):format(#names, root, MAX_MACROS),
        vim.log.levels.WARN)
      names = {}
    end
    macro_cache[root] = names
    for _, cb in ipairs(callbacks) do
      cb(names)
    end
  end))
end

local function clear_matches(winid)
  for _, id in ipairs(match_ids[winid] or {}) do
    pcall(vim.fn.matchdelete, id, winid)
  end
  match_ids[winid] = nil
end

local STORAGE = 'internal\\|function\\|global\\|local_persist\\|thread_local\\|inline\\|static'
  .. '\\|force_inline\\|no_inline\\|read_only\\|write_only\\|shared\\|exported'

-- The static patterns go in now, the project's #define names when the scan lands.
local function add_matches(winid)
  if match_ids[winid] then return end
  local ids = {}
  match_ids[winid] = ids

  local function add(group, pattern, priority)
    vim.api.nvim_win_call(winid, function()
      ids[#ids + 1] = vim.fn.matchadd(group, pattern, priority or 100)
    end)
  end

  add('YgKeyword', '\\<\\(yg\\|arc\\)_\\(internal\\|inline\\|global\\|local_persist\\)\\>')
  add('YgType',
    '\\<\\([usb]\\(8\\|16\\|32\\|64\\)\\|f\\(32\\|64\\)\\|void\\|Vec[234]\\(F32\\|F64\\|S16\\|S32\\|S64\\)\\?\\|Mat[34]\\(F32\\)\\?\\|Quaternion\\(F32\\)\\?\\|Rng[12]\\(F32\\|U32\\|U64\\|S16\\|S32\\)\\?\\|Arena\\|Scratch\\|String8\\|R_Handle\\|Entity\\(Handle\\|Store\\|Pool\\|Kind\\|Flags\\)\\?\\|Direction8\\)\\>')
  -- Return type after a yg/arc prefix macro.
  add('YgType', '\\<\\(yg\\|arc\\)_\\(internal\\|inline\\)\\s\\+\\zs\\w\\+\\ze')
  -- PREFIX TYPE name( and PREFIX TYPE *name(
  add('Function', '\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(')
  add('Function', '\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s*\\*\\s*\\zs\\w\\+\\ze\\s*(')
  add('Function', '\\<\\(' .. STORAGE .. '\\)\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(')
  add('Function', '\\<\\(' .. STORAGE .. '\\)\\s\\+\\w\\+\\s*\\*\\+\\s*\\zs\\w\\+\\ze\\s*(')
  -- PascalCase type after a storage-class macro; uppercase-first skips `const`, `int`.
  add('Type', '\\<\\(' .. STORAGE .. '\\)\\s\\+\\zs[A-Z]\\w*\\ze\\s*\\*\\?\\s*\\w')
  add('YgKeyword',
    '\\<\\(thread_local\\|force_inline\\|no_inline\\|read_only\\|write_only\\|shared\\|exported\\)\\>')

  local root = project_root(vim.api.nvim_win_get_buf(winid))
  if not root then return end

  scan_macros(root, function(macros)
    -- The window may be gone or re-matched while the scan was in flight.
    if not vim.api.nvim_win_is_valid(winid) or match_ids[winid] ~= ids then return end
    -- Priority 200 beats the Function patterns; chunks of 50 stay under the
    -- regex engine's limits.
    for i = 1, #macros, 50 do
      local chunk = vim.list_slice(macros, i, i + 49)
      add('YgKeyword', '\\<\\(' .. table.concat(chunk, '\\|') .. '\\)\\>', 200)
    end
  end)
end

-- matchadd is window-local and buffer-agnostic, so a window that switches to a
-- non-C buffer has to drop its matches.
local function refresh(winid)
  if not vim.api.nvim_win_is_valid(winid) then return end
  local buf = vim.api.nvim_win_get_buf(winid)
  if C_FT[vim.bo[buf].filetype] then
    add_matches(winid)
  else
    clear_matches(winid)
  end
end

local function refresh_all()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    clear_matches(win)
    refresh(win)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('HHMacroKeywords', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType', 'WinEnter' }, {
    group = group,
    callback = function() refresh(vim.api.nvim_get_current_win()) end,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(ev)
      local wid = tonumber(ev.match)
      if wid then match_ids[wid] = nil end
    end,
  })

  vim.api.nvim_create_user_command('HHMacroDump', function()
    local root = project_root(0)
    if not root then
      vim.notify('HH: no project root (need .git, compile_commands.json, or .clangd)',
        vim.log.levels.WARN)
      return
    end
    scan_macros(root, function(macros)
      vim.notify(('HH: root = %s\nHH: %d #define names\nHH: first 20 = %s')
        :format(root, #macros, table.concat(vim.list_slice(macros, 1, 20), ', ')),
        vim.log.levels.INFO)
    end)
  end, { desc = 'Show the #define names the macro indexer found' })

  vim.api.nvim_create_user_command('HHMacroRescan', function()
    macro_cache = {}
    refresh_all()
    vim.notify('HH: rescanning project macros', vim.log.levels.INFO)
  end, { desc = 'Re-scan the project for #define names' })

  refresh_all()
end

return M
