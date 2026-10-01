-- Shared Neovim highlights for the locally ported 4coder palettes.
local M = {}

function M.apply(name, c)
  vim.cmd('hi clear')
  if vim.g.syntax_on then vim.cmd('syntax reset') end
  vim.o.termguicolors = true
  vim.o.background = 'dark'
  vim.g.colors_name = name

  local hl = vim.api.nvim_set_hl
  local function paint(spec, groups)
    for _, group in ipairs(groups) do hl(0, group, spec) end
  end

  paint({ fg = c.fg, bg = c.bg }, { 'Normal', 'NormalNC' })
  hl(0, 'NormalFloat', { fg = c.fg, bg = c.bg2 })
  paint({ fg = c.ui_dim }, { 'NonText', 'EndOfBuffer', 'Whitespace', 'LineNr', 'SignColumn', 'FoldColumn' })
  paint({ fg = c.bg3 }, { 'VertSplit', 'WinSeparator', 'FloatBorder' })
  paint({ fg = c.bar_fg or c.fg, bg = c.bar_bg or c.bg1 }, { 'StatusLine', 'WinBar', 'TabLineSel' })
  paint({ fg = c.bar_nc_fg or c.ui_dim, bg = c.bar_nc_bg or c.bg1 }, { 'StatusLineNC', 'WinBarNC', 'TabLine', 'TabLineFill' })
  paint({ fg = c.ui_dim, bg = c.bg }, { 'LineNr', 'SignColumn', 'FoldColumn' })
  hl(0, 'CursorLineNr', { fg = c.fg, bg = c.bg })
  paint({ bg = c.bg3 }, { 'CursorLine', 'Folded' })
  paint({ bg = c.selection }, { 'Visual', 'VisualNOS' })
  hl(0, 'MatchParen', { fg = c.bracket, bg = c.bg3 })
  hl(0, 'Directory', { fg = c.code_function })
  paint({ fg = c.code_function }, { 'Title', 'FloatTitle' })

  paint({ bg = c.cursor }, { 'Cursor', 'lCursor' })
  hl(0, 'CursorNormal', { fg = c.cursor_fg or c.bg, bg = c.cursor })
  hl(0, 'CursorInsert', { fg = c.cursor_fg or c.bg, bg = c.cursor_insert or c.code_type })
  hl(0, 'CursorReplace', { fg = c.cursor_fg or c.bg, bg = c.cursor_replace or c.code_keyword })
  vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

  paint({ fg = c.code_keyword }, {
    'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception', 'StorageClass',
  })
  paint({ fg = c.code_type }, { 'Type', 'Structure', 'Typedef' })
  paint({ fg = c.code_function }, { 'Function' })
  paint({ fg = c.code_value }, { 'Constant', 'Boolean' })
  paint({ fg = c.code_number }, { 'Number', 'Float' })
  paint({ fg = c.code_string }, { 'String', 'Character' })
  paint({ fg = c.code_comment }, { 'Comment', 'SpecialComment' })
  paint({ fg = c.code_operation }, { 'Operator' })
  paint({ fg = c.code_punctuation }, { 'Delimiter' })
  paint({ fg = c.code_identifier }, { 'Identifier' })
  paint({ fg = c.code_macro }, { 'Macro', 'PreProc', 'Include', 'Define', 'PreCondit', 'Special' })
  paint({ fg = c.code_warning }, { 'Todo', 'WarningMsg', 'DiagnosticWarn' })
  paint({ fg = c.code_error }, { 'ErrorMsg', 'DiagnosticError', 'DiagnosticUnderlineError', 'SpellBad' })
  paint({ fg = c.code_note }, { 'Question', 'MoreMsg', 'ModeMsg' })

  hl(0, 'Search', { fg = c.fg, bg = c.search_inactive })
  paint({ fg = c.bg, bg = c.search_active }, { 'IncSearch', 'CurSearch' })
  hl(0, 'Pmenu', { fg = c.fg, bg = c.bg2 })
  paint({ fg = c.fg, bg = c.selection }, { 'PmenuSel', 'WildMenu' })
  hl(0, 'PmenuSbar', { bg = c.bg1 })
  hl(0, 'PmenuThumb', { bg = c.cursor })
  paint({ fg = c.code_highlight }, { 'PmenuMatch', 'PmenuMatchSel' })

  paint({ fg = c.code_addition, bg = c.region_addition }, { 'DiffAdd' })
  paint({ fg = c.code_deletion, bg = c.region_deletion }, { 'DiffDelete' })
  hl(0, 'DiffChange', { bg = c.bg3 })
  hl(0, 'DiffText', { bg = c.selection })
  paint({ fg = c.code_addition }, { 'Added' })
  paint({ fg = c.code_deletion }, { 'Removed' })

  local links = {
    YgKeyword = 'Macro', YgType = 'Type',
    ['@comment'] = 'Comment', ['@comment.documentation'] = 'Comment',
    ['@string'] = 'String', ['@string.documentation'] = 'Comment',
    ['@string.regexp'] = 'String', ['@string.escape'] = 'SpecialChar', ['@string.special'] = 'Special',
    ['@character'] = 'Character', ['@character.special'] = 'SpecialChar',
    ['@number'] = 'Number', ['@number.float'] = 'Float', ['@boolean'] = 'Boolean',
    ['@constant'] = 'Constant', ['@constant.builtin'] = 'Constant', ['@constant.macro'] = 'Macro',
    ['@function'] = 'Function', ['@function.call'] = 'Function', ['@function.method'] = 'Function',
    ['@function.method.call'] = 'Function', ['@function.builtin'] = 'Function', ['@function.macro'] = 'Macro',
    ['@variable'] = 'Identifier', ['@variable.builtin'] = 'Special',
    ['@variable.parameter'] = 'Identifier', ['@variable.member'] = 'Identifier',
    ['@property'] = 'Identifier', ['@field'] = 'Identifier',
    ['@type'] = 'Type', ['@type.builtin'] = 'Type', ['@type.definition'] = 'Type',
    ['@keyword'] = 'Keyword', ['@keyword.function'] = 'Keyword', ['@keyword.operator'] = 'Keyword',
    ['@keyword.import'] = 'PreProc', ['@keyword.return'] = 'Keyword', ['@keyword.repeat'] = 'Repeat',
    ['@keyword.conditional'] = 'Conditional', ['@keyword.exception'] = 'Exception',
    ['@keyword.modifier'] = 'StorageClass', ['@keyword.type'] = 'Keyword', ['@keyword.directive'] = 'PreProc',
    ['@operator'] = 'Operator', ['@punctuation.delimiter'] = 'Delimiter',
    ['@punctuation.bracket'] = 'Delimiter', ['@punctuation.special'] = 'Special',
    ['@tag'] = 'Keyword', ['@tag.attribute'] = 'Identifier', ['@tag.delimiter'] = 'Delimiter',
  }
  for group, target in pairs(links) do hl(0, group, { link = target }) end

  local function soften(hex, amount)
    local base = c.bg:gsub('#', '')
    local color = hex:gsub('#', '')
    local out = {}
    for i = 1, 6, 2 do
      local b = tonumber(base:sub(i, i + 1), 16)
      local v = tonumber(color:sub(i, i + 1), 16)
      out[#out + 1] = ('%02x'):format(math.floor(b + (v - b) * amount + 0.5))
    end
    return '#' .. table.concat(out)
  end

  local scope_bgs = c.scope_bgs or { c.bg, c.bg1, c.bg2, c.bg3, c.bg4 }
  local scope_mix = c.scope_mix or 0.4
  for i, bg in ipairs(scope_bgs) do
    hl(0, 'HHScope' .. i, { bg = soften(bg, scope_mix) })
  end
  for i, fg in ipairs(c.text_cycle or {}) do hl(0, 'HHTextCycle' .. i, { fg = fg }) end
  require('hh.scope').setup({ cycle_len = #scope_bgs })
  require('hh.macros').setup()
  require('hh.dim').setup({ fg = c.ui_dim })
end

return M
