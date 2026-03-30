local M = {}

local home = vim.fs.normalize(vim.uv.os_homedir())

M.markers = {
  'package.json', 'tsconfig.json', 'jsconfig.json',
  'Cargo.toml', 'go.mod',
  'build.jai', 'first.jai', 'launch.json',
  'CMakeLists.txt', 'Makefile',
  '.project', '.root', '.git',
}

---Find the project root from the current buffer.
---Uses vim.fs.root(0, fn) which resolves from buffer path, falling back to cwd for unnamed buffers.
---@param opts table|nil
---@return string
function M.find(opts)
  opts = opts or {}
  local markers = opts.markers or M.markers

  -- vim.fs.root(0, fn): resolves from current buffer, falls back to cwd for unnamed/special buffers
  local root = vim.fs.root(0, function(name, path)
    if vim.fs.normalize(path) == home then return false end
    for _, marker in ipairs(markers) do
      if name == marker then return true end
    end
    return false
  end)

  if not root then
    root = vim.fs.normalize(vim.uv.cwd())
  end

  return root
end

return M
