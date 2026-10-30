-- Darker Handmade Hero brown on soft off-white, with STB light's green comments.
require('hh.stb').apply('stb-brown-light', 'light', {
  bg = '#eeeae3', fg = '#806849',
  type = '#486e78',
  type_builtin = '#786080',
  keyword = '#9c3b35',
  cursor = '#d1bd9f', insert = '#d1bd9f', cursor_replace = '#d9b1aa',
  cursor_fg = '#30271d',
  bracket = '#806849',
  margin = '#e7e3dc', hover = '#e1ddd6', active = '#d1cbc1', line = '#e5e0d7',
  bar_fg = '#806849', bar_bg = '#ded7cd',
  bar_nc_fg = '#8a7863', bar_nc_bg = '#e7e2da',
  gutter_fg = '#8a7863', gutter_bg = '#eeeae3', menu_fg = '#705536',
  ghost = '#a99b89',
  search = '#dcd0bc', add_bg = '#dce6d6', delete_bg = '#ecd9d6',
  -- Subtle scope tints over the off-white background.
  scopes = { '#eee5de', '#e9eadf', '#e9e5e3', '#eeeadf' },
})
