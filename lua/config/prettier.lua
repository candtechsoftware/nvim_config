-- Prettier for JS/TS buffers, in two halves.
--
-- 1. `apply(bufnr)` — indent options from the project's Prettier config.
--    Prettier's default indent is 2 spaces and lua/config/options.lua's is 4,
--    so a JS/TS buffer in a project with no .editorconfig used to indent at 4
--    and get re-indented to 2 by the next `prettier --write`. `tabWidth` and
--    `useTabs` are read from the nearest config — walking up from the file in
--    the same file-name order Prettier uses — and set on the buffer; with no
--    config at all, Prettier's own defaults are what the buffer gets.
--
-- 2. `format(bufnr)` — run the project's Prettier over the buffer:
--    the `node_modules/.bin/prettier` nearest the file, else one on PATH.
--    `format_buffer` is what <leader>f does: that, then eslint's fixAll.
--
-- Config reading is node-free on purpose (a node start per buffer open is not
-- acceptable). JSON configs — package.json's "prettier" key, .prettierrc,
-- .prettierrc.json — are decoded properly, `overrides` included. YAML, JS and
-- TOML configs are scanned textually for `tabWidth: N` / `useTabs: true`,
-- which covers every flat config in ~/work. A config that is a bare string
-- (`"prettier": "@scope/config"`) cannot be followed here and yields the
-- defaults; :Prettier still formats correctly, the binary resolves it.

local M = {}

local TIMEOUT_MS = 10000

local PRETTIER_DEFAULTS = { tab_width = 2, use_tabs = false }

-- Prettier's per-directory search order. package.json only counts when it
-- has a top-level "prettier" key.
local CONFIG_NAMES = {
  'package.json',
  '.prettierrc', '.prettierrc.json', '.prettierrc.yaml', '.prettierrc.yml',
  '.prettierrc.json5', '.prettierrc.js', '.prettierrc.ts', '.prettierrc.mjs',
  '.prettierrc.mts', '.prettierrc.cjs', '.prettierrc.cts',
  'prettier.config.js', 'prettier.config.ts', 'prettier.config.mjs',
  'prettier.config.mts', 'prettier.config.cjs', 'prettier.config.cts',
  '.prettierrc.toml',
}

---@param path string
---@return string|nil
local function read_file(path)
  local f = io.open(path, 'rb')
  if not f then return nil end
  local text = f:read('*a')
  f:close()
  return text
end

---Turn one config file's text into a Prettier options table.
---@param path string
---@param text string
---@return table|nil options nil means "not a config, keep searching"
local function parse(path, text)
  local base = vim.fs.basename(path)

  if base == 'package.json' then
    local ok, pkg = pcall(vim.json.decode, text)
    if not ok or type(pkg) ~= 'table' or pkg.prettier == nil then return nil end
    return type(pkg.prettier) == 'table' and pkg.prettier or {}
  end

  -- .prettierrc is JSON or YAML; try JSON first and fall through otherwise.
  if base == '.prettierrc' or base == '.prettierrc.json' then
    local ok, cfg = pcall(vim.json.decode, text)
    if ok and type(cfg) == 'table' then return cfg end
  end

  -- Flat textual scan: YAML `tabWidth: 4`, JS `tabWidth: 4,`, TOML
  -- `tabWidth = 4`. Quoted keys ("tabWidth": 4 in JSON5) are matched too.
  local cfg = {}
  local tw = text:match('tabWidth["\']?%s*[:=]%s*(%d+)')
  if tw then cfg.tabWidth = tonumber(tw) end
  local ut = text:match('useTabs["\']?%s*[:=]%s*(%a+)')
  if ut == 'true' or ut == 'false' then cfg.useTabs = (ut == 'true') end
  return cfg
end

---The Prettier config governing `file`.
---@param file string absolute path; need not exist
---@return table|nil options
---@return string|nil dir directory holding the config
local function find_config(file)
  for dir in vim.fs.parents(file) do
    for _, name in ipairs(CONFIG_NAMES) do
      local path = vim.fs.joinpath(dir, name)
      local text = read_file(path)
      if text then
        local cfg = parse(path, text)
        if cfg then return cfg, dir end
      end
    end
  end
  return nil, nil
end

---@param v any
---@return table
local function to_list(v)
  if v == nil then return {} end
  if type(v) == 'table' then return v end
  return { v }
end

---Does `rel` match any of `patterns`? Mirrors Prettier's override matching:
---a pattern without a slash is matched against the basename, one with a
---slash against the path relative to the config's directory.
---@param rel string
---@param patterns table
---@return boolean
local function any_match(rel, patterns)
  local base = vim.fs.basename(rel)
  for _, pat in ipairs(patterns) do
    if type(pat) == 'string' then
      local ok, glob = pcall(vim.glob.to_lpeg, pat)
      local subject = pat:find('/', 1, true) and rel or base
      if ok and glob:match(subject) ~= nil then return true end
    end
  end
  return false
end

---`cfg` with its `overrides` for `rel` merged over it, in order.
---@param cfg table
---@param rel string
---@return table
local function with_overrides(cfg, rel)
  local out = {}
  for k, v in pairs(cfg) do out[k] = v end
  for _, o in ipairs(to_list(cfg.overrides)) do
    if type(o) == 'table' and type(o.options) == 'table'
      and any_match(rel, to_list(o.files))
      and not any_match(rel, to_list(o.excludeFiles))
    then
      for k, v in pairs(o.options) do out[k] = v end
    end
  end
  return out
end

---@param bufnr integer
---@return integer bufnr
local function resolve_bufnr(bufnr)
  return (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
end

---An absolute path standing for the buffer: its name, or a placeholder in
---cwd for an unnamed one so config/binary lookup still walks the project.
---@param bufnr integer
---@return string
local function buf_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= '' then return name end
  return vim.fs.joinpath(vim.uv.cwd() or vim.uv.os_homedir(), 'untitled')
end

---@class PrettierIndent
---@field tab_width integer|nil explicit `tabWidth`; nil when the config leaves it unset
---@field use_tabs boolean|nil explicit `useTabs`; nil when unset
---@field source string|nil directory whose config was used

---Indent-relevant Prettier options for a buffer. Only values the config sets
---explicitly are returned; the caller decides how to fill the gaps.
---@param bufnr integer|nil
---@return PrettierIndent
function M.resolve(bufnr)
  bufnr = resolve_bufnr(bufnr)
  local file = buf_path(bufnr)
  local cfg, dir = find_config(file)
  if not cfg then return {} end

  local rel = vim.fs.relpath(dir, file) or vim.fs.basename(file)
  cfg = with_overrides(cfg, rel)

  local tw = tonumber(cfg.tabWidth)
  return {
    tab_width = (tw and tw > 0) and math.floor(tw) or nil,
    use_tabs = type(cfg.useTabs) == 'boolean' and cfg.useTabs or nil,
    source = dir,
  }
end

---@param bufnr integer
---@param width integer
---@param use_tabs boolean
local function set_indent(bufnr, width, use_tabs)
  local bo = vim.bo[bufnr]
  bo.shiftwidth = width
  bo.tabstop = width
  bo.softtabstop = width
  bo.expandtab = not use_tabs
end

---Set the buffer's indent options from its Prettier config.
---@param bufnr integer|nil
function M.apply(bufnr)
  bufnr = resolve_bufnr(bufnr)
  local ind = M.resolve(bufnr)
  local tw = ind.tab_width or PRETTIER_DEFAULTS.tab_width
  local ut = ind.use_tabs
  if ut == nil then ut = PRETTIER_DEFAULTS.use_tabs end
  set_indent(bufnr, tw, ut)

  -- Neovim's built-in editorconfig runs on BufReadPost, AFTER the ftplugin
  -- this is called from, so an .editorconfig `indent_size` would beat an
  -- explicit `tabWidth` here. Prettier's precedence is the other way round:
  -- its own config wins, and it reads .editorconfig only for what that config
  -- leaves unset. Re-apply the explicit values once the read has settled. The
  -- defaults are deliberately NOT re-applied — with nothing explicit,
  -- editorconfig's value is exactly what Prettier would use too.
  if ind.tab_width == nil and ind.use_tabs == nil then return end
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local bo = vim.bo[bufnr]
    if ind.tab_width then
      bo.shiftwidth, bo.tabstop, bo.softtabstop = ind.tab_width, ind.tab_width, ind.tab_width
    end
    if ind.use_tabs ~= nil then bo.expandtab = not ind.use_tabs end
  end)
end

---The Prettier binary for `file`: the nearest node_modules/.bin/prettier
---above it, else `prettier` on PATH.
---@param file string
---@return string|nil bin
---@return string|nil root the directory holding that node_modules, if any
local function find_bin(file)
  for dir in vim.fs.parents(file) do
    local bin = vim.fs.joinpath(dir, 'node_modules', '.bin', 'prettier')
    if vim.fn.executable(bin) == 1 then return bin, dir end
  end
  if vim.fn.executable('prettier') == 1 then return 'prettier', nil end
  return nil, nil
end

---Run the whole buffer through Prettier and write the result back.
---@param bufnr integer|nil buffer to format (0/nil = current)
---@return boolean ok false if no Prettier was found or it rejected the buffer
function M.format(bufnr)
  bufnr = resolve_bufnr(bufnr)
  local file = buf_path(bufnr)

  local bin, root = find_bin(file)
  if not bin then
    vim.notify(
      'prettier not found: no node_modules/.bin/prettier above ' .. vim.fs.dirname(file)
        .. ' and none on PATH',
      vim.log.levels.WARN
    )
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- --stdin-filepath is what makes Prettier resolve the config, the parser
  -- and .prettierignore for THIS file. .prettierignore itself is looked up
  -- relative to the cwd, not the file, hence cwd = the project root.
  local res = vim.system(
    { bin, '--stdin-filepath', file },
    {
      cwd = root or vim.fs.dirname(file),
      stdin = table.concat(lines, '\n') .. '\n',
      text = true,
    }
  ):wait(TIMEOUT_MS)

  -- A buffer that does not parse is not formatted: Prettier reports the
  -- position on stderr and exits 2. Leave the text alone.
  if res.code ~= 0 or not res.stdout then
    local msg = vim.trim(res.stderr or '')
    vim.notify(msg ~= '' and ('prettier: ' .. msg) or 'prettier failed', vim.log.levels.WARN)
    return false
  end

  local format_buf = require('config.format_buf')
  format_buf.replace(bufnr, lines, format_buf.split_output(res.stdout))
  return true
end

---What <leader>f does in a JS/TS buffer: Prettier when the project has one,
---then eslint's `source.fixAll` when the server is attached. Prettier runs
---synchronously, so the code action sees the formatted text; in an
---eslint-plugin-prettier project (the Expo apps) the eslint step then has
---nothing left to do about layout and only applies its own fixes.
---@param bufnr integer|nil
function M.format_buffer(bufnr)
  bufnr = resolve_bufnr(bufnr)
  local has_prettier = find_bin(buf_path(bufnr)) ~= nil
  if has_prettier then M.format(bufnr) end

  local eslint = vim.lsp.get_clients({ bufnr = bufnr, name = 'eslint' })
  if #eslint > 0 then
    vim.lsp.buf.code_action({
      context = { only = { 'source.fixAll.eslint' }, diagnostics = {} },
      apply = true,
    })
  elseif not has_prettier then
    vim.notify('nothing to format with: no prettier in the project, eslint not attached',
      vim.log.levels.INFO)
  end
end

return M
