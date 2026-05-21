local M = {}

local home = vim.fs.normalize(vim.uv.os_homedir())

M.markers = {
  'package.json', 'tsconfig.json', 'jsconfig.json',
  'Cargo.toml', 'go.mod',
  'build.jai', 'first.jai', 'launch.json',
  'CMakeLists.txt', 'Makefile',
  '.project', '.root', '.git',
}

---Find the project root for a buffer (default: the current buffer).
---Resolves from the buffer's path, falling back to cwd for unnamed buffers.
---@param opts table|nil  { markers?: string[], buf?: integer }
---@return string
function M.find(opts)
  opts = opts or {}
  local markers = opts.markers or M.markers

  local root = vim.fs.root(opts.buf or 0, function(name, path)
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
