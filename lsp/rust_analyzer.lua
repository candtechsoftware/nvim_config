-- Rust Analyzer configuration
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  settings = {
    ['rust-analyzer'] = {
      completion = {
        callable = {
          snippets = 'none',  -- No snippet-style completions
        },
        postfix = {
          enable = false,  -- Disable postfix completions
        },
      },
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
}
