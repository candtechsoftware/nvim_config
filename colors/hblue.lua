vim.cmd('hi clear')
if vim.g.syntax_on then vim.cmd('syntax reset') end
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.colors_name = 'hblue'

-- colors/hmin.lua with its gold swapped for handmade's macro blue: keywords
-- white, types and macros blue, literals olive, comments gray, and everything
-- else the brown text.
local c = {
  bg = '#0c0c0c',
  fg = '#a08563',

  white = '#b4b4b4',   -- keywords
  blue = '#478980',    -- types, macros
  olive = '#6b8e23',   -- strings, chars, numbers, constants
  comment = '#686868',

  line = '#1f1f27',    -- cursor line, status bar, popups
  sel = '#315268',     -- visual, current match, popup selection
  sel_dim = '#1e2f3a', -- other search matches
  soft = '#272825',    -- borders and filler
  cursor = '#00ee00',
  cursor_insert = '#ee7700',
  red = '#ff0000',
  yellow = '#ffbb00',
  dim = '#5b4d3c',     -- line numbers, every window behind a picker
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
paint({ fg = c.blue, bg = c.line }, { 'StatusLine', 'WinBar' })
paint({ fg = c.comment, bg = c.line }, { 'StatusLineNC', 'WinBarNC' })
paint({ fg = c.dim }, { 'LineNr', 'SignColumn' })
hl(0, 'CursorLineNr', { fg = c.fg })
paint({ bg = c.sel }, { 'Visual', 'VisualNOS', 'MatchParen' })
hl(0, 'CursorLine', { bg = c.line })
hl(0, 'Directory', { fg = c.fg })
hl(0, 'Title', { fg = c.blue })

-- The colorscheme owns 'guicursor', since `hi clear` wipes the groups it names.
paint({ bg = c.cursor }, { 'Cursor', 'lCursor' })
hl(0, 'CursorNormal', { fg = c.bg, bg = c.cursor })
hl(0, 'CursorInsert', { fg = c.bg, bg = c.cursor_insert })
hl(0, 'CursorReplace', { fg = c.bg, bg = c.red })
vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

-- Syntax
paint({ fg = c.white }, {
  'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception', 'StorageClass',
})
paint({ fg = c.blue }, { 'Type', 'Structure', 'Typedef', 'Macro' })
paint({ fg = c.olive }, { 'String', 'Character', 'Number', 'Float', 'Boolean', 'Constant' })
paint({ fg = c.fg }, {
  'PreProc', 'Include', 'Define', 'PreCondit', 'Special', 'SpecialChar',
  'Function', 'Identifier', 'Operator', 'Delimiter',
})
paint({ fg = c.comment }, { 'Comment', 'SpecialComment', 'DiagnosticHint' })

paint({ fg = c.red }, { 'DiagnosticError', 'ErrorMsg' })
paint({ fg = c.yellow }, { 'DiagnosticWarn', 'WarningMsg' })
paint({ fg = c.olive }, { 'DiagnosticInfo', 'Question', 'MoreMsg', 'ModeMsg' })

-- Search and completion
hl(0, 'Search', { bg = c.sel_dim })
paint({ fg = c.fg, bg = c.sel }, { 'IncSearch', 'CurSearch', 'PmenuSel', 'PmenuThumb' })
hl(0, 'PmenuSbar', { bg = c.line })
-- options.lua strips the bold Neovim marks fuzzy matches with, so they need an fg.
paint({ fg = c.blue }, { 'PmenuMatch', 'PmenuMatchSel' })

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

-- Nested scope backgrounds for lua/hh/scope.lua, warming with depth.
local scope_bgs = {
  c.bg,
  '#12100d',
  '#181410',
  '#1e1813',
}
for i, bg in ipairs(scope_bgs) do
  hl(0, 'HHScope' .. i, { bg = bg })
end

require('hh.scope').setup({ cycle_len = #scope_bgs })
require('hh.macros').setup()
require('hh.dim').setup({ fg = c.dim })
