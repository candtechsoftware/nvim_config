local format = require('config.format')
vim.api.nvim_buf_create_user_command(0, 'Odinfmt', function() format.odin() end, { desc = 'Format with odinfmt' })

-- Opt in with `vim.g.odinfmt_on_save = true`. A buffer that does not parse is left alone.
local group = vim.api.nvim_create_augroup('odinfmt_on_save', { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buf = 0 })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  buf = 0,
  callback = function(ev)
    if vim.g.odinfmt_on_save then format.odin(ev.buf) end
  end,
})
