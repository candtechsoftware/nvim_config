-- :ClangdSetup writes a .clangd for a unity-build project. Each unity TU's
-- ordered includes become an -include chain, scoped by PathMatch fragments to
-- the dirs that TU covers. It also writes a flagless compile_commands.json,
-- because clangd's background indexer only takes its file list from a CDB.
-- A CDB a build system wrote is kept. :ClangdSetup! overwrites the .clangd.

local M = {}

local SRC_EXT = { c = true, cc = true, cpp = true, cxx = true, m = true, mm = true }
local SKIP_DIRS = require('config.project').SKIP_DIRS

-- Tried under the root when an include does not resolve next to its includer.
local INCLUDE_BASES = { '', 'src', 'include', 'code' }
-- Build-output roots, searched last, for generated headers.
local GENERATED_BASES = { 'build', 'out', 'gen', 'generated' }

local SYSNAME = vim.uv.os_uname().sysname

-- Path tokens (delimited by / _ - .) naming sources for other platforms.
local FOREIGN_PLATFORM = {
  Darwin = 'win|win32|windows|linux|lnx|wayland|x11',
  Linux = 'win|win32|windows|mac|macos|darwin|cocoa|metal',
  Windows_NT = 'mac|macos|darwin|cocoa|metal|linux|lnx|wayland|x11',
}
local FOREIGN = FOREIGN_PLATFORM[SYSNAME] or FOREIGN_PLATFORM.Windows_NT

-- The second element marks system (<...>) includes.
local INCLUDE_PATTERNS = {
  { '^%s*#%s*include%s+"([^"]+)"', false },
  { '^%s*#%s*import%s+"([^"]+)"', false },
  { '^%s*#%s*include%s+<([^>]+)>', true },
  { '^%s*#%s*import%s+<([^>]+)>', true },
}

-- Diagnostics every unity member reports when parsed standalone, even with a
-- good -include chain. Names are clang 22's.
local SUPPRESS = {
  'implicit_function_decl_c99',
  'implicit_function_decl',
  'implicit-function-declaration',
  'typecheck_convert_incompatible',
  'undeclared_var_use',
  'undeclared_var_use_suggest',
  'unknown_typename',
  'unknown_typename_suggest',
  'typecheck_decl_incomplete_type',
  'typecheck_incomplete_tag',
  'incomplete_member_access',
  'call_incomplete_argument',
  'call_incomplete_return',
  'field_incomplete_or_sizeless',
  'redefinition',
  'redefinition_different_kind',
  'redefinition_different_typedef',
  'static_non_static',
  'nested_redefinition',
  -- What a function-like macro missing from the preamble degrades into.
  'unexpected_typedef',
  'unexpected_typedef_ident',
  'ref_non_value',
  'missing_type_specifier',
  'expected_lparen_after_type',
  'invalid_storage_class_in_func_decl',
  'typename_invalid_storageclass',
  'expected_member_name_or_semi',
  'expected_member_name_or_semi_objcxx_keyword',
  'typecheck_invalid_operands',
  'typecheck_nonviable_condition',
  'typecheck_nonviable_condition_incomplete',
}

local BUILD_FILES = {
  Makefile = true, makefile = true, GNUmakefile = true,
  ['CMakeLists.txt'] = true, ['build.ninja'] = true,
  Justfile = true, justfile = true,
}
local BUILD_SCRIPT_EXT = { sh = true, zsh = true, bash = true, command = true, bat = true }

local function skipped(path)
  path = path .. '/'
  if path:find('/%.git/') or path:find('%.dSYM/') then return true end
  for _, d in ipairs(SKIP_DIRS) do
    if path:find('/' .. d .. '/', 1, true) then return true end
  end
  return false
end

local function ext_of(name)
  return name:match('%.(%w+)$')
end

local function is_source(name)
  return SRC_EXT[ext_of(name) or ''] == true
end

local function is_header(name)
  return name:match('%.h$') or name:match('%.hh$') or name:match('%.hpp$')
end

-- Build scripts are matched by shape, since per-platform ones (build_mac.sh)
-- have no fixed name.
local function build_file(name)
  if BUILD_FILES[name] or name:match('%.mk$') then return true end
  return BUILD_SCRIPT_EXT[ext_of(name) or ''] == true and name:lower():find('build', 1, true) ~= nil
end

local function file_matches(path, nlines, pats)
  local hits = {}
  for i = 1, #pats do hits[i] = false end
  local ok, lines = pcall(vim.fn.readfile, path, '', nlines)
  for _, line in ipairs(ok and lines or {}) do
    for i, p in ipairs(pats) do
      if not hits[i] and line:find(p) then hits[i] = true end
    end
  end
  return hits
end

-- Detected, never assumed: an ARC backend's `#error requires ARC` is a real
-- error, and -fobjc-arc breaks manual retain/release code.
local function arc_required(root, objc_srcs)
  for name, typ in vim.fs.dir(root) do
    if typ == 'file' and build_file(name) then
      local hits = file_matches(root .. '/' .. name, 500, { '%-fobjc%-arc', 'CLANG_ENABLE_OBJC_ARC' })
      if hits[1] or hits[2] then return true end
    end
  end
  for _, src in ipairs(objc_srcs) do
    local hdr = src:gsub('%.mm?$', '.h')
    if vim.uv.fs_stat(hdr) then
      -- Only a guard that hard-errors without ARC counts, not ARC-aware code.
      local hits = file_matches(hdr, 300, { '__has_feature%s*%(%s*objc_arc', '^%s*#%s*error' })
      if hits[1] and hits[2] then return true end
    end
  end
  return false
end

local function foreign_platform(rel)
  for comp in rel:gmatch('[^/]+') do
    for token in comp:gmatch('[^_%-%.]+') do
      for alt in FOREIGN:gmatch('[^|]+') do
        if token == alt then return true end
      end
    end
  end
  return false
end

local function relpath(root, abs)
  if abs:sub(1, #root + 1) == root .. '/' then return abs:sub(#root + 2) end
  return abs
end

-- <root>/.clangd-include-dirs lists include roots outside the project, one per
-- line: # comments, ~ and $VAR expand, relative paths resolve against the root.
local function extra_include_dirs(root)
  local ok, lines = pcall(vim.fn.readfile, root .. '/.clangd-include-dirs')
  local dirs, seen = {}, {}
  for _, line in ipairs(ok and lines or {}) do
    local s = line:gsub('%s*#.*$', ''):gsub('^%s+', ''):gsub('%s+$', '')
    if s ~= '' then
      s = vim.fn.expand(s)
      if not s:match('^/') then s = root .. '/' .. s end
      s = vim.fs.normalize(s)
      if not seen[s] and vim.uv.fs_stat(s) then
        seen[s] = true
        dirs[#dirs + 1] = s
      end
    end
  end
  return dirs
end

local function add_to_index(index, paths)
  for _, p in ipairs(paths) do
    p = vim.fs.normalize(p)
    local b = vim.fs.basename(p)
    index[b] = index[b] or {}
    table.insert(index[b], p)
  end
end

-- The one indexed path ending in /raw, and the -I base it implies.
local function suffix_lookup(index, raw)
  local matches = {}
  for _, p in ipairs(index[vim.fs.basename(raw)] or {}) do
    if p:sub(-(#raw + 1)) == '/' .. raw then matches[#matches + 1] = p end
  end
  if #matches ~= 1 then return nil end
  return matches[1], matches[1]:sub(1, #matches[1] - #raw - 1)
end

local function scan(root)
  local bases = {}
  for _, b in ipairs(INCLUDE_BASES) do
    local dir = b == '' and root or (root .. '/' .. b)
    if vim.uv.fs_stat(dir) then bases[#bases + 1] = dir end
  end
  -- External roots last, so an in-project header wins.
  vim.list_extend(bases, extra_include_dirs(root))
  local used_bases = {}

  -- Last resorts, indexed on first use: any project header or source by a
  -- unique path suffix, then generated headers under the build roots.
  local header_index, gen_index
  local function resolve(raw, filedir)
    local cand = vim.fs.normalize(vim.fs.joinpath(filedir, raw))
    if vim.uv.fs_stat(cand) then return cand end
    for _, b in ipairs(bases) do
      cand = vim.fs.normalize(vim.fs.joinpath(b, raw))
      if vim.uv.fs_stat(cand) then
        used_bases[b] = true
        return cand
      end
    end
    if not header_index then
      header_index = {}
      add_to_index(header_index, vim.fs.find(function(name, path)
        return (is_header(name) or is_source(name)) and not skipped(path)
      end, { path = root, type = 'file', limit = 1000 }))
    end
    local abs, base = suffix_lookup(header_index, raw)
    if not abs then
      if not gen_index then
        gen_index = {}
        for _, b in ipairs(GENERATED_BASES) do
          local dir = root .. '/' .. b
          if vim.uv.fs_stat(dir) then
            add_to_index(gen_index, vim.fs.find(function(name, path)
              return is_header(name) and not path:find('/%.git/')
            end, { path = dir, type = 'file', limit = 500 }))
          end
        end
      end
      abs, base = suffix_lookup(gen_index, raw)
    end
    if abs then used_bases[base] = true end
    return abs
  end

  local files = vim.fs.find(function(name, path)
    return is_source(name) and not skipped(path)
  end, { path = root, type = 'file', limit = 200 })
  if #files == 0 then
    return nil, 'no .c/.cc/.cpp files found under ' .. root
  end

  -- Includes per file, read lazily so the chain walk can read headers too,
  -- capped at 500 reads. Only the first 300 lines are read, and system
  -- includes after the first #if are platform-gated, so they are skipped.
  local info, reads = {}, 0
  local function load(abs)
    if info[abs] then return info[abs] end
    if reads >= 500 then return nil end
    reads = reads + 1
    local dir = vim.fs.dirname(abs)
    local entry = { incs = {}, src_inc_count = 0 }
    local ok, lines = pcall(vim.fn.readfile, abs, '', 300)
    local saw_cond = false
    for _, line in ipairs(ok and lines or {}) do
      if line:match('^%s*#%s*if') then saw_cond = true end
      for _, pat in ipairs(INCLUDE_PATTERNS) do
        local raw, system = line:match(pat[1]), pat[2]
        if raw then
          if not (system and saw_cond) then
            local is_src = not system and is_source(raw)
            entry.incs[#entry.incs + 1] = {
              raw = raw,
              abs = not system and resolve(raw, dir) or nil,
              is_src = is_src,
              system = system or nil,
            }
            if is_src then entry.src_inc_count = entry.src_inc_count + 1 end
          end
          break
        end
      end
    end
    info[abs] = entry
    return entry
  end

  -- A unity TU includes a source file and is not itself included by one.
  local included = {}
  for i, f in ipairs(files) do
    files[i] = vim.fs.normalize(f)
    local e = load(files[i])
    for _, inc in ipairs(e and e.incs or {}) do
      if inc.is_src and inc.abs then included[inc.abs] = true end
    end
  end
  local tus = {}
  for _, abs in ipairs(files) do
    local e = info[abs]
    if e and e.src_inc_count > 0 and not included[abs] then tus[#tus + 1] = abs end
  end

  -- A unity build that pulls in .m/.mm compiles as Objective-C, and clangd
  -- has to match.
  local objc_unity, objc_srcs = false, {}
  for _, abs in ipairs(files) do
    local ext = ext_of(abs)
    if ext == 'm' or ext == 'mm' then
      objc_srcs[#objc_srcs + 1] = abs
    elseif info[abs] then
      for _, inc in ipairs(info[abs].incs) do
        local ie = inc.is_src and ext_of(inc.raw) or nil
        if ie == 'm' or ie == 'mm' then objc_unity = true end
      end
    end
  end

  local model = {
    root = root, tus = {}, used_bases = used_bases,
    objc_unity = objc_unity, objc_arc = objc_unity and arc_required(root, objc_srcs),
  }

  for _, tu in ipairs(tus) do
    -- chain: the TU's ordered header includes, plus those of every source
    -- aggregate it pulls in, in place. dirs[d]: how much of the chain the
    -- unity build has compiled when it first reaches d, so no dir is fed a
    -- header the real build compiles after it. Paths stay absolute because
    -- clangd resolves flags relative to each file.
    local chain, dedup = {}, {}
    local seen, dirs, collected = {}, {}, {}

    local function claim(abs)
      local d = relpath(root, vim.fs.dirname(abs))
      dirs[d] = math.max(dirs[d] or 0, #chain)
    end

    local function mark(abs, depth)
      claim(abs)
      if depth > 4 or seen[abs] then return end
      seen[abs] = true
      local e = load(abs)
      if not e then return end
      for _, inc in ipairs(e.incs) do
        if inc.abs then mark(inc.abs, depth + 1) end
      end
    end

    local function collect(abs, depth)
      if depth > 4 or collected[abs] then return end
      collected[abs] = true
      seen[abs] = true
      claim(abs)
      local e = load(abs)
      if not e then return end
      for _, inc in ipairs(e.incs) do
        if inc.abs and foreign_platform(relpath(root, inc.abs)) then
          -- Another platform's header never joins this host's preamble.
        elseif not inc.is_src then
          local key = inc.abs or inc.raw
          if not dedup[key] then
            dedup[key] = true
            -- System includes resolve through clang's own search paths.
            chain[#chain + 1] = { path = key, unresolved = not inc.system and inc.abs == nil }
          end
          if inc.abs then mark(inc.abs, depth + 1) end
        elseif inc.abs and load(inc.abs) and info[inc.abs].src_inc_count > 0 then
          collect(inc.abs, depth + 1)
        elseif inc.abs then
          mark(inc.abs, depth + 1)
        end
      end
    end

    collect(tu, 1)
    -- The TU itself compiles under the whole chain.
    dirs[relpath(root, vim.fs.dirname(tu))] = #chain

    model.tus[#model.tus + 1] = {
      abs = tu,
      rel = relpath(root, tu),
      ext = ext_of(tu),
      dirs = dirs,
      seen = seen,
      coverage = vim.tbl_count(seen),
      chain = chain,
    }
  end

  -- Every dir holding a source or header, for the orphan-dir fallback.
  local all_dirs, headers_by_dir = {}, {}
  for _, abs in ipairs(files) do
    all_dirs[relpath(root, vim.fs.dirname(abs))] = true
  end
  local hdrs = vim.fs.find(function(name, path)
    return is_header(name) and not skipped(path)
  end, { path = root, type = 'file', limit = 1000 })
  for _, h in ipairs(hdrs) do
    h = vim.fs.normalize(h)
    local dir = relpath(root, vim.fs.dirname(h))
    all_dirs[dir] = true
    headers_by_dir[dir] = headers_by_dir[dir] or {}
    table.insert(headers_by_dir[dir], h)
  end
  model.all_dirs = all_dirs
  model.headers_by_dir = headers_by_dir
  model.files = files

  -- The primary TU is the widest; ties prefer main.*, then path order.
  table.sort(model.tus, function(a, b)
    if a.coverage ~= b.coverage then return a.coverage > b.coverage end
    local am = vim.fs.basename(a.abs):match('^main%.') and 1 or 0
    local bm = vim.fs.basename(b.abs):match('^main%.') and 1 or 0
    if am ~= bm then return am > bm end
    return a.rel < b.rel
  end)
  return model
end

local function emit_chain(chain, from, out, total)
  if #chain == 0 then return end
  local note = ''
  if total and total > #chain then
    note = (', first %d of %d: the rest compile after this dir'):format(#chain, total)
  end
  out[#out + 1] = '    # Unity preamble from ' .. from .. ' (include order matters' .. note .. ')'
  for _, h in ipairs(chain) do
    out[#out + 1] = '    - -include'
    out[#out + 1] = '    - ' .. h.path .. (h.unresolved and '  # verify path' or '')
  end
end

-- Files directly in dir only: every covered dir is listed on its own, so
-- subtree matching would apply nested chains twice.
local function path_pattern(dir)
  return dir:gsub('%.', '\\.') .. '/[^/]*'
end

local function render(model)
  local primary = model.tus[1]

  local idirs = { '-I' .. model.root }
  for b in pairs(model.used_bases) do
    if b ~= model.root then idirs[#idirs + 1] = '-I' .. b end
  end
  table.sort(idirs)

  -- Standards go in per-extension fragments, never globally: clangd parses a
  -- bare header as Objective-C++, where a C std is an invalid argument.
  local n_c, n_cpp = 0, 0
  for _, tu in ipairs(model.tus) do
    if tu.ext == 'c' or tu.ext == 'm' then n_c = n_c + 1 else n_cpp = n_cpp + 1 end
  end

  local out = {
    '# Generated by :ClangdSetup — unity-build clangd config.',
    '# Paths are absolute on purpose: clangd resolves these flags relative to',
    '# each file being parsed, so relative paths break outside the root dir.',
    '# Re-run :ClangdSetup! after moving the project (or on another machine).',
    'CompileFlags:',
    '  Add:',
  }
  for _, i in ipairs(idirs) do out[#out + 1] = '    - ' .. i end
  vim.list_extend(out, {
    '    - -DDEBUG',
    '    - -ferror-limit=0',
    '    - -w',
    '    - -Wno-error=implicit-function-declaration',
    '    - -Wno-implicit-function-declaration',
    '    - -Wno-error=incompatible-pointer-types',
    '    - -Wno-incompatible-pointer-types',
    'Diagnostics:',
    '  UnusedIncludes: None',
    '  MissingIncludes: None',
    '  ClangTidy:',
    "    Remove: ['*']",
    '  # Real syntax errors still surface; these are unity-build false',
    '  # positives (file parsed standalone, refs resolved by the unity TU).',
    '  Suppress:',
  })
  for _, s in ipairs(SUPPRESS) do out[#out + 1] = '    - ' .. s end
  -- Fragments merge in order, so this later Skip overrides the Build above.
  vim.list_extend(out, {
    'Index:',
    '  Background: Build',
    '---',
    '# Vendored/build trees: excluded from the TU scan, so exclude them from',
    '# the background index too (see SKIP_DIRS in lua/config/clangd_setup.lua).',
    'If:',
    "  PathMatch: ['(.*/)?(" .. table.concat(SKIP_DIRS, '|') .. ")/.*']",
    'Index:',
    '  Background: Skip',
  })

  local function flags_fragment(pathmatch, flags)
    vim.list_extend(out, { '---', 'If:', '  PathMatch: ' .. pathmatch, 'CompileFlags:', '  Add: ' .. flags })
  end

  -- Objective-C mode and ARC mirror the real mac build.
  local objc = model.objc_unity and SYSNAME == 'Darwin'
  local arc = (objc and model.objc_arc) and ', -fobjc-arc' or ''
  flags_fragment('[.*\\.c, .*\\.m]', objc and '[-xobjective-c, -std=c99' .. arc .. ']' or '[-std=c99]')
  flags_fragment('[.*\\.(cpp|cc|cxx|mm)]',
    objc and '[-xobjective-c++, -std=c++17' .. arc .. ']' or '[-std=c++17]')
  -- Headers follow the dominant TU language.
  if n_c >= n_cpp then
    local hdr_lang = objc and '-xobjective-c-header' or '-xc-header'
    flags_fragment('[.*\\.h]', '[' .. hdr_lang .. ', -std=c99' .. arc .. ']')
  else
    flags_fragment('[.*\\.(h|hh|hpp)]',
      objc and '[-xobjective-c++-header, -std=c++17' .. arc .. ']' or '[-std=c++17]')
  end

  vim.list_extend(out, {
    '---',
    '# Foreign-platform sources: cannot compile on this host, silence fully.',
    'If:',
    "  PathMatch: ['(.*/)?([^/]*[_.-])?(" .. FOREIGN .. ")([_.-][^/]*)?(/.*)?']",
    'Diagnostics:',
    "  Suppress: ['*']",
  })

  -- One fragment per TU, scoped to the dirs it covers that no earlier TU
  -- claimed. A chain applied to another TU's subtree causes redefinitions.
  local claimed = {}
  local fragments, collisions = 0, {}

  -- A module-aggregate TU whose includes never reach the primary TU's first
  -- header lacks the base types, so it gets the primary preamble prefixed.
  local base_hdr
  for _, h in ipairs(primary and primary.chain or {}) do
    if primary.seen[h.path] then
      base_hdr = h.path
      break
    end
  end

  -- Headers in dir and each of its parents, sorted.
  local function local_headers(dir)
    local headers, seen, parts = {}, {}, {}
    if dir ~= '.' then
      for p in dir:gmatch('[^/]+') do parts[#parts + 1] = p end
    end
    for i = 1, #parts do
      for _, h in ipairs(model.headers_by_dir[table.concat(parts, '/', 1, i)] or {}) do
        if not seen[h] then
          seen[h] = true
          headers[#headers + 1] = h
        end
      end
    end
    table.sort(headers)
    return headers
  end

  for _, tu in ipairs(model.tus) do
    local frag_dirs = {}
    for d in pairs(tu.dirs) do
      if d ~= '.' and not claimed[d] then
        claimed[d] = true
        frag_dirs[#frag_dirs + 1] = d
      end
    end
    table.sort(frag_dirs)

    local chain, from = tu.chain, tu.rel
    if base_hdr and tu ~= primary and not tu.seen[base_hdr] then
      chain, from = vim.deepcopy(primary.chain), primary.rel .. ' + ' .. tu.rel
      local have = {}
      for _, h in ipairs(chain) do have[h.path] = true end
      local gained = 0
      for _, h in ipairs(tu.chain) do
        if not have[h.path] then
          have[h.path] = true
          chain[#chain + 1] = h
          gained = gained + 1
        end
      end
      -- An aggregate of only sources adds no headers of its own, so its dirs
      -- get their local headers instead.
      if gained == 0 then
        for _, d in ipairs(frag_dirs) do
          for _, h in ipairs(local_headers(d)) do
            if not have[h] then
              have[h] = true
              chain[#chain + 1] = { path = h }
            end
          end
        end
        from = from .. ' + local headers'
      end
    end

    if #frag_dirs == 0 then
      collisions[#collisions + 1] = tu.rel
    elseif #chain > 0 then
      -- Group dirs by chain depth. A merged chain is not this TU's own
      -- include order, so every dir takes all of it.
      local by_depth = {}
      for _, d in ipairs(frag_dirs) do
        local n = chain == tu.chain and tu.dirs[d] or 0
        if n < 1 or n > #chain then n = #chain end
        by_depth[n] = by_depth[n] or {}
        table.insert(by_depth[n], d)
      end
      local depths = vim.tbl_keys(by_depth)
      table.sort(depths)
      for _, n in ipairs(depths) do
        fragments = fragments + 1
        vim.list_extend(out, { '---', 'If:', '  PathMatch:' })
        for _, d in ipairs(by_depth[n]) do out[#out + 1] = '    - ' .. path_pattern(d) end
        vim.list_extend(out, { 'CompileFlags:', '  Add:' })
        emit_chain(vim.list_slice(chain, 1, n), from, out, #chain)
      end
    end
  end

  -- Dirs no TU covers yet get the primary preamble plus their local headers.
  if primary and #primary.chain > 0 then
    local orphans = {}
    for d in pairs(model.all_dirs) do
      if d ~= '.' and not claimed[d] then orphans[#orphans + 1] = d end
    end
    table.sort(orphans)
    local no_local_headers = {}
    for _, d in ipairs(orphans) do
      local headers = local_headers(d)
      if #headers > 0 then
        local chain, seen = vim.deepcopy(primary.chain), {}
        for _, h in ipairs(chain) do seen[h.path] = true end
        for _, h in ipairs(headers) do
          if not seen[h] then
            seen[h] = true
            chain[#chain + 1] = { path = h }
          end
        end
        vim.list_extend(out, {
          '---',
          '# Orphan dir — no unity TU includes this yet; base preamble plus',
          '# local/parent headers so implementation files see module types.',
          'If:',
          '  PathMatch:',
          '    - ' .. path_pattern(d),
          'CompileFlags:',
          '  Add:',
        })
        emit_chain(chain, primary.rel .. ' + ' .. d .. ' headers', out)
      else
        no_local_headers[#no_local_headers + 1] = d
      end
    end
    if #no_local_headers > 0 then
      vim.list_extend(out, {
        '---',
        '# Orphan dirs — no unity TU includes these yet; base preamble so',
        '# their types resolve standalone (a TU claiming them wins on rerun).',
        'If:',
        '  PathMatch:',
      })
      for _, d in ipairs(no_local_headers) do out[#out + 1] = '    - ' .. path_pattern(d) end
      vim.list_extend(out, { 'CompileFlags:', '  Add:' })
      emit_chain(primary.chain, primary.rel, out)
    end
  end

  if #collisions > 0 then
    vim.list_extend(out, {
      '',
      '# TUs sharing dirs with the ones above (multiple TUs here — hand-tune',
      '# with extra If: PathMatch fragments if their subtrees need it):',
    })
    for _, c in ipairs(collisions) do out[#out + 1] = '#   ' .. c end
  end

  return out, {
    tus = #model.tus,
    primary = primary and primary.rel or nil,
    chain_len = primary and #primary.chain or 0,
    fragments = fragments,
    collisions = #collisions,
  }
end

-- One flagless entry per source, since .clangd supplies every flag. Foreign
-- sources are left out so the index never holds a second copy of a function.
local function render_cdb(model)
  local entries = {}
  for _, abs in ipairs(model.files) do
    if not foreign_platform(relpath(model.root, abs)) then entries[#entries + 1] = abs end
  end
  table.sort(entries)
  local out = { '[' }
  for i, abs in ipairs(entries) do
    out[#out + 1] = ('  {"directory": %s, "file": %s, "arguments": ["clang", "-c", %s]}%s')
      :format(vim.json.encode(model.root), vim.json.encode(abs), vim.json.encode(abs),
        i < #entries and ',' or '')
  end
  out[#out + 1] = ']'
  return out, #entries
end

-- Ours is always `clang -c <file>`; anything else came from a build system and
-- carries real flags.
local function build_system_cdb(path)
  if not vim.uv.fs_stat(path) then return false end
  local ok, db = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
  if not ok or type(db) ~= 'table' or type(db[1]) ~= 'table' then return false end
  local args = db[1].arguments
  return not (type(args) == 'table' and #args == 3 and args[1] == 'clang' and args[2] == '-c')
end

function M.generate(opts)
  opts = opts or {}
  -- Default root: the outermost dir holding a build file between the buffer
  -- and the git root, so each subproject of a monorepo gets its own .clangd.
  -- .clangd is a clangd root marker, so it also scopes the LSP root.
  local root
  if opts.dir and opts.dir ~= '' then
    root = vim.fn.fnamemodify(vim.fs.normalize(opts.dir), ':p'):gsub('/$', '')
    if not vim.uv.fs_stat(root) then
      vim.notify('ClangdSetup: no such directory: ' .. root, vim.log.levels.ERROR)
      return
    end
  else
    local git = vim.fs.root(0, '.git')
    local buf_name = vim.api.nvim_buf_get_name(0)
    local build_files = vim.fs.find(build_file, {
      upward = true,
      path = buf_name ~= '' and vim.fs.dirname(buf_name) or vim.fn.getcwd(),
      stop = git and vim.fs.dirname(git) or vim.uv.os_homedir(),
      limit = math.huge,
    })
    root = #build_files > 0 and vim.fs.dirname(build_files[#build_files]) or git or vim.fn.getcwd()
  end
  root = vim.fs.normalize(root)
  local target = root .. '/.clangd'

  if vim.uv.fs_stat(target) and not opts.force then
    vim.notify('.clangd already exists at ' .. root .. ' (use :ClangdSetup! to overwrite)',
      vim.log.levels.WARN)
    return
  end

  local model, err = scan(root)
  if not model then
    vim.notify('ClangdSetup: ' .. err, vim.log.levels.ERROR)
    return
  end

  local lines, summary = render(model)
  vim.fn.writefile(lines, target)

  local cdb = root .. '/compile_commands.json'
  local cdb_msg
  if build_system_cdb(cdb) then
    cdb_msg = '; kept the existing compile_commands.json (a build system writes it, with the real flags)'
  else
    local cdb_lines, cdb_count = render_cdb(model)
    vim.fn.writefile(cdb_lines, cdb)
    cdb_msg = ('; compile_commands.json lists %d source(s) for the background index'):format(cdb_count)
  end

  -- A running clangd has cached "no compilation database" for this root and
  -- will not index until restarted. enable() is a no-op for a live client.
  local running = vim.lsp.get_clients({ name = 'clangd' })
  if #running == 0 then
    vim.lsp.enable('clangd')
  else
    for _, client in ipairs(running) do client:stop() end
    vim.defer_fn(function() vim.lsp.enable('clangd') end, 200)
  end

  local msg
  if summary.tus == 0 then
    msg = ('Wrote %s — no unity TU detected; generic config (add an -include chain by hand)')
      :format(target)
  else
    msg = ('Wrote %s — %d unity TU(s), primary %s (%d -include headers), %d extra fragment(s)%s')
      :format(target, summary.tus, summary.primary, summary.chain_len, summary.fragments,
        summary.collisions > 0 and (', %d TU(s) need hand-tuning (see file comments)')
          :format(summary.collisions) or '')
  end
  vim.notify(msg .. cdb_msg, vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command('ClangdSetup', function(cmd)
    M.generate({ force = cmd.bang, dir = cmd.args })
  end, {
    bang = true,
    nargs = '?',
    complete = 'dir',
    desc = 'Generate a unity-build .clangd + compile_commands.json (arg: subproject dir; default outermost build-file dir, else git root; ! overwrites)',
  })
end

return M
