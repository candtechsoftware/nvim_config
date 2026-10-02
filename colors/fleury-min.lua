vim.cmd('hi clear')
if vim.g.syntax_on then vim.cmd('syntax reset') end
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.colors_name = 'fleury-min'

-- Fleury's 4coder theme (~/gits/coder/4coder-non-source/themes/theme-fleury.4coder)
-- cut down to its defining tones: gold keywords, types and macros, red-orange
-- functions, orange literals, gray comments, and everything else the tan text.
local c = {
  bg = '#020202',
  fg = '#b99468',

  keyword = '#f0c674',   -- keywords, directives, types, macros
  func = '#de451f',      -- index_function
  literal = '#ffa900',   -- strings, chars, numbers, constants, the status bar
  comment = '#666666',

  line = '#1e1e1e',      -- cursor line, status bar, popups
  sel = '#303040',       -- defcolor_highlight
  hit = '#ff44dd',       -- at_highlight: the current match's text
  soft = '#222425',      -- defcolor_margin: borders and filler
  cursor = '#00ee00',
  cursor_insert = '#e0741b',
  red = '#ff0000',
  dim = '#404040',       -- line numbers, every window behind a picker
}

local hl = vim.api.nvim_set_hl

local function paint(spec, groups)
  for _, group in ipairs(groups) do
    hl(0, group, spec)
  end
end

paint({ fg = c.fg, bg = c.bg }, { 'Normal', 'NormalNC' })
paint({ fg = c.fg, bg = c.line }, { 'NormalFloat', 'Pmenu' })
paint({ fg = c.soft }, { 'VertSplit', 'WinSeparator', 'FloatBorder', 'NonText', 'EndOfBuffer' })
paint({ fg = c.literal, bg = c.line }, { 'StatusLine', 'WinBar' })
paint({ fg = c.comment, bg = c.line }, { 'StatusLineNC', 'WinBarNC' })
paint({ fg = c.dim }, { 'LineNr', 'SignColumn' })
hl(0, 'CursorLineNr', { fg = c.fg })
paint({ bg = c.sel }, { 'Visual', 'VisualNOS', 'MatchParen', 'Search' })
hl(0, 'CursorLine', { bg = c.line })
hl(0, 'Directory', { fg = c.fg })
hl(0, 'Title', { fg = c.keyword })

-- The colorscheme owns 'guicursor', since `hi clear` wipes the groups it names.
paint({ bg = c.cursor }, { 'Cursor', 'lCursor' })
hl(0, 'CursorNormal', { fg = c.bg, bg = c.cursor })
hl(0, 'CursorInsert', { fg = c.bg, bg = c.cursor_insert })
hl(0, 'CursorReplace', { fg = c.bg, bg = c.red })
vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

-- Syntax
paint({ fg = c.keyword }, {
  'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception', 'StorageClass',
  'PreProc', 'Include', 'Define', 'PreCondit', 'Macro',
  'Type', 'Structure', 'Typedef',
})
paint({ fg = c.func }, { 'Function' })
paint({ fg = c.literal }, { 'String', 'Character', 'Number', 'Float', 'Boolean', 'Constant' })
paint({ fg = c.fg }, { 'Special', 'SpecialChar', 'Identifier', 'Operator', 'Delimiter' })
paint({ fg = c.comment }, { 'Comment', 'SpecialComment', 'DiagnosticHint' })

paint({ fg = c.red }, { 'DiagnosticError', 'ErrorMsg' })
paint({ fg = c.literal }, { 'DiagnosticWarn', 'WarningMsg' })
paint({ fg = c.keyword }, { 'DiagnosticInfo', 'Question', 'MoreMsg', 'ModeMsg' })

-- Search and completion
paint({ fg = c.hit, bg = c.sel }, { 'IncSearch', 'CurSearch' })
paint({ fg = c.fg, bg = c.sel }, { 'PmenuSel', 'PmenuThumb' })
hl(0, 'PmenuSbar', { bg = c.line })
-- options.lua strips the bold Neovim marks fuzzy matches with, so they need an fg.
paint({ fg = c.keyword }, { 'PmenuMatch', 'PmenuMatchSel' })

-- YgKeyword/YgType are what lua/hh/macros.lua paints project macros and base types with.
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
  ['@constant.builtin'] = 'Constant',
  ['@constant.macro'] = 'Macro',

  ['@function'] = 'Function',
  ['@function.call'] = 'Function',
  ['@function.method'] = 'Function',
  ['@function.method.call'] = 'Function',
  ['@function.macro'] = 'Macro',
  ['@function.builtin'] = 'Function',

  ['@variable'] = 'Identifier',
  ['@variable.builtin'] = 'Special',
  ['@variable.parameter'] = 'Identifier',
  ['@variable.member'] = 'Identifier',

  ['@property'] = 'Identifier',
  ['@field'] = 'Identifier',

  ['@type'] = 'Type',
  ['@type.builtin'] = 'Type',
  ['@type.definition'] = 'Type',

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
}

for group, target in pairs(links) do
  hl(0, group, { link = target })
end

-- No lua/hh/scope.lua: Fleury's back_cycle keeps the plain background through
-- every depth real code reaches.
require('hh.macros').setup()
require('hh.dim').setup({ fg = c.dim })
