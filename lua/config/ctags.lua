-- Ctags fallback for C/C++ go-to-definition
-- Generates tags under /tmp/nvim-ctags/ so the repo stays clean

local M = {}

local project_markers = {
  'compile_flags.txt', 'compile_commands.json', '.clangd',
  'Makefile', 'CMakeLists.txt', 'build.sh', '.clang-format', '.git',
}

local root_cache = {}

local function get_project_root()
  local buf_dir = vim.fn.expand('%:p:h')
  if buf_dir == '' then return nil end
  if root_cache[buf_dir] then return root_cache[buf_dir] end

  -- Try git first (from buffer's directory, not nvim's CWD)
  local result = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(buf_dir) .. ' rev-parse --show-toplevel')
  if vim.v.shell_error == 0 and #result > 0 then
    root_cache[buf_dir] = result[1]
    return result[1]
  end

  -- Walk up from buffer directory looking for project markers
  local dir = buf_dir
  local prev = nil
  while dir ~= prev do
    for _, marker in ipairs(project_markers) do
      if vim.fn.filereadable(dir .. '/' .. marker) == 1
        or vim.fn.isdirectory(dir .. '/' .. marker) == 1 then
        root_cache[buf_dir] = dir
        return dir
      end
    end
    prev = dir
    dir = vim.fn.fnamemodify(dir, ':h')
  end

  -- Last resort: buffer's directory
  root_cache[buf_dir] = buf_dir
  return buf_dir
end

local function tags_path(root)
  local escaped = root:gsub('/', '%%')
  return '/tmp/nvim-ctags/' .. escaped .. '/tags'
end

-- Member cache: { project_root -> { TypeName -> [{word, menu, info}, ...] } }
local member_cache = {}
-- Tag name cache: { project_root -> { name -> kind } }
local tag_name_cache = {}

local function build_member_cache(root)
  local tp = tags_path(root)
  local file = io.open(tp, 'r')
  if not file then return end

  local by_parent = {}
  local names = {}
  for line in file:lines() do
    if not line:match('^!_') then
      local name = line:match('^([^\t]+)')
      if name and not name:match('::') then
        -- Extract kind from the line
        local kind = line:match('\tkind:(%w+)') or line:match('\t(%a)\t') or line:match('\t(%a)$')
        if kind then
          names[name] = kind
        end
        -- Check if it's a member
        local is_member = kind == 'member' or kind == 'm'
        if is_member then
          local parent = line:match('\tstruct:([^\t\n]+)')
            or line:match('\tunion:([^\t\n]+)')
            or line:match('\tclass:([^\t\n]+)')
          if parent then
            if not by_parent[parent] then by_parent[parent] = {} end
            table.insert(by_parent[parent], {
              word = name,
              menu = '[' .. parent .. ']',
              info = 'member of ' .. parent,
            })
          end
        end
      end
    end
  end
  file:close()
  member_cache[root] = by_parent
  tag_name_cache[root] = names
end

local function generate_tags(root, outpath)
  local dir = vim.fn.fnamemodify(outpath, ':h')
  vim.fn.mkdir(dir, 'p')
  vim.fn.jobstart({
    'ctags', '-R',
    '--languages=C,C++,ObjectiveC',
    '--fields=+nKz',
    '--extras=+q',
    '-f', outpath,
    root,
  }, {
    detach = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          build_member_cache(root)
        end)
      end
    end,
  })
end

local function update_tags_for_file(root, outpath, filepath)
  local relpath = filepath
  if filepath:sub(1, #root) == root then
    relpath = filepath:sub(#root + 2)
  end
  vim.fn.jobstart({
    'sh', '-c', string.format(
      'grep -v "\t%s\t" %s > %s.new 2>/dev/null; ' ..
      'mv %s.new %s; ' ..
      'ctags -a --languages=C,C++,ObjectiveC --fields=+nKz --extras=+q -f %s %s',
      relpath, outpath, outpath,
      outpath, outpath,
      outpath, filepath
    )
  }, {
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function() build_member_cache(root) end)
      end
    end,
  })
end

--- Jump to tag using raw ctags, bypassing LSP tagfunc.
--- Single match: jumps directly. Multiple: vim.ui.select (Enter picks first).
function M.jump()
  local word = vim.fn.expand('<cword>')
  local saved = vim.bo.tagfunc
  vim.bo.tagfunc = ''
  local tags = vim.fn.taglist('^' .. word .. '$')
  vim.bo.tagfunc = saved

  if #tags == 0 then
    vim.notify('No tags found for: ' .. word, vim.log.levels.WARN)
    return
  end

  -- Single match: jump directly
  if #tags == 1 then
    vim.bo.tagfunc = ''
    pcall(vim.cmd, 'tag ' .. vim.fn.fnameescape(word))
    vim.bo.tagfunc = saved
    return
  end

  -- Multiple matches: vim.ui.select (Enter picks highlighted/first item)
  local items = {}
  for _, tag in ipairs(tags) do
    local file = vim.fn.fnamemodify(tag.filename, ':~:.')
    local kind = tag.kind or '?'
    table.insert(items, string.format('[%s] %s', kind, file))
  end

  vim.ui.select(items, {
    prompt = 'Tag: ' .. word,
  }, function(_, idx)
    if not idx then return end
    vim.bo.tagfunc = ''
    pcall(vim.cmd, idx .. 'tag ' .. vim.fn.fnameescape(word))
    vim.bo.tagfunc = saved
  end)
end

-- Active completion source for statusline
local active_source = ''

function M.get_active_source()
  return active_source
end

local function trigger_keyword_completion(bufnr, startcol, base)
  local items = {}
  local seen = {}

  -- Buffer words
  local buf_matches = vim.fn.getcompletion(base, 'buffer') or {}
  for _, word in ipairs(buf_matches) do
    if not seen[word] then
      seen[word] = true
      table.insert(items, { word = word, menu = '[Buf]' })
    end
  end

  -- Tag matches from cache (only for C/C++ where ctags are set up)
  local has_tags = false
  local ft = vim.bo[bufnr].filetype
  if ft == 'c' or ft == 'cpp' or ft == 'objc' or ft == 'objcpp' then
    local root = get_project_root()
    if root and tag_name_cache[root] then
      for name, kind in pairs(tag_name_cache[root]) do
        if name:sub(1, #base) == base and not seen[name] then
          seen[name] = true
          has_tags = true
          table.insert(items, { word = name, menu = '[Tag:' .. kind .. ']' })
        end
      end
    end
  end

  if #items > 0 then
    active_source = has_tags and '[Buf+Tag]' or '[Buf]'
    vim.fn.complete(startcol, items)
  end
end

-- Try to infer the type of the variable before . or ->
local function infer_type_at_cursor(bufnr)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local before = line:sub(1, col)

  -- Extract the variable name before . or ->
  local varname = before:match('([%w_]+)%s*%->%s*[%w_]*$')
    or before:match('([%w_]+)%s*%.%s*[%w_]*$')
  if not varname then return nil end

  -- Search backwards in the buffer for a declaration of this variable
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local search_start = math.max(0, cursor_line - 200)
  local lines = vim.api.nvim_buf_get_lines(bufnr, search_start, cursor_line, false)

  local skip = { ['return'] = true, ['if'] = true, ['for'] = true, ['while'] = true,
    ['switch'] = true, ['case'] = true, ['else'] = true, ['do'] = true }

  for i = #lines, 1, -1 do
    local l = lines[i]
    -- Match: Type *varname  or  Type varname  or  Type* varname
    local typ = l:match('([%w_]+)%s+%*?%s*' .. varname .. '%s*[;,=%)%[{]')
      or l:match('([%w_]+)%s+%*?%s*' .. varname .. '%s*$')
      or l:match('([%w_]+)%s*%*%s+' .. varname .. '%s*[;,=%)%[{]')
    if typ and not skip[typ] then
      return typ
    end
  end
  return nil
end

local function trigger_member_completion(bufnr, startcol, base)
  local inferred_type = infer_type_at_cursor(bufnr)
  local root = get_project_root()

  -- Try cache first (fast path)
  if root and member_cache[root] and inferred_type then
    local members = member_cache[root][inferred_type]
    if members then
      local items = {}
      for _, m in ipairs(members) do
        if base == '' or m.word:sub(1, #base) == base then
          table.insert(items, m)
        end
      end
      if #items > 0 then
        vim.schedule(function()
          if vim.api.nvim_get_current_buf() ~= bufnr then return end
          if vim.fn.pumvisible() == 1 then return end
          active_source = '[' .. inferred_type .. ']'
          vim.fn.complete(startcol, items)
        end)
        return
      end
    end
  end

  -- No type inferred and no base typed = can't provide useful results
  if not inferred_type and base == '' then return end

  -- Slow path: taglist fallback
  local saved = vim.bo[bufnr].tagfunc
  vim.bo[bufnr].tagfunc = ''
  local pattern = base ~= '' and ('^' .. base) or '.'
  local all_tags = vim.fn.taglist(pattern)
  vim.bo[bufnr].tagfunc = saved

  local items = {}
  local seen = {}
  for _, tag in ipairs(all_tags) do
    if tag.kind == 'member' then
      local name = tag.name
      if not name:match('::') then
        local parent = tag['struct'] or tag['union'] or tag['class'] or tag['typeref'] or ''
        -- If we know the type, only show members of that type
        if not inferred_type or parent == inferred_type then
          if base == '' or name:sub(1, #base) == base then
            if not seen[name] then
              seen[name] = true
              table.insert(items, {
                word = name,
                menu = parent ~= '' and ('[' .. parent .. ']') or '[Tag:m]',
                info = parent ~= '' and ('member of ' .. parent) or '',
              })
            end
          end
        end
      end
    end
  end

  if #items > 0 then
    vim.schedule(function()
      if vim.api.nvim_get_current_buf() ~= bufnr then return end
      if vim.fn.pumvisible() == 1 then return end
      active_source = inferred_type and ('[' .. inferred_type .. ']') or '[Tag:m]'
      vim.fn.complete(startcol, items)
    end)
  end
end

local function trigger_lsp_completion(bufnr, startcol, base)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local has_lsp = false
  for _, client in ipairs(clients) do
    if client.server_capabilities.completionProvider then
      has_lsp = true
      break
    end
  end

  if not has_lsp then
    -- Fall back to keyword completion if no LSP
    trigger_keyword_completion(bufnr, startcol, base)
    return
  end

  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(bufnr, 'textDocument/completion', params, function(err, result)
    if err or not result then
      trigger_member_completion(bufnr, startcol, base)
      return
    end

    local lsp_items = result.items or result
    if #lsp_items == 0 then
      trigger_member_completion(bufnr, startcol, base)
      return
    end

    local items = {}
    for _, item in ipairs(lsp_items) do
      local word = item.textEdit and item.textEdit.newText or item.insertText or item.label
      -- Skip snippet-style entries with placeholders
      if word and not word:match('%$') then
        table.insert(items, {
          word = word,
          abbr = item.label,
          menu = '[LSP]',
          info = item.documentation and (type(item.documentation) == 'string' and item.documentation or item.documentation.value) or '',
        })
      end
    end

    if #items == 0 then
      trigger_member_completion(bufnr, startcol, base)
      return
    end

    vim.schedule(function()
      if vim.api.nvim_get_current_buf() ~= bufnr then return end
      if vim.fn.pumvisible() == 1 then return end
      active_source = '[LSP]'
      vim.fn.complete(startcol, items)
    end)
  end)
end

local function setup_completion_trigger(bufnr)
  if vim.b[bufnr]._comp_trigger then return end
  vim.b[bufnr]._comp_trigger = true

  local comp_timer = vim.uv.new_timer()
  vim.api.nvim_create_autocmd('TextChangedI', {
    buffer = bufnr,
    callback = function()
      comp_timer:stop()
      comp_timer:start(100, 0, vim.schedule_wrap(function()
        if vim.api.nvim_get_current_buf() ~= bufnr then return end
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        if vim.fn.pumvisible() == 1 or vim.api.nvim_get_mode().mode ~= 'i' then
          return
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        if col < 1 then return end

        local line = vim.api.nvim_get_current_line()
        local before = line:sub(1, col)

        -- Member access: . or -> triggers LSP completion
        if before:match('%.$') or before:match('->$') then
          trigger_lsp_completion(bufnr, col + 1, '')
          return
        end

        -- Typing member name after . or -> : LSP with member-tag fallback
        if before:match('%.[%w_]$') or before:match('%->[%w_]$') then
          local base = before:match('([%w_]+)$') or ''
          local startcol = col - #base + 1
          trigger_lsp_completion(bufnr, startcol, base)
          return
        end

        -- 2+ identifier chars: keyword completion (LSP for Jai)
        if col >= 2 and before:match('[%w_][%w_]$') then
          local base = before:match('([%w_]+)$') or ''
          local startcol = col - #base + 1
          local prefix = before:sub(1, startcol - 1)
          if prefix:match('%.$') or prefix:match('->$') then
            trigger_lsp_completion(bufnr, startcol, base)
          elseif vim.bo[bufnr].filetype == 'jai' then
            trigger_lsp_completion(bufnr, startcol, base)
          else
            trigger_keyword_completion(bufnr, startcol, base)
          end
        end
      end))
    end,
  })

  -- Clear source indicator when completion finishes
  vim.api.nvim_create_autocmd('CompleteDonePre', {
    buffer = bufnr,
    callback = function()
      active_source = ''
    end,
  })
end

function M.setup()
  local group = vim.api.nvim_create_augroup('ctags_fallback', { clear = true })

  -- On BufEnter: add tags path, generate if missing, set up completion
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx', '*.m', '*.mm' },
    callback = function(args)
      local root = get_project_root()
      if not root then return end

      local tp = tags_path(root)

      -- Add to tags option if not already present
      local current = vim.opt.tags:get()
      for _, t in ipairs(current) do
        if t == tp then
          goto skip_add
        end
      end
      vim.opt.tags:append(tp)
      ::skip_add::

      -- Generate tags if file doesn't exist, otherwise build cache if needed
      if vim.fn.filereadable(tp) == 0 then
        generate_tags(root, tp)
      elseif not member_cache[root] then
        vim.schedule(function()
          build_member_cache(root)
        end)
      end

      -- Auto-trigger buffer keyword completion (works without LSP)
      setup_completion_trigger(args.buf)
    end,
  })

  -- On BufWritePost: incremental tag update for saved file only
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx', '*.m', '*.mm' },
    callback = function()
      local root = get_project_root()
      if not root then return end
      local tp = tags_path(root)
      if vim.fn.filereadable(tp) == 0 then
        generate_tags(root, tp)
      else
        update_tags_for_file(root, tp, vim.api.nvim_buf_get_name(0))
      end
    end,
  })

  -- Manual command
  vim.api.nvim_create_user_command('TagGen', function()
    local root = get_project_root()
    if not root then
      vim.notify('Could not determine project root', vim.log.levels.WARN)
      return
    end
    local tp = tags_path(root)
    generate_tags(root, tp)
    vim.notify('Generating tags: ' .. tp)
  end, { desc = 'Regenerate ctags for current project' })
end

M.setup_completion = setup_completion_trigger

return M
