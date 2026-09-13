-- Build command detection from a project's marker files, for :Make in
-- lua/launch (projects without a launch.json).

local M = {}

local function exists(root, fname)
  return vim.uv.fs_stat(root .. "/" .. fname) ~= nil
end

local function dexists(root, dname)
  local st = vim.uv.fs_stat(root .. "/" .. dname)
  return st ~= nil and st.type == "directory"
end

-- Per-build-system resolvers, shared by the .project_type switch, the
-- filetype quick wins, and the repo-level heuristics below — each command
-- string and marker-file ladder exists in exactly one place, so the three
-- call sites cannot drift apart. Each returns nil when its markers are
-- absent so callers can fall through.

local function node_build(root)
  if exists(root, "pnpm-lock.yaml") then return "pnpm run build" end
  if exists(root, "yarn.lock") then return "yarn build" end
  if exists(root, "package.json") then return "npm run build" end
end

local function c_build(root)
  if exists(root, "Makefile") or exists(root, "makefile") then return "make -j" end
  if exists(root, "CMakeLists.txt") then
    -- prefer build dir if present
    if dexists(root, "build") then
      return "cmake --build build --config Debug"
    end
    return "cmake -S . -B build && cmake --build build --config Debug"
  end
end

-- Jai (macOS): a build.jai entrypoint, else compile the current file
-- (% expands to the buffer's file; use `jai-macos -x %` to build & run).
local function jai_build(root)
  if exists(root, "build.jai") then return "jai-macos build.jai" end
  return "jai-macos %"
end

---The best build command for the project at `root`, given the current
---buffer's filetype.
---@param root string
---@param buf_ft string
---@return string
function M.detect(root, buf_ft)
  -- Highest priority: explicit project hint. The hint means "treat this as
  -- an X project" even when marker files are missing, hence the extra
  -- fallbacks node_build/c_build alone would not give.
  if exists(root, ".project_type") then
    local t = vim.fn.trim(vim.fn.readfile(root .. "/.project_type")[1] or "")
    if t == "zig" then return "zig build" end
    if t == "node" then return node_build(root) or "npm run build" end
    if t == "rust" then return "cargo build" end
    if t == "c" or t == "cpp" then return "make -j" end
    if t == "jai" then return jai_build(root) end
    if t == "odin" then return "odin build ." end
  end

  -- Per-language quick wins (based on filetype)
  if buf_ft == "zig" then return "zig build" end
  if buf_ft == "rust" then return "cargo build" end

  if buf_ft == "javascript" or buf_ft == "typescript" or buf_ft == "typescriptreact" or buf_ft == "javascriptreact" then
    local cmd = node_build(root)
    if cmd then return cmd end
  end

  if buf_ft == "c" or buf_ft == "cpp" then
    local cmd = c_build(root)
    if cmd then return cmd end
  end

  if buf_ft == "jai" then return jai_build(root) end
  if buf_ft == "odin" then return "odin build ." end

  -- Repo-level heuristics regardless of filetype
  if exists(root, "build.zig") then return "zig build" end
  if exists(root, "Cargo.toml") then return "cargo build" end
  local cmd = node_build(root) or c_build(root)
  if cmd then return cmd end
  if exists(root, "build.jai") then return "jai-macos build.jai" end

  -- Fallback: plain make
  return "make"
end

return M
