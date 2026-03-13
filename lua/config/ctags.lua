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

-- System tags infrastructure
local SYSTEM_TAGS_PATH = '/tmp/nvim-ctags/system-tags'
local system_includes_cache = nil
local system_member_cache = nil -- { TypeName -> [{word, menu, info}, ...] }
local system_tag_name_cache = nil -- { name -> kind }
local system_tags_generating = false

local function get_system_includes()
  if system_includes_cache then return system_includes_cache end

  local dirs = {}
  local seen = {}

  for _, lang in ipairs({ 'c', 'c++' }) do
    local cmd = string.format('echo | cc -E -v -x %s - 2>&1', lang)
    local output = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then goto continue end

    local in_block = false
    for line in output:gmatch('[^\n]+') do
      if line:match('#include <%.%.%.> search starts here') then
        in_block = true
      elseif line:match('End of search list') then
        in_block = false
      elseif in_block then
        local dir = vim.trim(line)
        -- Skip framework dirs and clang intrinsics (not useful for tags)
        if not dir:match('%(framework directory%)$')
          and not dir:match('/clang/[%d.]+/include$')
          and not seen[dir]
          and vim.fn.isdirectory(dir) == 1 then
          seen[dir] = true
          table.insert(dirs, dir)
        end
      end
    end
    ::continue::
  end

  system_includes_cache = dirs
  return dirs
end

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

local function build_system_member_cache()
  local file = io.open(SYSTEM_TAGS_PATH, 'r')
  if not file then return end

  local by_parent = {}
  local names = {}
  for line in file:lines() do
    if not line:match('^!_') then
      local name = line:match('^([^\t]+)')
      if name and not name:match('::') then
        local kind = line:match('\tkind:(%w+)') or line:match('\t(%a)\t') or line:match('\t(%a)$')
        if kind then
          names[name] = kind
        end
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
  system_member_cache = by_parent
  system_tag_name_cache = names
end

local function generate_system_tags(opts)
  opts = opts or {}
  if system_tags_generating then
    if opts.notify then vim.notify('System tags already generating...') end
    return
  end

  local includes = get_system_includes()
  if #includes == 0 then
    if opts.notify then vim.notify('No system include paths found', vim.log.levels.WARN) end
    return
  end

  system_tags_generating = true
  local dir = vim.fn.fnamemodify(SYSTEM_TAGS_PATH, ':h')
  vim.fn.mkdir(dir, 'p')

  -- System headers use compiler-specific macros that confuse ctags.
  -- Tell ctags to treat them as no-ops so prototypes parse correctly.
  local ignore_macros = {
    '__attribute__+',
    '__restrict',
  }
  if vim.fn.has('mac') == 1 then
    -- macOS / Darwin SDK macros
    vim.list_extend(ignore_macros, {
      '__printflike+', '__scanflike+',
      '__deprecated', '__deprecated_msg+',
      '__swift_unavailable+',
      '__OSX_AVAILABLE_STARTING+',
      '__API_AVAILABLE+', '__API_DEPRECATED+', '__API_DEPRECATED_WITH_REPLACEMENT+',
      '__DARWIN_ALIAS+', '__DARWIN_ALIAS_C+',
      '_LIBC_SINGLE_BY_DEFAULT+', '_LIBC_PTRCHECK_REPLACED+',
    })
  else
    -- Linux / glibc macros
    vim.list_extend(ignore_macros, {
      '__THROW', '__THROWNL', '__nonnull+',
      '__wur', '__fortify_function',
      '__attribute_pure__', '__attribute_const__',
      '__attribute_malloc__', '__attribute_format_strfmon__+',
      '__attribute_warn_unused_result__',
      '__glibc_likely+', '__glibc_unlikely+',
      '__BEGIN_DECLS', '__END_DECLS',
    })
  end

  local args = {
    'ctags', '-R',
    '--languages=C,C++,ObjectiveC',
    '--kinds-C=+p',
    '--kinds-C++=+p',
    '--fields=+nKz',
    '--extras=+q',
  }
  for _, macro in ipairs(ignore_macros) do
    table.insert(args, '-I')
    table.insert(args, macro)
  end
  table.insert(args, '-f')
  table.insert(args, SYSTEM_TAGS_PATH)
  for _, inc in ipairs(includes) do
    table.insert(args, inc)
  end

  if opts.notify then
    vim.notify('Generating system tags (' .. #includes .. ' include paths)...')
  end

  vim.fn.jobstart(args, {
    detach = true,
    on_exit = function(_, code)
      system_tags_generating = false
      vim.schedule(function()
        if code == 0 then
          build_system_member_cache()
          if opts.notify then vim.notify('System tags generated: ' .. SYSTEM_TAGS_PATH) end
        else
          if opts.notify then vim.notify('System tags generation failed (exit ' .. code .. ')', vim.log.levels.ERROR) end
        end
      end)
    end,
  })
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

  -- Filter out system tags if any project tags exist
  local root = get_project_root()
  if root then
    local project_tags = {}
    for _, tag in ipairs(tags) do
      local abs = vim.fn.fnamemodify(tag.filename, ':p')
      if abs:sub(1, #root) == root then
        table.insert(project_tags, tag)
      end
    end
    if #project_tags > 0 then
      tags = project_tags
    end
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

  -- Scan current buffer for matching words
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, line in ipairs(lines) do
    for word in line:gmatch('[%w_]+') do
      if #word >= 2 and word:sub(1, #base) == base and not seen[word] then
        seen[word] = true
        table.insert(items, { word = word, menu = '[Buf]' })
      end
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
    -- System tag name cache
    if system_tag_name_cache then
      for name, kind in pairs(system_tag_name_cache) do
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

  -- Try cache first (fast path) - merge project + system caches
  if inferred_type then
    local items = {}
    local seen = {}
    -- Project cache
    if root and member_cache[root] then
      local members = member_cache[root][inferred_type]
      if members then
        for _, m in ipairs(members) do
          if base == '' or m.word:sub(1, #base) == base then
            seen[m.word] = true
            table.insert(items, m)
          end
        end
      end
    end
    -- System cache
    if system_member_cache then
      local members = system_member_cache[inferred_type]
      if members then
        for _, m in ipairs(members) do
          if not seen[m.word] and (base == '' or m.word:sub(1, #base) == base) then
            table.insert(items, m)
          end
        end
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

  -- No type inferred and no base typed = can't provide useful results
  if not inferred_type and base == '' then return end

  -- Slow path: taglist fallback (only when we have a base to narrow results)
  -- taglist('.') matches every tag and is catastrophically slow with large tag files
  if base == '' then return end

  local saved = vim.bo[bufnr].tagfunc
  vim.bo[bufnr].tagfunc = ''
  local all_tags = vim.fn.taglist('^' .. base)
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

  local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
  local encoding = client and client.offset_encoding or 'utf-16'
  local params = vim.lsp.util.make_position_params(0, encoding)
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

    -- Safely extract a string value, skipping Blobs and other non-string types.
    -- Also strip null bytes which can cause E976 (Blob as String) when passed
    -- back to Vim via vim.fn.complete().
    local function safe_str(v)
      if type(v) ~= 'string' then return nil end
      return v:gsub('%z', '')
    end

    local items = {}
    for _, item in ipairs(lsp_items) do
      local raw
      if type(item.textEdit) == 'table' then
        raw = item.textEdit.newText
      end
      if not raw then raw = item.insertText end
      if not raw then raw = item.label end
      local word = safe_str(raw)
      if not word then goto next_item end
      -- Strip snippet placeholders ($0, $1, ${1:foo}) → use plain text
      word = word:gsub('%$%{%d+:[^}]*%}', ''):gsub('%$%d+', ''):gsub('%(%)$', '')
      if word ~= '' then
        local info = ''
        if type(item.documentation) == 'string' then
          info = safe_str(item.documentation) or ''
        elseif type(item.documentation) == 'table' and type(item.documentation.value) == 'string' then
          info = safe_str(item.documentation.value) or ''
        end
        table.insert(items, {
          word = word,
          abbr = safe_str(item.label) or word,
          menu = '[LSP]',
          info = info,
        })
      end
      ::next_item::
    end

    if #items == 0 then
      trigger_member_completion(bufnr, startcol, base)
      return
    end

    vim.schedule(function()
      if vim.api.nvim_get_current_buf() ~= bufnr then return end
      if vim.fn.pumvisible() == 1 then return end
      active_source = '[LSP]'
      local ok, err = pcall(vim.fn.complete, startcol, items)
      if not ok then
        vim.schedule(function()
          vim.notify('completion error: ' .. tostring(err), vim.log.levels.DEBUG)
        end)
      end
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

        -- Member access: . or -> triggers ctags member completion directly
        -- (skips LSP — clangd doesn't work well with unity builds)
        if before:match('%.$') or before:match('->$') then
          trigger_member_completion(bufnr, col + 1, '')
          return
        end

        -- Typing member name after . or ->
        if before:match('%.[%w_]$') or before:match('%->[%w_]$') then
          local base = before:match('([%w_]+)$') or ''
          local startcol = col - #base + 1
          trigger_member_completion(bufnr, startcol, base)
          return
        end

        -- 2+ identifier chars: keyword completion
        if col >= 2 and before:match('[%w_][%w_]$') then
          local base = before:match('([%w_]+)$') or ''
          local startcol = col - #base + 1
          local prefix = before:sub(1, startcol - 1)
          if prefix:match('%.$') or prefix:match('->$') then
            trigger_member_completion(bufnr, startcol, base)
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

      -- System tags: add to tags option and auto-generate if missing
      local current_tags = vim.opt.tags:get()
      local has_sys = false
      for _, t in ipairs(current_tags) do
        if t == SYSTEM_TAGS_PATH then has_sys = true; break end
      end
      if not has_sys then
        vim.opt.tags:append(SYSTEM_TAGS_PATH)
      end
      if vim.fn.filereadable(SYSTEM_TAGS_PATH) == 0 then
        generate_system_tags()
      elseif not system_member_cache then
        vim.schedule(function()
          build_system_member_cache()
        end)
      end

      -- Auto-trigger buffer keyword completion (works without LSP)
      setup_completion_trigger(args.buf)
    end,
  })

  -- On BufWritePost: debounced incremental tag update for saved file only
  local save_timer = vim.uv.new_timer()

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx', '*.m', '*.mm' },
    callback = function()
      save_timer:stop()
      save_timer:start(500, 0, vim.schedule_wrap(function()
        local root = get_project_root()
        if not root then return end
        local tp = tags_path(root)
        if vim.fn.filereadable(tp) == 0 then
          generate_tags(root, tp)
        else
          update_tags_for_file(root, tp, vim.api.nvim_buf_get_name(0))
        end
      end))
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

  vim.api.nvim_create_user_command('TagGenSystem', function()
    generate_system_tags({ notify = true })
  end, { desc = 'Generate/regenerate system library ctags' })
end

--- LSP-only auto-trigger (for non-C/C++ languages like Jai).
--- Same TextChangedI debounce pattern as setup_completion_trigger but uses
--- LSP completion for plain identifier typing instead of keyword/ctags.
local function setup_lsp_completion_trigger(bufnr)
  if vim.b[bufnr]._lsp_comp_trigger then return end
  vim.b[bufnr]._lsp_comp_trigger = true

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

        -- Dot access: trigger LSP immediately
        if before:match('%.$') then
          trigger_lsp_completion(bufnr, col + 1, '')
          return
        end

        -- Typing after dot: LSP with partial base
        if before:match('%.[%w_]$') then
          local base = before:match('([%w_]+)$') or ''
          local startcol = col - #base + 1
          trigger_lsp_completion(bufnr, startcol, base)
          return
        end

        -- 2+ identifier chars: LSP completion (not just keyword/ctags)
        if col >= 2 and before:match('[%w_][%w_]$') then
          local base = before:match('([%w_]+)$') or ''
          local startcol = col - #base + 1
          local prefix = before:sub(1, startcol - 1)
          if prefix:match('%.$') then
            trigger_lsp_completion(bufnr, startcol, base)
          else
            trigger_lsp_completion(bufnr, startcol, base)
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

M.setup_completion = setup_completion_trigger
M.setup_lsp_completion = setup_lsp_completion_trigger

--- Open a Telescope picker with all project tags (workspace symbols via ctags).
function M.workspace_symbols()
  local has_telescope, pickers = pcall(require, 'telescope.pickers')
  if not has_telescope then
    vim.notify('Telescope not available', vim.log.levels.WARN)
    return
  end
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local entry_display = require('telescope.pickers.entry_display')

  local root = get_project_root()
  if not root then
    vim.notify('Could not determine project root', vim.log.levels.WARN)
    return
  end

  local tp = tags_path(root)
  local file = io.open(tp, 'r')
  if not file then
    vim.notify('No tags file found. Run :TagGen first.', vim.log.levels.WARN)
    return
  end

  local entries = {}
  for line in file:lines() do
    if not line:match('^!_') then
      local name, filename, pattern_rest = line:match('^([^\t]+)\t([^\t]+)\t(.*)')
      if name and not name:match('::') then
        local kind = line:match('\tkind:(%w+)') or line:match('\t(%a)\t') or line:match('\t(%a)$') or '?'
        local lnum = line:match('\tline:(%d+)')
        table.insert(entries, {
          name = name,
          kind = kind,
          filename = filename,
          lnum = lnum and tonumber(lnum) or 1,
        })
      end
    end
  end
  file:close()

  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 6 },
      { width = 40 },
      { remaining = true },
    },
  })

  local function make_display(entry)
    return displayer({
      { '[' .. entry.kind .. ']', 'TelescopeResultsComment' },
      entry.value,
      { vim.fn.fnamemodify(entry.filename, ':~:.'), 'TelescopeResultsLineNr' },
    })
  end

  pickers.new({}, {
    prompt_title = 'Workspace Symbols (Tags)',
    finder = finders.new_table({
      results = entries,
      entry_maker = function(item)
        return {
          value = item.name,
          display = make_display,
          ordinal = item.name,
          filename = item.filename,
          lnum = item.lnum,
          kind = item.kind,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection.filename))
          vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
        end
      end)
      return true
    end,
  }):find()
end

M.get_project_root = get_project_root

return M
