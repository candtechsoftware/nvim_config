-- Pinned to the node version it is installed under: the zsh chpwd hook runs
-- `nvm use` per project, and most of those versions lack the global package.
local bin = vim.fn.expand('~/.nvm/versions/node/v22.10.0/bin/typescript-language-server')
if vim.fn.executable(bin) == 0 then bin = 'typescript-language-server' end

return {
  cmd = { bin, '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  init_options = {
    hostInfo = 'neovim',
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      includeCompletionsWithSnippetText = false,
      importModuleSpecifierPreference = 'shortest',
    },
  },
}
