return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  settings = {
    ['rust-analyzer'] = {
      completion = {
        callable = {
          snippets = 'none',
        },
        postfix = {
          enable = false,
        },
      },
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
}
