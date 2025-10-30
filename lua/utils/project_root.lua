local M = {}

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

  local root = find_with_markers(startpath, markers, stop)
  if root then
    return root
  end

  root = try_git_root(startpath)
  if root then
    return root
  end

  if opts.fallback_to_initial_cwd and _G.launch_initial_cwd then
    return normalize(_G.launch_initial_cwd)
  end

  return startpath or (normalize(vim.loop.cwd()) or normalize(vim.fn.getcwd()))
end

return M
