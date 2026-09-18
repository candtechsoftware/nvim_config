-- Formatting is manual (<leader>f) and runs plain binaries, so it works with
-- no server attached: odinfmt for Odin, Prettier then eslint's fixAll for JS/TS.
local M = {}

local JS = { javascript = true, javascriptreact = true, typescript = true, typescriptreact = true }

-- Prettier's per-directory search order. package.json counts only with a "prettier" key.
local PRETTIER_CONFIGS = {
  'package.json',
  '.prettierrc', '.prettierrc.json', '.prettierrc.yaml', '.prettierrc.yml',
  '.prettierrc.json5', '.prettierrc.js', '.prettierrc.ts', '.prettierrc.mjs',
  '.prettierrc.mts', '.prettierrc.cjs', '.prettierrc.cts',
  'prettier.config.js', 'prettier.config.ts', 'prettier.config.mjs',
  'prettier.config.mts', 'prettier.config.cjs', 'prettier.config.cts',
  '.prettierrc.toml',
}

local function buf_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= '' and name or vim.fs.joinpath(vim.uv.cwd(), 'untitled')
end

-- Pipe the buffer through `cmd` and swap in the output, keeping the view. A
-- tool that rejects the buffer (it does not parse) leaves it untouched.
local function run(buf, name, cmd, cwd)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local res = vim.system(cmd, { cwd = cwd, stdin = table.concat(lines, '\n') .. '\n', text = true }):wait(10000)
  if res.code ~= 0 then
    local msg = vim.trim(res.stderr or '')
    vim.notify(name .. ': ' .. (msg ~= '' and msg or 'failed'), vim.log.levels.WARN)
    return
  end
  local formatted = vim.split((res.stdout:gsub('\r\n', '\n')), '\n', { plain = true })
  while formatted[#formatted] == '' do
    table.remove(formatted)
  end
  if vim.deep_equal(lines, formatted) then return end
  local view = vim.api.nvim_get_current_buf() == buf and vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
  if view then
    view.lnum = math.min(view.lnum, math.max(#formatted, 1))
    vim.fn.winrestview(view)
  end
end

function M.odin(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if vim.fn.executable('odinfmt') == 0 then
    vim.notify('odinfmt not on PATH; build it with ~/gits/ols/odinfmt.sh', vim.log.levels.WARN)
    return
  end
  -- odinfmt finds odinfmt.json upward from -path, which defaults to cwd.
  run(buf, 'odinfmt', { 'odinfmt', '-path:' .. vim.fs.dirname(buf_path(buf)), '-stdin' })
end

-- The nearest node_modules/.bin/prettier, else one on PATH.
local function prettier_bin(file)
  for dir in vim.fs.parents(file) do
    local bin = vim.fs.joinpath(dir, 'node_modules', '.bin', 'prettier')
    if vim.fn.executable(bin) == 1 then return bin, dir end
  end
  if vim.fn.executable('prettier') == 1 then return 'prettier', nil end
end

function M.prettier(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local file = buf_path(buf)
  local bin, root = prettier_bin(file)
  if not bin then
    vim.notify('prettier: none in node_modules above ' .. vim.fs.dirname(file) .. ' or on PATH', vim.log.levels.WARN)
    return
  end
  -- --stdin-filepath resolves the config and parser for this file; .prettierignore is read from cwd.
  run(buf, 'prettier', { bin, '--stdin-filepath', file }, root or vim.fs.dirname(file))
end

function M.buffer(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft == 'odin' then
    M.odin(buf)
  elseif JS[ft] then
    local has_prettier = prettier_bin(buf_path(buf)) ~= nil
    if has_prettier then M.prettier(buf) end
    if #vim.lsp.get_clients({ bufnr = buf, name = 'eslint' }) > 0 then
      vim.lsp.buf.code_action({ context = { only = { 'source.fixAll.eslint' }, diagnostics = {} }, apply = true })
    elseif not has_prettier then
      vim.notify('nothing to format with: no prettier in the project, eslint not attached')
    end
  end
end

-- One config file's options, or nil if it is not a Prettier config. JSON is
-- decoded; YAML, JS and TOML are scanned for a flat tabWidth/useTabs.
local function parse_config(path)
  local f = io.open(path, 'rb')
  if not f then return end
  local text = f:read('*a')
  f:close()
  local base = vim.fs.basename(path)
  if base == 'package.json' then
    local ok, pkg = pcall(vim.json.decode, text)
    if not ok or type(pkg) ~= 'table' or pkg.prettier == nil then return end
    return type(pkg.prettier) == 'table' and pkg.prettier or {}
  end
  if base == '.prettierrc' or base == '.prettierrc.json' then
    local ok, cfg = pcall(vim.json.decode, text)
    if ok and type(cfg) == 'table' then return cfg end
  end
  local cfg = { tabWidth = tonumber(text:match('tabWidth["\']?%s*[:=]%s*(%d+)')) }
  local tabs = text:match('useTabs["\']?%s*[:=]%s*(%a+)')
  if tabs == 'true' or tabs == 'false' then cfg.useTabs = tabs == 'true' end
  return cfg
end

-- Prettier's override matching: a pattern without a slash matches the basename.
local function matches_any(rel, patterns)
  for _, pat in ipairs(type(patterns) == 'table' and patterns or { patterns }) do
    if type(pat) == 'string' then
      local ok, glob = pcall(vim.glob.to_lpeg, pat)
      if ok and glob:match(pat:find('/', 1, true) and rel or vim.fs.basename(rel)) then return true end
    end
  end
  return false
end

-- tabWidth and useTabs from the Prettier config governing `file`, nil where it leaves them unset.
local function prettier_indent(file)
  for dir in vim.fs.parents(file) do
    for _, name in ipairs(PRETTIER_CONFIGS) do
      local cfg = parse_config(vim.fs.joinpath(dir, name))
      if cfg then
        local rel = vim.fs.relpath(dir, file) or vim.fs.basename(file)
        local opts = cfg
        for _, o in ipairs(type(cfg.overrides) == 'table' and cfg.overrides or {}) do
          if type(o) == 'table' and type(o.options) == 'table'
            and matches_any(rel, o.files) and not matches_any(rel, o.excludeFiles) then
            opts = vim.tbl_extend('force', opts, o.options)
          end
        end
        local width = tonumber(opts.tabWidth)
        local tabs = nil
        if type(opts.useTabs) == 'boolean' then tabs = opts.useTabs end
        return (width and width > 0) and math.floor(width) or nil, tabs
      end
    end
  end
end

-- Indent from the project's Prettier config, Prettier's defaults (2 spaces) where it is silent.
function M.apply_prettier_indent(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local width, tabs = prettier_indent(buf_path(buf))
  local function set(w, t)
    local bo = vim.bo[buf]
    if w then bo.shiftwidth, bo.tabstop, bo.softtabstop = w, w, w end
    if t ~= nil then bo.expandtab = not t end
  end
  set(width or 2, tabs == true)
  -- editorconfig is applied after ftplugins, but an explicit Prettier value beats it.
  if width or tabs ~= nil then
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then set(width, tabs) end
    end)
  end
end

return M
