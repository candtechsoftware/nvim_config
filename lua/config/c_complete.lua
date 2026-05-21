-- Smart identifier completion for unity-build C/C++ with no LSP.
--
-- Wired as 'completefunc' (see after/ftplugin/c.lua) and invoked by <Tab>
-- via <C-x><C-u> (see lua/config/keymaps.lua) when the cursor sits on a plain
-- identifier prefix. Completes variable and function names.
--
-- Candidates are real identifiers only — never words from comments or string
-- literals — because they come from the buffer's treesitter syntax tree
-- (identifier nodes) merged with the project's ctags symbols. This is what
-- "takes over" the old raw <C-n> tag dump: ctags is now just one ranked
-- source feeding this function. Results are ranked so the most relevant
-- lead the popup:
--   [local]    identifier inside the function enclosing the cursor
--   [file]     identifier elsewhere in the current buffer
--   [project]  symbol from the ctags file (other files in the project)
--
-- Struct member completion (`.` / `->` / `::`) is handled separately by the
-- built-in `ccomplete` omnifunc — this function is only the identifier path.

local M = {}

-- treesitter node types that are genuine identifiers (valid in c and cpp).
local ID_QUERY = '[(identifier) (field_identifier) (type_identifier)] @id'

local MAX_IDENTS = 4000   -- cap the treesitter walk on huge unity-build buffers
local MAX_TAGS = 300      -- cap project symbols pulled from the tags file

local RANK_LOCAL, RANK_FILE, RANK_TAG = 0, 1, 2
local RANK_LABEL = {
  [RANK_LOCAL] = '[local]',
  [RANK_FILE] = '[file]',
  [RANK_TAG] = '[project]',
}

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

---Real identifiers in the current buffer, via treesitter.
---@param base string  prefix to match (may be empty)
---@return table<string, integer>  identifier -> best (lowest) scope rank
local function buffer_identifiers(base)
  local found = {}
  local buf = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return found end
  local ok_q, query = pcall(vim.treesitter.query.parse, parser:lang(), ID_QUERY)
  if not ok_q or not query then return found end
  local tree = (parser:parse() or {})[1]
  if not tree then return found end
  local root = tree:root()

  -- Row range of the function enclosing the cursor — drives the [local] rank.
  local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
  crow = crow - 1
  local node = root:named_descendant_for_range(crow, ccol, crow, ccol)
  while node and node:type() ~= 'function_definition' do
    node = node:parent()
  end
  local fn_start, fn_end
  if node then
    fn_start, _, fn_end = node:range()
  end

  local blow = base:lower()
  local n = 0
  for _, idnode in query:iter_captures(root, buf) do
    n = n + 1
    if n > MAX_IDENTS then break end
    local text = vim.treesitter.get_node_text(idnode, buf)
    if text:match('^[%a_][%w_]*$')
        and text ~= base
        and text:sub(1, #base):lower() == blow then
      local row = idnode:range()
      local rank = RANK_FILE
      if fn_start and row >= fn_start and row <= fn_end then
        rank = RANK_LOCAL
      end
      if found[text] == nil or rank < found[text] then
        found[text] = rank
      end
    end
  end
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

  local list = {}
  local seen = {}
  for word, rank in pairs(buffer_identifiers(base)) do
    seen[word] = true
    list[#list + 1] = { word = word, rank = rank }
  end

  local blow = base:lower()
  local tag_count = 0
  for _, name in ipairs(tag_symbols(base)) do
    if tag_count >= MAX_TAGS then break end
    if not seen[name] and name ~= base
        and name:match('^[%a_][%w_]*$')
        and name:sub(1, #base):lower() == blow then
      seen[name] = true
      list[#list + 1] = { word = name, rank = RANK_TAG }
      tag_count = tag_count + 1
    end
  end

  -- Rank first (local -> file -> project), then alphabetical within a rank.
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
