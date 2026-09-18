-- Treesitter 'indentexpr' driven by indents.scm queries. A port of
-- nvim-treesitter's indent.lua (v0.10.0, MIT), same query protocol:
--
--   @indent.begin   children of this node get one shiftwidth
--   @indent.end     closing delimiter, picks the reference node on blank lines
--   @indent.branch  dedent this node when it starts the line
--   @indent.dedent  dedent when it does not start the line
--   @indent.align   align continuation lines under a delimiter
--   @indent.auto    keep the line as it is
--   @indent.ignore  force column 0
--   @indent.zero    force column 0 for this node
--
-- Metadata: indent.open_delimiter, indent.close_delimiter, indent.increment,
-- indent.avoid_last_matching_next, indent.immediate, indent.start_at_same_line.
local ts = vim.treesitter

local M = {}

local comment_langs = { comment = true, jsdoc = true, phpdoc = true }

local function getline(lnum)
  return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''
end

local function indent_cols(lnum)
  local _, cols = getline(lnum):find('^%s*')
  return cols or 0
end

local function first_node_at(root, lnum, col)
  col = col or indent_cols(lnum)
  return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

local function last_node_at(root, lnum, col)
  col = col or (#getline(lnum) - 1)
  return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

-- Only nodes touching the broken region take the recovery path. has_error()
-- would mark every ancestor of one bad line, i.e. the whole file.
local function in_error_region(node)
  if node:type() == 'ERROR' or node:missing() then return true end
  local parent = node:parent()
  return parent ~= nil and parent:type() == 'ERROR'
end

local function node_length(node)
  local _, _, start_byte = node:start()
  local _, _, end_byte = node:end_()
  return end_byte - start_byte
end

-- Returns the delimiter child and whether nothing follows it on its line.
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

-- When the tree cannot answer, keep the line; a blank line gets the previous
-- line's indent plus a step if it left a bracket open.
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

-- Captures for the rows one call inspects, cached per tree and row range.
-- Querying only those rows keeps a `=` motion O(depth) per line, not O(file).
local indents_cache = setmetatable({}, { __mode = 'kv' })

local function get_indents(bufnr, root, lang, srow, erow)
  local key = ('%d%s_%s_%d_%d'):format(bufnr, root:id(), lang, srow, erow)
  if indents_cache[key] then return indents_cache[key] end

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
  if query then
    for id, node, metadata in query:iter_captures(root, bufnr, srow, erow) do
      local name = query.captures[id]
      if name:sub(1, 1) ~= '_' and map[name] then
        map[name][node:id()] = metadata or {}
      end
    end
  end
  indents_cache[key] = map
  return map
end

function M.get_indent(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok or not parser or not lnum then return -1 end

  -- 'indentkeys' can fire mid-edit, when the tree is a keystroke behind.
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

  local blank = getline(lnum):match('^%s*$') ~= nil
  local ref = blank and vim.fn.prevnonblank(lnum) or lnum
  if ref == 0 then ref = lnum end
  local q = get_indents(bufnr, root, lang_tree:lang(),
    math.max(0, math.min(ref, lnum) - 2), lnum + 1)

  local node
  if blank then
    -- Indent relative to the last node of the previous line, ignoring a
    -- trailing comment.
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

  -- Inside an ERROR node keep what the author wrote rather than flatten it to
  -- column 0. Missing nodes do not count: the surrounding blocks still parse.
  local probe = node
  while probe do
    if probe:type() == 'ERROR' then return bail(lnum, blank) end
    probe = probe:parent()
  end

  local indent_size = vim.fn.shiftwidth()
  local indent = 0
  local _, _, root_start = root:start()
  if root_start ~= 0 then
    indent = vim.fn.indent(root:start() + 1)
  end

  if q['indent.zero'][node:id()] then return 0 end

  -- One indent step per row, however many captured nodes start on it.
  local processed_rows = {}
  local touched = false

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

    if should_process and q['indent.begin'][id]
        and (srow ~= erow or in_error or q['indent.begin'][id]['indent.immediate'])
        and (srow ~= lnum - 1 or q['indent.begin'][id]['indent.start_at_same_line']) then
      indent = indent + indent_size
      is_processed = true
    end

    if in_error and not q['indent.align'][id] then
      -- Promote a child's alignment to the error node so half-typed code aligns.
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
          -- Opening delimiter ends its line: hanging indent.
          indent = indent + indent_size
          if c_last and c_srow and c_srow < lnum - 1 then
            indent = math.max(indent - indent_size, 0)
          end
        elseif c_last and c_srow and o_srow ~= c_srow and c_srow < lnum - 1 then
          -- Past the closing delimiter's line.
          indent = math.max(indent - indent_size, 0)
        else
          -- Line up under the column past the delimiter.
          indent = o_scol + (meta['indent.increment'] or 1)
          absolute = true
        end

        if c_srow and c_srow ~= o_srow and c_srow == lnum - 1
            and meta['indent.avoid_last_matching_next'] then
          if indent <= vim.fn.indent(o_srow + 1) + indent_size then
            indent = indent + indent_size
          end
        end

        is_processed = true
        if absolute then return indent end
      end
    end

    processed_rows[srow] = processed_rows[srow] or is_processed
    touched = touched or is_processed
    node = node:parent()
  end

  -- Nothing was captured in a tree with errors: lines under a swallowed `{`
  -- hang off the root, so 0 is not an answer here.
  if not touched and indent <= 0 and root:has_error() and (blank or indent_cols(lnum) > 0) then
    return bail(lnum, blank)
  end

  return math.max(indent, 0)
end

function M.attach()
  vim.bo.indentexpr = function() return M.get_indent(vim.v.lnum) end
  vim.bo.smartindent = false
  vim.bo.cindent = false
end

return M
