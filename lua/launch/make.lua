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

local function jai_executable()
  for _, name in ipairs({ 'jai-macos', 'jai', 'jai-linux' }) do
    if vim.fn.executable(name) == 1 then return name end
  end
  -- Keep the eventual shell error useful when Jai is not installed.
  return 'jai-macos'
end

-- `%` is the current file, shell-escaped and expanded by :Make. A build.jai
-- metaprogram is the project build; first.jai is the conventional entry point
-- for a project without one.
local function jai_build(root)
  local entry = exists(root, 'build.jai') and 'build.jai'
    or exists(root, 'first.jai') and 'first.jai'
    or '%'
  return jai_executable() .. ' ' .. entry
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
  if exists(root, 'build.jai') or exists(root, 'first.jai') then return jai_build(root) end
  return 'make'
end

-- The command that runs the program the build produced, or nil when the
-- project has no convention for it. launch.json can bind <leader>br itself.
function M.detect_run(root, ft)
  local build = M.detect(root, ft)
  local run

  if build == 'zig build' then run = 'zig build run' end
  if build == 'cargo build' then run = 'cargo run' end
  if build:match('^jai') and exists(root, 'build.jai') then run = 'jai-macos build.jai - -run' end
  if build:match('^make') then run = 'make run' end
  if build:match('^npm') or build:match('^pnpm') or build:match('^yarn') then
    run = build:gsub('build$', 'start')
  end

  return run
end

return M
