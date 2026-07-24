-- Zig Language Server configuration
return {
  cmd = { 'zls' },
  filetypes = { 'zig' },
  root_markers = { 'build.zig', 'build.zig.zon', 'zls.json', '.git' },
  settings = {
    zls = {
      enable_snippets = false,
      enable_argument_placeholders = false,
    },
  },
}
