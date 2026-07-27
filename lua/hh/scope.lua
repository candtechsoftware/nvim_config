-- Nested-scope background cycling.
--
-- Paints the line background of each treesitter scope containing the cursor,
-- innermost first, cycling through the HHScope1..N highlight groups that a
-- colorscheme defines. A colorscheme opts in by calling:
--
--     require("hh.scope").setup({ cycle_len = #scope_bgs })
--
-- after it has defined its HHScope groups. Any colorscheme that does NOT call
-- setup() gets torn down automatically on the next ColorScheme event.
--
-- This used to live inside colors/hh.lua. That was the root cause of several
-- bugs: a colors/*.lua chunk is re-sourced on EVERY :colorscheme, so all of its
-- file-local state (caches, timers, match ids) was silently reset to {} while
-- the autocmds and matches it had already created were still live — producing
-- duplicate engines, doubled matches, and repeated full project rescans. As a
-- `require`d module the state is cached once and survives colorscheme reloads.

local M = {}

local scope_ns = vim.api.nvim_create_namespace("hh_scope_highlight")

local DEBOUNCE_MS = 50

-- Filetypes the engine attaches to. Must have an entry in `queries` below.
local FILETYPES = {
  "c", "cpp", "objc", "objcpp", "jai", "lua",
  "typescript", "typescriptreact", "javascript", "javascriptreact",
}

local queries = {
  c = "(compound_statement) @scope",
  cpp = "(compound_statement) @scope",
  objc = "(compound_statement) @scope",
  objcpp = "(compound_statement) @scope",
  jai = "(block) @scope",
  -- `function_declaration` covers `local function f()` / `function M.f()`, which
  -- parse as declarations, NOT `function_definition` (that is only the anonymous
  -- `function() end` expression). Without it, named Lua functions — i.e. almost
  -- every function in a Lua file — got no scope background at all.
  lua = [[
    (function_declaration) @scope
    (function_definition) @scope
    (if_statement) @scope
    (for_statement) @scope
    (while_statement) @scope
  ]],
  typescript = "(statement_block) @scope",
  tsx = "(statement_block) @scope",
  javascript = "(statement_block) @scope",
}

-- Compiled queries, keyed by lang. A FAILED compile is cached as `false` — not
-- left nil. Leaving it nil meant a language whose grammar lacks the node type
-- (objc/objcpp are the likely victims) re-attempted, and re-threw, the same
-- failing query.parse on every cursor move and every keystroke, forever.
local compiled = {}

---@param lang string
---@return vim.treesitter.Query|nil
local function get_query(lang)
  if compiled[lang] == nil then
    local src = queries[lang]
    if not src then
      compiled[lang] = false
    else
      local ok, q = pcall(vim.treesitter.query.parse, lang, src)
      compiled[lang] = ok and q or false
    end
  end
  return compiled[lang] or nil
end

-- Per-buffer state: { timer = uv_timer, fingerprint = string }
local state = {}

-- How many HHScope groups the active colorscheme defines, and which colorscheme
-- turned us on (used to tear down when switching to one that does not want us).
local cycle_len = 6
local enabled_for = nil

---Scopes containing `row`, innermost first.
---
---Queried over the single row rather than the whole file. The old code collected
---EVERY scope node in the buffer into a table on each dirty parse, then linearly
---scanned and sorted that table on every cursor move. Captures intersecting one
---row ARE exactly the containing scopes, so this is O(depth) instead of
---O(nodes-in-file), and needs no all-scopes cache and no dirty flag (treesitter's
---own parse is already incremental).
---@param bufnr integer
---@param row integer 0-indexed
---@return table[]
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
  -- iter_captures can throw on a partially-parsed tree; it was never wrapped.
  ok = pcall(function()
    for _, node in query:iter_captures(root, bufnr, row, row + 1) do
      local start_row, _, end_row, _ = node:range()
      if row >= start_row and row <= end_row then
        scopes[#scopes + 1] = {
          start_row = start_row,
          end_row = end_row,
          size = end_row - start_row,
        }
      end
    end
  end)
  if not ok then return {} end

  table.sort(scopes, function(a, b) return a.size < b.size end)
  return scopes
end

---Resolve a window that is actually displaying `bufnr`.
---
---The debounced callback used to call highlight_scopes(bufnr) with no winid,
---50ms later, and the function defaulted winid to the CURRENT window. Switch
---windows inside that 50ms (trivial: `j` then <C-w>w) and it would read the
---cursor and viewport of a window showing a completely different buffer, then
---apply the resulting rows to bufnr.
---@param bufnr integer
---@return integer|nil
local function window_for(bufnr)
  local cur = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_is_valid(cur) and vim.api.nvim_win_get_buf(cur) == bufnr then
    return cur
  end
  local wins = vim.fn.win_findbuf(bufnr)
  return wins[1]
end

---Repaint the scope backgrounds for `bufnr`.
---@param bufnr integer
---@param force boolean? repaint even if nothing appears to have changed
function M.highlight(bufnr, force)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local winid = window_for(bufnr)
  if not winid then return end

  local row = vim.api.nvim_win_get_cursor(winid)[1] - 1
  local scopes = containing_scopes(bufnr, row)

  -- Extmarks are only created for the visible band, so the viewport is part of
  -- the identity of what is currently drawn. w$ (bottom) was missing from the
  -- old fingerprint, so a :resize left newly-exposed lines unpainted.
  local top = vim.fn.line("w0", winid) - 1
  local bot = vim.fn.line("w$", winid) - 1

  local parts = { tostring(top), tostring(bot) }
  for _, s in ipairs(scopes) do
    parts[#parts + 1] = s.start_row .. ":" .. s.end_row
  end
  local fingerprint = table.concat(parts, ",")

  local st = state[bufnr]
  if not st then return end
  if not force and fingerprint == st.fingerprint then return end
  st.fingerprint = fingerprint

  vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
  for depth, scope in ipairs(scopes) do
    local group = "HHScope" .. (((depth - 1) % cycle_len) + 1)
    for line = math.max(scope.start_row, top), math.min(scope.end_row, bot) do
      vim.api.nvim_buf_set_extmark(bufnr, scope_ns, line, 0, {
        line_hl_group = group,
        priority = 100 - depth, -- inner scopes win
      })
    end
  end
end

---Debounced repaint. One reusable timer per buffer.
---
---The old version allocated a NEW uv timer on every CursorMoved and every
---keystroke in insert mode, stop()ing the superseded one but never close()ing
---it — so handles piled up until luv's __gc got around to them.
---@param bufnr integer
---@param force boolean|nil  skip the fingerprint check when the timer fires
local function schedule_highlight(bufnr, force)
  local st = state[bufnr]
  if not st then return end
  -- Coalescing must not downgrade a forced request: if a forced and a plain
  -- one land in the same debounce window, only one highlight() call survives,
  -- and it has to be the stronger of the two.
  st.pending_force = st.pending_force or force or false
  st.timer:stop()
  st.timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function()
    local f = st.pending_force
    st.pending_force = false
    M.highlight(bufnr, f)
  end))
end

---@param bufnr integer
local function augroup_name(bufnr)
  return "HHScopeBuf" .. bufnr
end

---@param bufnr integer
function M.attach(bufnr)
  if state[bufnr] then return end
  state[bufnr] = {
    timer = assert(vim.uv.new_timer()),
    fingerprint = nil,
  }

  local group = vim.api.nvim_create_augroup(augroup_name(bufnr), { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = bufnr,
    callback = function() schedule_highlight(bufnr) end,
  })

  -- Viewport events. Extmarks are only painted for the visible band, so
  -- <C-e>, <C-y>, zz, zt — which move the viewport without moving the cursor —
  -- scrolled unpainted lines into view and left them that way until the cursor
  -- happened to move.
  --
  -- These are split by frequency. WinScrolled fires once per scroll STEP, so a
  -- held <C-e> ran the full containing_scopes() treesitter query per step with
  -- no rate limit at all — the CursorMoved arm above has been debounced since
  -- forever, this one never was. It goes through the same timer now.
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    buffer = bufnr,
    callback = function() schedule_highlight(bufnr, true) end,
  })

  -- BufEnter/WinEnter/WinResized fire once per switch or resize, not per step.
  -- Debouncing these would buy nothing and cost a visible 50ms of unpainted
  -- scope every time you change buffer, so they stay immediate.
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "WinResized" }, {
    group = group,
    buffer = bufnr,
    callback = function() M.highlight(bufnr, true) end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    buffer = bufnr,
    callback = function() M.detach(bufnr) end,
  })

  vim.schedule(function() M.highlight(bufnr, true) end)
end

---@param bufnr integer
function M.detach(bufnr)
  local st = state[bufnr]
  if st then
    st.timer:stop()
    -- close() on an already-closing handle RAISES ("handle is already
    -- closing"); the old code called it unconditionally from both the timer
    -- body and the BufDelete handler.
    if not st.timer:is_closing() then st.timer:close() end
    state[bufnr] = nil
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
  end
  -- Deleting a buffer removes its buffer-local autocmds but NOT the augroup, and
  -- buffer numbers only ever increase — so a long session leaked one empty
  -- augroup per file opened.
  pcall(vim.api.nvim_del_augroup_by_name, augroup_name(bufnr))
end

function M.detach_all()
  for bufnr in pairs(state) do
    M.detach(bufnr)
  end
end

---Called by a colorscheme, after it has defined its HHScope groups.
---@param opts { cycle_len: integer? }?
function M.setup(opts)
  opts = opts or {}
  cycle_len = opts.cycle_len or 6
  enabled_for = vim.g.colors_name

  local group = vim.api.nvim_create_augroup("HHScopeSetup", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = FILETYPES,
    callback = function(ev)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then M.attach(ev.buf) end
      end)
    end,
  })

  -- Tear down when the user switches to a colorscheme that does not opt in.
  -- Previously nothing did this: the engine kept parsing and kept setting
  -- line_hl_group = "HHScope3" long after the new colorscheme's `hi clear` had
  -- deleted that group.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      vim.schedule(function()
        if enabled_for ~= vim.g.colors_name then
          M.detach_all()
        else
          for bufnr in pairs(state) do
            M.highlight(bufnr, true)
          end
        end
      end)
    end,
  })

  -- Attach to already-open buffers (the colorscheme may load after them).
  local supported = {}
  for _, ft in ipairs(FILETYPES) do supported[ft] = true end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and supported[vim.bo[bufnr].filetype] then
      M.attach(bufnr)
    end
  end
end

return M
