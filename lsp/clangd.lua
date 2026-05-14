-- Clangd configuration for C/C++
return {
  cmd = {
    'clangd',
    '--background-index',
    '--header-insertion=never',
    '--completion-style=detailed',
    '--function-arg-placeholders=0',
    '--fallback-style=llvm',
    '--pch-storage=memory',
    '--all-scopes-completion=false',
    '--limit-results=20',
    '--clang-tidy=false',
    '--ranking-model=decision_forest',
    '-j=4',
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'hlsl' },
  root_markers = { 'compile_flags.txt', 'compile_commands.json', '.clangd', '.git' },
  settings = {
    clangd = {
      completion = {
        snippets = false,
      },
    },
  },
}
