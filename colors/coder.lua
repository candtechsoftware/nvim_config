-- [25] # Version number. Do not delete.
-- Based on the supplied Coder 4coder palette.
require('hh.palette_theme').apply('coder', {
  bg = '#0c0c0c', bg1 = '#101010', bg2 = '#181818', bg3 = '#1e1e1e', bg4 = '#252525',
  fg = '#90b080', ui_dim = '#404040',
  bar_fg = '#888888', bar_bg = '#000000', bar_nc_fg = '#666666', bar_nc_bg = '#000000',
  cursor = '#00ee00', cursor_insert = '#ee7700', cursor_fg = '#0c0c0c',
  selection = '#ddee00', search_active = '#ff44dd', search_inactive = '#494949',
  bracket = '#ddee00',
  code_default = '#90b080', code_identifier = '#90b080', code_comment = '#2090f0',
  code_string = '#50ff30', code_number = '#50ff30', code_value = '#50ff30',
  code_function = '#90b080', code_type = '#d08f20', code_keyword = '#d08f20',
  code_operation = '#90b080', code_punctuation = '#90b080', code_highlight = '#ddee00',
  code_warning = '#ddee00', code_error = '#ff0000', code_macro = '#90b080',
  code_note = '#00a000', code_addition = '#00a000', code_deletion = '#a00000',
  region_addition = '#00a000', region_deletion = '#3a0000',
  -- Original cycle entries carry low alpha; these are their subtle RGB blends
  -- over defcolor_back, represented as opaque Neovim highlight backgrounds.
  scope_bgs = { '#160c0c', '#0c130c', '#0c0c13', '#13130c' },
  text_cycle = { '#a00000', '#00a000', '#0030b0', '#a0a000' },
})
