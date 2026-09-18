-- Completion for C-family buffers with no LSP, wired in after/ftplugin/c.lua.
-- complete(): identifiers ranked [local] > [file] > [open] > [project], from the
-- treesitter trees of the open buffers plus the tags file.
-- omnifunc(): members after `.`/`->`/`::`. Treesitter resolves the variable's
-- type, the tags file supplies that type's members.
local M = {}

local ID_QUERY = '[(identifier) (field_identifier) (type_identifier)] @id'
local DECL_QUERY = '[(declaration) (parameter_declaration)] @decl'
local SCOPE_NODES = { function_definition = true, lambda_expression = true }
local C_FILETYPES = { c = true, cpp = true, objc = true, objcpp = true }

local MAX_IDENTS = 4000
local MAX_OPEN_IDENTS = 2000
local MAX_TAGS = 300

local RANK_LOCAL, RANK_FILE, RANK_OPEN, RANK_TAG = 0, 1, 2, 3
local RANK_LABEL = {
  [RANK_LOCAL] = '[local]',
  [RANK_FILE] = '[file]',
  [RANK_OPEN] = '[open]',
  [RANK_TAG] = '[project]',
}

-- Case-insensitive prefix match. Only the exact word already typed is excluded.
local function matches(word, base, blow)
  return word ~= base and word:sub(1, #blow):lower() == blow
end

local function find_start()
  local line = vim.fn.getline('.')
  local s = vim.fn.col('.') - 1
  while s > 0 and line:sub(s, s):match('[%w_]') do
    s = s - 1
  end
  return s
end

local function root_and_query(buf, src)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end
  local ok_q, query = pcall(vim.treesitter.query.parse, parser:lang(), src)
  if not ok_q then return end
  local tree = (parser:parse() or {})[1]
  if tree then return tree:root(), query end
end

local function enclosing_scope(node)
  while node and not SCOPE_NODES[node:type()] do
    node = node:parent()
  end
  return node
end

local function identifiers(node, query, buf, cap)
  local words, n = {}, 0
  for _, id in query:iter_captures(node, buf) do
    n = n + 1
    if n > cap then break end
    words[vim.treesitter.get_node_text(id, buf)] = true
  end
  return words
end

-- Whole-buffer identifier sets, recollected only when the buffer changes.
local ident_cache = {}

local function buffer_words(buf, cap)
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local entry = ident_cache[buf]
  if entry and entry.tick == tick and entry.cap == cap then return entry.words end
  local root, query = root_and_query(buf, ID_QUERY)
  local words = root and identifiers(root, query, buf, cap) or {}
  ident_cache[buf] = { tick = tick, cap = cap, words = words }
  return words
end

local function merge(words, rank, base, blow, found)
  for word in pairs(words) do
    if matches(word, base, blow) and (found[word] == nil or rank < found[word]) then
      found[word] = rank
    end
  end
end

function M.complete(findstart, base)
  if findstart == 1 then return find_start() end
  local blow = base:lower()

  for buf in pairs(ident_cache) do
    if not vim.api.nvim_buf_is_loaded(buf) then ident_cache[buf] = nil end
  end

  local found = {}
  local cur = vim.api.nvim_get_current_buf()
  local root, query = root_and_query(cur, ID_QUERY)
  if root then
    -- The enclosing function is walked uncapped so [local] is never lost.
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local scope = enclosing_scope(root:named_descendant_for_range(row - 1, col, row - 1, col))
    if scope then
      merge(identifiers(scope, query, cur, math.huge), RANK_LOCAL, base, blow, found)
    end
    merge(buffer_words(cur, MAX_IDENTS), RANK_FILE, base, blow, found)
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
      and C_FILETYPES[vim.bo[buf].filetype] then
      merge(buffer_words(buf, MAX_OPEN_IDENTS), RANK_OPEN, base, blow, found)
    end
  end

  local list = {}
  for word, rank in pairs(found) do
    list[#list + 1] = { word = word, rank = rank }
  end

  local tags = {}
  if base ~= '' then
    local ok, names = pcall(vim.fn.getcompletion, base, 'tag')
    tags = ok and names or {}
  end
  local ntags = 0
  for _, name in ipairs(tags) do
    if ntags >= MAX_TAGS then break end
    -- Tag names can be operators or qualified names; only plain identifiers complete here.
    if not found[name] and name:match('^[%a_][%w_]*$') and matches(name, base, blow) then
      found[name] = RANK_TAG
      list[#list + 1] = { word = name, rank = RANK_TAG }
      ntags = ntags + 1
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

-- Member index parsed from the first tags file on &tags, rebuilt when it changes.
local tag_index = {}

-- ctags kinds the index reads: member, enumerator, typedef, struct, union, enum.
local WANT_KIND = {}
for kind in ('metsug'):gmatch('.') do
  WANT_KIND[kind:byte()] = true
end
local AGGREGATE_PREFIX = { s = 'struct:', u = 'union:', g = 'enum:' }

local function scope_token(field)
  return field:match('^(struct:.+)$') or field:match('^(union:.+)$')
    or field:match('^(enum:.+)$') or field:match('^(class:.+)$')
end

-- members:    "struct:Foo" -> { { name, type } }
-- typedefs:   typedef name -> the aggregate scope it aliases
-- aggregates: struct/union/enum name -> its own scope
local function parse_tags(path)
  local members, typedefs, aggregates = {}, {}, {}
  local f = io.open(path, 'r')
  if f then
    for line in f:lines() do
      -- `;"<Tab>` ends the search command and the kind letter follows it. Checking
      -- the kind first skips the unused half of the file before any pattern runs.
      local sep = line:find(';"\t', 1, true)
      if line:byte(1) ~= 33 and sep and WANT_KIND[line:byte(sep + 3)] then
        local kind = line:sub(sep + 3, sep + 3)
        local name = line:match('^([^\t]+)\t')
        if name then
          local scope, typeref
          local i = 0
          for field in (line:sub(sep + 3) .. '\t'):gmatch('([^\t]*)\t') do
            i = i + 1
            if i > 1 then
              scope = scope_token(field) or scope
              typeref = field:match('^typeref:(.+)$') or typeref
            end
          end
          if (kind == 'm' or kind == 'e') and scope then
            members[scope] = members[scope] or {}
            table.insert(members[scope], { name = name, type = typeref })
          elseif kind == 't' and typeref then
            local aliased = scope_token(typeref)
            if aliased then typedefs[name] = aliased end
          elseif AGGREGATE_PREFIX[kind] then
            aggregates[name] = AGGREGATE_PREFIX[kind] .. name
          end
        end
      end
    end
    f:close()
  end
  return { members = members, typedefs = typedefs, aggregates = aggregates }
end

local function get_tag_index()
  for _, path in ipairs(vim.split(vim.bo.tags, ',', { trimempty = true })) do
    local st = vim.uv.fs_stat(path)
    if st then
      local stamp = ('%d.%d.%d'):format(st.mtime.sec, st.mtime.nsec, st.size)
      if tag_index.path ~= path or tag_index.stamp ~= stamp then
        tag_index = { path = path, stamp = stamp, index = parse_tags(path) }
      end
      return tag_index.index
    end
  end
end

-- The member scope for a type name, following one typedef hop.
local function scope_for_type(index, typename)
  typename = typename:gsub('^%s*struct%s+', ''):gsub('^%s*union%s+', ''):gsub('^%s*enum%s+', '')
  typename = typename:match('^%s*([%w_]+)') or typename
  local td = index.typedefs[typename]
  if td and index.members[td] then return td end
  local agg = index.aggregates[typename]
  if agg and index.members[agg] then return agg end
  for _, prefix in ipairs({ 'struct:', 'union:', 'enum:', 'class:' }) do
    if index.members[prefix .. typename] then return prefix .. typename end
  end
end

-- The identifier a declarator binds, under any pointer/array/init/function declarators.
local function declared_name(node)
  local t = node:type()
  if t == 'identifier' or t == 'field_identifier' then
    return vim.treesitter.get_node_text(node, 0)
  end
  local inner = node:field('declarator')[1]
  if inner then return declared_name(inner) end
  for child in node:iter_children() do
    if child:named() then
      local name = declared_name(child)
      if name then return name end
    end
  end
end

local function type_name(type_node)
  local t = type_node:type()
  if t == 'struct_specifier' or t == 'union_specifier' or t == 'enum_specifier' or t == 'class_specifier' then
    local name = type_node:field('name')[1]
    return name and vim.treesitter.get_node_text(name, 0) or nil
  end
  return vim.treesitter.get_node_text(type_node, 0)
end

-- Storage-class macros treesitter mis-parses as the declaration's type.
local STORAGE_MACROS = { internal = true, global = true, local_persist = true, ['function'] = true }

-- The type `node` declares `var` with, if it declares `var` at all.
local function decl_binds(node, buf, var)
  local tnode = node:field('type')[1]
  if not tnode then return end

  local macro = vim.treesitter.get_node_text(tnode, buf)
  if not STORAGE_MACROS[macro] then
    for _, dnode in ipairs(node:field('declarator')) do
      if declared_name(dnode) == var then return type_name(tnode) end
    end
    return
  end

  -- Error recovery around the macro has no stable shape, so swap it for
  -- `static` and re-parse the declaration on its own.
  local text = vim.treesitter.get_node_text(node, buf)
  local fixed = text:gsub('^(%s*)' .. vim.pesc(macro) .. '%f[%W]', '%1static', 1)
  if fixed == text then return end
  local ok, sparser = pcall(vim.treesitter.get_string_parser, fixed, 'c')
  if not ok or not sparser then return end
  local stree = (sparser:parse() or {})[1]
  if not stree then return end

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
    local name = vim.treesitter.get_node_text(dnode, fixed)
    name = name:match('([%a_][%w_]*)%s*[%[%(]?') or name
    if name == var then
      local tname = ftype:field('name')[1]
      return vim.treesitter.get_node_text(tname or ftype, fixed)
    end
  end
end

-- The type of `var` from the nearest declaration at or above the cursor. Only
-- the cursor's own function or file scope can bind the name the cursor sees,
-- and a local shadows a file-scope declaration.
local function resolve_var_type(buf, var, crow)
  local root, query = root_and_query(buf, DECL_QUERY)
  if not root then return end
  local cursor_scope = enclosing_scope(vim.treesitter.get_node({ bufnr = buf, pos = { crow - 1, 0 } }))

  local best, best_row, best_local = nil, -1, false
  for _, node in query:iter_captures(root, buf, 0, crow) do
    local srow = node:range()
    if srow <= crow - 1 then
      local fn = enclosing_scope(node:parent())
      local visible = fn == nil or (cursor_scope ~= nil and fn:equal(cursor_scope))
      local is_local = fn ~= nil
      if visible and ((is_local and not best_local) or (is_local == best_local and srow > best_row)) then
        local tname = decl_binds(node, buf, var)
        if tname then
          best, best_row, best_local = tname, srow, is_local
        end
      end
    end
  end
  return best
end

-- The member-access chain ending at the operator before the cursor:
-- `cmd_line->inputs.` gives { 'cmd_line', 'inputs' }. nil when a call or index
-- sits in the chain.
local function access_chain()
  local line = vim.fn.getline('.')
  local before = line:sub(1, find_start()):gsub('%s+$', '')
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
    if not pid then return nil end
    table.insert(parts, 1, pid)
    before = before:sub(1, #before - #pid):gsub('%s+$', '')
  end
  return parts
end

-- A member's typeref ('typename:StringNode *', 'struct:Foo') as a member scope.
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

local function chain_scope(index, parts, buf, crow)
  local typename = resolve_var_type(buf, parts[1], crow)
  if not typename then return end
  local scope = scope_for_type(index, typename)
  for i = 2, #parts do
    if not scope then return end
    local mtype
    for _, m in ipairs(index.members[scope] or {}) do
      if m.name == parts[i] then
        mtype = m.type
        break
      end
    end
    scope = scope_from_typeref(index, mtype)
  end
  return scope
end

local function pretty_type(typeref)
  if not typeref then return '' end
  return (typeref:gsub('^typename:', ''):gsub('^struct:', 'struct ')
    :gsub('^union:', 'union '):gsub('^enum:', 'enum '))
end

function M.omnifunc(findstart, base)
  if findstart == 1 then return find_start() end
  local parts = access_chain()
  local index = parts and get_tag_index()
  if not index then return {} end
  local buf = vim.api.nvim_get_current_buf()
  local scope = chain_scope(index, parts, buf, vim.api.nvim_win_get_cursor(0)[1])
  if not scope or not index.members[scope] then return {} end

  local blow = base:lower()
  local items, seen = {}, {}
  for _, m in ipairs(index.members[scope]) do
    if not seen[m.name] and m.name:sub(1, #blow):lower() == blow then
      seen[m.name] = true
      items[#items + 1] = { word = m.name, menu = pretty_type(m.type), kind = 'm', icase = 1 }
    end
  end
  table.sort(items, function(a, b) return a.word < b.word end)
  return items
end

return M
