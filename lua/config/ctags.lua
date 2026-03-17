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
-- Reverse index: { project_root -> { filename -> { [name]=true } } }
local file_entries = {}
-- Prefix index: { project_root -> { "ab" -> {name1, name2, ...} } }
local tag_prefix_index = {}
-- Mtime tracking: { filepath -> mtime_sec }
local cache_mtime = {}
-- Cache version counters (bumped on cache update, used by blink source)
local cache_version = 0
local system_cache_version = 0
-- Per-buffer root cache (avoids vim.fn calls during completion)
local buf_root = {} -- { bufnr -> root }

-- System tags infrastructure
local SYSTEM_TAGS_PATH = '/tmp/nvim-ctags/system-tags'
local system_includes_cache = nil
local system_member_cache = nil -- { TypeName -> [{word, menu, info}, ...] }
local system_tag_name_cache = nil -- { name -> kind }
local system_tag_prefix_index = nil -- { "ab" -> {name1, name2, ...} }
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

-- Parse a single ctags line, returns (name, filename, kind, parent) or nil
local function parse_tag_line(line)
  if line:byte(1) == 33 then return nil end -- skip !_ metadata lines
  local name, filename = line:match('^([^\t]+)\t([^\t]+)')
  if not name or name:find('::', 1, true) then return nil end
  local kind = line:match('\tkind:(%w+)') or line:match('\t(%a)\t') or line:match('\t(%a)$')
  if not kind then return nil end
  local parent = nil
  if kind == 'member' or kind == 'm' then
    parent = line:match('\tstruct:([^\t\n]+)')
      or line:match('\tunion:([^\t\n]+)')
      or line:match('\tclass:([^\t\n]+)')
  end
  return name, filename, kind, parent
end

-- Add parsed tag to cache tables
local function add_to_caches(name, filename, kind, parent, by_parent, names, findex, pindex)
  names[name] = kind
  if parent then
    if not by_parent[parent] then by_parent[parent] = {} end
    table.insert(by_parent[parent], {
      word = name,
      menu = '[' .. parent .. ']',
      info = 'member of ' .. parent,
    })
  end
  if findex then
    if not findex[filename] then findex[filename] = {} end
    findex[filename][name] = true
  end
  if pindex and #name >= 2 then
    local key = name:sub(1, 2):lower()
    if not pindex[key] then pindex[key] = {} end
    pindex[key][#pindex[key] + 1] = name
  end
end

-- Async chunked cache building using libuv.
-- Reads file in 64KB chunks, parses tags, yields between chunks so the
-- editor stays responsive even for the 105MB system tags file.
-- Calls on_done(by_parent, names, findex, pindex) when complete, or on_done(nil) on error.
local function build_cache_async(filepath, on_done)
  vim.uv.fs_open(filepath, 'r', 438, function(err, fd)
    if err or not fd then
      if on_done then vim.schedule(function() on_done(nil) end) end
      return
    end
    vim.uv.fs_fstat(fd, function(serr, stat)
      if serr or not stat then
        vim.uv.fs_close(fd, function() end)
        if on_done then vim.schedule(function() on_done(nil) end) end
        return
      end

      local CHUNK = 65536
      local by_parent = {}
      local names = {}
      local findex = {}
      local pindex = {}
      local leftover = ''
      local offset = 0
      local file_size = stat.size

      local function finish()
        if #leftover > 0 then
          local n, fn, k, p = parse_tag_line(leftover)
          if n then add_to_caches(n, fn, k, p, by_parent, names, findex, pindex) end
        end
        vim.uv.fs_close(fd, function() end)
        if on_done then
          vim.schedule(function() on_done(by_parent, names, findex, pindex) end)
        end
      end

      local function read_chunk()
        if offset >= file_size then finish(); return end
        vim.uv.fs_read(fd, CHUNK, offset, function(rerr, data)
          if rerr or not data or #data == 0 then finish(); return end
          offset = offset + #data
          local block = leftover .. data
          local last_nl = nil
          for i = #block, 1, -1 do
            if block:byte(i) == 10 then last_nl = i; break end
          end
          if last_nl then
            local complete = block:sub(1, last_nl - 1)
            leftover = block:sub(last_nl + 1)
            for line in complete:gmatch('[^\n]+') do
              local n, fn, k, p = parse_tag_line(line)
              if n then add_to_caches(n, fn, k, p, by_parent, names, findex, pindex) end
            end
          else
            leftover = block
          end
          -- Yield to event loop between chunks so editor stays responsive
          vim.schedule(read_chunk)
        end)
      end
      read_chunk()
    end)
  end)
end

-- Check if file mtime changed since last cache build
local function mtime_changed(filepath)
  local stat = vim.uv.fs_stat(filepath)
  if not stat then return false end
  local mtime = stat.mtime.sec
  if cache_mtime[filepath] and cache_mtime[filepath] == mtime then
    return false
  end
  cache_mtime[filepath] = mtime
  return true
end

-- Async project cache build (replaces synchronous build_member_cache)
local function build_member_cache_async(root, force)
  local tp = tags_path(root)
  if not force and not mtime_changed(tp) then return end
  if force then
    local stat = vim.uv.fs_stat(tp)
    if stat then cache_mtime[tp] = stat.mtime.sec end
  end
  build_cache_async(tp, function(by_parent, names, findex, pindex)
    if not by_parent then return end
    member_cache[root] = by_parent
    tag_name_cache[root] = names
    file_entries[root] = findex
    tag_prefix_index[root] = pindex
    cache_version = cache_version + 1
  end)
end

-- Async system cache build (replaces synchronous build_system_member_cache)
local function build_system_member_cache_async(force)
  if not force and not mtime_changed(SYSTEM_TAGS_PATH) then return end
  if force then
    local stat = vim.uv.fs_stat(SYSTEM_TAGS_PATH)
    if stat then cache_mtime[SYSTEM_TAGS_PATH] = stat.mtime.sec end
  end
  build_cache_async(SYSTEM_TAGS_PATH, function(by_parent, names, _, pindex)
    if not by_parent then return end
    system_member_cache = by_parent
    system_tag_name_cache = names
    system_tag_prefix_index = pindex
    system_cache_version = system_cache_version + 1
  end)
end

-- Incremental cache update for a single file (avoids full rebuild on save)
local function update_cache_for_file(root, filepath)
  local relpath = filepath
  if filepath:sub(1, #root) == root then
    relpath = filepath:sub(#root + 2)
  end

  -- Remove old entries for this file from caches
  local fent = file_entries[root]
  if fent then
    -- Try both absolute and relative paths (tags file may use either)
    local old_names = fent[filepath] or fent[relpath]
    if old_names then
      local mc = member_cache[root]
      local tnc = tag_name_cache[root]
      local pindex = tag_prefix_index[root]
      if tnc then
        for name in pairs(old_names) do tnc[name] = nil end
      end
      if mc then
        for parent, members in pairs(mc) do
          for i = #members, 1, -1 do
            if old_names[members[i].word] then
              table.remove(members, i)
            end
          end
          if #members == 0 then mc[parent] = nil end
        end
      end
      -- Remove from prefix index
      if pindex then
        for name in pairs(old_names) do
          if #name >= 2 then
            local key = name:sub(1, 2):lower()
            local bucket = pindex[key]
            if bucket then
              for i = #bucket, 1, -1 do
                if bucket[i] == name then
                  table.remove(bucket, i)
                  break
                end
              end
            end
          end
        end
      end
      fent[filepath] = nil
      fent[relpath] = nil
    end
  end

  -- Run ctags on just this file to get new entries
  vim.fn.jobstart({
    'ctags', '-f', '-',
    '--languages=C,C++,ObjectiveC',
    '--fields=+nKz',
    '--extras=+q',
    filepath,
  }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then return end
      vim.schedule(function()
        local mc = member_cache[root] or {}
        local tnc = tag_name_cache[root] or {}
        local fi = file_entries[root] or {}
        local pi = tag_prefix_index[root] or {}
        for _, line in ipairs(data) do
          if line ~= '' then
            local n, fn, k, p = parse_tag_line(line)
            if n then add_to_caches(n, fn, k, p, mc, tnc, fi, pi) end
          end
        end
        member_cache[root] = mc
        tag_name_cache[root] = tnc
        file_entries[root] = fi
        tag_prefix_index[root] = pi
        cache_version = cache_version + 1
      end)
    end,
  })
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
          build_system_member_cache_async(true)
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
          build_member_cache_async(root, true)
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
        vim.schedule(function() update_cache_for_file(root, filepath) end)
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

function M.setup()
  local group = vim.api.nvim_create_augroup('ctags_fallback', { clear = true })

  -- On BufEnter: add tags path, generate if missing, set up completion
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx', '*.m', '*.mm' },
    callback = function(args)
      local root = get_project_root()
      if not root then return end
      buf_root[args.buf] = root

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

      -- Generate tags if file doesn't exist, otherwise build cache async if needed
      if vim.fn.filereadable(tp) == 0 then
        generate_tags(root, tp)
      elseif not member_cache[root] then
        build_member_cache_async(root)
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
        build_system_member_cache_async()
      end

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
M.infer_type_at_cursor = infer_type_at_cursor

function M.get_member_cache() return member_cache end
function M.get_tag_name_cache() return tag_name_cache end
function M.get_system_member_cache() return system_member_cache end
function M.get_system_tag_name_cache() return system_tag_name_cache end
function M.get_cache_version() return cache_version end
function M.get_system_cache_version() return system_cache_version end

--- Fast prefix lookup using 2-char hash index.
--- Returns up to max_items {name, kind} pairs matching the given lowercase prefix.
--- Uses buf_root cache to avoid vim.fn calls during insert mode.
function M.get_prefix_matches(prefix, max_items)
  local results = {}
  local key = prefix:sub(1, 2)
  local seen = {}

  -- Project tags first (use buf_root to avoid vim.fn during completion)
  local root = buf_root[vim.api.nvim_get_current_buf()]
  if root then
    local pindex = tag_prefix_index[root]
    local tnc = tag_name_cache[root]
    if pindex and pindex[key] and tnc then
      for _, name in ipairs(pindex[key]) do
        if not seen[name] and name:lower():sub(1, #prefix) == prefix then
          seen[name] = true
          results[#results + 1] = { name = name, kind = tnc[name] }
          if #results >= max_items then return results end
        end
      end
    end
  end

  -- System tags
  if system_tag_prefix_index and system_tag_prefix_index[key] and system_tag_name_cache then
    for _, name in ipairs(system_tag_prefix_index[key]) do
      if not seen[name] and name:lower():sub(1, #prefix) == prefix then
        seen[name] = true
        results[#results + 1] = { name = name, kind = system_tag_name_cache[name] }
        if #results >= max_items then return results end
      end
    end
  end

  return results
end

return M
