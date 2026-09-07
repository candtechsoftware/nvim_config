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
  local buf = opts.buf or 0
  local cwd = vim.uv.cwd()

  -- vim.fs.root resolves the buffer name against cwd and asserts when there
  -- isn't one (the project was deleted out from under a running session).
  -- An absolute buffer name never needs cwd, so only skip for unnamed ones.
  local root
  if cwd or vim.api.nvim_buf_get_name(buf):sub(1, 1) == '/' then
    root = vim.fs.root(buf, function(name, path)
      if vim.fs.normalize(path) == home then return false end
      for _, marker in ipairs(markers) do
        if name == marker then return true end
      end
      return false
    end)
  end

  if not root then
    root = vim.fs.normalize(cwd or home)
  end

  return root
end

-- Search scope is the repo, not the nearest manifest. `vim.fs.root` stops at
-- the NEAREST marker, so a buffer in ~/work/percipio-repo/percipio/packages/api
-- resolved to `packages/api` and a grep never left that one package. Every
-- checkout under ~/work is its own git repo and the directory holding them has
-- no markers of its own, so `.git` is exactly one project: all of its packages,
-- none of its 17 siblings. Outside a repo, fall back to the shared marker list.
--
-- Lives here rather than in a picker module because both pickers need it:
-- config.fff scopes find/grep to it, config.telescope scopes what it kept.
---@return string
function M.search_root()
    local root = M.find({ markers = { ".git" } })
    return vim.uv.fs_stat(root .. "/.git") and root or M.find()
end

return M
