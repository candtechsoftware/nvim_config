vim.cmd('hi clear')
if vim.g.syntax_on then vim.cmd('syntax reset') end
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.g.colors_name = 'handmade'

-- Casey Muratori's Handmade Hero colors, ported from his own 4coder theme:
-- ~/gits/coder/4coder-non-source/themes/theme-casey.4coder.
--
-- That is the later era of the show and it carries what his .emacs never had:
-- indexed functions in burnt orange, types in gold, macros and named constants
-- in teal, and braces and operators dimmed under the text. Literals stay olive
-- and comments stay gray, the way they always were.
local c = {
  bg = '#0c0c0c',       -- defcolor_back
  fg = '#a08563',       -- defcolor_text_default

  keyword = '#ac7b0b',
  type = '#d8a51d',     -- index_product_type / index_sum_type
  func = '#cc5735',     -- index_function
  macro = '#478980',    -- index_macro / index_constant: named, not literal
  literal = '#6b8e23',  -- strings, chars, numbers, bools
  preproc = '#dab98f',  -- his .emacs builtin face, unchanged in 4coder
  escape = '#ff0000',   -- special_character
  punct = '#907553',    -- syntax_crap and operators, dimmed under the text
  comment = '#686868',
  note = '#00a000',     -- comment_pop

  cursor = '#00ee00',
  cursor_insert = '#ee7700',
  cursor_replace = '#de2368', -- cursor_macro
  line = '#1f1f27',     -- highlight_cursor_line, and the status bar
  bar_fg = '#cb9401',   -- defcolor_base
  sel = '#315268',      -- defcolor_highlight: the marked range
  sel_dim = '#1e2f3a',  -- it, halfway to the background: other search matches
  hit_fg = '#c4b82b',   -- at_highlight
  brace = '#b09573',    -- brace_highlight
  prompt = '#70971e',   -- pop1
  yellow = '#ffbb00',   -- defcolor_paste
  red = '#ff0000',

  panel = '#171e20',    -- list_item_hover
  panel_sel = '#2d3640',-- list_item_active
  gutter = '#101010',   -- line_numbers_back
  gutter_fg = '#404040',-- line_numbers_text
  soft = '#272825',     -- brace_line over the background: brackets, ghosts
  dim = '#5b4d3c',      -- ghost_character: every window behind a picker
}

local hl = vim.api.nvim_set_hl

local function paint(spec, groups)
  for _, group in ipairs(groups) do
    hl(0, group, spec)
  end
end

paint({ fg = c.fg, bg = c.bg }, { 'Normal', 'NormalNC' })
hl(0, 'NormalFloat', { fg = c.fg, bg = c.panel })
paint({ fg = c.soft }, { 'VertSplit', 'WinSeparator', 'FloatBorder', 'NonText', 'EndOfBuffer' })
paint({ fg = c.bar_fg, bg = c.line }, { 'StatusLine', 'WinBar' })
paint({ fg = c.comment, bg = c.line }, { 'StatusLineNC', 'WinBarNC' })
paint({ fg = c.gutter_fg, bg = c.gutter }, { 'LineNr', 'SignColumn' })
hl(0, 'CursorLineNr', { fg = c.bar_fg, bg = c.gutter })
paint({ bg = c.sel }, { 'Visual', 'VisualNOS' })
hl(0, 'MatchParen', { fg = c.brace })
hl(0, 'CursorLine', { bg = c.line })
hl(0, 'Directory', { fg = c.fg })
hl(0, 'Title', { fg = c.type })

-- The colorscheme owns 'guicursor', since `hi clear` wipes the groups it names.
paint({ bg = c.cursor }, { 'Cursor', 'lCursor' })
hl(0, 'CursorNormal', { fg = c.bg, bg = c.cursor })
hl(0, 'CursorInsert', { fg = c.bg, bg = c.cursor_insert })
hl(0, 'CursorReplace', { fg = c.bg, bg = c.cursor_replace })
vim.o.guicursor = 'n-v-c-o:block-CursorNormal,i-ci-ve:block-CursorInsert,r-cr:block-CursorReplace'

-- Syntax
paint({ fg = c.keyword }, {
  'Keyword', 'Statement', 'Conditional', 'Repeat', 'Label', 'Exception', 'StorageClass',
})
paint({ fg = c.type }, { 'Type', 'Structure', 'Typedef' })
paint({ fg = c.func }, { 'Function' })
paint({ fg = c.macro }, { 'Constant', 'Macro' })
paint({ fg = c.literal }, { 'String', 'Character', 'Number', 'Float', 'Boolean' })
paint({ fg = c.preproc }, { 'PreProc', 'Include', 'Define', 'PreCondit', 'Special' })
paint({ fg = c.escape }, { 'SpecialChar' })
paint({ fg = c.punct }, { 'Operator', 'Delimiter' })
paint({ fg = c.fg }, { 'Identifier' })
paint({ fg = c.comment }, { 'Comment' })
hl(0, 'SpecialComment', { fg = c.note })

hl(0, 'DiagnosticError', { fg = c.red })
hl(0, 'DiagnosticWarn', { fg = c.yellow })
hl(0, 'DiagnosticInfo', { fg = c.prompt })
hl(0, 'DiagnosticHint', { fg = c.comment })
hl(0, 'ErrorMsg', { fg = c.red })
hl(0, 'WarningMsg', { fg = c.yellow })
paint({ fg = c.prompt }, { 'Question', 'MoreMsg', 'ModeMsg' })

-- Search and completion
hl(0, 'Search', { bg = c.sel_dim })
paint({ fg = c.hit_fg, bg = c.sel }, { 'IncSearch', 'CurSearch' })
hl(0, 'Pmenu', { fg = c.fg, bg = c.panel })
hl(0, 'PmenuSel', { fg = c.fg, bg = c.panel_sel })
hl(0, 'PmenuSbar', { bg = c.gutter })
hl(0, 'PmenuThumb', { bg = c.panel_sel })
-- 'completeopt' has fuzzy, and Neovim marks the matched characters with bold
-- alone, which options.lua strips. Without an fg of their own they vanish.
paint({ fg = c.bar_fg }, { 'PmenuMatch', 'PmenuMatchSel' })

-- YgKeyword/YgType are what lua/hh/macros.lua paints project macros and base
-- types with: 4coder's indexer colors, from the same theme.
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

-- Nested scope backgrounds for lua/hh/scope.lua: defcolor_back_cycle, warming
-- with depth.
local scope_bgs = {
  c.bg,
  '#12100d',
  '#181410',
  '#1e1813',
  '#241c15',
  '#2a2018',
}
for i, bg in ipairs(scope_bgs) do
  hl(0, 'HHScope' .. i, { bg = bg })
end

require('hh.scope').setup({ cycle_len = #scope_bgs })
require('hh.macros').setup()
require('hh.dim').setup({ fg = c.dim })
