-- :ClangdSetup — bootstrap clangd for a unity-build project with ONE file.
--
-- Unity builds have no compile_commands.json and member files don't compile
-- standalone, so clangd needs to be told the preamble each file is compiled
-- under. This command scans the project for unity translation units (sources
-- that #include other .c/.cpp files), turns each TU's ordered header includes
-- into an `-include` chain, and writes a multi-fragment .clangd at the project
-- root (global fragment = primary TU; `If: PathMatch` fragments for the other
-- TU subtrees). Diagnostics keep real syntax errors but suppress the
-- undeclared/unknown-type family that is pure unity false-positive noise.
--
-- :ClangdSetup! overwrites an existing .clangd.

local M = {}

local SRC_EXT = { c = true, cc = true, cpp = true, cxx = true, m = true, mm = true }
local SKIP_DIRS = {
  'build', 'bin', 'out', 'dist',
  'third_party', 'thirdparty', 'vendor', 'node_modules',
}

-- Diagnostics that fire on every unity member file parsed standalone even
-- with a good -include chain (out-of-order refs, partial preambles). Names
-- verified against clang 22 Diagnostic*.inc — `implicit_function_declaration`
-- no longer exists, it's `implicit_function_decl_c99` now.
local SUPPRESS = {
  'implicit_function_decl_c99',
  'implicit_function_decl',
  'implicit-function-declaration',
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
  -- Redefinitions: unity members re-included across preamble fragments, or
  -- aggregates without include guards. The real build catches true dupes.
  'redefinition',
  'redefinition_different_kind',
  'redefinition_different_typedef',
  'static_non_static',
  'nested_redefinition',
  -- Function-like macros defined in unity .cpp members (4coder-style
  -- push_array etc.) parse as identifiers when the macro isn't in the
  -- preamble; these are what that failure mode degrades into.
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

---@param path string directory path (with or without trailing slash)
---@return boolean
local function skipped(path)
  path = path .. '/'
  if path:find('/%.git/') or path:find('%.dSYM/') then return true end
  for _, d in ipairs(SKIP_DIRS) do
    if path:find('/' .. d .. '/', 1, true) then return true end
  end
  return false
end

---@param name string
---@return string|nil
local function ext_of(name)
  return name:match('%.(%w+)$')
end

---#include/#import directives from the first 300 lines of a file.
---System (<...>) includes matter for chain ORDER: in the real unity TU,
---framework headers are parsed before the project's macros exist; a chain
---that -includes macro headers first makes clang parse Apple/system headers
---with those macros active (e.g. 4coder's `internal` colliding with
---framework identifiers). System includes after the first preprocessor
---conditional are skipped — those are platform-gated and the parser doesn't
---evaluate conditions.
---@param path string
---@return {raw:string, is_src:boolean, system:boolean|nil}[]
local function parse_includes(path)
  local ok, lines = pcall(vim.fn.readfile, path, '', 300)
  if not ok then return {} end
  local incs, saw_cond = {}, false
  for _, line in ipairs(lines) do
    if line:match('^%s*#%s*if') then saw_cond = true end
    local raw = line:match('^%s*#%s*include%s+"([^"]+)"')
      or line:match('^%s*#%s*import%s+"([^"]+)"')
    if raw then
      local e = ext_of(raw)
      incs[#incs + 1] = { raw = raw, is_src = (e ~= nil and SRC_EXT[e]) or false }
    else
      local sys = line:match('^%s*#%s*include%s+<([^>]+)>')
        or line:match('^%s*#%s*import%s+<([^>]+)>')
      if sys and not saw_cond then
        incs[#incs + 1] = { raw = sys, is_src = false, system = true }
      end
    end
  end
  return incs
end

---@param root string
---@param abs string
---@return string path relative to root when under it, else the absolute path
local function relpath(root, abs)
  if abs:sub(1, #root + 1) == root .. '/' then
    return abs:sub(#root + 2)
  end
  return abs
end

---Build the project model: scan sources, resolve includes, find unity TUs.
---@param root string
---@return table|nil model, string|nil err
local function scan(root)
  -- Include resolver: quoted includes resolve against the includer's dir
  -- first (no -I needed), then against candidate -I bases. A base that
  -- actually resolves something is recorded so it ends up as a -I flag.
  local bases = {}
  for _, b in ipairs({ root, root .. '/src', root .. '/include', root .. '/code' }) do
    if vim.uv.fs_stat(b) then bases[#bases + 1] = b end
  end
  local used_bases = {}

  -- Last-resort resolver: index every header in the project by basename and
  -- accept a unique suffix match (e.g. `4coder_base_types.h` -> code/custom/).
  -- The implied base dir becomes a -I flag so sibling includes resolve too.
  local header_index
  local function header_lookup(raw)
    if not header_index then
      header_index = {}
      local hdrs = vim.fs.find(function(name, path)
        return (name:match('%.h$') or name:match('%.hh$') or name:match('%.hpp$'))
          and not skipped(path)
      end, { path = root, type = 'file', limit = 1000 })
      for _, h in ipairs(hdrs) do
        h = vim.fs.normalize(h)
        local b = vim.fs.basename(h)
        header_index[b] = header_index[b] or {}
        table.insert(header_index[b], h)
      end
    end
    local cands = header_index[vim.fs.basename(raw)] or {}
    local matches = {}
    for _, h in ipairs(cands) do
      if h:sub(-(#raw + 1)) == '/' .. raw then matches[#matches + 1] = h end
    end
    if #matches ~= 1 then return nil end
    return matches[1], matches[1]:sub(1, #matches[1] - #raw - 1)
  end

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
    local abs, base = header_lookup(raw)
    if abs then
      used_bases[base] = true
      return abs
    end
    return nil
  end

  local files = vim.fs.find(function(name, path)
    local e = ext_of(name)
    return (e ~= nil and SRC_EXT[e]) and not skipped(path)
  end, { path = root, type = 'file', limit = 200 })
  if #files == 0 then
    return nil, 'no .c/.cc/.cpp files found under ' .. root
  end

  -- info[abs] = { incs = {raw, abs, is_src}[], src_inc_count = n }
  -- Lazily loaded so the transitive walk can read headers too, capped at 500
  -- file reads total to stay bounded on huge trees.
  local info, reads = {}, 0
  local function load(abs)
    if info[abs] then return info[abs] end
    if reads >= 500 then return nil end
    reads = reads + 1
    local dir = vim.fs.dirname(abs)
    local entry = { incs = {}, src_inc_count = 0 }
    for _, inc in ipairs(parse_includes(abs)) do
      entry.incs[#entry.incs + 1] = {
        raw = inc.raw,
        abs = (not inc.system) and resolve(inc.raw, dir) or nil,
        is_src = inc.is_src,
        system = inc.system,
      }
      if inc.is_src then entry.src_inc_count = entry.src_inc_count + 1 end
    end
    info[abs] = entry
    return entry
  end

  -- A file is a unity TU if it includes >=1 source file and is not itself
  -- included by another file (filters nested unity files like base_inc.c).
  local included = {}
  for i, f in ipairs(files) do
    files[i] = vim.fs.normalize(f)
    local e = load(files[i])
    if e then
      for _, inc in ipairs(e.incs) do
        if inc.is_src and inc.abs then included[inc.abs] = true end
      end
    end
  end
  local tus = {}
  for _, abs in ipairs(files) do
    local e = info[abs]
    if e and e.src_inc_count > 0 and not included[abs] then
      tus[#tus + 1] = abs
    end
  end

  -- Does a C/C++ file pull a .m/.mm into the unity build? Then the real
  -- build compiles those TUs as Objective-C (the_std passes -ObjC on mac)
  -- and clangd must match, or `#error requires Objective-C` guards fire.
  local objc_unity = false
  for _, abs in ipairs(files) do
    local e, self_ext = info[abs], ext_of(abs)
    if e and self_ext ~= 'm' and self_ext ~= 'mm' then
      for _, inc in ipairs(e.incs) do
        local ie = inc.is_src and ext_of(inc.raw) or nil
        if ie == 'm' or ie == 'mm' then objc_unity = true end
      end
    end
  end

  -- Per-TU: transitive coverage (which dirs its build touches, depth<=4) and
  -- the -include chain (the TU's own ordered quoted headers — exactly the
  -- preamble its member files are compiled under).
  local model = { root = root, tus = {}, used_bases = used_bases, objc_unity = objc_unity }
  for _, tu in ipairs(tus) do
    local seen, dirs = {}, {}
    local function walk(abs, depth)
      if depth > 4 or seen[abs] then return end
      seen[abs] = true
      dirs[relpath(root, vim.fs.dirname(abs))] = true
      local e = load(abs)
      if not e then return end
      for _, inc in ipairs(e.incs) do
        if inc.abs then walk(inc.abs, depth + 1) end
      end
    end
    walk(tu, 1)

    -- The TU's ordered header includes are the preamble its member files
    -- compile under. A TU whose first include is itself a source aggregate
    -- (e.g. 4coder_default_bindings.cpp -> 4coder_default_include.cpp)
    -- has no direct headers, so take the preamble from that aggregate.
    local top = {}
    for _, inc in ipairs(info[tu].incs) do
      if not inc.is_src then top[#top + 1] = inc end
    end
    if #top == 0 then
      for _, inc in ipairs(info[tu].incs) do
        if inc.is_src and inc.abs and load(inc.abs) then
          for _, sub in ipairs(info[inc.abs].incs) do
            if not sub.is_src then top[#top + 1] = sub end
          end
          break
        end
      end
    end

    -- clangd resolves fallback-command flags relative to each FILE's
    -- directory, not the .clangd location, so relative -include/-I paths
    -- silently fail for any file outside the root dir. Emit absolute paths.
    local chain, dedup = {}, {}
    for _, inc in ipairs(top) do
      local key = inc.abs or inc.raw
      if not dedup[key] then
        dedup[key] = true
        -- System entries stay as-is; -include resolves them through the
        -- normal header/framework search (Cocoa/Cocoa.h etc. just work).
        chain[#chain + 1] = {
          path = key,
          unresolved = not inc.system and inc.abs == nil,
        }
      end
    end

    model.tus[#model.tus + 1] = {
      abs = tu,
      rel = relpath(root, tu),
      ext = ext_of(tu),
      dirs = dirs,
      coverage = vim.tbl_count(seen),
      chain = chain,
    }
  end

  -- Primary TU = widest coverage; ties prefer main.* then stable path order.
  table.sort(model.tus, function(a, b)
    if a.coverage ~= b.coverage then return a.coverage > b.coverage end
    local am = vim.fs.basename(a.abs):match('^main%.') and 1 or 0
    local bm = vim.fs.basename(b.abs):match('^main%.') and 1 or 0
    if am ~= bm then return am > bm end
    return a.rel < b.rel
  end)
  return model
end

---@param chain {path:string, unresolved:boolean}[]
---@param from string TU the chain came from (for the comment)
---@param out string[]
local function emit_chain(chain, from, out)
  if #chain == 0 then return end
  out[#out + 1] = '    # Unity preamble from ' .. from .. ' (include order matters)'
  for _, h in ipairs(chain) do
    out[#out + 1] = '    - -include'
    out[#out + 1] = '    - ' .. h.path .. (h.unresolved and '  # verify path' or '')
  end
end

---@param dir string project-relative dir
---@return string clangd PathMatch regex for files DIRECTLY in dir (coverage
---enumerates every dir explicitly, so subtree matching would double-apply
---chains wherever TU claims nest, e.g. code/.* vs code/custom/.*)
local function path_pattern(dir)
  return dir:gsub('%.', '\\.') .. '/[^/]*'
end

---Render the .clangd content for a scanned model.
---@param model table
---@return string[] lines, table summary
local function render(model)
  local primary = model.tus[1]

  -- -I dirs: project root always, plus any base dir that resolved includes.
  -- Absolute, for the same reason as the -include chain above.
  local idirs = { '-I' .. model.root }
  for b in pairs(model.used_bases) do
    if b ~= model.root then idirs[#idirs + 1] = '-I' .. b end
  end
  table.sort(idirs)

  -- Language standards are NEVER global: clangd parses standalone headers
  -- as Objective-C++, where a C std is an invalid argument ("-std=c99 not
  -- allowed with Objective-C++" on every .h). Stds are emitted as
  -- per-extension fragments below; headers follow the dominant TU language.
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
    '    - -w',  -- errors only; pedantic warnings are noise in unity members
    '    - -Wno-error=implicit-function-declaration',
    '    - -Wno-implicit-function-declaration',
    '    - -Wno-error=incompatible-pointer-types',
    '    - -Wno-incompatible-pointer-types',
  })
  vim.list_extend(out, {
    '  Remove:',
    '    - -Werror*',
    '    - -Wall',
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
  vim.list_extend(out, {
    'Index:',
    '  Background: Build',
  })

  -- Per-extension language standards (see comment above on why not global).
  -- -ObjC mirrors the real build when the unity TU pulls in .m files: the C
  -- sources must parse as Objective-C or their `#error requires
  -- Objective-C` guards fire.
  local c_flags = model.objc_unity and '[-std=c99, -ObjC]' or '[-std=c99]'
  vim.list_extend(out, {
    '---',
    'If:',
    '  PathMatch: [.*\\.c, .*\\.m]',
    'CompileFlags:',
    '  Add: ' .. c_flags,
    '---',
    'If:',
    '  PathMatch: [.*\\.(cpp|cc|cxx|mm)]',
    'CompileFlags:',
    '  Add: [-std=c++17]',
  })
  if n_c >= n_cpp then
    -- C project: force headers to C (ObjC when the unity build is ObjC),
    -- else clangd's ObjC++ header mode rejects C-isms (and a C std would
    -- be an invalid argument).
    local hdr_lang = model.objc_unity and '-xobjective-c-header' or '-xc-header'
    vim.list_extend(out, {
      '---',
      'If:',
      '  PathMatch: [.*\\.h]',
      'CompileFlags:',
      '  Add: [' .. hdr_lang .. ', -std=c99]',
    })
  else
    -- C++ project: keep clangd's permissive ObjC++ header mode (some
    -- platform headers may hold ObjC), just pin the C++ std (valid there).
    vim.list_extend(out, {
      '---',
      'If:',
      '  PathMatch: [.*\\.(h|hh|hpp)]',
      'CompileFlags:',
      '  Add: [-std=c++17]',
    })
  end

  -- Sources for OTHER platforms can never compile on this host (their
  -- system headers don't exist here); every diagnostic in them is noise.
  local sysname = vim.uv.os_uname().sysname
  local foreign
  if sysname == 'Darwin' then
    foreign = 'win32|windows|linux|wayland|x11'
  elseif sysname == 'Linux' then
    foreign = 'win32|windows|mac|macos|darwin|cocoa|metal'
  else
    foreign = 'mac|macos|darwin|cocoa|metal|linux|wayland|x11'
  end
  vim.list_extend(out, {
    '---',
    '# Foreign-platform sources: cannot compile on this host, silence fully.',
    'If:',
    "  PathMatch: ['(.*/)?[^/]*(" .. foreign .. ")[^/]*(/.*)?']",
    'Diagnostics:',
    "  Suppress: ['*']",
  })

  -- One PathMatch fragment per TU (primary included), scoped to the dirs
  -- that TU covers and no earlier TU claimed. Chains are never global:
  -- applying one TU's preamble to another TU's subtree is what produces
  -- "redefinition of X" noise (e.g. an app-layer chain stacked onto
  -- platform-layer .mm files).
  local claimed = {}
  local fragments, collisions = 0, {}
  for i = 1, #model.tus do
    local tu = model.tus[i]
    local frag_dirs = {}
    for d in pairs(tu.dirs) do
      if d ~= '.' and not claimed[d] then
        claimed[d] = true
        frag_dirs[#frag_dirs + 1] = d
      end
    end
    table.sort(frag_dirs)
    if #frag_dirs == 0 then
      collisions[#collisions + 1] = tu.rel
    elseif #tu.chain > 0 then
      fragments = fragments + 1
      vim.list_extend(out, { '---', 'If:', '  PathMatch:' })
      for _, d in ipairs(frag_dirs) do
        out[#out + 1] = '    - ' .. path_pattern(d)
      end
      vim.list_extend(out, { 'CompileFlags:', '  Add:' })
      emit_chain(tu.chain, tu.rel, out)
    end
  end
  if #collisions > 0 then
    out[#out + 1] = ''
    out[#out + 1] = '# TUs sharing dirs with the ones above (multiple TUs here — hand-tune'
    out[#out + 1] = '# with extra If: PathMatch fragments if their subtrees need it):'
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

---@param opts? {force?: boolean}
function M.generate(opts)
  opts = opts or {}
  local root = vim.fs.root(0, '.git') or vim.fs.normalize(vim.fn.getcwd())
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

  -- Re-running enable() re-fires activation on open buffers, so clangd
  -- attaches to this buffer without :edit.
  vim.lsp.enable('clangd')

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
  vim.notify(msg, vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command('ClangdSetup', function(cmd)
    M.generate({ force = cmd.bang })
  end, {
    bang = true,
    desc = 'Generate a unity-build .clangd at the project root (! overwrites)',
  })
end

return M
