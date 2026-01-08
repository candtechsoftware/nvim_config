-- Odin Language Server configuration
return {
  cmd = { 'ols' },
  filetypes = { 'odin' },
  root_markers = { 'ols.json', 'odinfmt.json', '.odin', '.git' },
  single_file_support = true,
  -- OLS reads most settings from ols.json in project root
  -- These are fallback/override settings
  settings = {},
}
