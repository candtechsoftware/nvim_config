vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.cinoptions = 't0,:s,l1,(0,Ws'
vim.bo.indentexpr = require('config.c_indent').indent
vim.bo.smartindent = false

-- Completion without an LSP: <Tab> (lua/config/keymaps.lua) uses omnifunc
-- after `.`/`->`/`::` and completefunc on a plain identifier.
vim.bo.completefunc = function(...) return require('config.c_complete').complete(...) end
vim.bo.omnifunc = function(...) return require('config.c_complete').omnifunc(...) end
-- No 'fuzzy', which would re-sort away completefunc's scope ranking.
vim.bo.completeopt = 'menu,menuone,noselect'
vim.bo.complete = 't,.'

vim.keymap.set('n', 'gd', function()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local ok, err = pcall(vim.cmd, 'tjump ' .. word)
  if not ok then
    vim.notify((tostring(err):gsub('^Vim%b():', '')), vim.log.levels.WARN)
  end
end, { buf = 0, silent = true, desc = 'Go to definition (tags)' })
