-- Custom blink.cmp source for ctags completion (C/C++ member access + keyword)
-- Bridges existing ctags caches from config.ctags into blink.cmp's source API
--
-- Performance: uses 2-char prefix hash index built during async cache read.
-- No vim.fn calls on the completion hot path (avoids command-line flash).

local ctags_source = {}

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
    callback({
      items = items,
      is_incomplete_forward = true,
      is_incomplete_backward = true,
    })
  else
    -- Keyword completion: fast prefix lookup (no vim.fn calls)
    local keyword = before:match('([%w_]+)$') or ''
    if #keyword < 2 then
      -- Too short for ctags — tell blink to re-query when more chars typed
      callback({
        items = {},
        is_incomplete_forward = true,
        is_incomplete_backward = true,
      })
      return
    end

    -- Defer to next event loop tick so blink's trigger handling completes first
    vim.schedule(function()
      local matches = ctags.get_prefix_matches(keyword:lower(), 200)
      for _, m in ipairs(matches) do
        items[#items + 1] = {
          label = m.name,
          kind = kind_map[m.kind] or CompletionItemKind.Variable,
          detail = '[Tag:' .. (m.kind or '?') .. ']',
        }
      end
      -- Got items: tell blink to cache and filter locally (no re-query)
      callback({
        items = items,
        is_incomplete_forward = false,
        is_incomplete_backward = false,
      })
    end)
  end
end

return ctags_source
