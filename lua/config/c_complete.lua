-- Smart identifier completion for unity-build C/C++ with no LSP.
--
-- Wired as 'completefunc' (see after/ftplugin/c.lua), invoked by <Tab> via
-- <C-x><C-u> on a plain identifier. Candidates are real identifiers only —
-- never words from comments or string literals — drawn from the buffer's
-- treesitter tree merged with the project's ctags symbols, ranked so the
-- most relevant lead the popup:
--   [local]    identifier inside the function enclosing the cursor
--   [file]     identifier elsewhere in the current buffer
--   [project]  symbol from the ctags file (other files in the project)
--
-- Struct member completion (`.` / `->` / `::`) is handled separately by the
-- built-in `ccomplete` omnifunc.

local M = {}

-- treesitter node types that are genuine identifiers (valid in c and cpp).
local ID_QUERY = '[(identifier) (field_identifier) (type_identifier)] @id'

-- Node types that bound a "local" scope for the [local] rank.
local SCOPE_NODES = {
  function_definition = true,
  lambda_expression = true,
}

local MAX_IDENTS = 4000   -- cap the file-wide treesitter walk on huge buffers
local MAX_TAGS = 300      -- cap project symbols pulled from the tags file

local RANK_LOCAL, RANK_FILE, RANK_TAG = 0, 1, 2
local RANK_LABEL = {
  [RANK_LOCAL] = '[local]',
  [RANK_FILE] = '[file]',
  [RANK_TAG] = '[project]',
}

---True if `word` can complete `base`: a case-insensitive prefix match that
---is not an exact-case repeat of `base`. (Completing the typed word to
---itself is the only true no-op — a different-cased hit like `Foo` for
---`foo` is a useful completion and must NOT be excluded.)
---@param word string
---@param base string
---@param blow string  base:lower(), hoisted by the caller
---@return boolean
local function matches(word, base, blow)
  return word ~= base and word:sub(1, #blow):lower() == blow
end

---0-based byte column where the identifier under the cursor begins.
---@return integer
local function find_start()
  local line = vim.fn.getline('.')
  local s = vim.fn.col('.') - 1
  while s > 0 and line:sub(s, s):match('[%w_]') do
    s = s - 1
  end
  return s
end

---Record identifier captures under `node`, keeping each word's best (lowest)
---rank. `cap` bounds the walk; nil = unbounded.
---@param node TSNode
---@param query vim.treesitter.Query
---@param buf integer
---@param rank integer
---@param base string
---@param blow string
---@param found table<string, integer>
---@param cap integer?
local function collect(node, query, buf, rank, base, blow, found, cap)
  local n = 0
  for _, idnode in query:iter_captures(node, buf) do
    n = n + 1
    if cap and n > cap then break end
    local text = vim.treesitter.get_node_text(idnode, buf)
    if matches(text, base, blow) and (found[text] == nil or rank < found[text]) then
      found[text] = rank
    end
  end
end

---Real identifiers in the current buffer, via treesitter.
---@param base string  prefix to match (may be empty)
---@param blow string
---@return table<string, integer>  identifier -> best (lowest) scope rank
local function buffer_identifiers(base, blow)
  local found = {}
  local buf = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return found end
  local ok_q, query = pcall(vim.treesitter.query.parse, parser:lang(), ID_QUERY)
  if not ok_q or not query then return found end
  local tree = (parser:parse() or {})[1]
  if not tree then return found end
  local root = tree:root()

  -- The function enclosing the cursor is walked in full (it is small), so
  -- the [local] rank is always correct; only the file-wide walk is capped,
  -- so a huge buffer loses some [file] suggestions but never [local] ones.
  local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
  local node = root:named_descendant_for_range(crow - 1, ccol, crow - 1, ccol)
  while node and not SCOPE_NODES[node:type()] do
    node = node:parent()
  end
  if node then
    collect(node, query, buf, RANK_LOCAL, base, blow, found)
  end
  collect(root, query, buf, RANK_FILE, base, blow, found, MAX_IDENTS)
  return found
end

---Project symbols matching `base` from the ctags file (&tags).
---@param base string
---@return string[]
local function tag_symbols(base)
  if base == '' then return {} end
  local ok, names = pcall(vim.fn.getcompletion, base, 'tag')
  if not ok or type(names) ~= 'table' then return {} end
  return names
end

---'completefunc' implementation. See |complete-functions|.
---@param findstart integer
---@param base string
function M.complete(findstart, base)
  if findstart == 1 then
    return find_start()
  end
  base = base or ''
  local blow = base:lower()

  local list = {}
  local seen = {}
  for word, rank in pairs(buffer_identifiers(base, blow)) do
    seen[word] = true
    list[#list + 1] = { word = word, rank = rank }
  end

  local tag_count = 0
  for _, name in ipairs(tag_symbols(base)) do
    if tag_count >= MAX_TAGS then break end
    -- tag names can be operators or qualified (operator==, Foo::bar) — this
    -- path only completes plain identifiers.
    if not seen[name] and name:match('^[%a_][%w_]*$') and matches(name, base, blow) then
      seen[name] = true
      list[#list + 1] = { word = name, rank = RANK_TAG }
      tag_count = tag_count + 1
    end
  end

  table.sort(list, function(a, b)
    if a.rank ~= b.rank then return a.rank < b.rank end
    return a.word < b.word
  end)

  local items = {}
  for _, e in ipairs(list) do
    items[#items + 1] = { word = e.word, menu = RANK_LABEL[e.rank], icase = 1 }
  end
  return items
end

return M
