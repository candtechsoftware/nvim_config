-- C/C++ Language Server configuration (unity-build projects)
-- Attach is gated: workspace_required + these root_markers mean clangd only
-- starts in projects that opted in (run :ClangdSetup to generate a .clangd).
-- Everywhere else the ctags/treesitter completion keeps working unchanged.
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
  workspace_required = true,  -- no marker => no attach (not even single-file mode)
}
