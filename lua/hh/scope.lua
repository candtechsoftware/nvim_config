-- Paints the line background of each treesitter scope containing the cursor,
-- innermost first, cycling through the colorscheme's HHScope1..N groups. A
-- colorscheme opts in with `require('hh.scope').setup({ cycle_len = N })`.
-- It is a module, not part of the colors file, because colors/*.lua is
-- re-sourced on every :colorscheme and would reset this state under live autocmds.
local M = {}

local scope_ns = vim.api.nvim_create_namespace('hh_scope_highlight')

local DEBOUNCE_MS = 50

local FILETYPES = {
  'c', 'cpp', 'objc', 'objcpp', 'jai', 'lua',
  'typescript', 'typescriptreact', 'javascript', 'javascriptreact',
}

local queries = {
  c = '(compound_statement) @scope',
  cpp = '(compound_statement) @scope',
  objc = '(compound_statement) @scope',
  objcpp = '(compound_statement) @scope',
  jai = '(block) @scope',
  -- Named functions parse as function_declaration, anonymous ones as
  -- function_definition.
  lua = [[
    (function_declaration) @scope
    (function_definition) @scope
    (if_statement) @scope
    (for_statement) @scope
    (while_statement) @scope
  ]],
  typescript = '(statement_block) @scope',
  tsx = '(statement_block) @scope',
  javascript = '(statement_block) @scope',
}

-- A failed compile is cached as false so it is not retried on every keystroke.
local compiled = {}

local function get_query(lang)
  if compiled[lang] == nil then
    local ok, q = false, nil
    if queries[lang] then ok, q = pcall(vim.treesitter.query.parse, lang, queries[lang]) end
    compiled[lang] = ok and q or false
  end
  return compiled[lang] or nil
end

-- Per-buffer state: { timer, fingerprint, pending_force }
local state = {}

local cycle_len = 6
local enabled_for = nil

-- Scopes containing `row`, innermost first. Captures intersecting one row are
-- exactly the containing scopes.
local function containing_scopes(bufnr, row)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return {} end
  local query = get_query(parser:lang())
  if not query then return {} end
  local parsed
  ok, parsed = pcall(parser.parse, parser)
  if not ok or not parsed or not parsed[1] then return {} end
  local root = parsed[1]:root()

  local scopes = {}
  ok = pcall(function()
    for _, node in query:iter_captures(root, bufnr, row, row + 1) do
      local start_row, _, end_row, _ = node:range()
      if row >= start_row and row <= end_row then
        scopes[#scopes + 1] = { start_row = start_row, end_row = end_row, size = end_row - start_row }
      end
    end
  end)
  if not ok then return {} end

  table.sort(scopes, function(a, b) return a.size < b.size end)
  return scopes
end

-- A window actually showing `bufnr`: the debounced repaint can land after
-- the user switched to a window on another buffer.
local function window_for(bufnr)
  local cur = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(cur) == bufnr then return cur end
  return vim.fn.win_findbuf(bufnr)[1]
end

function M.highlight(bufnr, force)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local winid = window_for(bufnr)
  if not winid then return end

  local row = vim.api.nvim_win_get_cursor(winid)[1] - 1
  local scopes = containing_scopes(bufnr, row)

  -- Only the visible band is painted, so the viewport is part of what is drawn.
  local top = vim.fn.line('w0', winid) - 1
  local bot = vim.fn.line('w$', winid) - 1
  local parts = { tostring(top), tostring(bot) }
  for _, s in ipairs(scopes) do
    parts[#parts + 1] = s.start_row .. ':' .. s.end_row
  end
  local fingerprint = table.concat(parts, ',')

  local st = state[bufnr]
  if not st then return end
  if not force and fingerprint == st.fingerprint then return end
  st.fingerprint = fingerprint

  vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
  for depth, scope in ipairs(scopes) do
    local group = 'HHScope' .. (((depth - 1) % cycle_len) + 1)
    for line = math.max(scope.start_row, top), math.min(scope.end_row, bot) do
      vim.api.nvim_buf_set_extmark(bufnr, scope_ns, line, 0, {
        line_hl_group = group,
        priority = 100 - depth,
      })
    end
  end
end

-- A forced request coalesced with a plain one stays forced.
local function schedule_highlight(bufnr, force)
  local st = state[bufnr]
  if not st then return end
  st.pending_force = st.pending_force or force or false
  st.timer:stop()
  st.timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function()
    local f = st.pending_force
    st.pending_force = false
    M.highlight(bufnr, f)
  end))
end

local function augroup_name(bufnr)
  return 'HHScopeBuf' .. bufnr
end

function M.attach(bufnr)
  if state[bufnr] then return end
  state[bufnr] = { timer = assert(vim.uv.new_timer()) }

  local group = vim.api.nvim_create_augroup(augroup_name(bufnr), { clear = true })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI' }, {
    group = group,
    buf = bufnr,
    callback = function() schedule_highlight(bufnr) end,
  })
  -- Scrolling moves the viewport without moving the cursor. It fires per step,
  -- so it goes through the debounce too.
  vim.api.nvim_create_autocmd('WinScrolled', {
    group = group,
    buf = bufnr,
    callback = function() schedule_highlight(bufnr, true) end,
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'WinResized' }, {
    group = group,
    buf = bufnr,
    callback = function() M.highlight(bufnr, true) end,
  })
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = group,
    buf = bufnr,
    callback = function() M.detach(bufnr) end,
  })

  vim.schedule(function() M.highlight(bufnr, true) end)
end

function M.detach(bufnr)
  local st = state[bufnr]
  if st then
    st.timer:stop()
    if not st.timer:is_closing() then st.timer:close() end
    state[bufnr] = nil
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
  end
  -- Deleting a buffer removes its autocmds but not the augroup.
  pcall(vim.api.nvim_del_augroup_by_name, augroup_name(bufnr))
end

function M.setup(opts)
  cycle_len = (opts or {}).cycle_len or 6
  enabled_for = vim.g.colors_name

  local group = vim.api.nvim_create_augroup('HHScopeSetup', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = FILETYPES,
    callback = function(ev)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then M.attach(ev.buf) end
      end)
    end,
  })

  -- Tear down when switching to a colorscheme that does not opt in.
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      vim.schedule(function()
        for bufnr in pairs(state) do
          if enabled_for ~= vim.g.colors_name then
            M.detach(bufnr)
          else
            M.highlight(bufnr, true)
          end
        end
      end)
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.list_contains(FILETYPES, vim.bo[bufnr].filetype) then
      M.attach(bufnr)
    end
  end
end

return M
