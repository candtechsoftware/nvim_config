-- Ported from ~/gits/coder/4coder-non-source/themes/theme-stb{,-dark}.4coder.
-- STB keeps code monochrome, with green comments and red escape sequences.
local M = {}

function M.apply(name, background, overrides)
  local light = background == 'light'
  local p = light and {
    bg = '#d6d6d6', fg = '#000000', comment = '#005800',
    margin = '#9e9e9e', hover = '#7e7e7e', active = '#5c5c5c',
    line = '#bcbcbc', selection = '#0044ff', cursor = '#000000', insert = '#002020',
    ghost = '#6b6b6b', escape = '#9a0000', info = '#1111dc', error = '#e80505',
    note = '#00a000', deletion = '#a00000', paste = '#00b8b8',
    search = '#b8c5dc', add_bg = '#bed6be', delete_bg = '#e5bcbc',
    -- Alpha-composited defcolor_back_cycle over defcolor_back (0x10 alpha).
    scopes = { '#d3c9c9', '#c9d3c9', '#c9c9d3', '#d3d3c9' },
    text = { '#a00000', '#00a000', '#0000a0', '#a0a000' },
  } or {
    bg = '#303030', fg = '#aaaaaa', comment = '#6ac000',
    margin = '#383838', hover = '#404040', active = '#484848',
    line = '#383838', selection = '#006080', cursor = '#dddddd', insert = '#ddf0f0',
    ghost = '#6d6d6d', escape = '#ff0000', info = '#00b0d0', error = '#ff3a00',
    note = '#149014', deletion = '#aa0a0a', paste = '#00ffff',
    search = '#30434a', add_bg = '#304030', delete_bg = '#482020',
    -- Alpha-composited defcolor_back_cycle over defcolor_back (0x06 alpha).
    scopes = { '#332f2f', '#2f332f', '#2f2f33', '#33332f' },
    text = { '#aa0a0a', '#149014', '#0060a8', '#909000' },
  }

  p = vim.tbl_extend('force', p, overrides or {})

  require('hh.palette_theme').apply(name, {
    background = background,
    bg = p.bg, bg1 = p.margin, bg2 = p.hover, bg3 = p.line, bg4 = p.active,
    fg = p.fg, ui_dim = p.ghost,
    bar_fg = p.bar_fg or '#000000', bar_bg = p.bar_bg or '#3e3e3e',
    bar_nc_fg = p.bar_nc_fg or '#000000', bar_nc_bg = p.bar_nc_bg or '#606060',
    cursor = p.cursor, cursor_insert = p.insert, cursor_replace = p.cursor_replace or p.error,
    cursor_fg = p.cursor_fg or p.bg, selection = p.selection,
    search_active = p.selection, search_inactive = p.search, bracket = p.bracket or p.cursor,
    code_identifier = p.fg, code_comment = p.comment,
    code_string = p.fg, code_number = p.fg, code_value = p.fg,
    code_function = p.fg, code_type = p.type or p.fg, code_keyword = p.keyword or p.fg,
    code_operation = p.fg, code_punctuation = p.fg, code_macro = p.fg,
    code_highlight = p.paste, code_warning = p.paste, code_error = p.error,
    code_note = p.info, code_addition = p.note, code_deletion = p.deletion,
    region_addition = p.add_bg, region_deletion = p.delete_bg,
    scope_bgs = p.scopes, scope_mix = 1, text_cycle = p.text,
  })

  local hl = vim.api.nvim_set_hl
  if p.type_builtin then
    hl(0, '@type.builtin', { fg = p.type_builtin })
    hl(0, 'YgType', { fg = p.type_builtin })
  end
  hl(0, 'SpecialChar', { fg = p.escape })
  hl(0, 'SpecialComment', { fg = p.note })
  hl(0, 'Visual', { fg = p.bg, bg = p.selection })
  hl(0, 'VisualNOS', { link = 'Visual' })
  hl(0, 'PmenuSel', { fg = p.menu_fg or p.bg, bg = p.active })
  hl(0, 'WildMenu', { link = 'PmenuSel' })
  hl(0, 'LineNr', { fg = p.gutter_fg or p.bg, bg = p.gutter_bg or '#808080' })
  hl(0, 'CursorLineNr', { fg = p.fg, bg = p.gutter_bg or '#808080' })
  hl(0, 'DiagnosticInfo', { fg = p.info })
  hl(0, 'DiagnosticHint', { fg = p.ghost })
  hl(0, 'DiagnosticOk', { fg = p.note })

  -- Semantic token modifiers must not reintroduce colored or styled code.
  for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
    hl(0, group, {})
  end
end

return M
