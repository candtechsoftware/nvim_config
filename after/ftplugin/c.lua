-- Indent width. The fallback is 2 spaces — the raddebugger style
-- (~/gits/raddebugger: 2-space, no tabs) — but a file that already has an
-- indent keeps it, so ~/projects/engine's 4-space files are left alone.
--
-- Three steps, first conclusive one wins:
--   1. this buffer's first indented line;
--   2. a sibling .c/.h in the same directory — a prototype-only header or a
--      brand-new file has no indented line of its own, and this is what makes
--      a new file in a 4-space project come out 4-wide and a raddebugger
--      header come out 2-wide instead of both falling through to the default;
--   3. 2.
-- Only 2/4/8 count as an indent: the ` *` body of a block comment or an
-- aligned continuation line says nothing about the project's width.
local WIDTHS = { [2] = true, [4] = true, [8] = true }
local SIBLING_EXTS = { c = true, h = true, cpp = true, cc = true, hpp = true, hh = true, m = true, mm = true }
local HEAD_LINES = 100
local MAX_SIBLINGS = 8

---@param lines string[]
---@return integer|nil
local function sniff(lines)
  for _, line in ipairs(lines) do
    local spaces = line:match('^( +)%S')
    if spaces and WIDTHS[#spaces] then return #spaces end
  end
end

---@param path string
---@return string[]
local function head(path)
  local f = io.open(path, 'r')
  if not f then return {} end
  local lines = {}
  for line in f:lines() do
    lines[#lines + 1] = line
    if #lines >= HEAD_LINES then break end
  end
  f:close()
  return lines
end

local function detect_indent()
  local bufnr = vim.api.nvim_get_current_buf()
  local width = sniff(vim.api.nvim_buf_get_lines(bufnr, 0, HEAD_LINES, false))
  if width then return width end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= '' then
    local dir, self = vim.fs.dirname(name), vim.fs.basename(name)
    local seen = 0
    for entry, kind in vim.fs.dir(dir) do
      if kind == 'file' and entry ~= self and SIBLING_EXTS[entry:match('%.(%w+)$') or ''] then
        width = sniff(head(dir .. '/' .. entry))
        if width then return width end
        seen = seen + 1
        if seen >= MAX_SIBLINGS then break end
      end
    end
  end

  return 2
end

local sw = detect_indent()
vim.bo.shiftwidth = sw
vim.bo.tabstop = sw
vim.bo.softtabstop = sw
vim.bo.cinoptions = 't0,:s,l1,(0,Ws'

-- Identifier completion for unity-build C/C++ with no LSP. <Tab> (see
-- lua/config/keymaps.lua) routes completion by context:
--   * after `.` / `->` / `::`  -> the `omnifunc` below: treesitter resolves the
--     type of the variable before the operator, then the ctags index supplies
--     that type's members (replaces the unreliable built-in `ccomplete`).
--   * on a plain identifier    -> the `completefunc` below: variable and
--     function names from the buffer's treesitter tree + ctags, ranked by
--     scope (local -> file -> project). See lua/config/c_complete.lua.
vim.bo.completefunc = "v:lua.require'config.c_complete'.complete"
vim.bo.omnifunc = "v:lua.require'config.c_complete'.omnifunc"

-- Drop 'fuzzy' for these buffers so the completefunc's scope ranking is
-- preserved instead of being re-sorted by fuzzy match score. 'noselect'
-- (nothing pre-selected) is kept.
vim.bo.completeopt = 'menu,menuone,noselect'

-- Manual <C-n> keyword completion still works as a fallback: tags first
-- (real symbols), then the current buffer.
vim.bo.complete = 't,.'

-- Custom indentexpr: cindent, with the `{`-after-case-label layout fixed up
-- (see config.c_indent). Combined with cinoptions=t0 for "return type on its
-- own line" style. Shared with the C++/Obj-C/Obj-C++ ftplugins.
_G._c_indentexpr = require('config.c_indent').indent
vim.bo.indentexpr = 'v:lua._c_indentexpr()'
vim.bo.smartindent = false

-- Goto-definition via the project tags file. These are unity-build C/C++
-- projects with no LSP, so `gd` is a tag jump: `:tjump` goes straight to a
-- single match and only prompts a picker when a name is ambiguous.
-- The built-in <C-]> (jump) and <C-t> (jump back) work too.
vim.keymap.set('n', 'gd', function()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local ok, err = pcall(vim.cmd, 'tjump ' .. word)
  if not ok then
    vim.notify((tostring(err):gsub('^Vim%b():', '')), vim.log.levels.WARN)
  end
end, { buffer = true, silent = true, desc = 'Go to definition (tags)' })
