-- typescript-language-server (the stable Node-based TS server).
-- Replaces tsgo for Expo/React Native projects where tsgo 7.0.0-dev still has gaps.
--
-- Pinned to an absolute path so the server resolves regardless of the project's
-- active node version. nvm keeps global npm packages PER node version, and our
-- zsh chpwd hook runs `nvm use` from a project's .nvmrc — so launching nvim in a
-- repo pinned to a node version that lacks this package (e.g. IrisBetaApp →
-- v24.16.0) would otherwise leave `typescript-language-server` off PATH and
-- vim.lsp.enable() would silently attach 0 clients. The server is plain JS and
-- runs fine under whatever node is on PATH (its `env node` shebang).
-- If you ever remove v22.10.0, install the package under another version and
-- update TSLS_BIN below (or it falls back to PATH lookup).
local TSLS_BIN = vim.fn.expand('~/.nvm/versions/node/v22.10.0/bin/typescript-language-server')
if vim.fn.executable(TSLS_BIN) == 0 then
  TSLS_BIN = 'typescript-language-server'
end

return {
  cmd = { TSLS_BIN, '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  single_file_support = true,
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
