-- Odin gets its indent/commentstring from the runtime ftplugin; this file only
-- wires up formatting. See lua/config/odinfmt.lua for how odinfmt is invoked.
local odinfmt = require('config.odinfmt')

vim.api.nvim_buf_create_user_command(0, 'Odinfmt', function()
  odinfmt.format(0)
end, { desc = 'Format buffer with odinfmt' })

-- lua/config/lsp.lua sets the same <leader>f on LspAttach and routes odin
-- buffers here; this mapping is what keeps it working when ols never attached.
vim.keymap.set('n', '<leader>f', function()
  odinfmt.format(0)
end, { buffer = true, silent = true, desc = 'Format with odinfmt' })

-- Format on save is opt-in, matching the "formatting is manual" rule the rest
-- of this config follows: `:lua vim.g.odinfmt_on_save = true` (or set it in
-- init.lua) to turn it on. A buffer that fails to parse is left untouched, so
-- this cannot eat a broken save.
local group = vim.api.nvim_create_augroup('odinfmt_on_save', { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  buffer = 0,
  desc = 'Format with odinfmt before writing (opt-in via g:odinfmt_on_save)',
  callback = function(args)
    if vim.g.odinfmt_on_save then odinfmt.format(args.buf) end
  end,
})
