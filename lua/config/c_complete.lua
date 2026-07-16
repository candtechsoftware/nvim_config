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
-- Struct/union member completion (`.` / `->`) is handled by M.omnifunc below
-- (wired as 'omnifunc' in after/ftplugin/c.lua, invoked via <C-x><C-o>):
-- treesitter resolves the type of the variable before the operator, then the
-- project's ctags index supplies that type's members. This replaces the
-- built-in `ccomplete`, which resolves types unreliably from the tags file.

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

-- ===========================================================================
-- Member completion (`.` / `->`): treesitter type resolution + ctags members.
-- ===========================================================================

-- Parsed ctags member index, keyed by the project tags file + its mtime so it
-- is rebuilt only after a regenerate (debounced save in lua/config/ctags.lua).
local tag_index_cache = { path = nil, stamp = nil, index = nil }

---First existing tags file on &tags (the project cache file is listed first).
---@return string?
local function project_tags_file()
  for _, t in ipairs(vim.split(vim.bo.tags, ',', { trimempty = true })) do
    if vim.uv.fs_stat(t) then return t end
  end
end

-- The ctags kind letters this index actually uses, keyed by byte value so the
-- hot loop in parse_tags can test one byte instead of building a substring.
--   m member  e enumerator  t typedef  s struct  u union  g enum
-- Everything else in the file (f function, v variable, d macro, p prototype,
-- x extern, l local, ...) is skipped before any pattern matching runs.
local WANT_KIND = {
  [string.byte('m')] = true,
  [string.byte('e')] = true,
  [string.byte('t')] = true,
  [string.byte('s')] = true,
  [string.byte('u')] = true,
  [string.byte('g')] = true,
}

---Pull a `struct:`/`union:`/`enum:`/`class:` scope token out of a tag field.
---@param field string
---@return string?
local function scope_token(field)
  return field:match('^(struct:.+)$') or field:match('^(union:.+)$')
    or field:match('^(enum:.+)$') or field:match('^(class:.+)$')
end

---Parse a ctags file into the lookups member completion needs:
---  members    scope ("struct:Foo") -> list of { name, type }
---  typedefs   typedef name          -> aggregate scope it aliases
---  aggregates struct/union/enum name -> its own scope ("struct:Foo")
---@param path string
---@return { members: table, typedefs: table, aggregates: table }
local function parse_tags(path)
  local members, typedefs, aggregates = {}, {}, {}
  local f = io.open(path, 'r')
  if not f then return { members = members, typedefs = typedefs, aggregates = aggregates } end
  for line in f:lines() do
    if line:byte(1) ~= 33 then -- skip "!_TAG_..." pseudo-tags
      -- Reject uninteresting lines as cheaply as possible, BEFORE running any
      -- pattern match. About half of a C tags file is kinds this index does not
      -- use (f, v, d, p, x, l...), and the old code ran `^([^\t]+)\t` plus a
      -- gmatch field loop over every one of them. On a 6.7MB/35k-line file that
      -- was 77ms; rejecting on the kind letter first brings it to 33ms for a
      -- byte-identical index.
      --
      -- `find(..., true)` is a plain substring search (no regex engine). `sep`
      -- is the index of the ';' in the `;"` that terminates the search command,
      -- so: ';'=sep, '"'=sep+1, '\t'=sep+2, kind letter=sep+3.
      local sep = line:find(';"\t', 1, true)
      if sep and WANT_KIND[line:byte(sep + 3)] then
        local kind = line:sub(sep + 3, sep + 3)
        local name = line:match('^([^\t]+)\t')
        -- Fields follow the `;"`; the first is the kind letter, the rest are
        -- key:value (scope, typeref, ...).
        local fields = line:sub(sep + 3)
        if name then
          local scope, typeref
          local i = 0
          for fld in (fields .. '\t'):gmatch('([^\t]*)\t') do
            i = i + 1
            if i > 1 then
              scope = scope_token(fld) or scope
              typeref = fld:match('^typeref:(.+)$') or typeref
            end
          end
          if (kind == 'm' or kind == 'e') and scope then
            local list = members[scope]
            if not list then list = {}; members[scope] = list end
            list[#list + 1] = { name = name, type = typeref }
          elseif kind == 't' and typeref then
            local tr = scope_token(typeref)
            if tr then typedefs[name] = tr end
          elseif kind == 's' then
            aggregates[name] = 'struct:' .. name
          elseif kind == 'u' then
            aggregates[name] = 'union:' .. name
          elseif kind == 'g' then
            aggregates[name] = 'enum:' .. name
          end
        end
      end
    end
  end
  f:close()
  return { members = members, typedefs = typedefs, aggregates = aggregates }
end

---The current project's member index, rebuilt only when the tags file changes.
---@return { members: table, typedefs: table, aggregates: table }?
local function get_tag_index()
  local path = project_tags_file()
  if not path then return end
  local st = vim.uv.fs_stat(path)
  if not st then return end
  -- Key on nanoseconds AND size, not just mtime.sec. At one-second granularity
  -- a regenerate landing in the same wall-clock second as the previous stat
  -- looked unchanged, and the stale index was served with no way to invalidate
  -- it short of another save.
  local stamp = ('%d.%d.%d'):format(st.mtime.sec, st.mtime.nsec, st.size)
  if tag_index_cache.path == path and tag_index_cache.stamp == stamp then
    return tag_index_cache.index
  end
  local index = parse_tags(path)
  tag_index_cache = { path = path, stamp = stamp, index = index }
  return index
end

---Resolve a type name to the member-scope key whose members we should list,
---following one typedef hop and falling back to a direct aggregate guess.
---@param index table
---@param typename string
---@return string?
local function scope_for_type(index, typename)
  typename = typename
    :gsub('^%s*struct%s+', ''):gsub('^%s*union%s+', ''):gsub('^%s*enum%s+', '')
  typename = typename:match('^%s*([%w_]+)') or typename
  local td = index.typedefs[typename]
  if td and index.members[td] then return td end
  local agg = index.aggregates[typename]
  if agg and index.members[agg] then return agg end
  for _, pre in ipairs({ 'struct:', 'union:', 'enum:', 'class:' }) do
    if index.members[pre .. typename] then return pre .. typename end
  end
end

-- Declarations and parameters — the nodes that bind a name to a type.
local DECL_QUERY = '[(declaration) (parameter_declaration)] @decl'

---Innermost declared identifier under a declarator subtree (peels
---pointer/array/init/function declarators down to the name).
---@param node TSNode
---@return string?
local function declared_name(node)
  local t = node:type()
  if t == 'identifier' or t == 'field_identifier' then
    return vim.treesitter.get_node_text(node, 0)
  end
  local inner = node:field('declarator')[1]
  if inner then return declared_name(inner) end
  for child in node:iter_children() do
    if child:named() then
      local r = declared_name(child)
      if r then return r end
    end
  end
end

---Type name from a `type:` node — the tag/aggregate name for struct/union/enum
---specifiers, otherwise the node text (type_identifier, primitive_type, ...).
---@param type_node TSNode
---@return string?
local function type_name(type_node)
  local t = type_node:type()
  if t == 'struct_specifier' or t == 'union_specifier'
    or t == 'enum_specifier' or t == 'class_specifier' then
    local nm = type_node:field('name')[1]
    return nm and vim.treesitter.get_node_text(nm, 0) or nil
  end
  return vim.treesitter.get_node_text(type_node, 0)
end

-- The project's storage-class macros. tree-sitter has no idea these are
-- storage classes, so it mis-parses any declaration starting with one and the
-- `type:`/`declarator:` fields cannot be trusted — see `decl_binds` below.
-- (after/ftplugin/c.lua plays the same trick for cindent, and
-- after/queries/c/highlights.scm has its own ERROR-node workaround for
-- highlighting. This is the completion path's version.)
local STORAGE_MACROS = {
  internal = true, global = true, local_persist = true, ['function'] = true,
}

---Does `node` bind `var`, and if so to what type?
---
---Straightforward for a well-formed declaration: read the `type:` and
---`declarator:` fields. But `global Foo bar;` parses as
---  (declaration type: (type_identifier)"global" (ERROR (identifier)"Foo")
---                declarator: (identifier)"bar")
---— the macro is taken as the type and the real type is stranded in an ERROR
---node. There is no stable rule for digging it back out, because the recovery
---shape is not even consistent: for `internal Widget w;` the parser puts the
---TYPE in `declarator:` and the NAME in the ERROR node, exactly the other way
---round. So instead of pattern-matching error recovery, rewrite the macro to
---`static` (which tree-sitter parses correctly, as a real storage_class_specifier)
---and re-parse the one declaration in isolation.
---@param node TSNode
---@param buf integer
---@param var string
---@return string?  type name, if this declaration binds `var`
local function decl_binds(node, buf, var)
  local tnode = node:field('type')[1]
  if not tnode then return end

  local macro = vim.treesitter.get_node_text(tnode, buf)
  if not STORAGE_MACROS[macro] then
    -- Normal declaration: trust the fields.
    for _, dnode in ipairs(node:field('declarator')) do
      if declared_name(dnode) == var then return type_name(tnode) end
    end
    return
  end

  local text = vim.treesitter.get_node_text(node, buf)
  local fixed = text:gsub('^(%s*)' .. vim.pesc(macro) .. '%f[%W]', '%1static', 1)
  if fixed == text then return end

  local ok, sparser = pcall(vim.treesitter.get_string_parser, fixed, 'c')
  if not ok or not sparser then return end
  local stree = (sparser:parse() or {})[1]
  if not stree then return end

  -- Find the declaration in the re-parsed fragment and read its real fields.
  local found
  local function walk(n)
    if found then return end
    if n:type() == 'declaration' or n:type() == 'parameter_declaration' then
      found = n
      return
    end
    for c in n:iter_children() do walk(c) end
  end
  walk(stree:root())
  if not found then return end

  local ftype = found:field('type')[1]
  if not ftype then return end
  for _, dnode in ipairs(found:field('declarator')) do
    -- declared_name/type_name read text via buffer 0; on this detached tree the
    -- nodes belong to `fixed`, so pull the text from the string instead.
    local name = vim.treesitter.get_node_text(dnode, fixed)
    -- peel pointer/array declarators down to the bare name
    name = name:match('([%a_][%w_]*)%s*[%[%(]?') or name
    if name == var then
      local tn = vim.treesitter.get_node_text(ftype, fixed)
      local nm = ftype:field('name')[1]
      if nm then tn = vim.treesitter.get_node_text(nm, fixed) end
      return tn
    end
  end
end

---Type name of the variable `var`, via the nearest declaration at or above the
---cursor that binds it, preferring one inside the cursor's enclosing function
---over a file-scope one.
---
---The scope preference matters in a unity build: this used to take the nearest
---declaration above the cursor anywhere in the file, so in a 17k-line file
---where `arena`/`ctx`/`state` are re-declared in every function, a name that is
---NOT declared in the current function silently resolved to some unrelated
---function's local and offered that type's members. Wrong-but-confident is
---worse than empty.
---@param buf integer
---@param var string
---@param crow integer  1-based cursor row
---@return string?
local function resolve_var_type(buf, var, crow)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end
  local tree = (parser:parse() or {})[1]
  if not tree then return end
  local ok_q, query = pcall(vim.treesitter.query.parse, parser:lang(), DECL_QUERY)
  if not ok_q or not query then return end

  -- The function (if any) the cursor sits in.
  local cursor_scope = vim.treesitter.get_node({ bufnr = buf, pos = { crow - 1, 0 } })
  while cursor_scope and not SCOPE_NODES[cursor_scope:type()] do
    cursor_scope = cursor_scope:parent()
  end

  ---The function enclosing `node`, or nil if it is at file scope.
  ---@param node TSNode
  ---@return TSNode?
  local function enclosing_fn(node)
    local n = node:parent()
    while n and not SCOPE_NODES[n:type()] do
      n = n:parent()
    end
    return n
  end

  local best, best_row, best_local = nil, -1, false
  for _, node in query:iter_captures(tree:root(), buf) do
    local srow = node:range()
    if srow <= crow - 1 then
      local fn = enclosing_fn(node)
      -- Only two kinds of declaration can bind the name the cursor sees: one
      -- in the cursor's own function, or one at file scope. A declaration
      -- inside a DIFFERENT function is invisible here, and must be ignored
      -- rather than used as a fallback — that is what made `arena`/`ctx`/
      -- `state` resolve to an unrelated function's type and complete members
      -- that do not exist on the variable in front of you. No answer is the
      -- correct answer for an undeclared name.
      local visible = (fn == nil) or (cursor_scope ~= nil and fn:equal(cursor_scope))
      if visible then
        local is_local = fn ~= nil
        -- A local shadows a file-scope declaration; among equals, nearest wins.
        local better = (is_local and not best_local)
          or (is_local == best_local and srow > best_row)
        if better then
          local tn = decl_binds(node, buf, var)
          if tn then
            best, best_row, best_local = tn, srow, is_local
          end
        end
      end
    end
  end
  return best
end

---The member-access chain ending at the operator under the cursor: e.g.
---`cmd_line->inputs.` yields { 'cmd_line', 'inputs' } (root first, the member
---just before the trailing operator last). Returns nil when the text is not a
---plain identifier chain — a call or index in the middle (`get().x`, `a[i].x`)
---bails rather than guess.
---@return string[]?
local function access_chain()
  local line = vim.fn.getline('.')
  local before = line:sub(1, find_start()):gsub('%s+$', '')   -- up to & incl operator
  before = before:gsub('%->$', ''):gsub('%.$', ''):gsub('::$', '')

  local id = before:match('([%w_]+)$')
  if not id then return nil end
  local parts = { id }
  before = before:sub(1, #before - #id):gsub('%s+$', '')
  while #before > 0 do
    local op = before:match('(%->)$') or before:match('([.])$') or before:match('(::)$')
    if not op then break end
    before = before:sub(1, #before - #op):gsub('%s+$', '')
    local pid = before:match('([%w_]+)$')
    if not pid then return nil end                            -- `)`/`]` before op: too complex
    table.insert(parts, 1, pid)
    before = before:sub(1, #before - #pid):gsub('%s+$', '')
  end
  return parts
end

---Member scope for a member's typeref (as stored by parse_tags, e.g.
---'typename:StringList', 'typename:StringNode *', 'struct:Foo'). Used to step
---from one link of an access chain to the next.
---@param index table
---@param typeref string?
---@return string?
local function scope_from_typeref(index, typeref)
  if not typeref then return end
  local kind, rest = typeref:match('^(%a+):(.+)$')
  rest = rest or typeref
  if kind == 'struct' or kind == 'union' or kind == 'enum' or kind == 'class' then
    local key = kind .. ':' .. (rest:match('([%w_]+)') or rest)
    if index.members[key] then return key end
  end
  local tname = rest:match('([%w_]+)')
  return tname and scope_for_type(index, tname) or nil
end

---Walk an access chain to the member scope whose members should be offered:
---treesitter resolves the root variable's type, then each intermediate member's
---type is followed through the ctags index.
---@param index table
---@param parts string[]
---@param buf integer
---@param crow integer  1-based cursor row
---@return string?
local function chain_scope(index, parts, buf, crow)
  local typename = resolve_var_type(buf, parts[1], crow)
  if not typename then return end
  local scope = scope_for_type(index, typename)
  for i = 2, #parts do
    if not scope then return end
    local mtype
    for _, m in ipairs(index.members[scope] or {}) do
      if m.name == parts[i] then mtype = m.type; break end
    end
    scope = scope_from_typeref(index, mtype)
  end
  return scope
end

---Strip the `typeref:` namespace prefix for a readable popup menu label.
---@param typeref string?
---@return string
local function pretty_type(typeref)
  if not typeref then return '' end
  return (typeref:gsub('^typename:', '')
    :gsub('^struct:', 'struct ')
    :gsub('^union:', 'union ')
    :gsub('^enum:', 'enum '))
end

---'omnifunc' implementation for member completion. See |complete-functions|.
---@param findstart integer
---@param base string
function M.omnifunc(findstart, base)
  if findstart == 1 then
    return find_start()
  end
  base = base or ''
  local blow = base:lower()
  local parts = access_chain()
  if not parts then return {} end

  local index = get_tag_index()
  if not index then return {} end

  local buf = vim.api.nvim_get_current_buf()
  local crow = vim.api.nvim_win_get_cursor(0)[1]
  local scope = chain_scope(index, parts, buf, crow)
  if not scope or not index.members[scope] then return {} end

  local items, seen = {}, {}
  for _, m in ipairs(index.members[scope]) do
    if not seen[m.name] and (base == '' or m.name:sub(1, #blow):lower() == blow) then
      seen[m.name] = true
      items[#items + 1] = { word = m.name, menu = pretty_type(m.type), kind = 'm', icase = 1 }
    end
  end
  table.sort(items, function(a, b) return a.word < b.word end)
  return items
end

return M
