-- Treesitter-driven `indentexpr`, native (no nvim-treesitter plugin).
--
-- Core Neovim ships a treesitter parser and query engine but no indent engine:
-- `indents.scm` queries are dead files unless something walks the tree and
-- interprets them. nvim-treesitter's `master` branch has that engine, but
-- master is frozen and the `main` rewrite dropped indent support entirely, so
-- adopting it would mean pinning a dead plugin -- and it would fight
-- config.ts_parsers over parser installation besides.
--
-- This is a port of nvim-treesitter's indent.lua (v0.10.0, MIT) with the
-- plugin plumbing removed. The query protocol is unchanged, so any
-- `indents.scm` written for nvim-treesitter works here as-is:
--
--   @indent.begin   children of this node get one shiftwidth
--   @indent.end     marks a closing delimiter (used to pick the reference
--                   node when indenting a blank line)
--   @indent.branch  dedent this node when it *starts* the line (`}`, `else`)
--   @indent.dedent  dedent when it does not start the line
--   @indent.align   align continuation lines under a delimiter -- this is what
--                   makes a wrapped parameter list line up under the `(`
--   @indent.auto    leave the line alone (return -1)
--   @indent.ignore  force column 0
--   @indent.zero    force column 0 for this node
--
-- Recognised `#set!` metadata: indent.open_delimiter, indent.close_delimiter,
-- indent.increment, indent.avoid_last_matching_next, indent.immediate,
-- indent.start_at_same_line.
local ts = vim.treesitter

local M = {}

-- Injected comment grammars have their own trees but no useful indent
-- structure; prefer the host language's tree over them.
local comment_langs = { comment = true, jsdoc = true, phpdoc = true }

---@param lnum integer 1-indexed
---@return string
local function getline(lnum)
  return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''
end

---@param lnum integer
---@return integer
local function indent_cols(lnum)
  local _, cols = getline(lnum):find('^%s*')
  return cols or 0
end

---@param root TSNode
---@param lnum integer
---@param col? integer
---@return TSNode
local function first_node_at(root, lnum, col)
  col = col or indent_cols(lnum)
  return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

---@param root TSNode
---@param lnum integer
---@param col? integer
---@return TSNode
local function last_node_at(root, lnum, col)
  col = col or (#getline(lnum) - 1)
  return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

---Is this node part of a region the parser could not make sense of?
---
---nvim-treesitter asks `node:parent():has_error()` here, but `has_error` is
---true for any node with a syntax error *anywhere* beneath it -- so a single
---bad line near the top of a file marks every ancestor, which in a
---single-struct file is the whole tree. That costs twice over: the alignment
---promotion below then iterates every child of a file-spanning node (~13,000
---of them in the Jai modules' GL/glad_all.jai, ~50ms per line, minutes for one
---`=` motion), and the `srow ~= erow` exemption quietly grants an indent step
---to every single-line node in the file.
---
---Only nodes touching the broken region need the recovery path, which is also
---all the query's `(ERROR)` handling was ever aimed at.
---@param node TSNode
---@return boolean
local function in_error_region(node)
  if node:type() == 'ERROR' or node:missing() then return true end
  local parent = node:parent()
  return parent ~= nil and parent:type() == 'ERROR'
end

---@param node TSNode
---@return integer
local function node_length(node)
  local _, _, start_byte = node:start()
  local _, _, end_byte = node:end_()
  return end_byte - start_byte
end

---Find a delimiter token among `node`'s children.
---@param bufnr integer
---@param node TSNode
---@param delimiter string
---@return TSNode|nil child
---@return boolean|nil is_last_in_line true when nothing follows it on its line
local function find_delimiter(bufnr, node, delimiter)
  for child in node:iter_children() do
    if child:type() == delimiter then
      local linenr = child:start()
      local line = vim.api.nvim_buf_get_lines(bufnr, linenr, linenr + 1, false)[1] or ''
      local _, end_col = child:end_()
      local escaped = delimiter:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]', '%%%1')
      local trailing = line:sub(end_col + 1):gsub('[%s' .. escaped .. ']*', '')
      return child, #trailing == 0
    end
  end
end

---What to do when the tree cannot answer: keep the line as it is, unless it is
---blank, in which case there is nothing to keep and a guess beats column 0.
---
---The guess is the whole of what the old hand-rolled jai indentexpr did --
---previous line, plus a step if it left a bracket open. A poor primary rule,
---since it cannot see a wrapped parameter list, but a fine last resort for
---half-typed code no parser can place. It matters for the ordinary flow of
---typing a new procedure at the end of a file: until the closing `}` exists,
---the buffer does not parse, and every `<CR>` would otherwise land on 0.
---@param lnum integer
---@param blank boolean is the target line empty?
---@return integer
local function bail(lnum, blank)
  if not blank then return -1 end

  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev == 0 then return 0 end

  local text = vim.fn.getline(prev):gsub('//.*$', '')
  local indent = vim.fn.indent(prev)
  local opened = select(2, text:gsub('[%[{(]', ''))
  local closed = select(2, text:gsub('[%]})]', ''))
  if opened > closed then indent = indent + vim.fn.shiftwidth() end

  return math.max(indent, 0)
end

---@generic F: function
---@param fn F
---@param hash fun(...): any
---@return F
local function memoize(fn, hash)
  local cache = setmetatable({}, { __mode = 'kv' })
  return function(...)
    local key = hash(...)
    if cache[key] == nil then
      local v = fn(...)
      cache[key] = v ~= nil and v or vim.NIL
    end
    local v = cache[key]
    return v ~= vim.NIL and v or nil
  end
end

-- Captures for the rows this call actually inspects.
--
-- nvim-treesitter queries the whole file here and memoizes on the tree root.
-- That collapses during a `=` motion: every line it reindents edits the
-- buffer, which yields a new tree, which misses the cache -- so each line pays
-- for a full-file query. Measured on the 13,620-line GL/glad_all.jai from the
-- Jai modules: 13,424 captures and ~50ms *per line*, i.e. ~11 minutes to
-- reindent the file, versus 51ms to parse the whole thing once.
--
-- Only nodes that touch the target row can affect it: the target's ancestors
-- all span it by definition. Restricting the row range makes a call cost
-- O(depth) instead of O(file). Same lesson as the scan window in
-- config.c_indent, one layer up.
local get_indents = memoize(function(bufnr, root, lang, srow, erow)
  local map = {
    ['indent.auto'] = {},
    ['indent.begin'] = {},
    ['indent.end'] = {},
    ['indent.dedent'] = {},
    ['indent.branch'] = {},
    ['indent.ignore'] = {},
    ['indent.align'] = {},
    ['indent.zero'] = {},
  }

  local query = ts.query.get(lang, 'indents')
  if not query then return map end

  for id, node, metadata in query:iter_captures(root, bufnr, srow, erow) do
    local name = query.captures[id]
    -- `_`-prefixed captures exist only to anchor a pattern.
    if name:sub(1, 1) ~= '_' and map[name] then
      map[name][node:id()] = metadata or {}
    end
  end

  return map
end, function(bufnr, root, lang, srow, erow)
  return ('%d%s_%s_%d_%d'):format(bufnr, root:id(), lang, srow, erow)
end)

---@param lnum integer 1-indexed
---@return integer indent in columns, or -1 to keep the current indent
function M.get_indent(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok or not parser or not lnum then return -1 end

  -- Reparse the visible range: 'indentkeys' can fire us mid-edit, when the
  -- tree is still one keystroke behind the buffer.
  pcall(function()
    parser:parse({ vim.fn.line('w0') - 1, vim.fn.line('w$') })
  end)

  -- Smallest non-comment tree containing this line.
  local root, lang_tree
  parser:for_each_tree(function(tstree, tree)
    if not tstree or comment_langs[tree:lang()] then return end
    local local_root = tstree:root()
    if ts.is_in_node_range(local_root, lnum - 1, 0) then
      if not root or node_length(root) >= node_length(local_root) then
        root, lang_tree = local_root, tree
      end
    end
  end)
  if not root then return 0 end

  -- Rows this call can read: the target, and the previous non-blank line when
  -- the target is empty. One row of slack either side.
  local blank = getline(lnum):match('^%s*$') ~= nil
  local ref = blank and vim.fn.prevnonblank(lnum) or lnum
  if ref == 0 then ref = lnum end
  local q = get_indents(bufnr, root, lang_tree:lang(),
    math.max(0, math.min(ref, lnum) - 2), lnum + 1)

  local node
  if blank then
    -- Blank line (`o`, `<CR>`): indent relative to the last node of the
    -- previous line instead, ignoring any trailing comment.
    local prev = vim.fn.prevnonblank(lnum)
    if prev == 0 then return 0 end
    local cols = indent_cols(prev)
    local text = vim.trim(getline(prev))
    node = last_node_at(root, prev, cols + #text - 1)
    if node:type():match('comment') then
      local first = first_node_at(root, prev, cols)
      local _, scol = node:range()
      if first:id() ~= node:id() then
        text = vim.trim(text:sub(1, scol - cols))
        node = last_node_at(root, prev, cols + #text - 1)
      end
    end
    if q['indent.end'][node:id()] then
      node = first_node_at(root, lnum)
    end
  else
    node = first_node_at(root, lnum)
  end

  -- Where the parser gave up, keep whatever the author wrote.
  --
  -- Without this the walk below simply finds no captured ancestors and returns
  -- 0, so a single construct the grammar cannot handle flushes every line
  -- under it to column 0 -- silent, and destructive under a `=` motion. This
  -- is not hypothetical: tree-sitter-jai leaves an ERROR node somewhere in 217
  -- of the 553 files in the Jai modules directory (Math/matrix.jai is one
  -- 1373-row error), and half-typed code hits it constantly. Declining to
  -- indent is always recoverable; flattening the file is not.
  -- Testing the line's own ancestors is not enough: when the grammar chokes,
  -- the ERROR node usually *swallows* the enclosing `{`, so the lines under it
  -- become siblings of the error rather than children, reach no captured block,
  -- and land on 0. Widen the test to the whole top-level declaration -- one bad
  -- procedure declines to reindent, the rest of the file still does.
  local probe, outermost = node, node
  while probe do
    if probe:type() == 'ERROR' or probe:missing() then return bail(lnum, blank) end
    local parent = probe:parent()
    if parent then outermost = probe end
    probe = parent
  end
  if outermost:has_error() then return bail(lnum, blank) end

  local indent_size = vim.fn.shiftwidth()
  local indent = 0
  local _, _, root_start = root:start()
  if root_start ~= 0 then
    indent = vim.fn.indent(root:start() + 1) -- injected tree
  end

  if q['indent.zero'][node:id()] then return 0 end

  -- One indent step per *row*, however many captured nodes start on it.
  local processed_rows = {}

  while node do
    local id = node:id()

    if not q['indent.begin'][id] and not q['indent.align'][id] and q['indent.auto'][id]
        and node:start() < lnum - 1 and lnum - 1 <= node:end_() then
      return -1
    end

    if not q['indent.begin'][id] and q['indent.ignore'][id]
        and node:start() < lnum - 1 and lnum - 1 <= node:end_() then
      return 0
    end

    local srow, _, erow = node:range()
    local is_processed = false

    if not processed_rows[srow]
        and ((q['indent.branch'][id] and srow == lnum - 1)
          or (q['indent.dedent'][id] and srow ~= lnum - 1)) then
      indent = indent - indent_size
      is_processed = true
    end

    local should_process = not processed_rows[srow]
    local in_error = should_process and in_error_region(node)

    -- A node opening and closing on one line adds nothing, and a node adds
    -- nothing to the very line it starts on.
    if should_process and q['indent.begin'][id]
        and (srow ~= erow or in_error or q['indent.begin'][id]['indent.immediate'])
        and (srow ~= lnum - 1 or q['indent.begin'][id]['indent.start_at_same_line']) then
      indent = indent + indent_size
      is_processed = true
    end

    if in_error and not q['indent.align'][id] then
      -- Inside an ERROR node, promote a child's alignment to the error node
      -- so half-typed code still aligns.
      for child in node:iter_children() do
        if q['indent.align'][child:id()] then
          q['indent.align'][id] = q['indent.align'][child:id()]
          break
        end
      end
    end

    if should_process and q['indent.align'][id] and (srow ~= erow or in_error) and srow ~= lnum - 1 then
      local meta = q['indent.align'][id]
      local o_delim, o_last, c_delim, c_last
      local absolute = false

      if meta['indent.open_delimiter'] then
        o_delim, o_last = find_delimiter(bufnr, node, meta['indent.open_delimiter'])
      else
        o_delim = node
      end
      if meta['indent.close_delimiter'] then
        c_delim, c_last = find_delimiter(bufnr, node, meta['indent.close_delimiter'])
      else
        c_delim = node
      end

      if o_delim then
        local o_srow, o_scol = o_delim:start()
        local c_srow = c_delim and c_delim:start() or nil

        if o_last then
          -- Opening delimiter ended its line: hanging indent, one step in.
          indent = indent + indent_size
          if c_last and c_srow and c_srow < lnum - 1 then
            indent = math.max(indent - indent_size, 0)
          end
        elseif c_last and c_srow and o_srow ~= c_srow and c_srow < lnum - 1 then
          -- Past the closing delimiter's line: out of the aligned region.
          indent = math.max(indent - indent_size, 0)
        else
          -- Aligned indent: line up under the column past the delimiter.
          indent = o_scol + (meta['indent.increment'] or 1)
          absolute = true
        end

        if c_srow and c_srow ~= o_srow and c_srow == lnum - 1
            and meta['indent.avoid_last_matching_next'] then
          -- Keep the closing line from colliding with what follows it.
          if indent <= vim.fn.indent(o_srow + 1) + indent_size then
            indent = indent + indent_size
          end
        end

        is_processed = true
        if absolute then return indent end
      end
    end

    processed_rows[srow] = processed_rows[srow] or is_processed
    node = node:parent()
  end

  -- Last net, for the failure the two guards above cannot see. When the
  -- grammar chokes, the ERROR node swallows the enclosing `{`, and the lines
  -- beneath it reparse as top-level declarations hanging straight off
  -- `source_file` -- every ancestor reports has_error=false, and the walk
  -- honestly finds nothing to indent against. The tell is the combination:
  -- the file did not fully parse, and we are about to flush a line the author
  -- indented out to column 0. That is never an improvement, so decline.
  if indent <= 0 and root:has_error() and (blank or indent_cols(lnum) > 0) then
    return bail(lnum, blank)
  end

  return math.max(indent, 0)
end

---Install as the buffer's 'indentexpr'. Call from an ftplugin/FileType hook.
function M.attach()
  vim.bo.indentexpr = "v:lua.require'config.ts_indent'.get_indent(v:lnum)"
  vim.bo.smartindent = false
  vim.bo.cindent = false
end

return M
