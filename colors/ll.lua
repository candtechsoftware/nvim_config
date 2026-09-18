vim.cmd('hi clear')
if vim.g.syntax_on then vim.cmd('syntax reset') end
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.colors_name = 'll'

-- Keywords, operators and identifiers share one plain tone; calls, types,
-- constants and literals are slate blue, strings sage green, comments a step
-- below the text.
local c = {
  bg = '#1c1c1c',
  fg = '#bcbcb2',

  blue = '#8a9eaf',   -- calls, types, constants, numbers
  green = '#9db08e',  -- strings
  gray = 'gray50',    -- status text
  comment = '#767670', -- fg one step down: comments recede

  -- Chrome. Neutral greys a few steps either side of the background.
  border = '#121212',
  bar = '#111111',
  bar_nc = '#171717',
  sel = '#3a3a3a',    -- visual, search, popup
  sel_hi = '#525252', -- matching paren, popup selection
  line = '#272727',   -- cursor line (directory listing only)
  yellow = '#b09a6a', -- warnings
  rose = '#ad6b7d',   -- current search match, replace-mode cursor, errors
  cursor = '#7fcf9f',
  dim = '#4a4a46', -- every window behind a picker (lua/hh/dim.lua)
}

local hl = vim.api.nvim_set_hl

local function paint(spec, groups)
  for _, group in ipairs(groups) do
    hl(0, group, spec)
  end
end

-- Normal is transparent, so the terminal background shows through everything
-- that names no bg of its own. c.bg is the text color on the cursor and
-- current match.
paint({ fg = c.fg, bg = 'none' }, { 'Normal', 'NormalNC', 'NormalFloat' })
paint({ fg = c.border }, { 'VertSplit', 'WinSeparator' })
paint({ fg = c.gray, bg = c.bar }, { 'StatusLine', 'WinBar' })
paint({ fg = c.gray, bg = c.bar_nc }, { 'StatusLineNC', 'WinBarNC' })
paint({ fg = c.comment }, { 'FloatBorder', 'LineNr', 'SignColumn' })
paint({ bg = c.sel }, { 'Visual', 'VisualNOS' })
paint({ bg = c.sel_hi }, { 'MatchParen' })
paint({ bg = c.line }, { 'CursorLine' })
paint({ fg = c.fg }, { 'Directory' })

-- The colorscheme owns 'guicursor', since `hi clear` wipes the groups it names.
paint({ bg = c.cursor }, { 'Cursor', 'lCursor' })
hl(0, 'CursorNormal', { fg = c.bg, bg = c.cursor })
hl(0, 'CursorInsert', { fg = c.bg, bg = c.blue })
hl(0, 'CursorReplace', { fg = c.bg, bg = c.rose })
vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

-- Syntax
paint({ fg = c.fg }, {
  'PreProc', 'Include', 'Define', 'PreCondit',
  'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception', 'StorageClass',
  'Identifier', 'Operator', 'Delimiter', 'Special', 'SpecialChar',
})
paint({ fg = c.blue }, {
  'Type', 'Structure', 'Typedef',
  'Constant', 'Boolean', 'Number', 'Float', 'Function', 'Macro',
})
paint({ fg = c.comment }, { 'Comment', 'SpecialComment' })
paint({ fg = c.green }, { 'String', 'Character' })

hl(0, 'DiagnosticWarn', { fg = c.yellow })
hl(0, 'WarningMsg', { fg = c.yellow })
hl(0, 'ErrorMsg', { fg = c.rose })

-- Search and completion
hl(0, 'Search', { bg = c.sel })
paint({ fg = c.bg, bg = c.rose }, { 'IncSearch', 'CurSearch' })
hl(0, 'Pmenu', { fg = c.fg })
hl(0, 'PmenuSel', { fg = c.fg, bg = c.sel_hi })
hl(0, 'PmenuSbar', { bg = c.sel })
hl(0, 'PmenuThumb', { bg = c.sel_hi })

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
  ['@character.special'] = 'Special',

  ['@number'] = 'Number',
  ['@number.float'] = 'Float',

  ['@boolean'] = 'Boolean',

  ['@constant'] = 'Constant',
  ['@constant.builtin'] = 'Constant',
  ['@constant.macro'] = 'Macro',

  ['@function'] = 'Function',
  ['@function.builtin'] = 'Function',
  ['@function.call'] = 'Function',
  ['@function.method'] = 'Function',
  ['@function.method.call'] = 'Function',

  ['@variable'] = 'Identifier',
  ['@variable.builtin'] = 'Keyword',
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

-- Nested scope backgrounds for lua/hh/scope.lua, cycled by depth. The
-- outermost paints nothing so it stays the terminal background.
local scope_bgs = {
  'none',
  '#252525',
  '#2e2d2a',
  '#37352f',
}
for i, bg in ipairs(scope_bgs) do
  hl(0, 'HHScope' .. i, { bg = bg })
end

require('hh.scope').setup({ cycle_len = #scope_bgs })
require('hh.macros').setup()
require('hh.dim').setup({ fg = c.dim })
