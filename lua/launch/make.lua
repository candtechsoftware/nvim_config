-- Build command detection from a project's marker files, for :Make in
-- projects without a launch.json.
local M = {}

local function exists(root, name)
  return vim.uv.fs_stat(root .. '/' .. name) ~= nil
end

local function node_build(root)
  if exists(root, 'pnpm-lock.yaml') then return 'pnpm run build' end
  if exists(root, 'yarn.lock') then return 'yarn build' end
  if exists(root, 'package.json') then return 'npm run build' end
end

local function c_build(root)
  if exists(root, 'Makefile') or exists(root, 'makefile') then return 'make -j' end
  if exists(root, 'CMakeLists.txt') then
    local build = vim.uv.fs_stat(root .. '/build')
    if build and build.type == 'directory' then
      return 'cmake --build build --config Debug'
    end
    return 'cmake -S . -B build && cmake --build build --config Debug'
  end
end

-- `%` is the current file, expanded by :Make.
local function jai_build(root)
  if exists(root, 'build.jai') then return 'jai-macos build.jai' end
  return 'jai-macos %'
end

local JS = { javascript = true, typescript = true, javascriptreact = true, typescriptreact = true }

function M.detect(root, ft)
  -- .project_type forces a project kind even when its marker files are missing.
  if exists(root, '.project_type') then
    local t = vim.trim(vim.fn.readfile(root .. '/.project_type')[1] or '')
    if t == 'zig' then return 'zig build' end
    if t == 'node' then return node_build(root) or 'npm run build' end
    if t == 'rust' then return 'cargo build' end
    if t == 'c' or t == 'cpp' then return 'make -j' end
    if t == 'jai' then return jai_build(root) end
    if t == 'odin' then return 'odin build .' end
  end

  if ft == 'zig' then return 'zig build' end
  if ft == 'rust' then return 'cargo build' end
  if JS[ft] and node_build(root) then return node_build(root) end
  if (ft == 'c' or ft == 'cpp') and c_build(root) then return c_build(root) end
  if ft == 'jai' then return jai_build(root) end
  if ft == 'odin' then return 'odin build .' end

  if exists(root, 'build.zig') then return 'zig build' end
  if exists(root, 'Cargo.toml') then return 'cargo build' end
  local cmd = node_build(root) or c_build(root)
  if cmd then return cmd end
  if exists(root, 'build.jai') then return 'jai-macos build.jai' end
  return 'make'
end

return M
