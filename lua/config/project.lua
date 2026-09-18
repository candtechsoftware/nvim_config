local M = {}

-- Vendored and build trees that every project scanner skips. They are checked
-- in, so .gitignore does not filter them.
M.SKIP_DIRS = {
  'build', 'bin', 'out', 'dist',
  'third_party', 'thirdparty', '3rd_party', '3rdparty',
  'vendor', 'node_modules',
}

M.MARKERS = {
  'package.json', 'tsconfig.json', 'jsconfig.json',
  'Cargo.toml', 'go.mod',
  'build.jai', 'first.jai', 'launch.json',
  'CMakeLists.txt', 'Makefile',
  '.project', '.root', '.git',
}

local home = vim.fs.normalize(vim.uv.os_homedir())

-- Nearest ancestor of the buffer holding one of `markers`, never home itself.
-- Falls back to cwd.
function M.root(buf, markers)
  markers = markers or M.MARKERS
  local root = vim.fs.root(buf or 0, function(name, path)
    return vim.fs.normalize(path) ~= home and vim.list_contains(markers, name)
  end)
  return root or vim.fs.normalize(vim.uv.cwd() or home)
end

-- Pickers search the whole repo, not the nearest package inside it.
function M.search_root()
  local root = M.root(0, { '.git' })
  return vim.uv.fs_stat(root .. '/.git') and root or M.root()
end

return M
