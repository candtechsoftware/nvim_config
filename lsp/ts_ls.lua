-- typescript-language-server (the stable Node-based TS server).
-- Replaces tsgo for Expo/React Native projects where tsgo 7.0.0-dev still has gaps.
return {
  cmd = { 'typescript-language-server', '--stdio' },
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
