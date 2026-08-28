-- Indent width for the C-family ftplugins: the project's dominant width wins
-- over the buffer's own, so 4-space code pasted into a 2-space tree is a file
-- to fix, not a style to follow.
--
-- Only 2/4/8 count as an indent: the ` *` body of a block comment or an
-- aligned continuation line says nothing about the width.
local project_root = require('utils.project_root')

local WIDTHS = { 2, 4, 8 }
local EXTS = { c = true, h = true, cpp = true, cc = true, hpp = true, hh = true, m = true, mm = true }
local HEAD_LINES = 100
local MAX_FILES = 40
local MAX_DEPTH = 4

local SKIP = {}
for _, name in ipairs(require('utils.skip_dirs').NAMES) do
  SKIP[name] = true
end

-- One scan per project root per session.
local cached = {}

local M = {}

---@param lines string[]
---@return integer|nil
local function sniff(lines)
  for _, line in ipairs(lines) do
    local spaces = line:match('^( +)%S')
    if spaces and vim.list_contains(WIDTHS, #spaces) then return #spaces end
  end
end

-- `vim.fs.dir` hands `skip` the path relative to the root, so a nested
-- `game/.build` or `src/third_party` only matches on its last component.
---@param dir string
---@return boolean
local function walk_into(dir)
  local base = vim.fs.basename(dir)
  return base:sub(1, 1) ~= '.' and not SKIP[base]
end

---@param root string
---@return integer|nil
local function scan(root)
  local votes, files = {}, 0
  for entry, kind in vim.fs.dir(root, { depth = MAX_DEPTH, skip = walk_into }) do
    if kind == 'file' and EXTS[entry:match('%.(%w+)$')] then
      local ok, lines = pcall(vim.fn.readfile, root .. '/' .. entry, '', HEAD_LINES)
      local width = ok and sniff(lines)
      if width then votes[width] = (votes[width] or 0) + 1 end
      files = files + 1
      if files >= MAX_FILES then break end
    end
  end

  -- Ties go to the narrower width, so the same tree always answers the same.
  local best
  for _, width in ipairs(WIDTHS) do
    if (votes[width] or 0) > (votes[best] or 0) then best = width end
  end
  return best
end

---@return integer
function M.detect()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  local dir = name ~= '' and vim.fs.dirname(name) or nil

  -- project_root falls back to cwd when nothing above the file is a project;
  -- for a width vote the file's own directory is the honest answer.
  local root = dir and project_root.find({ buf = bufnr })
  if root and not vim.startswith(dir, root) then root = dir end

  local width = root and (cached[root] or scan(root))
  if width then cached[root] = width end

  return width or sniff(vim.api.nvim_buf_get_lines(bufnr, 0, HEAD_LINES, false)) or 2
end

return M
