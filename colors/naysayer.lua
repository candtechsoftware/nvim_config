-- naysayer: dark green-blue scheme with tan text.
-- Ported from Nick Aversano's Emacs naysayer-theme.el, itself inspired by
-- Jonathan Blow's compiler livestreams. Unlike hmin this keeps naysayer's
-- distinct palette (white keywords/functions, green types/punctuation, tan
-- text, bluish variables, teal literals) rather than collapsing to monochrome.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "naysayer"

local hl = vim.api.nvim_set_hl

-- Palette -----------------------------------------------------------------
local c = {
  back     = "#062329", -- editor background
  float    = "#0a2e34", -- floats / popups (slightly lifted)
  line_bg  = "#062329", -- gutter background (same as editor in naysayer)
  cur_line = "#0b3335", -- cursorline / current-line highlight

  fg       = "#d0b892", -- default text (warm tan)
  comment  = "#53d549", -- comments (green)
  punct    = "#8cde94", -- punctuation, operators, types, preproc (light green)
  white    = "#ffffff", -- keywords, functions, builtins
  variable = "#d0b892", -- variables, members, properties (tan, matching naysayer.nvim)
  string   = "#3ad0b5", -- strings (teal)
  constant = "#87ffde", -- constants, numbers, escapes (light teal)

  line_fg  = "#126367", -- line numbers / non-current
  ghost    = "#0f4145", -- non-text, whitespace, indent guides
  sel      = "#0000ff", -- visual selection (authentic naysayer region)
  sel_soft = "#103a55", -- menu selection / search (softer blue)
  cursor   = "#ffffff",

  error    = "#ff0000",
  warning  = "#ffaa00",
  ok       = "#a6e22e",

  -- Monokai accents (used by the original for rainbow delimiters & ANSI)
  yellow   = "#e6db74",
  orange   = "#fd971f",
  red      = "#f92672",
  magenta  = "#fd5ff0",
  blue     = "#66d9ef",
  green    = "#a6e22e",
  cyan     = "#a1efe4",
  violet   = "#ae81ff",
}

-- Core UI -----------------------------------------------------------------
hl(0, "Normal",       { fg = c.fg, bg = c.back })
hl(0, "NormalNC",     { fg = c.fg, bg = c.back })
hl(0, "NormalFloat",  { fg = c.fg, bg = c.float })
hl(0, "FloatBorder",  { fg = c.line_fg, bg = c.float })
hl(0, "FloatTitle",   { fg = c.white, bg = c.float, bold = true })

hl(0, "Cursor",       { fg = c.back, bg = c.cursor })
hl(0, "lCursor",      { fg = c.back, bg = c.cursor })
hl(0, "TermCursor",   { fg = c.back, bg = c.cursor })

hl(0, "CursorLine",   { bg = c.cur_line })
hl(0, "CursorColumn", { bg = c.cur_line })
hl(0, "ColorColumn",  { bg = c.cur_line })
hl(0, "Visual",       { bg = c.sel })
hl(0, "VisualNOS",    { bg = c.sel })

hl(0, "LineNr",       { fg = c.line_fg, bg = c.line_bg })
hl(0, "CursorLineNr", { fg = c.white, bg = c.line_bg, bold = true })
hl(0, "SignColumn",   { bg = c.line_bg })
hl(0, "FoldColumn",   { fg = c.line_fg, bg = c.line_bg })
hl(0, "Folded",       { fg = c.comment, bg = c.cur_line })

hl(0, "StatusLine",   { fg = c.back, bg = c.fg })
hl(0, "StatusLineNC", { fg = c.fg, bg = c.cur_line })
hl(0, "WinBar",       { fg = c.fg, bg = c.back })
hl(0, "WinBarNC",     { fg = c.comment, bg = c.back })
hl(0, "TabLine",      { fg = c.fg, bg = c.cur_line })
hl(0, "TabLineFill",  { bg = c.back })
hl(0, "TabLineSel",   { fg = c.back, bg = c.fg, bold = true })

hl(0, "VertSplit",    { fg = c.cur_line, bg = c.back })
hl(0, "WinSeparator", { fg = c.cur_line, bg = c.back })

hl(0, "Search",       { fg = c.fg, bg = c.sel_soft })
hl(0, "IncSearch",    { fg = c.back, bg = c.warning })
hl(0, "CurSearch",    { fg = c.back, bg = c.warning })
hl(0, "Substitute",   { fg = c.back, bg = c.warning })
hl(0, "MatchParen",   { fg = c.white, bg = c.line_fg, bold = true })

hl(0, "Pmenu",        { fg = c.fg, bg = c.float })
hl(0, "PmenuSel",     { fg = c.white, bg = c.sel_soft })
hl(0, "PmenuSbar",    { bg = c.cur_line })
hl(0, "PmenuThumb",   { bg = c.line_fg })
hl(0, "WildMenu",     { fg = c.white, bg = c.sel_soft })
hl(0, "QuickFixLine", { bg = c.cur_line })

hl(0, "NonText",      { fg = c.ghost })
hl(0, "SpecialKey",   { fg = c.ghost })
hl(0, "Whitespace",   { fg = c.ghost })
hl(0, "Conceal",      { fg = c.ghost })
hl(0, "EndOfBuffer",  { fg = c.back })
hl(0, "Directory",    { fg = c.punct })
hl(0, "Title",        { fg = c.white, bold = true })

hl(0, "ModeMsg",      { fg = c.fg })
hl(0, "MoreMsg",      { fg = c.comment })
hl(0, "Question",     { fg = c.comment })
hl(0, "ErrorMsg",     { fg = c.error })
hl(0, "WarningMsg",   { fg = c.warning })

-- Syntax ------------------------------------------------------------------
hl(0, "Comment",        { fg = c.comment })
hl(0, "SpecialComment", { fg = c.comment })

hl(0, "String",       { fg = c.string })
hl(0, "Character",    { fg = c.string })
hl(0, "Number",       { fg = c.constant })
hl(0, "Float",        { fg = c.constant })
hl(0, "Boolean",      { fg = c.constant })
hl(0, "Constant",     { fg = c.constant })

hl(0, "Identifier",   { fg = c.fg })
hl(0, "Function",     { fg = c.fg })

hl(0, "Statement",    { fg = c.white })
hl(0, "Conditional",  { fg = c.white })
hl(0, "Repeat",       { fg = c.white })
hl(0, "Label",        { fg = c.punct })
hl(0, "Keyword",      { fg = c.white })
hl(0, "Exception",    { fg = c.white })
hl(0, "Operator",     { fg = c.punct })
hl(0, "StorageClass", { fg = c.punct })

hl(0, "Type",         { fg = c.punct })
hl(0, "Structure",    { fg = c.punct })
hl(0, "Typedef",      { fg = c.punct })

hl(0, "PreProc",      { fg = c.punct })
hl(0, "Include",      { fg = c.punct })
hl(0, "Define",       { fg = c.punct })
hl(0, "Macro",        { fg = c.punct })
hl(0, "PreCondit",    { fg = c.punct })

hl(0, "Special",      { fg = c.constant })
hl(0, "SpecialChar",  { fg = c.constant })
hl(0, "Delimiter",    { fg = c.punct })
hl(0, "Tag",          { fg = c.punct })
hl(0, "Debug",        { fg = c.error })
hl(0, "Underlined",   { fg = c.blue, underline = true })
hl(0, "Ignore",       { fg = c.ghost })
hl(0, "Error",        { fg = c.error, bold = true })
hl(0, "Todo",         { fg = c.warning, bg = c.cur_line, bold = true })

-- Treesitter --------------------------------------------------------------
local links = {
  ["@comment"]               = "Comment",
  ["@comment.documentation"] = "Comment",
  ["@comment.error"]         = "Error",
  ["@comment.warning"]       = "WarningMsg",
  ["@comment.todo"]          = "Todo",
  ["@comment.note"]          = "SpecialComment",

  ["@string"]                = "String",
  ["@string.documentation"]  = "String",
  ["@string.regexp"]         = "String",
  ["@string.escape"]         = "Special",
  ["@string.special"]        = "Special",
  ["@character"]             = "Character",
  ["@character.special"]     = "Special",
  ["@boolean"]               = "Boolean",
  ["@number"]                = "Number",
  ["@number.float"]          = "Float",
  ["@constant"]              = "Constant",
  ["@constant.builtin"]      = "Constant",
  ["@constant.macro"]        = "PreProc",

  ["@variable"]              = "@variable",
  ["@variable.builtin"]      = "Constant",
  ["@variable.parameter"]    = "Identifier",
  ["@variable.member"]       = "@variable",
  ["@property"]              = "@variable",
  ["@field"]                 = "@variable",

  ["@function"]              = "Function",
  ["@function.builtin"]      = "Function",
  ["@function.call"]         = "Function",
  ["@function.macro"]        = "PreProc",
  ["@function.method"]       = "Function",
  ["@function.method.call"]  = "Function",
  ["@constructor"]           = "Function",

  ["@type"]                  = "Type",
  ["@type.builtin"]          = "Type",
  ["@type.definition"]       = "Type",
  ["@module"]                = "Type",
  ["@attribute"]             = "PreProc",

  ["@keyword"]               = "Keyword",
  ["@keyword.function"]      = "Keyword",
  ["@keyword.operator"]      = "Operator",
  ["@keyword.import"]        = "PreProc",
  ["@keyword.return"]        = "Keyword",
  ["@keyword.repeat"]        = "Repeat",
  ["@keyword.conditional"]   = "Conditional",
  ["@keyword.exception"]     = "Exception",
  ["@keyword.modifier"]      = "StorageClass",
  ["@keyword.type"]          = "Keyword",
  ["@keyword.directive"]     = "PreProc",
  ["@label"]                 = "Label",

  ["@operator"]              = "Operator",
  ["@punctuation"]           = "Delimiter",
  ["@punctuation.delimiter"] = "Delimiter",
  ["@punctuation.bracket"]   = "Delimiter",
  ["@punctuation.special"]   = "Special",

  ["@tag"]                   = "Tag",
  ["@tag.attribute"]         = "@variable",
  ["@tag.delimiter"]         = "Delimiter",

  -- LSP semantic tokens
  ["@lsp.type.class"]         = "Type",
  ["@lsp.type.enum"]          = "Type",
  ["@lsp.type.enumMember"]    = "Constant",
  ["@lsp.type.interface"]     = "Type",
  ["@lsp.type.struct"]        = "Type",
  ["@lsp.type.namespace"]     = "Type",
  ["@lsp.type.type"]          = "Type",
  ["@lsp.type.typeParameter"] = "Type",
  ["@lsp.type.function"]      = "Function",
  ["@lsp.type.method"]        = "Function",
  ["@lsp.type.macro"]         = "PreProc",
  ["@lsp.type.parameter"]     = "Identifier",
  ["@lsp.type.property"]      = "@variable",
  ["@lsp.type.variable"]      = "@variable",
  ["@lsp.type.comment"]       = "Comment",
  ["@lsp.type.decorator"]     = "PreProc",
  ["@lsp.typemod.enumMember"] = "Constant",

  -- Markup
  ["@markup"]                = "Normal",
  ["@markup.heading"]        = "Title",
  ["@markup.raw"]            = "String",
  ["@markup.link"]           = "Underlined",
  ["@markup.list"]           = "Delimiter",
  ["@markup.quote"]          = "Comment",
}
-- @variable carries naysayer's cool grey-blue; everything else links to base.
hl(0, "@variable", { fg = c.variable })
for group, target in pairs(links) do
  if group ~= "@variable" then
    hl(0, group, { link = target })
  end
end

-- Diagnostics -------------------------------------------------------------
hl(0, "DiagnosticError", { fg = c.error })
hl(0, "DiagnosticWarn",  { fg = c.warning })
hl(0, "DiagnosticInfo",  { fg = c.blue })
hl(0, "DiagnosticHint",  { fg = c.comment })
hl(0, "DiagnosticOk",    { fg = c.ok })
hl(0, "DiagnosticVirtualTextError", { fg = c.error })
hl(0, "DiagnosticVirtualTextWarn",  { fg = c.warning })
hl(0, "DiagnosticVirtualTextInfo",  { fg = c.blue })
hl(0, "DiagnosticVirtualTextHint",  { fg = c.comment })
hl(0, "DiagnosticUnderlineError", { sp = c.error, undercurl = true })
hl(0, "DiagnosticUnderlineWarn",  { sp = c.warning, undercurl = true })
hl(0, "DiagnosticUnderlineInfo",  { sp = c.blue, undercurl = true })
hl(0, "DiagnosticUnderlineHint",  { sp = c.comment, undercurl = true })
hl(0, "DiagnosticSignError", { fg = c.error, bg = c.line_bg })
hl(0, "DiagnosticSignWarn",  { fg = c.warning, bg = c.line_bg })
hl(0, "DiagnosticSignInfo",  { fg = c.blue, bg = c.line_bg })
hl(0, "DiagnosticSignHint",  { fg = c.comment, bg = c.line_bg })

-- Git ---------------------------------------------------------------------
hl(0, "GitSignsAdd",    { fg = c.ok, bg = c.line_bg })
hl(0, "GitSignsChange", { fg = c.warning, bg = c.line_bg })
hl(0, "GitSignsDelete", { fg = c.error, bg = c.line_bg })
hl(0, "DiffAdd",    { bg = "#0a2a1a" })
hl(0, "DiffChange", { bg = "#0a2330" })
hl(0, "DiffDelete", { fg = c.error, bg = "#2a0a12" })
hl(0, "DiffText",   { bg = "#103a55", bold = true })

-- Rainbow delimiters (Monokai accents, matching the original) -------------
local rainbow = { c.violet, c.blue, c.green, c.yellow, c.orange, c.red }
for i = 1, 7 do
  hl(0, "RainbowDelimiter" .. ({ "Red", "Yellow", "Blue", "Orange", "Green", "Violet", "Cyan" })[i],
    { fg = ({ c.red, c.yellow, c.blue, c.orange, c.green, c.violet, c.cyan })[i] })
end
for i = 1, 6 do
  hl(0, "@punctuation.bracket." .. i, { fg = rainbow[i] })
end

-- Telescope ---------------------------------------------------------------
hl(0, "TelescopeNormal",         { fg = c.fg, bg = c.back })
hl(0, "TelescopeBorder",         { fg = c.line_fg, bg = c.back })
hl(0, "TelescopePromptNormal",   { fg = c.fg, bg = c.back })
hl(0, "TelescopePromptBorder",   { fg = c.line_fg, bg = c.back })
hl(0, "TelescopePromptPrefix",   { fg = c.white, bg = c.back })
hl(0, "TelescopeResultsNormal",  { fg = c.fg, bg = c.back })
hl(0, "TelescopeResultsBorder",  { fg = c.line_fg, bg = c.back })
hl(0, "TelescopePreviewNormal",  { fg = c.fg, bg = c.back })
hl(0, "TelescopePreviewBorder",  { fg = c.line_fg, bg = c.back })
hl(0, "TelescopeSelection",      { fg = c.white, bg = c.sel_soft })
hl(0, "TelescopeSelectionCaret", { fg = c.white, bg = c.sel_soft })
hl(0, "TelescopeMatching",       { fg = c.constant, bold = true })

-- Indent / misc -----------------------------------------------------------
hl(0, "IblIndent", { fg = c.ghost })
hl(0, "IblScope",  { fg = c.line_fg })
hl(0, "WhichKey",      { fg = c.white })
hl(0, "WhichKeyGroup", { fg = c.punct })
hl(0, "WhichKeyDesc",  { fg = c.fg })
hl(0, "WhichKeyFloat", { bg = c.float })

return c
