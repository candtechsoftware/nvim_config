-- Only starts where a root marker exists: run :ClangdSetup to opt a unity-build
-- project in. Everywhere else the ctags/treesitter completion is used.
return {
  cmd = {
    'clangd',
    '--background-index',
    '--header-insertion=never',
    '--completion-style=detailed',
    '--function-arg-placeholders=0',
    '--all-scopes-completion',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_markers = { '.clangd', 'compile_commands.json', 'compile_flags.txt' },
  workspace_required = true,
}
