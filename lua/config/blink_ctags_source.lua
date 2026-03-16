-- Custom blink.cmp source for ctags completion (C/C++ member access + keyword)
-- Bridges existing ctags caches from config.ctags into blink.cmp's source API

local ctags_source = {}

-- Pre-built keyword items cache (rebuilt only when cache version changes)
local keyword_items = {}
local keyword_cache_ver = -1
local keyword_sys_cache_ver = -1

local CompletionItemKind = {
  Field = 5,
  Variable = 6,
  Function = 3,
  Struct = 22,
  Enum = 13,
  Constant = 21,
  Keyword = 14,
  Module = 9,
}

-- Map ctags kind letters/names to LSP CompletionItemKind
local kind_map = {
  member = CompletionItemKind.Field,
  m = CompletionItemKind.Field,
  ['function'] = CompletionItemKind.Function,
  f = CompletionItemKind.Function,
  variable = CompletionItemKind.Variable,
  v = CompletionItemKind.Variable,
  struct = CompletionItemKind.Struct,
  s = CompletionItemKind.Struct,
  enum = CompletionItemKind.Enum,
  g = CompletionItemKind.Enum,
  macro = CompletionItemKind.Constant,
  d = CompletionItemKind.Constant,
  typedef = CompletionItemKind.Keyword,
  t = CompletionItemKind.Keyword,
  prototype = CompletionItemKind.Function,
  p = CompletionItemKind.Function,
  enumerator = CompletionItemKind.Enum,
  e = CompletionItemKind.Enum,
  header = CompletionItemKind.Module,
  h = CompletionItemKind.Module,
}

function ctags_source.new(opts)
  return setmetatable({ opts = opts or {} }, { __index = ctags_source })
end

function ctags_source:enabled()
  local ft = vim.bo.filetype
  return ft == 'c' or ft == 'cpp' or ft == 'objc' or ft == 'objcpp'
end

function ctags_source:get_trigger_characters()
  return { '.', '>' }
end

function ctags_source:get_completions(context, callback)
  local ctags = require('config.ctags')
  local line = context.line
  local col = context.cursor[2]
  local before = line:sub(1, col)

  -- Determine if this is a member access (. or ->)
  local is_member = before:match('%.$')
    or before:match('->$')
    or before:match('%.[%w_]+$')
    or before:match('%->[%w_]+$')

  local items = {}

  if is_member then
    -- Member access: use type inference + member caches
    local inferred_type = ctags.infer_type_at_cursor(context.bufnr)
    if inferred_type then
      local seen = {}
      -- Project member cache
      local mc = ctags.get_member_cache()
      local root = ctags.get_project_root()
      if root and mc[root] then
        local members = mc[root][inferred_type]
        if members then
          for _, m in ipairs(members) do
            if not seen[m.word] then
              seen[m.word] = true
              table.insert(items, {
                label = m.word,
                kind = CompletionItemKind.Field,
                detail = inferred_type,
                labelDetails = { description = inferred_type },
              })
            end
          end
        end
      end
      -- System member cache
      local smc = ctags.get_system_member_cache()
      if smc then
        local members = smc[inferred_type]
        if members then
          for _, m in ipairs(members) do
            if not seen[m.word] then
              seen[m.word] = true
              table.insert(items, {
                label = m.word,
                kind = CompletionItemKind.Field,
                detail = inferred_type,
                labelDetails = { description = inferred_type },
              })
            end
          end
        end
      end
    end
  else
    -- Keyword completion: use pre-built items cache, rebuild only when version changes
    local cv = ctags.get_cache_version()
    local scv = ctags.get_system_cache_version()
    if cv ~= keyword_cache_ver or scv ~= keyword_sys_cache_ver then
      local new_items = {}
      local seen = {}
      local root = ctags.get_project_root()
      local tnc = ctags.get_tag_name_cache()
      if root and tnc[root] then
        for name, kind in pairs(tnc[root]) do
          if not seen[name] then
            seen[name] = true
            table.insert(new_items, {
              label = name,
              kind = kind_map[kind] or CompletionItemKind.Variable,
              detail = '[Tag:' .. kind .. ']',
            })
          end
        end
      end
      local stnc = ctags.get_system_tag_name_cache()
      if stnc then
        for name, kind in pairs(stnc) do
          if not seen[name] then
            seen[name] = true
            table.insert(new_items, {
              label = name,
              kind = kind_map[kind] or CompletionItemKind.Variable,
              detail = '[Tag:' .. kind .. ']',
            })
          end
        end
      end
      keyword_items = new_items
      keyword_cache_ver = cv
      keyword_sys_cache_ver = scv
    end
    items = keyword_items
  end

  -- blink.cmp handles fuzzy filtering - return all items
  -- Only mark member completion as incomplete (type inference can change);
  -- keyword items are static and safe to cache across keystrokes
  callback({
    items = items,
    is_incomplete_forward = is_member and true or false,
    is_incomplete_backward = is_member and true or false,
  })
end

return ctags_source
