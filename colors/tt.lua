-- tt — token-palette theme
-- Single colorscheme with light + dark variants, dispatched on
-- `vim.o.background`. Set with `:colorscheme tt` (background follows
-- whatever you've set globally).

---@class TokenPalette
--- Background ramp
--- Dark:  bg0 (darkest) -> bg5 (lightest), bg3 = Normal
--- Light: bg3 (lightest) -> bg0 (darkest), bg4/bg5 also darker than bg3
---@field bg0 string
---@field bg1 string
---@field bg2 string
---@field bg3 string  Normal background
---@field bg4 string
---@field bg5 string
--- Foreground ramp
---@field fg0 string  Normal foreground
---@field fg1 string
---@field fg2 string  Comments, muted text
---@field fg3 string  Most muted foreground
--- Accent hues
---@field accent string   Primary accent (functions, titles)
---@field accent2 string  Secondary accent (keywords, booleans)
--- Syntax hues
---@field blue string
---@field green string
---@field red string
---@field yellow string
---@field purple string
---@field cyan string
---@field orange string   Numeric literals
---@field olive string    Warm yellow-green (numbers)
--- Bright variants (terminal colors 10-14 only)
---@field bright_green string
---@field bright_blue string
---@field bright_purple string
---@field bright_cyan string
--- Diff backgrounds
---@field diff_add string
---@field diff_del string
---@field diff_add_inline string
---@field diff_del_inline string
---@field diff_add_strong string
---@field diff_del_strong string
---@field diff_change string
---@field diff_text string
--- Diagnostic backgrounds
---@field diag_info string
---@field diag_hint string
--- UI elements
---@field sel string
---@field match string
---@field indent string
---@field indent_active string
---@field line_nr string
--- Git sign column
---@field gsign_add string
---@field gsign_change string
---@field gsign_del string
---@field gsign_untracked string
---@field gsign_add_staged string
---@field gsign_change_staged string
---@field gsign_del_staged string
---@field gsign_untracked_staged string

---@param background 'dark'|'light'
---@return TokenPalette
local function palette(background)
  if background ~= 'dark' and background ~= 'light' then
    error('palette: expected "dark" or "light", got: ' .. tostring(background))
  end

  if background == 'light' then
    return {
      bg0 = '#e6e5e1', bg1 = '#ecebe7', bg2 = '#f6f5f1',
      bg3 = '#faf9f5', bg4 = '#f0efeb', bg5 = '#eae9e5',
      fg0 = '#2a2920', fg1 = '#3d3929', fg2 = '#6c675f', fg3 = '#858179',
      accent = '#9a4929', accent2 = '#876032',
      blue = '#527594', green = '#3f643c', red = '#b05555', yellow = '#6e5c20',
      purple = '#7c619a', cyan = '#2d6c6c', orange = '#9a5f22', olive = '#63742f',
      bright_green = '#3a5e37', bright_blue = '#486a88',
      bright_purple = '#6f578c', bright_cyan = '#286363',
      diff_add = '#daf6d5', diff_del = '#ffdada',
      diff_add_inline = '#c0d8bc', diff_del_inline = '#e8c4c4',
      diff_add_strong = '#a8c8a2', diff_del_strong = '#d8aaaa',
      diff_change = '#eee4c6', diff_text = '#e2dac0',
      diag_info = '#dae4f2', diag_hint = '#d6eeea',
      sel = '#dddcd6', match = '#e8d8b0',
      indent = '#e0ddd8', indent_active = '#a8a49c', line_nr = '#b5b2ab',
      gsign_add = '#24831f', gsign_change = '#9d6600', gsign_del = '#c82a2a',
      gsign_untracked = '#a5a29b',
      gsign_add_staged = '#5ea059', gsign_change_staged = '#b28c43',
      gsign_del_staged = '#d17473', gsign_untracked_staged = '#858179',
      back_cycle = {
        '#f2ecf5', -- purple
        '#ecf3ec', -- green
        '#ecf0f8', -- blue
        '#f7eee2', -- amber
        '#f7ecf0', -- pink
        '#ecf5f3', -- cyan
        '#f1efe2', -- olive
        '#eee8f6', -- violet
      },
    }
  end

  return {
    bg0 = '#191918', bg1 = '#1d1d1c', bg2 = '#212120',
    bg3 = '#262624', bg4 = '#2f2f2d', bg5 = '#383835',
    fg0 = '#e8e4dc', fg1 = '#d4cfc6', fg2 = '#938e87', fg3 = '#5a5955',
    accent = '#d97757', accent2 = '#c4956a',
    blue = '#7b9ebd', green = '#7da47a', red = '#c67777', yellow = '#c4a855',
    purple = '#a68bbf', cyan = '#6ba8a8', orange = '#d4914a', olive = '#a8b56b',
    bright_green = '#98bf95', bright_blue = '#96b8d3',
    bright_purple = '#bea5d4', bright_cyan = '#88c0c0',
    diff_add = '#1e3524', diff_del = '#3c2024',
    diff_add_inline = '#2e5232', diff_del_inline = '#5a2529',
    diff_add_strong = '#3a6e3e', diff_del_strong = '#7a2e34',
    diff_change = '#2b2b29', diff_text = '#444039',
    diag_info = '#1e2634', diag_hint = '#1c2e2e',
    sel = '#3a3a37', match = '#4a4030',
    indent = '#333330', indent_active = '#636360', line_nr = '#585855',
    gsign_add = '#7da47a', gsign_change = '#c4a855', gsign_del = '#c67777',
    gsign_untracked = '#7a7670',
    gsign_add_staged = '#5e7a5c', gsign_change_staged = '#88753f',
    gsign_del_staged = '#9a5f5f', gsign_untracked_staged = '#5a5955',
    back_cycle = {
      '#2c2530', -- purple
      '#252e26', -- green
      '#252830', -- blue
      '#322a20', -- amber
      '#322528', -- pink
      '#253030', -- cyan
      '#2c2c22', -- olive
      '#272235', -- violet
    },
  }
end

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then vim.cmd('syntax reset') end
vim.g.colors_name = 'tt'

local p = palette(vim.o.background == 'light' and 'light' or 'dark')
local set = vim.api.nvim_set_hl

-- Frame
set(0, 'Normal',         { fg = p.fg0, bg = p.bg3 })
set(0, 'NormalNC',       { fg = p.fg0, bg = p.bg3 })
set(0, 'NormalFloat',    { fg = p.fg0, bg = p.bg2 })
set(0, 'FloatBorder',    { fg = p.fg3, bg = p.bg2 })
set(0, 'FloatTitle',     { fg = p.accent, bold = true })
set(0, 'VertSplit',      { fg = p.bg1 })
set(0, 'WinSeparator',   { fg = p.bg1 })
set(0, 'EndOfBuffer',    { fg = p.bg3 })

set(0, 'Cursor',         { fg = p.bg3, bg = p.fg0 })
set(0, 'lCursor',        { fg = p.bg3, bg = p.fg0 })
set(0, 'TermCursor',     { fg = p.bg3, bg = p.fg0 })

set(0, 'CursorLine',     { bg = p.bg4 })
set(0, 'CursorColumn',   { bg = p.bg4 })
set(0, 'ColorColumn',    { bg = p.bg2 })

set(0, 'Visual',         { bg = p.sel })
set(0, 'VisualNOS',      { bg = p.sel })

set(0, 'MatchParen',     { bg = p.bg5, bold = true })

set(0, 'LineNr',         { fg = p.line_nr, bg = p.bg3 })
set(0, 'CursorLineNr',   { fg = p.fg0, bg = p.bg3, bold = true })
set(0, 'SignColumn',     { fg = p.fg2, bg = p.bg3 })
set(0, 'FoldColumn',     { fg = p.fg3, bg = p.bg3 })
set(0, 'Folded',         { fg = p.fg2, bg = p.bg2 })

set(0, 'ModeMsg',        { fg = p.fg0 })
set(0, 'MsgArea',        { fg = p.fg0 })
set(0, 'MoreMsg',        { fg = p.green })
set(0, 'Question',       { fg = p.green })
set(0, 'WarningMsg',     { fg = p.yellow, bold = true })
set(0, 'ErrorMsg',       { fg = p.red, bold = true })

set(0, 'Title',          { fg = p.accent, bold = true })
set(0, 'Directory',      { fg = p.blue })

-- Status / tab line
set(0, 'StatusLine',     { fg = p.fg0, bg = p.bg2 })
set(0, 'StatusLineNC',   { fg = p.fg3, bg = p.bg1 })
set(0, 'TabLine',        { fg = p.fg2, bg = p.bg1 })
set(0, 'TabLineSel',     { fg = p.fg0, bg = p.bg3, bold = true })
set(0, 'TabLineFill',    { fg = p.fg3, bg = p.bg1 })
set(0, 'WinBar',         { fg = p.fg0, bg = p.bg3, bold = true })
set(0, 'WinBarNC',       { fg = p.fg3, bg = p.bg3 })

-- Pmenu / completion
set(0, 'Pmenu',          { fg = p.fg0, bg = p.bg2 })
set(0, 'PmenuSel',       { fg = p.fg0, bg = p.bg5, bold = true })
set(0, 'PmenuSbar',      { bg = p.bg2 })
set(0, 'PmenuThumb',     { bg = p.fg3 })
set(0, 'PmenuKind',      { fg = p.yellow, bg = p.bg2 })
set(0, 'PmenuKindSel',   { fg = p.yellow, bg = p.bg5, bold = true })
set(0, 'PmenuExtra',     { fg = p.fg3, bg = p.bg2 })
set(0, 'PmenuExtraSel',  { fg = p.fg3, bg = p.bg5 })

-- Search
set(0, 'Search',         { bg = p.match })
set(0, 'IncSearch',      { fg = p.bg3, bg = p.accent, bold = true })
set(0, 'CurSearch',      { fg = p.bg3, bg = p.accent, bold = true })
set(0, 'Substitute',     { fg = p.bg3, bg = p.yellow })

-- Diff
set(0, 'DiffAdd',        { bg = p.diff_add })
set(0, 'DiffChange',     { bg = p.diff_change })
set(0, 'DiffDelete',     { fg = p.red, bg = p.diff_del })
set(0, 'DiffText',       { bg = p.diff_text, bold = true })

-- Spelling
set(0, 'SpellBad',       { sp = p.red,    undercurl = true })
set(0, 'SpellCap',       { sp = p.blue,   undercurl = true })
set(0, 'SpellLocal',     { sp = p.green,  undercurl = true })
set(0, 'SpellRare',      { sp = p.purple, undercurl = true })

-- Code (classic syntax groups)
set(0, 'Comment',        { fg = p.fg2, italic = true })
set(0, 'SpecialComment', { fg = p.fg2, italic = true, bold = true })

set(0, 'Constant',       { fg = p.orange })
set(0, 'String',         { fg = p.green })
set(0, 'Character',      { fg = p.green })
set(0, 'Number',         { fg = p.orange })
set(0, 'Float',          { fg = p.orange })
set(0, 'Boolean',        { fg = p.accent2 })

set(0, 'Identifier',     { fg = p.fg0 })
set(0, 'Function',       { fg = p.accent })

set(0, 'Statement',      { fg = p.accent2 })
set(0, 'Conditional',    { fg = p.accent2 })
set(0, 'Repeat',         { fg = p.accent2 })
set(0, 'Label',          { fg = p.accent2 })
set(0, 'Operator',       { fg = p.fg2 })
set(0, 'Keyword',        { fg = p.accent2 })
set(0, 'Exception',      { fg = p.red })

set(0, 'PreProc',        { fg = p.purple })
set(0, 'Include',        { fg = p.purple })
set(0, 'Define',         { fg = p.purple })
set(0, 'Macro',          { fg = p.purple })
set(0, 'PreCondit',      { fg = p.purple })

set(0, 'Type',           { fg = p.yellow })
set(0, 'StorageClass',   { fg = p.yellow })
set(0, 'Structure',      { fg = p.yellow })
set(0, 'Typedef',        { fg = p.yellow })

set(0, 'Special',        { fg = p.cyan })
set(0, 'SpecialChar',    { fg = p.cyan })
set(0, 'Tag',            { fg = p.blue })
set(0, 'Delimiter',      { fg = p.fg2 })
set(0, 'Debug',          { fg = p.red })

set(0, 'Underlined',     { fg = p.blue, underline = true })
set(0, 'Ignore',         { fg = p.fg3 })
set(0, 'Error',          { fg = p.red, bold = true })
set(0, 'Todo',           { fg = p.bg3, bg = p.yellow, bold = true })

-- Tree-sitter (@captures)
set(0, '@variable',              { fg = p.fg0 })
set(0, '@variable.builtin',      { fg = p.accent2 })
set(0, '@variable.parameter',    { fg = p.fg1 })
set(0, '@variable.member',       { fg = p.fg1 })
set(0, '@constant',              { fg = p.orange })
set(0, '@constant.builtin',      { fg = p.accent2 })
set(0, '@constant.macro',        { fg = p.purple })
set(0, '@module',                { fg = p.yellow })
set(0, '@label',                 { fg = p.accent2 })
set(0, '@string',                { fg = p.green })
set(0, '@string.escape',         { fg = p.cyan })
set(0, '@string.regexp',         { fg = p.cyan })
set(0, '@string.special',        { fg = p.cyan })
set(0, '@character',             { fg = p.green })
set(0, '@character.special',     { fg = p.cyan })
set(0, '@number',                { fg = p.orange })
set(0, '@number.float',          { fg = p.orange })
set(0, '@boolean',               { fg = p.accent2 })
set(0, '@function',              { fg = p.accent })
set(0, '@function.builtin',      { fg = p.accent })
set(0, '@function.call',         { fg = p.accent })
set(0, '@function.macro',        { fg = p.purple })
set(0, '@function.method',       { fg = p.accent })
set(0, '@function.method.call',  { fg = p.accent })
set(0, '@constructor',           { fg = p.yellow })
set(0, '@operator',              { fg = p.fg2 })
set(0, '@keyword',               { fg = p.accent2 })
set(0, '@keyword.function',      { fg = p.accent2 })
set(0, '@keyword.return',        { fg = p.accent2 })
set(0, '@keyword.operator',      { fg = p.accent2 })
set(0, '@keyword.import',        { fg = p.purple })
set(0, '@keyword.directive',     { fg = p.purple })
set(0, '@keyword.exception',     { fg = p.red })
set(0, '@keyword.conditional',   { fg = p.accent2 })
set(0, '@keyword.repeat',        { fg = p.accent2 })
set(0, '@type',                  { fg = p.yellow })
set(0, '@type.builtin',          { fg = p.yellow })
set(0, '@type.definition',       { fg = p.yellow })
set(0, '@attribute',             { fg = p.purple })
set(0, '@property',              { fg = p.fg1 })
set(0, '@punctuation',           { fg = p.fg2 })
set(0, '@punctuation.bracket',   { fg = p.fg2 })
set(0, '@punctuation.delimiter', { fg = p.fg2 })
set(0, '@punctuation.special',   { fg = p.cyan })
set(0, '@comment',               { fg = p.fg2, italic = true })
set(0, '@comment.todo',          { fg = p.bg3, bg = p.yellow, bold = true })
set(0, '@comment.warning',       { fg = p.bg3, bg = p.yellow, bold = true })
set(0, '@comment.error',         { fg = p.bg3, bg = p.red,    bold = true })
set(0, '@comment.note',          { fg = p.bg3, bg = p.blue,   bold = true })
set(0, '@tag',                   { fg = p.blue })
set(0, '@tag.attribute',         { fg = p.yellow })
set(0, '@tag.delimiter',         { fg = p.fg2 })

-- LSP semantic tokens
set(0, '@lsp.type.namespace',     { link = '@module' })
set(0, '@lsp.type.type',          { link = '@type' })
set(0, '@lsp.type.class',         { link = '@type' })
set(0, '@lsp.type.enum',          { link = '@type' })
set(0, '@lsp.type.interface',     { link = '@type' })
set(0, '@lsp.type.struct',        { link = '@type' })
set(0, '@lsp.type.parameter',     { link = '@variable.parameter' })
set(0, '@lsp.type.variable',      { link = '@variable' })
set(0, '@lsp.type.property',      { link = '@property' })
set(0, '@lsp.type.enumMember',    { link = '@constant' })
set(0, '@lsp.type.function',      { link = '@function' })
set(0, '@lsp.type.method',        { link = '@function.method' })
set(0, '@lsp.type.macro',         { link = '@function.macro' })
set(0, '@lsp.type.decorator',     { link = '@attribute' })

-- Diagnostics
set(0, 'DiagnosticError',         { fg = p.red })
set(0, 'DiagnosticWarn',          { fg = p.yellow })
set(0, 'DiagnosticInfo',          { fg = p.blue })
set(0, 'DiagnosticHint',          { fg = p.cyan })
set(0, 'DiagnosticOk',            { fg = p.green })
set(0, 'DiagnosticUnderlineError', { sp = p.red,    undercurl = true })
set(0, 'DiagnosticUnderlineWarn',  { sp = p.yellow, undercurl = true })
set(0, 'DiagnosticUnderlineInfo',  { sp = p.blue,   undercurl = true })
set(0, 'DiagnosticUnderlineHint',  { sp = p.cyan,   undercurl = true })
set(0, 'DiagnosticVirtualTextError', { fg = p.red,    bg = p.bg2 })
set(0, 'DiagnosticVirtualTextWarn',  { fg = p.yellow, bg = p.bg2 })
set(0, 'DiagnosticVirtualTextInfo',  { fg = p.blue,   bg = p.diag_info })
set(0, 'DiagnosticVirtualTextHint',  { fg = p.cyan,   bg = p.diag_hint })

-- Gitsigns
set(0, 'GitSignsAdd',                { fg = p.gsign_add,       bg = p.bg3 })
set(0, 'GitSignsChange',             { fg = p.gsign_change,    bg = p.bg3 })
set(0, 'GitSignsDelete',             { fg = p.gsign_del,       bg = p.bg3 })
set(0, 'GitSignsUntracked',          { fg = p.gsign_untracked, bg = p.bg3 })
set(0, 'GitSignsAddInline',          { bg = p.diff_add_inline })
set(0, 'GitSignsDeleteInline',       { bg = p.diff_del_inline })
set(0, 'GitSignsAddLn',              { bg = p.diff_add })
set(0, 'GitSignsDeleteLn',           { bg = p.diff_del })
set(0, 'GitSignsChangedeleteLn',     { bg = p.diff_change })
set(0, 'GitSignsStagedAdd',          { fg = p.gsign_add_staged,       bg = p.bg3 })
set(0, 'GitSignsStagedChange',       { fg = p.gsign_change_staged,    bg = p.bg3 })
set(0, 'GitSignsStagedDelete',       { fg = p.gsign_del_staged,       bg = p.bg3 })
set(0, 'GitSignsStagedUntracked',    { fg = p.gsign_untracked_staged, bg = p.bg3 })

-- Telescope
set(0, 'TelescopeNormal',         { fg = p.fg0, bg = p.bg2 })
set(0, 'TelescopeBorder',         { fg = p.fg3, bg = p.bg2 })
set(0, 'TelescopePromptNormal',   { fg = p.fg0, bg = p.bg1 })
set(0, 'TelescopePromptBorder',   { fg = p.bg1, bg = p.bg1 })
set(0, 'TelescopePromptTitle',    { fg = p.bg3, bg = p.accent, bold = true })
set(0, 'TelescopePreviewTitle',   { fg = p.bg3, bg = p.green,  bold = true })
set(0, 'TelescopeResultsTitle',   { fg = p.bg2, bg = p.bg2 })
set(0, 'TelescopeSelection',      { fg = p.fg0, bg = p.sel,    bold = true })
set(0, 'TelescopeSelectionCaret', { fg = p.accent, bg = p.sel })
set(0, 'TelescopeMatching',       { fg = p.accent, bold = true })

-- Indent guides (ibl / mini.indentscope)
set(0, 'IblIndent',                  { fg = p.indent })
set(0, 'IblScope',                   { fg = p.indent_active })
set(0, 'MiniIndentscopeSymbol',      { fg = p.indent_active })

-- Floats / hover docs
set(0, 'NormalFloatBorder',     { fg = p.fg3, bg = p.bg2 })
set(0, 'LspInfoBorder',         { fg = p.fg3, bg = p.bg2 })
set(0, 'LspSignatureActiveParameter', { fg = p.accent, bold = true })
set(0, 'LspReferenceText',      { bg = p.bg5 })
set(0, 'LspReferenceRead',      { bg = p.bg5 })
set(0, 'LspReferenceWrite',     { bg = p.bg5, bold = true })

-- which-key
set(0, 'WhichKey',          { fg = p.accent, bold = true })
set(0, 'WhichKeyGroup',     { fg = p.yellow })
set(0, 'WhichKeyDesc',      { fg = p.fg0 })
set(0, 'WhichKeySeparator', { fg = p.fg3 })
set(0, 'WhichKeyFloat',     { bg = p.bg2 })

-- Misc
set(0, 'Conceal',           { fg = p.fg3 })
set(0, 'NonText',           { fg = p.fg3 })
set(0, 'SpecialKey',        { fg = p.fg3 })
set(0, 'Whitespace',        { fg = p.bg5 })
set(0, 'QuickFixLine',      { bg = p.bg5, bold = true })
set(0, 'qfLineNr',          { fg = p.line_nr })
set(0, 'qfFileName',        { fg = p.blue })

-- Terminal ANSI 0..15
vim.g.terminal_color_0  = p.bg0
vim.g.terminal_color_1  = p.red
vim.g.terminal_color_2  = p.green
vim.g.terminal_color_3  = p.yellow
vim.g.terminal_color_4  = p.blue
vim.g.terminal_color_5  = p.purple
vim.g.terminal_color_6  = p.cyan
vim.g.terminal_color_7  = p.fg0
vim.g.terminal_color_8  = p.fg3
vim.g.terminal_color_9  = p.red
vim.g.terminal_color_10 = p.bright_green
vim.g.terminal_color_11 = p.yellow
vim.g.terminal_color_12 = p.bright_blue
vim.g.terminal_color_13 = p.bright_purple
vim.g.terminal_color_14 = p.bright_cyan
vim.g.terminal_color_15 = p.fg0

-- Nested scope background cycle (consumed by hh.lua's scope highlighter)
for i, bg in ipairs(p.back_cycle) do
  set(0, 'HHScope' .. i, { bg = bg })
end
