-- JavaScript/TypeScript: indent options come from the project's Prettier
-- config, and <leader>f / :Prettier format with the project's Prettier binary.
-- See lua/config/prettier.lua. typescript.lua dofile()s this, and the
-- runtime's javascriptreact/typescriptreact ftplugins `runtime!` those two,
-- so JSX/TSX buffers get it as well.
local prettier = require('config.prettier')

prettier.apply(0)

vim.api.nvim_buf_create_user_command(0, 'Prettier', function()
  prettier.format(0)
end, { desc = "Format buffer with the project's Prettier" })

-- lua/config/lsp.lua sets the same <leader>f on LspAttach and routes JS/TS
-- buffers here; this mapping is what keeps it working when neither ts_ls nor
-- eslint attached.
vim.keymap.set('n', '<leader>f', function()
  prettier.format_buffer(0)
end, { buffer = true, silent = true, desc = 'Format: Prettier, then eslint fixAll' })
