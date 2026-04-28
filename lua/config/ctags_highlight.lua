-- Ctags-driven type highlighting for C/C++/ObjC/ObjC++.
--
-- Reads the tag-name cache maintained by config.ctags (which already parses
-- tags files async, bucketing by kind and bumping a version counter on
-- update). Names whose kind is a type (typedef/struct/union/enum/class) get
-- painted with the `Type` highlight group via chunked matchadd patterns.
--
-- Why matchadd and not treesitter injection: tree-sitter-c can only see the
-- typedefs in the current buffer, so cross-file types (and anything in a
-- unity build where headers aren't TU-separated) fall through as plain
-- identifiers. matchadd operates on buffer text and doesn't care about parse
-- state, so it reliably catches every reference.
--
-- Priority 50 keeps us below tree-sitter's default (~100) and the theme's
-- overlay queries (200), so local captures (parameters, enum members the
-- parser can see) still win.

local ctags = require('config.ctags')

local M = {}

-- Ctags kind strings that should be colored as Type. Full names come from
-- `--fields=+K` (the existing config uses this); single chars are kept as a
-- defensive fallback in case the tags file is regenerated without +K.
local TYPE_KINDS = {
  typedef = true, struct = true, union = true, enum = true, class = true,
  t = true, s = true, u = true, g = true, c = true,
}

local CHUNK_SIZE = 500
local PRIORITY = 50

-- { winid -> { match_ids, last_project_version, last_system_version } }
local win_state = {}

local function collect_type_names()
  local names = {}

  local project_cache = ctags.get_tag_name_cache()
  if project_cache then
    for _, by_name in pairs(project_cache) do
      for name, kind in pairs(by_name) do
        if TYPE_KINDS[kind] then names[name] = true end
      end
    end
  end

  local system_cache = ctags.get_system_tag_name_cache()
  if system_cache then
    for name, kind in pairs(system_cache) do
      if TYPE_KINDS[kind] then names[name] = true end
    end
  end

  return names
end

local function clear_matches(winid)
  local st = win_state[winid]
  if not st then return end
  for _, id in ipairs(st.match_ids) do
    pcall(vim.fn.matchdelete, id, winid)
  end
  st.match_ids = {}
end

local function apply_matches(winid, names_set)
  clear_matches(winid)
  win_state[winid] = win_state[winid] or {}
  win_state[winid].match_ids = {}

  local names = {}
  for name, _ in pairs(names_set) do
    if name:match('^[%w_][%w_]*$') then
      table.insert(names, name)
    end
  end
  if #names == 0 then return end
  table.sort(names)

  local st = win_state[winid]
  for i = 1, #names, CHUNK_SIZE do
    local hi = math.min(i + CHUNK_SIZE - 1, #names)
    local chunk = {}
    for j = i, hi do chunk[#chunk + 1] = names[j] end
    local pattern = '\\<\\(' .. table.concat(chunk, '\\|') .. '\\)\\>'
    local ok, id = pcall(vim.fn.matchadd, 'Type', pattern, PRIORITY, -1, { window = winid })
    if ok and type(id) == 'number' and id ~= -1 then
      st.match_ids[#st.match_ids + 1] = id
    end
  end
end

local function is_c_family_buf(bufnr)
  local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  return ft == 'c' or ft == 'cpp' or ft == 'objc' or ft == 'objcpp'
end

function M.refresh(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(winid) then return end
  local bufnr = vim.api.nvim_win_get_buf(winid)
  if not is_c_family_buf(bufnr) then return end

  local pv = ctags.get_cache_version()
  local sv = ctags.get_system_cache_version()
  local st = win_state[winid]
  if st and st.last_project_version == pv and st.last_system_version == sv and #st.match_ids > 0 then
    return
  end

  apply_matches(winid, collect_type_names())
  st = win_state[winid]
  st.last_project_version = pv
  st.last_system_version = sv
end

function M.setup()
  local group = vim.api.nvim_create_augroup('CtagsHighlight', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'c', 'cpp', 'objc', 'objcpp' },
    callback = function()
      M.refresh()
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    group = group,
    callback = function()
      if is_c_family_buf(vim.api.nvim_get_current_buf()) then
        M.refresh()
      end
    end,
  })

  -- The tag cache is built async after BufEnter; poll lazily on CursorHold
  -- so the first highlight arrives once the background parse finishes.
  -- Early-outs on version match, so this is cheap.
  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = group,
    callback = function()
      if is_c_family_buf(vim.api.nvim_get_current_buf()) then
        M.refresh()
      end
    end,
  })

  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(ev)
      local wid = tonumber(ev.match)
      if wid then win_state[wid] = nil end
    end,
  })

  vim.api.nvim_create_user_command('CtagsHighlightRefresh', function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      win_state[win] = nil
      M.refresh(win)
    end
  end, { desc = 'Force-refresh ctags-based type highlighting' })
end

return M
