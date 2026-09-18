-- typescript.lua and the runtime's jsx/tsx ftplugins source this one too.
local format = require('config.format')
format.apply_prettier_indent()
vim.api.nvim_buf_create_user_command(0, 'Prettier', function() format.prettier() end, { desc = "Format with the project's Prettier" })
