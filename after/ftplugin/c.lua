local sw = require('config.c_width').get()
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
