local M = {}

local _cache = {}
local _cache_expiry = {}
local CACHE_TTL = 5000

M.default_markers = {
  'package.json', 'tsconfig.json', 'jsconfig.json',
  'Cargo.toml', 'go.mod',
  'build.jai', 'first.jai', 'launch.json',
  'CMakeLists.txt', 'Makefile',
  '.project', '.root', '.git',
}

local function resolve_startpath(startpath)
  if startpath and startpath ~= '' then
    if vim.fn.isdirectory(startpath) == 1 then
      return vim.fs.normalize(startpath)
    end
    return vim.fs.normalize(vim.fs.dirname(startpath))
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= '' then
    return vim.fs.normalize(vim.fs.dirname(bufname))
  end

  return vim.fs.normalize(vim.uv.cwd()) or vim.fs.normalize(vim.fn.getcwd())
end

---Find the best project root for the given path.
---@param opts table|nil
---@return string
function M.find(opts)
  opts = opts or {}
  local markers = opts.markers or M.default_markers
  local startpath = resolve_startpath(opts.startpath)

  local cache_key = startpath .. '|' .. table.concat(markers, ',')
  local now = vim.uv.now()

  if _cache[cache_key] and _cache_expiry[cache_key] and _cache_expiry[cache_key] > now then
    return _cache[cache_key]
  end

  -- vim.fs.root walks up from path looking for markers (0.10+)
  local root = vim.fs.root(startpath, markers)

  if not root then
    -- Git fallback
    local out = vim.system({ 'git', '-C', startpath, 'rev-parse', '--show-toplevel' }):wait()
    if out.code == 0 and out.stdout and out.stdout ~= '' then
      root = vim.fs.normalize(vim.trim(out.stdout))
    end
  end

  if not root then
    if opts.fallback_to_initial_cwd and _G.launch_initial_cwd then
      root = vim.fs.normalize(_G.launch_initial_cwd)
    else
      root = startpath or vim.fs.normalize(vim.uv.cwd()) or vim.fs.normalize(vim.fn.getcwd())
    end
  end

  _cache[cache_key] = root
  _cache_expiry[cache_key] = now + CACHE_TTL
  return root
end

return M
