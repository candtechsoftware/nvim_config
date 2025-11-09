local M = {}

-- Cache for performance
local _cache = {}
local _cache_expiry = {}
local CACHE_TTL = 5000  -- 5 seconds TTL

M.default_markers = {
  'package.json',
  'tsconfig.json',
  'jsconfig.json',
  'Cargo.toml',
  'go.mod',
  'build.jai',
  'first.jai',
  'CMakeLists.txt',
  'Makefile',
  '.project',
  '.root',
  '.git',
}

local function normalize(path)
  if not path or path == '' then
    return nil
  end
  return vim.fs.normalize(path)
end

local function resolve_startpath(startpath)
  if startpath and startpath ~= '' then
    if vim.fn.isdirectory(startpath) == 1 then
      return normalize(startpath)
    end
    return normalize(vim.fs.dirname(startpath))
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= '' then
    return normalize(vim.fs.dirname(bufname))
  end

  return normalize(vim.loop.cwd()) or normalize(vim.fn.getcwd())
end

local function try_git_root(dir)
  if not dir or dir == '' then
    return nil
  end

  local output = vim.fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  if vim.v.shell_error == 0 and output[1] and output[1] ~= '' then
    return normalize(output[1])
  end

  return nil
end

local function find_with_markers(dir, markers, stop)
  if not dir then
    return nil
  end

  local current = dir
  local home = stop or vim.loop.os_homedir()

  while current and current ~= home and current ~= '/' do
    for _, marker in ipairs(markers) do
      local marker_path = current .. '/' .. marker
      if vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1 then
        return current
      end
    end

    local parent = vim.fs.dirname(current)
    if parent == current then
      break
    end
    current = parent
  end

  return nil
end

---Find the best project root for the given path.
---@param opts table|nil
---@return string
function M.find(opts)
  opts = opts or {}
  local markers = opts.markers or M.default_markers
  local stop = opts.stop or vim.loop.os_homedir()
  local startpath = resolve_startpath(opts.startpath)

  -- Create cache key
  local cache_key = startpath .. '|' .. vim.fn.join(markers, ',')
  local now = vim.uv.now()

  -- Check cache first
  if _cache[cache_key] and _cache_expiry[cache_key] and _cache_expiry[cache_key] > now then
    return _cache[cache_key]
  end

  local root = find_with_markers(startpath, markers, stop)
  if root then
    _cache[cache_key] = root
    _cache_expiry[cache_key] = now + CACHE_TTL
    return root
  end

  root = try_git_root(startpath)
  if root then
    _cache[cache_key] = root
    _cache_expiry[cache_key] = now + CACHE_TTL
    return root
  end

  local fallback = startpath
  if opts.fallback_to_initial_cwd and _G.launch_initial_cwd then
    fallback = normalize(_G.launch_initial_cwd)
  end

  if not fallback then
    fallback = normalize(vim.loop.cwd()) or normalize(vim.fn.getcwd())
  end

  _cache[cache_key] = fallback
  _cache_expiry[cache_key] = now + CACHE_TTL
  return fallback
end

-- Clear expired cache entries periodically
vim.defer_fn(function()
  local now = vim.uv.now()
  for key, expiry in pairs(_cache_expiry) do
    if expiry <= now then
      _cache[key] = nil
      _cache_expiry[key] = nil
    end
  end
end, 10000)  -- Clean every 10 seconds

return M
