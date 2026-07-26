-- fourcoder: a direct port of a 4coder theme (the defcolor_* block below).
--
-- 4coder colors syntax by category, not by symbol kind: there is one color for
-- keywords, one for every literal (str/char/int/float/bool/include share
-- defcolor_str_constant), and *everything else* — identifiers, functions,
-- types, operators, punctuation, preproc — falls through to
-- defcolor_text_default. This port keeps that flatness rather than inventing
-- hues 4coder never had, so Type/Function/Identifier/Operator all sit on the
-- muted green. The only extra structure comes from colors the theme does
-- define but Vim has no direct analogue for: defcolor_pop1/pop2 drive
-- diagnostics, defcolor_back_cycle drives the nested-scope backgrounds, and
-- defcolor_text_cycle drives rainbow delimiters.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "fourcoder"

local hl = vim.api.nvim_set_hl

-- Palette -----------------------------------------------------------------
-- Names mirror the defcolor_* they come from, minus the prefix.
local c = {
  back          = "#0c0c0c", -- defcolor_back
  base          = "#000000", -- defcolor_base (text on the bar)
  margin        = "#181818", -- defcolor_margin
  margin_hover  = "#252525", -- defcolor_margin_hover
  margin_active = "#323232", -- defcolor_margin_active
  cursor_line   = "#1e1e1e", -- defcolor_highlight_cursor_line

  text          = "#90b080", -- defcolor_text_default (and preproc)
  comment       = "#2090f0", -- defcolor_comment (blue, the 4coder signature)
  keyword       = "#d08f20", -- defcolor_keyword
  constant      = "#50ff30", -- defcolor_str/char/int/float/bool/include
  special_char  = "#ff0000", -- defcolor_special_character
  ghost         = "#4e5e46", -- defcolor_ghost_character

  highlight     = "#ddee00", -- defcolor_highlight (bg of highlighted text)
  at_highlight  = "#ff44dd", -- defcolor_at_highlight (fg under that bg)
  mark          = "#494949", -- defcolor_mark
  paste         = "#ddee00", -- defcolor_paste
  undo          = "#00ddee", -- defcolor_undo

  cursor        = "#00ee00", -- defcolor_cursor[0]
  cursor_alt    = "#ee7700", -- defcolor_cursor[1]
  at_cursor     = "#0c0c0c", -- defcolor_at_cursor (= back)

  junk          = "#3a0000", -- defcolor_highlight_junk
  white_hl      = "#003a3a", -- defcolor_highlight_white

  bar           = "#888888", -- defcolor_bar
  bar_active    = "#666666", -- defcolor_bar_active
  pop1          = "#3c57dc", -- defcolor_pop1
  pop2          = "#ff0000", -- defcolor_pop2

  line_nr_back  = "#101010", -- defcolor_line_numbers_back
  line_nr_text  = "#404040", -- defcolor_line_numbers_text

  -- defcolor_comment_pop = {0xFF00A000, 0xFFA00000}
  comment_pop1  = "#00a000",
  comment_pop2  = "#a00000",
}

-- defcolor_text_cycle, used for nested delimiters.
local text_cycle = { "#a00000", "#00a000", "#0030b0", "#a0a000" }

-- Cursor ------------------------------------------------------------------
-- 'guicursor' is global and every scheme in colors/ owns it; `hi clear` above
-- wipes the Cursor* groups it names, so each scheme must redefine them or the
-- previous scheme's guicursor is left pointing at nothing. 4coder only ships
-- two cursor colors (defcolor_cursor), so the extra modes borrow from the
-- theme's other accents.
hl(0, "CursorNormal",  { fg = c.at_cursor, bg = c.cursor })
hl(0, "CursorInsert",  { fg = c.at_cursor, bg = c.cursor_alt })
hl(0, "CursorVisual",  { fg = c.at_cursor, bg = c.highlight })
hl(0, "CursorReplace", { fg = c.at_cursor, bg = c.pop2 })
hl(0, "CursorCommand", { fg = c.at_cursor, bg = c.pop1 })
vim.opt.guicursor = {
  "n-c:block-CursorNormal",      -- normal / command -> green block
  "i-ci-ve:block-CursorInsert",  -- insert -> orange block
  "v-V:block-CursorVisual",      -- visual -> yellow block
  "r-cr:block-CursorReplace",    -- replace -> red block
  "o:block-CursorNormal",        -- operator-pending -> green block
}

-- Core UI -----------------------------------------------------------------
hl(0, "Normal",       { fg = c.text, bg = c.back })
hl(0, "NormalNC",     { fg = c.text, bg = c.back })
hl(0, "NormalFloat",  { fg = c.text, bg = c.margin })
hl(0, "FloatBorder",  { fg = c.margin_active, bg = c.margin })
hl(0, "FloatTitle",   { fg = c.keyword, bg = c.margin, bold = true })

hl(0, "Cursor",       { fg = c.at_cursor, bg = c.cursor })
hl(0, "lCursor",      { fg = c.at_cursor, bg = c.cursor })
hl(0, "TermCursor",   { fg = c.at_cursor, bg = c.cursor })

hl(0, "CursorLine",   { bg = c.cursor_line })
hl(0, "CursorColumn", { bg = c.cursor_line })
hl(0, "ColorColumn",  { bg = c.margin })
hl(0, "Visual",       { bg = c.mark })
hl(0, "VisualNOS",    { bg = c.mark })

hl(0, "LineNr",       { fg = c.line_nr_text, bg = c.line_nr_back })
hl(0, "CursorLineNr", { fg = c.text, bg = c.line_nr_back, bold = true })
hl(0, "SignColumn",   { bg = c.line_nr_back })
hl(0, "FoldColumn",   { fg = c.line_nr_text, bg = c.line_nr_back })
hl(0, "Folded",       { fg = c.comment, bg = c.margin })

-- defcolor_bar / bar_active are light greys with defcolor_base (black) text.
hl(0, "StatusLine",   { fg = c.base, bg = c.bar })
hl(0, "StatusLineNC", { fg = c.back, bg = c.bar_active })
hl(0, "WinBar",       { fg = c.text, bg = c.back })
hl(0, "WinBarNC",     { fg = c.line_nr_text, bg = c.back })
hl(0, "TabLine",      { fg = c.text, bg = c.margin })
hl(0, "TabLineFill",  { bg = c.back })
hl(0, "TabLineSel",   { fg = c.base, bg = c.bar, bold = true })

hl(0, "VertSplit",    { fg = c.margin_active, bg = c.back })
hl(0, "WinSeparator", { fg = c.margin_active, bg = c.back })

-- defcolor_highlight is the *background* of highlighted text and
-- defcolor_at_highlight the foreground drawn on top of it.
hl(0, "Search",       { fg = c.at_highlight, bg = c.highlight })
hl(0, "CurSearch",    { fg = c.at_highlight, bg = c.highlight, bold = true })
hl(0, "IncSearch",    { fg = c.back, bg = c.paste })
hl(0, "Substitute",   { fg = c.back, bg = c.paste })
hl(0, "MatchParen",   { fg = c.at_cursor, bg = c.cursor, bold = true })

-- defcolor_list_item{,_hover,_active} are the lister rows.
hl(0, "Pmenu",         { fg = c.text, bg = c.margin })
hl(0, "PmenuSel",      { fg = c.text, bg = c.margin_active })
hl(0, "PmenuSbar",     { bg = c.margin_hover })
hl(0, "PmenuThumb",    { bg = c.margin_active })
-- Fuzzy-matched chars in the completion menu; see handmade.lua for why these
-- need an explicit fg rather than the bold-only default.
hl(0, "PmenuMatch",    { fg = c.keyword })
hl(0, "PmenuMatchSel", { fg = c.keyword })
hl(0, "WildMenu",      { fg = c.text, bg = c.margin_active })
hl(0, "QuickFixLine",  { bg = c.margin_hover })

hl(0, "NonText",      { fg = c.ghost })
hl(0, "SpecialKey",   { fg = c.ghost })
hl(0, "Whitespace",   { fg = c.ghost })
hl(0, "Conceal",      { fg = c.ghost })
hl(0, "EndOfBuffer",  { fg = c.back })
hl(0, "Directory",    { fg = c.keyword })
hl(0, "Title",        { fg = c.keyword, bold = true })

hl(0, "ModeMsg",      { fg = c.text })
hl(0, "MoreMsg",      { fg = c.comment })
hl(0, "Question",     { fg = c.comment })
hl(0, "ErrorMsg",     { fg = c.pop2 })
hl(0, "WarningMsg",   { fg = c.keyword })

-- Syntax ------------------------------------------------------------------
hl(0, "Comment",        { fg = c.comment })
hl(0, "SpecialComment", { fg = c.comment_pop1 })

-- One color for every literal: defcolor_str_constant, which char/int/float/
-- bool/include all alias in the source theme.
hl(0, "String",       { fg = c.constant })
hl(0, "Character",    { fg = c.constant })
hl(0, "Number",       { fg = c.constant })
hl(0, "Float",        { fg = c.constant })
hl(0, "Boolean",      { fg = c.constant })
hl(0, "Constant",     { fg = c.constant })

-- No defcolor for identifiers/functions/types/operators -> text_default.
hl(0, "Identifier",   { fg = c.text })
hl(0, "Function",     { fg = c.text })
hl(0, "Type",         { fg = c.text })
hl(0, "Structure",    { fg = c.text })
hl(0, "Typedef",      { fg = c.text })
hl(0, "Operator",     { fg = c.text })
hl(0, "Delimiter",    { fg = c.text })
hl(0, "Tag",          { fg = c.text })

hl(0, "Statement",    { fg = c.keyword })
hl(0, "Conditional",  { fg = c.keyword })
hl(0, "Repeat",       { fg = c.keyword })
hl(0, "Label",        { fg = c.keyword })
hl(0, "Keyword",      { fg = c.keyword })
hl(0, "Exception",    { fg = c.keyword })
hl(0, "StorageClass", { fg = c.keyword })

-- defcolor_preproc = defcolor_text_default, but defcolor_include is a literal.
hl(0, "PreProc",      { fg = c.text })
hl(0, "Define",       { fg = c.text })
hl(0, "Macro",        { fg = c.text })
hl(0, "PreCondit",    { fg = c.text })
hl(0, "Include",      { fg = c.constant })

hl(0, "Special",      { fg = c.special_char })
hl(0, "SpecialChar",  { fg = c.special_char })
hl(0, "Debug",        { fg = c.pop2 })
hl(0, "Underlined",   { fg = c.pop1, underline = true })
hl(0, "Ignore",       { fg = c.ghost })
hl(0, "Error",        { fg = c.pop2, bold = true })
hl(0, "Todo",         { fg = c.comment_pop2, bg = c.cursor_line, bold = true })

-- The 4coder macro indexer's groups (lua/hh/macros.lua).
hl(0, "YgKeyword",    { fg = c.keyword })
hl(0, "YgType",       { fg = c.text })

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

  ["@variable"]              = "Identifier",
  ["@variable.builtin"]      = "Keyword",
  ["@variable.parameter"]    = "Identifier",
  ["@variable.member"]       = "Identifier",
  ["@property"]              = "Identifier",
  ["@field"]                 = "Identifier",

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
  ["@keyword.operator"]      = "Keyword",
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
  ["@tag.attribute"]         = "Identifier",
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
  ["@lsp.type.property"]      = "Identifier",
  ["@lsp.type.variable"]      = "Identifier",
  ["@lsp.type.comment"]       = "Comment",
  ["@lsp.type.decorator"]     = "PreProc",
  ["@lsp.typemod.enumMember"] = "Constant",
  ["@lsp.mod.inactive"]       = "Normal",
  ["@lsp.typemod.class.inactive"] = "Type",
  ["@lsp.typemod.enum.inactive"] = "Type",
  ["@lsp.typemod.enumMember.inactive"] = "Constant",
  ["@lsp.typemod.interface.inactive"] = "Type",
  ["@lsp.typemod.struct.inactive"] = "Type",
  ["@lsp.typemod.namespace.inactive"] = "Type",
  ["@lsp.typemod.type.inactive"] = "Type",
  ["@lsp.typemod.typeParameter.inactive"] = "Type",
  ["@lsp.typemod.function.inactive"] = "Function",
  ["@lsp.typemod.method.inactive"] = "Function",
  ["@lsp.typemod.macro.inactive"] = "PreProc",
  ["@lsp.typemod.parameter.inactive"] = "Identifier",
  ["@lsp.typemod.property.inactive"] = "Identifier",
  ["@lsp.typemod.variable.inactive"] = "Identifier",
  ["@lsp.typemod.comment.inactive"] = "Comment",
  ["@lsp.typemod.decorator.inactive"] = "PreProc",

  -- Markup
  ["@markup"]                = "Normal",
  ["@markup.heading"]        = "Title",
  ["@markup.raw"]            = "String",
  ["@markup.link"]           = "Underlined",
  ["@markup.list"]           = "Delimiter",
  ["@markup.quote"]          = "Comment",
}
for group, target in pairs(links) do
  hl(0, group, { link = target })
end

-- Ghost text (inlay hints, completion preview) is its own defcolor.
hl(0, "LspInlayHint",       { fg = c.ghost, bg = c.line_nr_back })
hl(0, "LspCodeLens",        { fg = c.ghost })
hl(0, "ComplHint",          { fg = c.ghost })
hl(0, "LspReferenceText",   { bg = c.margin_hover })
hl(0, "LspReferenceRead",   { bg = c.margin_hover })
hl(0, "LspReferenceWrite",  { bg = c.margin_active })

-- Diagnostics -------------------------------------------------------------
-- defcolor_pop2 is 4coder's error red, pop1 its info blue.
hl(0, "DiagnosticError", { fg = c.pop2 })
hl(0, "DiagnosticWarn",  { fg = c.keyword })
hl(0, "DiagnosticInfo",  { fg = c.comment })
hl(0, "DiagnosticHint",  { fg = c.pop1 })
hl(0, "DiagnosticOk",    { fg = c.comment_pop1 })
hl(0, "DiagnosticVirtualTextError", { fg = c.pop2 })
hl(0, "DiagnosticVirtualTextWarn",  { fg = c.keyword })
hl(0, "DiagnosticVirtualTextInfo",  { fg = c.comment })
hl(0, "DiagnosticVirtualTextHint",  { fg = c.pop1 })
hl(0, "DiagnosticUnderlineError", { sp = c.pop2, undercurl = true })
hl(0, "DiagnosticUnderlineWarn",  { sp = c.keyword, undercurl = true })
hl(0, "DiagnosticUnderlineInfo",  { sp = c.comment, undercurl = true })
hl(0, "DiagnosticUnderlineHint",  { sp = c.pop1, undercurl = true })
hl(0, "DiagnosticSignError", { fg = c.pop2, bg = c.line_nr_back })
hl(0, "DiagnosticSignWarn",  { fg = c.keyword, bg = c.line_nr_back })
hl(0, "DiagnosticSignInfo",  { fg = c.comment, bg = c.line_nr_back })
hl(0, "DiagnosticSignHint",  { fg = c.pop1, bg = c.line_nr_back })

-- Git ---------------------------------------------------------------------
-- The diff washes reuse defcolor_highlight_junk (red) and highlight_white
-- (cyan); the add wash is the same idea in the constant green's hue.
hl(0, "GitSignsAdd",    { fg = c.comment_pop1, bg = c.line_nr_back })
hl(0, "GitSignsChange", { fg = c.keyword, bg = c.line_nr_back })
hl(0, "GitSignsDelete", { fg = c.pop2, bg = c.line_nr_back })
hl(0, "DiffAdd",    { bg = "#0a2a0a" })
hl(0, "DiffChange", { bg = c.white_hl })
hl(0, "DiffDelete", { fg = c.pop2, bg = c.junk })
hl(0, "DiffText",   { bg = "#00565a", bold = true })

-- Rainbow delimiters (defcolor_text_cycle) --------------------------------
-- Only four entries upstream; the remaining named groups borrow accents the
-- theme already defines so plugins that reference them are not left unset.
hl(0, "RainbowDelimiterRed",    { fg = text_cycle[1] })
hl(0, "RainbowDelimiterGreen",  { fg = text_cycle[2] })
hl(0, "RainbowDelimiterBlue",   { fg = text_cycle[3] })
hl(0, "RainbowDelimiterYellow", { fg = text_cycle[4] })
hl(0, "RainbowDelimiterOrange", { fg = c.cursor_alt })
hl(0, "RainbowDelimiterViolet", { fg = c.at_highlight })
hl(0, "RainbowDelimiterCyan",   { fg = c.undo })
for i = 1, #text_cycle do
  hl(0, "@punctuation.bracket." .. i, { fg = text_cycle[i] })
end

-- Telescope ---------------------------------------------------------------
hl(0, "TelescopeNormal",         { fg = c.text, bg = c.back })
hl(0, "TelescopeBorder",         { fg = c.margin_active, bg = c.back })
hl(0, "TelescopePromptNormal",   { fg = c.text, bg = c.back })
hl(0, "TelescopePromptBorder",   { fg = c.margin_active, bg = c.back })
hl(0, "TelescopePromptPrefix",   { fg = c.keyword, bg = c.back })
hl(0, "TelescopeResultsNormal",  { fg = c.text, bg = c.back })
hl(0, "TelescopeResultsBorder",  { fg = c.margin_active, bg = c.back })
hl(0, "TelescopePreviewNormal",  { fg = c.text, bg = c.back })
hl(0, "TelescopePreviewBorder",  { fg = c.margin_active, bg = c.back })
hl(0, "TelescopeSelection",      { fg = c.text, bg = c.margin_active })
hl(0, "TelescopeSelectionCaret", { fg = c.cursor, bg = c.margin_active })
hl(0, "TelescopeMultiSelection", { fg = c.constant, bg = c.margin_hover })
hl(0, "TelescopeMatching",       { fg = c.keyword, bold = true })

hl(0, "HarpoonBorder", { fg = c.margin_active })
hl(0, "HarpoonWindow", { fg = c.text })

-- Indent / misc -----------------------------------------------------------
hl(0, "IblIndent", { fg = c.margin_active })
hl(0, "IblScope",  { fg = c.line_nr_text })
hl(0, "WhichKey",         { fg = c.keyword })
hl(0, "WhichKeyGroup",    { fg = c.text })
hl(0, "WhichKeyDesc",     { fg = c.text })
hl(0, "WhichKeySeperator", { fg = c.line_nr_text })
hl(0, "WhichKeyFloat",    { bg = c.margin })
hl(0, "WhichKeyValue",    { fg = c.constant })

-- Nested-scope backgrounds (defcolor_back_cycle) --------------------------
-- Upstream these are ARGB with a low alpha, composited over defcolor_back:
--   0x10A00000 0x0C00A000 0x0C0000A0 0x0CA0A000 over #0c0c0c. Neovim has no
-- alpha, so the blends are precomputed here.
local scope_bgs = {
  "#150b0b", -- 0x10A00000 (red,   alpha 16)
  "#0b130b", -- 0x0C00A000 (green, alpha 12)
  "#0b0b13", -- 0x0C0000A0 (blue,  alpha 12)
  "#13130b", -- 0x0CA0A000 (olive, alpha 12)
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

-- Opt in to the nested-scope background cycle and the project #define indexer
-- (lua/hh/scope.lua, lua/hh/macros.lua), same as handmade.lua.
require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()

return c
