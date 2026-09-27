vim.cmd('hi clear')
if vim.g.syntax_on then vim.cmd('syntax reset') end
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.colors_name = 'naysayer'

-- Jonathan Blow's colors, ported from
-- ~/gits/coder/4coder-non-source/themes/theme-naysayer.4coder.
--
-- Tan text on dark teal, white keywords, green comments, teal strings, pale
-- teal literals and builtin types, and a mid green for macros and the
-- preprocessor. Everything else is the text color, the way his emacs leaves
-- it: functions, identifiers, user types, named constants, operators and
-- punctuation.
local c = {
  bg = '#062329',      -- defcolor_back
  fg = '#d0b892',      -- defcolor_text_default: text, functions, identifiers

  white = '#ffffff',   -- keywords
  comment = '#53d549',
  string = '#3ad0b5',
  constant = '#87ffde', -- numbers, bools, builtin types, escapes
  preproc = '#8cde94', -- macros, preproc

  cursor = '#53d549',
  cursor_insert = '#ffaa00',
  cursor_replace = '#ff0000',
  line = '#0b3335',    -- highlight_cursor_line
  sel = '#0000ff',     -- defcolor_highlight: the authentic naysayer region
  sel_soft = '#103a55',-- margin_active: search matches, menu selection

  float = '#0a2e34',   -- margin_hover: floats and popups
  line_fg = '#126367', -- line numbers, and the mark
  ghost = '#0f4145',   -- ghost_character: non-text
  ok = '#a6e22e',      -- pop1
  warning = '#ffaa00', -- defcolor_base
  error = '#ff0000',   -- pop2
  dim = '#126367',     -- every window behind a picker (lua/hh/dim.lua)
}

local hl = vim.api.nvim_set_hl

local function paint(spec, groups)
  for _, group in ipairs(groups) do
    hl(0, group, spec)
  end
end

paint({ fg = c.fg, bg = c.bg }, { 'Normal', 'NormalNC' })
hl(0, 'NormalFloat', { fg = c.fg, bg = c.float })
paint({ fg = c.line_fg }, { 'VertSplit', 'WinSeparator', 'FloatBorder' })
paint({ fg = c.ghost }, { 'NonText', 'EndOfBuffer' })
-- defcolor_bar is the text color: a tan bar with the background as its text,
-- which is what his mode line's inverse video comes out as.
paint({ fg = c.bg, bg = c.fg }, { 'StatusLine', 'WinBar' })
paint({ fg = c.bg, bg = c.line_fg }, { 'StatusLineNC', 'WinBarNC' })
paint({ fg = c.line_fg, bg = c.bg }, { 'LineNr', 'SignColumn' })
hl(0, 'CursorLineNr', { fg = c.fg, bg = c.bg })
paint({ bg = c.sel }, { 'Visual', 'VisualNOS' })
hl(0, 'MatchParen', { fg = c.white })
hl(0, 'CursorLine', { bg = c.line })
hl(0, 'Directory', { fg = c.fg })
hl(0, 'Title', { fg = c.preproc })

-- The colorscheme owns 'guicursor', since `hi clear` wipes the groups it names.
paint({ bg = c.cursor }, { 'Cursor', 'lCursor' })
hl(0, 'CursorNormal', { fg = c.bg, bg = c.cursor })
hl(0, 'CursorInsert', { fg = c.bg, bg = c.cursor_insert })
hl(0, 'CursorReplace', { fg = c.bg, bg = c.cursor_replace })
vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

-- Syntax
paint({ fg = c.white }, {
  'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception', 'StorageClass',
})
paint({ fg = c.preproc }, {
  'Structure', 'Typedef', 'Macro',
  'PreProc', 'Include', 'Define', 'PreCondit', 'Special',
})
paint({ fg = c.string }, { 'String', 'Character' })
paint({ fg = c.constant }, { 'Constant', 'Number', 'Float', 'Boolean', 'SpecialChar', 'Type' })
paint({ fg = c.fg }, { 'Function', 'Identifier', 'Operator', 'Delimiter' })
paint({ fg = c.comment }, { 'Comment' })
hl(0, 'SpecialComment', { fg = c.ok })

hl(0, 'DiagnosticError', { fg = c.error })
hl(0, 'DiagnosticWarn', { fg = c.warning })
hl(0, 'DiagnosticInfo', { fg = c.ok })
hl(0, 'DiagnosticHint', { fg = c.line_fg })
hl(0, 'ErrorMsg', { fg = c.error })
hl(0, 'WarningMsg', { fg = c.warning })
paint({ fg = c.ok }, { 'Question', 'MoreMsg', 'ModeMsg' })

-- Search and completion
hl(0, 'Search', { fg = c.fg, bg = c.sel_soft })
paint({ fg = c.bg, bg = c.fg }, { 'IncSearch', 'CurSearch' })
hl(0, 'Pmenu', { fg = c.fg, bg = c.float })
hl(0, 'PmenuSel', { fg = c.fg, bg = c.sel_soft })
hl(0, 'PmenuSbar', { bg = c.float })
hl(0, 'PmenuThumb', { bg = c.sel_soft })
-- 'completeopt' has fuzzy, and Neovim marks the matched characters with bold
-- alone, which options.lua strips. Without an fg of their own they vanish.
paint({ fg = c.warning }, { 'PmenuMatch', 'PmenuMatchSel' })

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

  ['@constant'] = 'Identifier',
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
}

for group, target in pairs(links) do
  hl(0, group, { link = target })
end

-- His emacs colors from syntax alone. LSP semantic tokens would paint over
-- treesitter: jails calls u32 a plain type and true a keyword.
for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
  hl(0, group, {})
end

-- Nested scope backgrounds for lua/hh/scope.lua: defcolor_back_cycle.
local scope_bgs = {
  c.bg,
  '#07262c',
  '#082a2e',
  '#092d31',
  '#0a3134',
  '#0b3437',
  '#0c3839',
  '#0d3b3c',
}
for i, bg in ipairs(scope_bgs) do
  hl(0, 'HHScope' .. i, { bg = bg })
end

require('hh.scope').setup({ cycle_len = #scope_bgs })
require('hh.macros').setup()
require('hh.dim').setup({ fg = c.dim })
