-- STB dark syntax on near-black surfaces.
require('hh.stb').apply('stb-night', 'dark', {
  bg = '#0c0c0c',
  margin = '#121212', hover = '#181818', active = '#303030', line = '#161616',
  bar_fg = '#aaaaaa', bar_bg = '#1c1c1c',
  bar_nc_fg = '#6d6d6d', bar_nc_bg = '#121212',
  gutter_fg = '#555555', gutter_bg = '#0c0c0c', menu_fg = '#aaaaaa',
  search = '#102830', add_bg = '#102010', delete_bg = '#281414',
  -- The same subtle scope tints, composited over the near-black background.
  scopes = { '#0f0c0c', '#0c0f0c', '#0c0c0f', '#0f0f0c' },
})
