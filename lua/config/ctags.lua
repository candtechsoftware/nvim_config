-- ctags-based completion + gd for C/C++/ObjC.
-- Port of ~/.config/emacs/lisp/init-cpp.el — same tags-file path so both
-- editors share one index. Works without compile_commands.json / .clangd.

local M = {}

M.tags_root = '/tmp/nvim-ctags'
M.ctags_args = {
  '-R',
  '--languages=C,C++,ObjectiveC',
  '--fields=+nKzSs',  -- S=signature, s=scope (struct/union/class/enum)
  '--extras=+q',
}

local FT = { c = true, cpp = true, objc = true, objcpp = true }

local ROOT_MARKERS = {
  '.git', 'compile_commands.json', '.clangd', 'build.sh', 'build.bat',
  'Makefile', 'CMakeLists.txt', 'project.4coder',
}

-- Path helpers ---------------------------------------------------------------

local function find_root(start_dir)
  if not start_dir or start_dir == '' then return nil end
  local found = vim.fs.find(ROOT_MARKERS, { path = start_dir, upward = true })
  if not found or #found == 0 then return nil end
  return vim.fs.dirname(found[1])
end

function M.project_root(buf)
  buf = buf or 0
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return nil end
  return find_root(vim.fs.dirname(name))
end

function M.tags_file(root)
  if not root then return nil end
  local abs = vim.fs.normalize(root)
  -- Drop trailing slash; never escape the empty root.
  if #abs > 1 and abs:sub(-1) == '/' then abs = abs:sub(1, -2) end
  local escaped = abs:gsub('/', '%%%%')
  return M.tags_root .. '/' .. escaped .. '/tags'
end

-- Generation -----------------------------------------------------------------

local function ensure_dir(path)
  local dir = vim.fs.dirname(path)
  vim.fn.mkdir(dir, 'p')
end

local function ctags_executable()
  return vim.fn.executable('ctags') == 1
end

local generating = {} -- tags_file -> true while a ctags process is running

-- Detect tags files written without --fields=+S (no signature: tokens).
-- Such files are leftovers from the round-1 args and need regenerating once.
local function tags_file_needs_upgrade(tags)
  local fd = io.open(tags, 'r')
  if not fd then return false end
  local saw_function, saw_signature = false, false
  for _ = 1, 5000 do  -- scan only a slice; signatures appear within seconds
    local line = fd:read('*l')
    if not line then break end
    if line:sub(1, 1) ~= '!' then
      if line:find('kind:function', 1, true) or line:find('\tf\t', 1, true) then
        saw_function = true
        if line:find('signature:', 1, true) then saw_signature = true; break end
      end
    end
  end
  fd:close()
  return saw_function and not saw_signature
end

function M.generate(root, force)
  if not root or not ctags_executable() then return end
  local tags = M.tags_file(root)
  if not tags then return end
  if generating[tags] then return end
  local exists = vim.uv.fs_stat(tags) ~= nil
  if exists and not force and tags_file_needs_upgrade(tags) then
    force = true
  end
  if exists and not force then return end
  ensure_dir(tags)
  generating[tags] = true
  local cmd = { 'ctags' }
  vim.list_extend(cmd, M.ctags_args)
  vim.list_extend(cmd, { '-f', tags, root })
  vim.system(cmd, { cwd = root, text = true }, function()
    generating[tags] = nil
  end)
end

function M.update_file(file, root)
  if not root or not file or not ctags_executable() then return end
  local tags = M.tags_file(root)
  if not tags or not vim.uv.fs_stat(tags) then return end
  local abs_root = vim.fs.normalize(root)
  local abs_file = vim.fs.normalize(file)
  if not vim.startswith(abs_file, abs_root) then return end
  local cmd = { 'ctags' }
  vim.list_extend(cmd, M.ctags_args)
  vim.list_extend(cmd, { '--append=yes', '-f', tags, file })
  vim.system(cmd, { cwd = root, text = true })
end

-- Tag index (mtime-keyed cache) ----------------------------------------------

local cache = {} -- tags_file -> { mtime, by_name, names } (names = sorted name list)

local function parse_extras(rest)
  -- rest is the tab-joined trailing fields. Universal Ctags emits one field
  -- per tab: `line:N`, `kind:X`, `signature:Y`, and a scope field whose
  -- KEY is the scope kind itself, e.g. `struct:AC_Artifact`, `union:Foo`,
  -- `class:Bar`, `enum:Quux`. There's no literal `scope:` prefix.
  local line = rest:match('line:(%d+)')
  local kind = rest:match('kind:([^\t\n]+)')
  local sig  = rest:match('signature:([^\t\n]+)')
  local scope = rest:match('\tstruct:([^\t\n]+)')
       or rest:match('\tunion:([^\t\n]+)')
       or rest:match('\tclass:([^\t\n]+)')
       or rest:match('\tenum:([^\t\n]+)')
       or rest:match('^struct:([^\t\n]+)')
       or rest:match('^union:([^\t\n]+)')
       or rest:match('^class:([^\t\n]+)')
       or rest:match('^enum:([^\t\n]+)')
  return tonumber(line) or 1, kind or '', sig, scope
end

function M.index(tags_file)
  if not tags_file then return nil end
  local stat = vim.uv.fs_stat(tags_file)
  if not stat then return nil end
  local mtime = stat.mtime.sec
  local cached = cache[tags_file]
  if cached and cached.mtime == mtime then return cached.by_name end

  local by_name = {}
  local names = {}
  local fd = io.open(tags_file, 'r')
  if not fd then return nil end
  for line in fd:lines() do
    if line:sub(1, 1) ~= '!' then
      -- Split into fields by tab; need at least name, file, ex-cmd-or-extra.
      local first_tab = line:find('\t', 1, true)
      if first_tab then
        local name = line:sub(1, first_tab - 1)
        local rest1 = line:sub(first_tab + 1)
        local second_tab = rest1:find('\t', 1, true)
        if second_tab then
          local file = rest1:sub(1, second_tab - 1)
          local trailing = rest1:sub(second_tab + 1)
          local lnum, kind, sig, scope = parse_extras(trailing)
          local entries = by_name[name]
          if not entries then
            entries = {}
            by_name[name] = entries
            names[#names + 1] = name
          end
          entries[#entries + 1] = {
            file = file, line = lnum, kind = kind,
            sig = sig, scope = scope,
          }
        end
      end
    end
  end
  fd:close()
  cache[tags_file] = { mtime = mtime, by_name = by_name, names = names }
  return by_name
end

-- Flat sorted-by-insertion name list, for vim.fn.matchfuzzy.
function M.names(tags_file)
  M.index(tags_file)
  local c = cache[tags_file]
  return c and c.names or nil
end

function M.invalidate()
  cache = {}
end

-- Definition lookup ----------------------------------------------------------

function M.find_definitions(symbol, root)
  if not symbol or symbol == '' or not root then return {} end
  local tags = M.tags_file(root)
  local idx = tags and M.index(tags)
  if not idx then return {} end
  local raw = idx[symbol]
  if not raw then return {} end
  local root_abs = vim.fs.normalize(root)
  if root_abs:sub(-1) ~= '/' then root_abs = root_abs .. '/' end
  local out = {}
  for _, e in ipairs(raw) do
    local f = e.file
    local abs
    if f:sub(1, 1) == '/' then
      abs = vim.fs.normalize(f)
    else
      abs = vim.fs.normalize(root_abs .. f)
    end
    if vim.startswith(abs, root_abs) then
      out[#out + 1] = { filename = abs, lnum = e.line, kind = e.kind }
    end
  end
  return out
end

-- Ranking: prefer source files over headers, function definitions over
-- prototypes/macros, and project source over build output. Higher = better.
local KIND_SCORE = {
  ['function']    =  3,
  ['member']      =  2,
  ['field']       =  2,
  ['struct']      =  2,
  ['union']       =  2,
  ['class']       =  2,
  ['typedef']     =  2,
  ['enum']        =  2,
  ['enumerator']  =  2,
  ['variable']    =  1,
  ['macro']       =  0,
  ['prototype']   = -2,
  ['externvar']   = -2,
}

local function score(item)
  local f = item.filename or ''
  local s = KIND_SCORE[item.kind] or 0
  if f:match('%.c$') or f:match('%.cpp$') or f:match('%.cc$')
      or f:match('%.m$') or f:match('%.mm$') then
    s = s + 3
  elseif f:match('%.h$') or f:match('%.hpp$') or f:match('%.hh$') then
    s = s - 1
  end
  if f:match('/build/') or f:match('/dist/') or f:match('/local/') then
    s = s - 5
  end
  return s
end

local function jump(item)
  -- Push current position onto the jumplist so <C-o> returns here.
  vim.cmd("normal! m'")
  vim.cmd('edit ' .. vim.fn.fnameescape(item.filename))
  vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
  vim.cmd('normal! ^')
end

-- Jump to the top-ranked match and always echo the landing location so the
-- user has clear feedback (cross-file jumps are easy to miss otherwise).
local function rank_and_jump(matches)
  table.sort(matches, function(a, b) return score(a) > score(b) end)
  local best = matches[1]
  jump(best)
  local count_chunk = (#matches > 1)
      and ('ctags: %d matches; jumped to '):format(#matches)
      or 'ctags: jumped to '
  vim.api.nvim_echo({
    { count_chunk, 'Comment' },
    { vim.fn.fnamemodify(best.filename, ':.') .. ':' .. best.lnum, 'Directory' },
    { ('  [%s]'):format(best.kind), 'Comment' },
  }, false, {})
end

function M.goto_definition()
  local symbol = vim.fn.expand('<cword>')
  local root = M.project_root()
  local matches = (symbol ~= '' and root) and M.find_definitions(symbol, root) or {}
  if #matches > 0 then
    rank_and_jump(matches)
    return
  end
  -- Fall through to LSP with source-over-header ranking.
  if vim.lsp.buf and vim.lsp.buf.definition then
    vim.lsp.buf.definition({
      on_list = function(opts)
        local items = opts.items or {}
        if #items == 0 then
          vim.notify('No definition for `' .. symbol .. '`',
            vim.log.levels.INFO)
          return
        end
        table.sort(items, function(a, b) return score(a) > score(b) end)
        local best = items[1]
        vim.cmd('edit ' .. vim.fn.fnameescape(best.filename))
        vim.api.nvim_win_set_cursor(0, {
          best.lnum, math.max(0, (best.col or 1) - 1)
        })
      end,
    })
  else
    vim.notify('No tag or LSP definition for `' .. symbol .. '`',
      vim.log.levels.WARN)
  end
end

function M.goto_definition_ctags_only()
  local symbol = vim.fn.expand('<cword>')
  local root = M.project_root()
  local matches = (symbol ~= '' and root) and M.find_definitions(symbol, root) or {}
  if #matches == 0 then
    vim.notify('No ctag for `' .. symbol .. '`', vim.log.levels.WARN)
    return
  end
  rank_and_jump(matches)
end

-- Picker: useful when the top-ranked match isn't the one you want.
function M.pick_definition()
  local symbol = vim.fn.expand('<cword>')
  local root = M.project_root()
  local matches = (symbol ~= '' and root) and M.find_definitions(symbol, root) or {}
  if #matches == 0 then
    vim.notify('No ctag for `' .. symbol .. '`', vim.log.levels.WARN)
    return
  end
  table.sort(matches, function(a, b) return score(a) > score(b) end)
  vim.ui.select(matches, {
    prompt = 'Definition of ' .. symbol .. ':',
    format_item = function(m)
      return ('%s:%d  [%s]'):format(vim.fn.fnamemodify(m.filename, ':.'),
        m.lnum, m.kind)
    end,
  }, function(choice) if choice then jump(choice) end end)
end

-- Omnifunc -------------------------------------------------------------------

-- ctags C kind names that count as struct-member access targets. `m` is the
-- short form of `member`; `f` would be a standalone function, NOT a member.
-- Function-pointer fields in C are tagged `m`.
local MEMBER_KINDS = {
  member = true, field = true, ['m'] = true,
}

-- Map ctags single-letter kinds to readable names. Used in the popup `kind`
-- column so users see `function` / `member` / `macro` instead of `f` / `m`
-- / `d`. Falls back to the original string for unknown kinds.
local KIND_FULL = {
  f = 'function', m = 'member',  v = 'variable', s = 'struct',
  u = 'union',    c = 'class',   t = 'typedef',  e = 'enumerator',
  g = 'enum',     d = 'macro',   p = 'prototype', x = 'externvar',
  l = 'label',    z = 'param',
}

local function readable_kind(k)
  if not k or k == '' then return '' end
  return KIND_FULL[k] or k
end

-- C keywords to exclude from buffer-words and type inference. Anything else
-- starting with an identifier char is a candidate.
local C_KEYWORDS = {
  ['if']=true, ['else']=true, ['for']=true, ['while']=true, ['do']=true,
  ['switch']=true, ['case']=true, ['default']=true, ['break']=true,
  ['continue']=true, ['return']=true, ['goto']=true, ['sizeof']=true,
  ['typedef']=true, ['struct']=true, ['union']=true, ['enum']=true,
  ['const']=true, ['static']=true, ['extern']=true, ['inline']=true,
  ['register']=true, ['volatile']=true, ['restrict']=true, ['auto']=true,
  ['signed']=true, ['unsigned']=true, ['void']=true, ['char']=true,
  ['short']=true, ['int']=true, ['long']=true, ['float']=true,
  ['double']=true, ['_Bool']=true, ['_Atomic']=true, ['_Thread_local']=true,
  ['NULL']=true, ['true']=true, ['false']=true,
}

-- Scan the current buffer above the cursor for a declaration of `varname`.
-- Returns the captured type name on success, or nil if no usable declaration
-- is found. The heuristic recognizes:
--   `Arena *arena;`
--   `Arena *arena = ...;`
--   `Arena arena;`
--   `(Arena *arena, ...)` inside a parameter list
--   `Arena *arena[...]`
-- It deliberately does NOT understand `Foo<Bar>` templates or multi-decl
-- statements like `int a, b, c` past the first identifier.
local function infer_var_type(buf, varname)
  if not varname or varname == '' then return nil end
  if C_KEYWORDS[varname] then return nil end
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local last = math.max(1, cursor_line)
  -- Pull only up to the cursor line; declarations BELOW the cursor don't
  -- shadow earlier ones, and we want the closest preceding one.
  local lines = vim.api.nvim_buf_get_lines(buf, 0, last, false)
  -- Walk backward (closest declaration wins).
  local pat = '([%w_]+)[%s%*]+' .. varname:gsub('([^%w_])', '%%%1')
              .. '[%s%[=,%);]'
  for i = #lines, 1, -1 do
    local ln = lines[i]
    -- Strip leading whitespace and any opening paren (parameter list).
    local hay = ln:gsub('^[%s%(]+', '')
    local typename = hay:match('^' .. pat)
    if typename and not C_KEYWORDS[typename] then
      return typename
    end
    -- Also try a function-parameter form (..., Type *name, ...).
    typename = ln:match('[(,]%s*([%w_]+)[%s%*]+' .. varname:gsub('([^%w_])', '%%%1') .. '[%s%[=,%)]')
    if typename and not C_KEYWORDS[typename] then
      return typename
    end
  end
  return nil
end

-- Collect identifier tokens from the current buffer for the dabbrev fallback.
-- De-duped, length>=3, excludes C keywords. Used to surface local variables
-- and function parameters that ctags doesn't index.
local function buffer_words(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local seen = {}
  local out = {}
  for _, ln in ipairs(lines) do
    for tok in ln:gmatch('[%a_][%w_]+') do
      if #tok >= 3 and not C_KEYWORDS[tok] and not seen[tok] then
        seen[tok] = true
        out[#out + 1] = tok
      end
    end
  end
  return out
end

-- Stash trigger context between findstart and match phases.
local pending_trigger = nil
local pending_var = nil

function M.omnifunc(findstart, base)
  local buf = vim.api.nvim_get_current_buf()
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    -- Detect trigger context: `.` or `->` immediately before the word
    -- (bare `-` does NOT count — that would false-trigger on subtraction).
    local before = line:sub(1, col)
    local arrow = before:match('([%w_]+)%->[%w_]*$')
    local dot = arrow and nil or before:match('([%w_]+)%.[%w_]*$')
    pending_var = arrow or dot
    pending_trigger = (arrow or dot) and 'member' or 'word'
    -- Walk back over [A-Za-z0-9_].
    local i = col
    while i > 0 do
      local c = line:sub(i, i)
      if c:match('[%w_]') then i = i - 1 else break end
    end
    return i
  end

  local root = M.project_root(buf)
  if not root then return {} end
  local tags = M.tags_file(root)
  local idx = tags and M.index(tags)
  local names = tags and M.names(tags)
  if not idx or not names then return {} end

  local trigger = pending_trigger
  local var = pending_var
  pending_trigger, pending_var = nil, nil

  local root_abs = vim.fs.normalize(root)
  if root_abs:sub(-1) ~= '/' then root_abs = root_abs .. '/' end

  -- File-proximity context: same-file > same-dir > rest.
  local cur_file = vim.fs.normalize(vim.api.nvim_buf_get_name(buf) or '')
  local cur_dir
  if cur_file ~= '' then cur_dir = vim.fs.dirname(cur_file) .. '/' end

  local function abs_of(file)
    if file:sub(1, 1) == '/' then return vim.fs.normalize(file) end
    return vim.fs.normalize(root_abs .. file)
  end

  local function proximity(file)
    local abs = abs_of(file)
    if cur_file ~= '' and abs == cur_file then return 100 end
    if cur_dir and vim.startswith(abs, cur_dir) then return 50 end
    return 0
  end

  -- Best-effort type inference for `var->` or `var.`. Only consulted for
  -- ranking — never used to HIDE a member, since the heuristic can miss
  -- (e.g., the var was assigned from a function return, or is a typedef).
  local wanted_scope
  if trigger == 'member' and var then
    wanted_scope = infer_var_type(buf, var)
  end

  -- For a name with several entries, pick the closest-to-buffer one,
  -- preferring members whose scope matches the inferred type.
  local function pick_entry(entries, want_member)
    local best, best_score
    for _, e in ipairs(entries) do
      if (not want_member) or MEMBER_KINDS[e.kind] then
        local s = proximity(e.file)
        if wanted_scope and e.scope == wanted_scope then s = s + 1000 end
        if best_score == nil or s > best_score then
          best, best_score = e, s
        end
      end
    end
    return best, best_score or 0
  end

  -- Fuzzy-filter the flat name list first. `matchfuzzy` returns names
  -- ranked by score; an empty base returns nothing, so handle that case.
  local candidates
  if base == '' then
    candidates = names
  else
    candidates = vim.fn.matchfuzzy(names, base)
  end

  local matches = {}
  local ctags_seen = {}
  local cap = 200
  -- We process every candidate (no early-exit) so the final sort can pick
  -- the top-`cap` items globally rather than from the first 400 alphabetical
  -- hits. For `base=''` with member trigger this means iterating all member
  -- names — ~50ms on a 35k-tag index, acceptable for a Tab keystroke.
  local want_member = trigger == 'member'
  for _, name in ipairs(candidates) do
    -- In member context, skip qualified `Type::member` forms — inserting
    -- those after `a->` would yield `a->Arena::base_pos` which is invalid
    -- C. The plain `base_pos` form (also in the index) covers the case.
    if want_member and name:find('::', 1, true) then goto continue end
    local entries = idx[name]
    if entries then
      local picked, prox = pick_entry(entries, want_member)
      if picked then
        ctags_seen[name] = true
        local relpath = picked.file
        local abs = abs_of(relpath)
        if vim.startswith(abs, root_abs) then
          relpath = abs:sub(#root_abs + 1)
        end
        local menu = picked.sig
            or (picked.scope and ('scope ' .. picked.scope))
            or relpath
        matches[#matches + 1] = {
          word = name,
          abbr = name,
          kind = readable_kind(picked.kind),
          menu = menu,
          info = picked.sig
            and ('%s\n%s:%d'):format(picked.sig, relpath, picked.line)
            or ('%s:%d'):format(relpath, picked.line),
          _prox = prox,
        }
      end
    end
    ::continue::
  end

  -- Buffer-words fallback (dabbrev-like). Only for non-member context —
  -- after `.`/`->` you almost never want a local variable name. Inserted
  -- BEFORE the final sort so a strong prefix-match local can outrank low-
  -- score fuzzy ctags hits.
  if trigger ~= 'member' then
    local words = buffer_words(buf)
    if base ~= '' and #words > 0 then
      local ok, filtered = pcall(vim.fn.matchfuzzy, words, base)
      if ok then words = filtered end
    end
    local added, word_cap = 0, 50
    for _, w in ipairs(words) do
      if not ctags_seen[w] and added < word_cap then
        -- Boost buffer-words that prefix-match the typed base — these are
        -- almost certainly what the user is reaching for (local var/param).
        local prox = (base ~= '' and vim.startswith(w, base)) and 90 or 10
        matches[#matches + 1] = {
          word = w,
          abbr = w,
          kind = 'local',
          menu = '(buffer)',
          _prox = prox,
        }
        added = added + 1
      end
    end
  end

  -- Sort: proximity desc (same-file 100, prefix-match buffer-word 90,
  -- same-dir 50, etc.), then alphabetical. Cap AFTER ranking so the
  -- 200-cap keeps the most relevant items even when matchfuzzy returns
  -- thousands.
  table.sort(matches, function(a, b)
    if a._prox ~= b._prox then return a._prox > b._prox end
    return a.word < b.word
  end)
  if #matches > cap then
    for i = cap + 1, #matches do matches[i] = nil end
  end

  for _, m in ipairs(matches) do m._prox = nil end
  return matches
end

-- Setup ----------------------------------------------------------------------

local function attach_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local ft = vim.bo[buf].filetype
  if not FT[ft] then return end
  local root = M.project_root(buf)
  if not root then return end
  local tags = M.tags_file(root)
  if not tags then return end

  vim.bo[buf].omnifunc = 'v:lua.require("config.ctags").omnifunc'
  vim.bo[buf].tags = tags
  -- Set buffer-local `gd` here (not in LspAttach) so it works even if
  -- clangd hasn't attached or never will (no clangd binary, slow start,
  -- project rejected, etc.). lsp.lua re-sets the same handler on attach,
  -- which is a no-op idempotent overwrite.
  vim.keymap.set('n', 'gd', M.goto_definition,
    { buffer = buf, silent = true, desc = 'ctags-first definition' })
  vim.keymap.set('n', '<leader>gi', M.goto_definition_ctags_only,
    { buffer = buf, silent = true, desc = 'ctags-only definition' })
  M.generate(root, false)
end

function M.setup()
  local grp = vim.api.nvim_create_augroup('config_ctags', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = grp,
    pattern = { 'c', 'cpp', 'objc', 'objcpp' },
    callback = function(args) attach_buffer(args.buf) end,
  })

  -- Reattach omnifunc after LSP attach (LSP sets omnifunc to vim.lsp.omnifunc).
  vim.api.nvim_create_autocmd('LspAttach', {
    group = grp,
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if not FT[ft] then return end
      vim.bo[args.buf].omnifunc = 'v:lua.require("config.ctags").omnifunc'
    end,
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = grp,
    pattern = { '*.c', '*.h', '*.cpp', '*.cc', '*.hpp', '*.hh', '*.m', '*.mm' },
    callback = function(args)
      local root = M.project_root(args.buf)
      if root then M.update_file(args.file, root) end
    end,
  })

  vim.api.nvim_create_user_command('CtagsRegen', function()
    local root = M.project_root()
    if not root then
      vim.notify('No project root', vim.log.levels.WARN); return
    end
    M.invalidate()
    M.generate(root, true)
    vim.notify('Regenerating tags for ' .. root, vim.log.levels.INFO)
  end, { desc = 'Force regenerate ctags for current project' })

  vim.api.nvim_create_user_command('CtagsDebug', function()
    local buf = vim.api.nvim_get_current_buf()
    local root = M.project_root(buf)
    local tags = root and M.tags_file(root)
    local stat = tags and vim.uv.fs_stat(tags)
    local idx = tags and M.index(tags)
    local n = 0
    if idx then for _ in pairs(idx) do n = n + 1 end end
    local word = vim.fn.expand('<cword>')
    local sample = idx and idx[word] or nil
    local lines = {
      'buffer:    ' .. vim.api.nvim_buf_get_name(buf),
      'filetype:  ' .. vim.bo[buf].filetype,
      'omnifunc:  ' .. tostring(vim.bo[buf].omnifunc),
      'tags(buf): ' .. tostring(vim.bo[buf].tags),
      'root:      ' .. tostring(root),
      'tags file: ' .. tostring(tags),
      'tags size: ' .. (stat and stat.size or 'MISSING'),
      'idx names: ' .. n,
      'cword:     ' .. word,
      'cword hits: ' .. (sample and #sample or 0),
    }
    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
  end, { desc = 'Print ctags state for current buffer' })

  -- :CtagsExplain <prefix> — prints the first 20 candidates the omnifunc
  -- would produce for the given prefix, with kind/scope/proximity. Useful
  -- when the popup "doesn't make sense" — shows exactly why each item
  -- ranks where it does.
  vim.api.nvim_create_user_command('CtagsExplain', function(opts)
    local prefix = opts.args or ''
    if prefix == '' then
      vim.notify('usage: :CtagsExplain <prefix>', vim.log.levels.WARN); return
    end
    local buf = vim.api.nvim_get_current_buf()
    local root = M.project_root(buf)
    local tags = root and M.tags_file(root)
    local idx = tags and M.index(tags)
    local names = tags and M.names(tags)
    if not idx or not names then
      vim.notify('No tags index for current buffer', vim.log.levels.WARN); return
    end
    local cands = vim.fn.matchfuzzy(names, prefix)
    local cur_file = vim.fs.normalize(vim.api.nvim_buf_get_name(buf) or '')
    local cur_dir = cur_file ~= '' and (vim.fs.dirname(cur_file) .. '/') or nil
    local root_abs = vim.fs.normalize(root)
    if root_abs:sub(-1) ~= '/' then root_abs = root_abs .. '/' end
    local rows = { ('Top 20 candidates for %q (of %d fuzzy hits):'):format(prefix, #cands) }
    for i = 1, math.min(20, #cands) do
      local name = cands[i]
      local e = idx[name] and idx[name][1]
      if e then
        local abs = e.file:sub(1, 1) == '/' and e.file or (root_abs .. e.file)
        local prox = 0
        if cur_file ~= '' and abs == cur_file then prox = 100
        elseif cur_dir and vim.startswith(abs, cur_dir) then prox = 50 end
        rows[#rows + 1] = ('  %2d. %-30s  kind=%-10s  scope=%-15s  prox=%3d  %s:%d')
          :format(i, name, readable_kind(e.kind), e.scope or '-', prox, e.file, e.line)
      end
    end
    vim.notify(table.concat(rows, '\n'), vim.log.levels.INFO)
  end, { nargs = 1, desc = 'Show top ctags omnifunc candidates for a prefix' })
end

return M
