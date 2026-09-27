vim.cmd('hi clear')
if vim.g.syntax_on then vim.cmd('syntax reset') end
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.colors_name = 'cl'

-- From the screenshot references: charcoal, gray text, brick keywords,
-- amber calls, dusty strings, olive literals and blue directives.
local c = {
  bg = '#0c0c0c',
  fg = '#c5c5c2',
  keyword = '#a6534d',
  func = '#b38449',
  string = '#927571',
  number = '#89966b',
  directive = '#6085a6',
  comment = '#70706c',
  punct = '#969690',
  gutter = '#141414',
  gutter_fg = '#686864',
  line = '#161615',
  panel = '#191919',
  border = '#343434',
  selection = '#354354',
  search = '#443a29',
  cursor = '#a8b8ca',
  error = '#d56850',
  warning = '#c59b59',
  dim = '#53534f',
}

local hl = vim.api.nvim_set_hl
local function paint(spec, groups)
  for _, group in ipairs(groups) do
    hl(0, group, spec)
  end
end

paint({ fg = c.fg, bg = c.bg }, { 'Normal', 'NormalNC' })
hl(0, 'NormalFloat', { fg = c.fg, bg = c.panel })
paint({ fg = c.border }, { 'VertSplit', 'WinSeparator', 'FloatBorder' })
paint({ fg = c.border }, { 'NonText', 'EndOfBuffer', 'Whitespace' })
paint({ fg = c.fg, bg = c.panel }, { 'StatusLine', 'WinBar', 'TabLineSel' })
paint({ fg = c.comment, bg = c.gutter }, { 'StatusLineNC', 'WinBarNC', 'TabLine', 'TabLineFill' })
paint({ fg = c.gutter_fg, bg = c.gutter }, { 'LineNr', 'SignColumn', 'FoldColumn' })
hl(0, 'CursorLineNr', { fg = c.fg, bg = c.gutter })
paint({ bg = c.line }, { 'CursorLine', 'CursorColumn', 'ColorColumn' })
paint({ bg = c.selection }, { 'Visual', 'VisualNOS' })
hl(0, 'MatchParen', { fg = c.cursor, bg = c.selection })
hl(0, 'Folded', { fg = c.comment, bg = c.line })
hl(0, 'Directory', { fg = c.fg })
paint({ fg = c.func }, { 'Title', 'FloatTitle' })

paint({ fg = c.bg, bg = c.cursor }, { 'Cursor', 'lCursor', 'CursorNormal' })
hl(0, 'CursorInsert', { fg = c.bg, bg = c.func })
hl(0, 'CursorReplace', { fg = c.bg, bg = c.keyword })
vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

-- User-defined names and constants remain gray; builtin types share the
-- keyword red (the u32 declarations in the references).
paint({ fg = c.keyword }, {
  'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception',
  'StorageClass', 'Type', 'Structure', 'Typedef',
})
paint({ fg = c.fg }, { 'Identifier', 'Constant', 'Macro' })
hl(0, 'Function', { fg = c.func })
paint({ fg = c.string }, { 'String', 'Character' })
paint({ fg = c.number }, { 'Number', 'Float', 'Boolean' })
paint({ fg = c.directive }, { 'PreProc', 'Include', 'Define', 'PreCondit', 'Special', 'SpecialChar' })
paint({ fg = c.punct }, { 'Operator', 'Delimiter' })
paint({ fg = c.comment }, { 'Comment', 'SpecialComment' })
hl(0, 'Todo', { fg = c.warning })

paint({ fg = c.error }, { 'DiagnosticError', 'DiagnosticUnderlineError', 'Error', 'ErrorMsg' })
paint({ fg = c.warning }, { 'DiagnosticWarn', 'DiagnosticUnderlineWarn', 'WarningMsg' })
paint({ fg = c.directive }, { 'DiagnosticInfo', 'DiagnosticUnderlineInfo' })
paint({ fg = c.comment }, { 'DiagnosticHint', 'DiagnosticUnderlineHint' })
paint({ fg = c.number }, { 'DiagnosticOk', 'Question', 'MoreMsg', 'ModeMsg' })
hl(0, 'DiagnosticUnnecessary', { fg = c.comment })
hl(0, 'DiagnosticDeprecated', { fg = c.comment })

hl(0, 'Search', { fg = c.fg, bg = c.search })
paint({ fg = c.bg, bg = c.func }, { 'IncSearch', 'CurSearch' })
hl(0, 'Substitute', { fg = c.bg, bg = c.keyword })
hl(0, 'Pmenu', { fg = c.fg, bg = c.panel })
paint({ fg = c.fg, bg = c.selection }, { 'PmenuSel', 'WildMenu' })
hl(0, 'PmenuSbar', { bg = c.gutter })
hl(0, 'PmenuThumb', { bg = c.border })
paint({ fg = c.func }, { 'PmenuMatch', 'PmenuMatchSel' })

hl(0, 'DiffAdd', { bg = '#252e23' })
hl(0, 'DiffChange', { bg = '#252d36' })
hl(0, 'DiffText', { bg = c.selection })
hl(0, 'DiffDelete', { fg = c.keyword, bg = '#342423' })
hl(0, 'Added', { fg = c.number })
hl(0, 'Changed', { fg = c.directive })
hl(0, 'Removed', { fg = c.keyword })
paint({ fg = c.error }, { 'SpellBad' })
paint({ fg = c.warning }, { 'SpellCap', 'SpellRare', 'SpellLocal' })

local links = {
  YgKeyword = 'Macro',
  YgType = 'Type',
  ['@comment'] = 'Comment',
  ['@comment.documentation'] = 'Comment',
  ['@string'] = 'String',
  ['@string.documentation'] = 'Comment',
  ['@string.regexp'] = 'String',
  ['@string.escape'] = 'SpecialChar',
  ['@string.special'] = 'Special',
  ['@character'] = 'Character',
  ['@character.special'] = 'SpecialChar',
  ['@number'] = 'Number',
  ['@number.float'] = 'Float',
  ['@boolean'] = 'Boolean',
  ['@constant'] = 'Constant',
  ['@constant.builtin'] = 'Boolean',
  ['@constant.macro'] = 'Macro',
  ['@function'] = 'Function',
  ['@function.builtin'] = 'Function',
  ['@function.call'] = 'Function',
  ['@function.method'] = 'Function',
  ['@function.method.call'] = 'Function',
  ['@function.macro'] = 'Macro',
  ['@variable'] = 'Identifier',
  ['@variable.builtin'] = 'Keyword',
  ['@variable.parameter'] = 'Identifier',
  ['@variable.member'] = 'Identifier',
  ['@property'] = 'Identifier',
  ['@field'] = 'Identifier',
  ['@type'] = 'Identifier',
  ['@type.builtin'] = 'Type',
  ['@type.definition'] = 'Identifier',
  ['@keyword'] = 'Keyword',
  ['@keyword.function'] = 'Keyword',
  ['@keyword.operator'] = 'Keyword',
  ['@keyword.import'] = 'PreProc',
  ['@keyword.return'] = 'Keyword',
  ['@keyword.repeat'] = 'Repeat',
  ['@keyword.conditional'] = 'Conditional',
  ['@keyword.exception'] = 'Exception',
  ['@keyword.modifier'] = 'StorageClass',
  ['@keyword.type'] = 'Keyword',
  ['@keyword.directive'] = 'PreProc',
  ['@operator'] = 'Operator',
  ['@punctuation.delimiter'] = 'Delimiter',
  ['@punctuation.bracket'] = 'Delimiter',
  ['@punctuation.special'] = 'Special',
  ['@tag'] = 'Keyword',
  ['@tag.attribute'] = 'Identifier',
  ['@tag.delimiter'] = 'Delimiter',
  ['@markup.heading'] = 'Title',
  ['@markup.link'] = 'PreProc',
  ['@markup.link.url'] = 'String',
  ['@markup.raw'] = 'String',
  ['@markup.list'] = 'Keyword',
}
for group, target in pairs(links) do
  hl(0, group, { link = target })
end

-- Let syntax determine the colors: semantic tokens can otherwise turn
-- builtin Jai types gray and literals into keywords.
for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
  hl(0, group, {})
end

-- Keep scopes flat like the reference, including when switching from a
-- theme that already enabled the scope module.
hl(0, 'HHScope1', { bg = c.bg })
require('hh.scope').setup({ cycle_len = 1 })
require('hh.macros').setup()
require('hh.dim').setup({ fg = c.dim })
