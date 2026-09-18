-- Treesitter without nvim-treesitter: parsers are cloned and compiled with the
-- system cc into site/parser, their queries copied into site/queries.
local M = {}

local SITE = vim.fn.stdpath('data') .. '/site'

-- Generated headers past this size get no highlighting at all.
local MAX_BYTES = 512 * 1024

local PARSERS = {
  cpp = { url = 'https://github.com/tree-sitter/tree-sitter-cpp', inherits = 'c' },
  rust = { url = 'https://github.com/tree-sitter/tree-sitter-rust' },
  go = { url = 'https://github.com/tree-sitter/tree-sitter-go' },
  javascript = { url = 'https://github.com/tree-sitter/tree-sitter-javascript' },
  typescript = { url = 'https://github.com/tree-sitter/tree-sitter-typescript', location = 'typescript', inherits = 'javascript' },
  tsx = { url = 'https://github.com/tree-sitter/tree-sitter-typescript', location = 'tsx', inherits = 'javascript' },
  json = { url = 'https://github.com/tree-sitter/tree-sitter-json' },
  yaml = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-yaml' },
  toml = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-toml' },
  bash = { url = 'https://github.com/tree-sitter/tree-sitter-bash' },
  glsl = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-glsl' },
  hlsl = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-hlsl' },
  odin = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-odin' },
  zig = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-zig' },
  jai = { url = 'https://github.com/constantitus/tree-sitter-jai' },
  objc = { url = 'https://github.com/tree-sitter-grammars/tree-sitter-objc', inherits = 'c' },
}

local ENSURE_INSTALLED = {
  'cpp', 'rust', 'go', 'javascript', 'typescript', 'tsx',
  'json', 'yaml', 'toml', 'bash', 'glsl', 'hlsl', 'objc',
}

local function installed(lang)
  return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
end

local function copy_queries(repo, dir, lang, inherits)
  local src = vim.fn.isdirectory(dir .. '/queries') == 1 and dir .. '/queries' or repo .. '/queries'
  local dst = SITE .. '/queries/' .. lang
  vim.fn.mkdir(dst, 'p')
  for _, file in ipairs(vim.fn.glob(src .. '/*.scm', false, true)) do
    local lines = vim.fn.readfile(file)
    local name = vim.fs.basename(file)
    -- Some grammars already declare it, and a second line compiles the parent query twice.
    if inherits and name == 'highlights.scm' and not (lines[1] or ''):match('^; inherits:') then
      table.insert(lines, 1, '; inherits: ' .. inherits)
    end
    vim.fn.writefile(lines, dst .. '/' .. name)
  end
end

-- Clone, compile and install each of `langs` in turn, without blocking the editor.
local function install(langs, i)
  i = i or 1
  local lang = langs[i]
  if not lang then return end
  local info = PARSERS[lang]
  if not info then
    vim.notify('Unknown parser: ' .. lang, vim.log.levels.ERROR)
    return install(langs, i + 1)
  end
  local repo = vim.fn.tempname()
  local dir = info.location and (repo .. '/' .. info.location) or repo
  local src = dir .. '/src'

  local function finish(err)
    vim.fn.delete(repo, 'rf')
    if err then
      vim.notify(('Failed to install %s parser: %s'):format(lang, err), vim.log.levels.ERROR)
    else
      vim.treesitter.language.add(lang)
      vim.notify(('Installed %s parser (%d/%d)'):format(lang, i, #langs))
    end
    install(langs, i + 1)
  end

  vim.system({ 'git', 'clone', '--depth', '1', '--filter=blob:none', info.url, repo }, {}, vim.schedule_wrap(function(clone)
    if clone.code ~= 0 or vim.fn.filereadable(src .. '/parser.c') == 0 then
      return finish(clone.code ~= 0 and clone.stderr or 'no src/parser.c')
    end
    local cpp = vim.fn.filereadable(src .. '/scanner.cc') == 1
    local cmd = { cpp and 'c++' or 'cc', '-shared', '-fPIC', '-O2', '-I', src, '-o', SITE .. '/parser/' .. lang .. '.so', src .. '/parser.c' }
    if cpp then
      table.insert(cmd, src .. '/scanner.cc')
    elseif vim.fn.filereadable(src .. '/scanner.c') == 1 then
      table.insert(cmd, src .. '/scanner.c')
    end
    -- macOS needs this to leave tree-sitter's symbols for the host nvim; Linux ld rejects it.
    if vim.fn.has('mac') == 1 then vim.list_extend(cmd, { '-undefined', 'dynamic_lookup' }) end
    vim.fn.mkdir(SITE .. '/parser', 'p')
    vim.system(cmd, {}, vim.schedule_wrap(function(build)
      if build.code ~= 0 then return finish(build.stderr) end
      copy_queries(repo, dir, lang, info.inherits)
      finish(nil)
    end))
  end))
end

local function names()
  local out = vim.tbl_keys(PARSERS)
  table.sort(out)
  return out
end

-- The first buffer of a language compiles its highlights query, which is slow
-- for cpp and objc, so that buffer is drawn first and coloured after.
local started = {}

local function start(buf, lang)
  if started[lang] then
    pcall(vim.treesitter.start, buf)
    return
  end
  started[lang] = true
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.cmd.redraw()
      pcall(vim.treesitter.start, buf)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
      if ev.match == 'zig' then return end
      local buf = ev.buf
      local name = vim.api.nvim_buf_get_name(buf)
      local st = name ~= '' and vim.uv.fs_stat(name)
      local bytes = st and st.size or vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
      if bytes <= MAX_BYTES then
        start(buf, vim.treesitter.language.get_lang(ev.match) or ev.match)
      else
        -- Scheduled, or synload.vim's own FileType handler turns syntax back on.
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then vim.bo[buf].syntax = 'off' end
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function()
      install(vim.tbl_filter(function(lang) return not installed(lang) end, ENSURE_INSTALLED))
    end,
  })

  local cmd = vim.api.nvim_create_user_command
  cmd('TSInstall', function(o) install({ o.args }) end, { nargs = 1, complete = names })
  cmd('TSUpdate', function(o)
    install(o.args ~= '' and { o.args } or ENSURE_INSTALLED)
  end, { nargs = '?', complete = names })
  cmd('TSList', function()
    local lines = vim.tbl_map(function(lang)
      return (installed(lang) and '[x] ' or '[ ] ') .. lang
    end, names())
    vim.notify(table.concat(lines, '\n'))
  end, {})

  vim.keymap.set('n', '<leader>ts', function()
    local ok, parser = pcall(vim.treesitter.get_parser)
    print(('filetype=%s parser=%s'):format(vim.bo.filetype, ok and parser and parser:lang() or 'none'))
  end, { desc = 'Show treesitter parser' })
  vim.keymap.set('n', '<leader>hh', function()
    local captures = vim.treesitter.get_captures_at_cursor(0)
    print(#captures == 0 and 'No captures' or '@' .. table.concat(captures, ' @'))
  end, { desc = 'Show treesitter captures' })
  vim.keymap.set('n', '<leader>hi', '<cmd>Inspect<CR>', { desc = 'Inspect highlight under cursor' })
end

return M
