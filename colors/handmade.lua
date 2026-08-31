-- handmade: Casey Muratori's Handmade Hero emacs palette, ported from
-- focus/config/themes/handmade-hero.focus-theme.
-- Reuses hh's scope-highlighting and macro/indexer autocmds, then replaces the
-- visual palette. The focus theme leaves region_scope_* flat at the background
-- color; the back_cycle ramp below is ours.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "handmade"

local hl = vim.api.nvim_set_hl

local c = {
  back = "#161616",       -- background0
  panel = "#141414",      -- background1
  panel_deep = "#121212", -- background3/4, title bars, cursor_line_highlight

  -- selection_active is 0100CD upstream — Casey's deep blue block.
  selection = "#0100cd",
  search_active = "#b55f75",
  -- Alpha colors from the focus theme, pre-blended over their backdrop.
  soft_highlight = "#383638", -- FCEDFC26 over back: brackets, indent guides
  list_cursor = "#4b4133",    -- CDAA7D4C over panel
  list_hover = "#26231e",     -- CDAA7D19 over panel
  splitter = "#282520",       -- CDAA7D19 over back
  ruler = "#192619",          -- 40FF4011 over back: faint green pane border

  cursor = "#40ff40", -- the unmistakable bright green
  at_cursor = "#161616", -- char_under_cursor

  text = "#cdaa7d",       -- code_default / ui_default (burlywood)
  identifier = "#bfc9db", -- code_identifier / enum_variant
  comment = "#7f7f7f",    -- code_comment (flat gray)
  comment_multi = "#87919d",
  keyword = "#b8860b",    -- code_keyword / code_type / letter_highlight (goldenrod)
  type = "#b8860b",
  string = "#6b8e23",     -- olive: strings, chars, values
  value = "#6b8e23",
  number = "#d699b5",
  macro = "#e0ad82",      -- code_macro / note / builtin_function
  macro_define = "#2895c7", -- 4coder fleury_color_index_macro: indexed #define names
  modifier = "#e67d74",   -- code_modifier / attribute / directive / headers
  highlight = "#d89b75",
  warning = "#e4d97d",
  error = "#ff0000",

  ui_dim = "#7f7f7f",
  ui_neutral = "#7f7f7f",
  ui_warning = "#ffad34",
  ui_success = "#227722",

  diff_add = "#192c19",    -- region_addition over back
  diff_delete = "#331919", -- region_deletion over back
  code_add = "#33b333",
  code_del = "#e64d4d",
}

local function link(group, target)
  hl(0, group, { link = target })
end

hl(0, "CursorNormal", { fg = c.at_cursor, bg = c.cursor })
hl(0, "CursorInsert", { fg = c.at_cursor, bg = c.ui_warning })
hl(0, "CursorVisual", { fg = c.at_cursor, bg = c.number })
hl(0, "CursorReplace", { fg = c.at_cursor, bg = c.error })
hl(0, "CursorCommand", { fg = c.at_cursor, bg = c.keyword })
vim.opt.guicursor = {
  "n-c:block-CursorNormal",
  "i-ci-ve:block-CursorInsert",
  "v-V:block-CursorVisual",
  "r-cr:block-CursorReplace",
  "o:block-CursorNormal",
}

hl(0, "Normal", { fg = c.text, bg = c.back })
hl(0, "NormalNC", { fg = c.text, bg = c.back })
hl(0, "NormalFloat", { fg = c.text, bg = c.panel })
hl(0, "FloatBorder", { fg = c.splitter, bg = c.panel })
hl(0, "FloatTitle", { fg = c.keyword, bg = c.panel, bold = true })

hl(0, "CursorLine", { bg = c.panel_deep })
hl(0, "CursorColumn", { bg = c.panel_deep })
hl(0, "ColorColumn", { bg = c.panel_deep })
hl(0, "Visual", { bg = c.selection })
hl(0, "VisualNOS", { bg = c.selection })
hl(0, "Search", { bg = c.soft_highlight })
hl(0, "IncSearch", { fg = c.at_cursor, bg = c.search_active })
hl(0, "CurSearch", { fg = c.at_cursor, bg = c.search_active })
hl(0, "Substitute", { fg = c.at_cursor, bg = c.highlight })
hl(0, "MatchParen", { fg = c.highlight })

hl(0, "LspReferenceText", { bg = c.soft_highlight })
hl(0, "LspReferenceRead", { bg = c.soft_highlight })
hl(0, "LspReferenceWrite", { bg = c.soft_highlight })

hl(0, "LineNr", { fg = c.ui_neutral, bg = c.panel_deep })
hl(0, "CursorLineNr", { fg = c.keyword, bg = c.panel_deep, bold = true })
hl(0, "SignColumn", { bg = c.panel_deep })
hl(0, "FoldColumn", { fg = c.ui_neutral, bg = c.panel_deep })
hl(0, "Folded", { fg = c.comment_multi, bg = c.panel })

hl(0, "StatusLine", { fg = c.text, bg = c.panel_deep })
hl(0, "StatusLineNC", { fg = c.ui_neutral, bg = c.panel_deep })
hl(0, "StatusLineNormal", { fg = c.at_cursor, bg = c.cursor, bold = true })
hl(0, "StatusLineInsert", { fg = c.at_cursor, bg = c.ui_warning, bold = true })
hl(0, "StatusLineVisual", { fg = c.at_cursor, bg = c.number, bold = true })
hl(0, "StatusLineReplace", { fg = c.at_cursor, bg = c.error, bold = true })
hl(0, "StatusLineCommand", { fg = c.at_cursor, bg = c.keyword, bold = true })
hl(0, "WinBar", { fg = c.text, bg = c.back })
hl(0, "WinBarNC", { fg = c.ui_dim, bg = c.back })
hl(0, "TabLine", { fg = c.ui_dim, bg = c.panel_deep })
hl(0, "TabLineFill", { bg = c.panel_deep })
hl(0, "TabLineSel", { fg = c.text, bg = c.back, bold = true })
hl(0, "VertSplit", { fg = c.ruler, bg = c.back })
hl(0, "WinSeparator", { fg = c.ruler, bg = c.back })

hl(0, "Pmenu", { fg = c.text, bg = c.panel })
hl(0, "PmenuSel", { fg = c.text, bg = c.list_cursor })
hl(0, "PmenuSbar", { bg = c.panel_deep })
hl(0, "PmenuThumb", { bg = c.list_cursor })
-- The fuzzy-matched characters in the completion menu ('completeopt' has
-- 'fuzzy'). Neovim's default for these is bold-only, which options.lua's
-- strip_decorations then removes — leaving them invisible. Give them a real
-- fg so the match still reads with no decoration. Only fg is set; the bg
-- comes from Pmenu/PmenuSel underneath.
hl(0, "PmenuMatch", { fg = c.highlight })
hl(0, "PmenuMatchSel", { fg = c.highlight })
hl(0, "WildMenu", { fg = c.text, bg = c.list_cursor })
hl(0, "QuickFixLine", { bg = c.list_hover })

hl(0, "MsgArea", { fg = c.text })
hl(0, "ModeMsg", { fg = c.keyword })
hl(0, "MoreMsg", { fg = c.keyword })
hl(0, "Question", { fg = c.string })
hl(0, "ErrorMsg", { fg = c.error })
hl(0, "WarningMsg", { fg = c.ui_warning })

hl(0, "NonText", { fg = c.soft_highlight })
hl(0, "SpecialKey", { fg = c.soft_highlight })
hl(0, "Whitespace", { fg = c.soft_highlight })
hl(0, "Conceal", { fg = c.ui_neutral })
hl(0, "EndOfBuffer", { fg = c.back })
hl(0, "Directory", { fg = c.keyword })
hl(0, "Title", { fg = c.modifier, bold = true })

hl(0, "Comment", { fg = c.comment })
hl(0, "SpecialComment", { fg = c.macro })
hl(0, "Constant", { fg = c.value })
hl(0, "String", { fg = c.string })
hl(0, "Character", { fg = c.string })
hl(0, "Number", { fg = c.number })
hl(0, "Boolean", { fg = c.value })
hl(0, "Float", { fg = c.number })
hl(0, "Identifier", { fg = c.identifier })
hl(0, "Function", { fg = c.text })
hl(0, "Statement", { fg = c.keyword })
hl(0, "Conditional", { fg = c.keyword })
hl(0, "Repeat", { fg = c.keyword })
hl(0, "Label", { fg = c.keyword })
hl(0, "Keyword", { fg = c.keyword })
hl(0, "Exception", { fg = c.keyword })
hl(0, "Operator", { fg = c.text })
hl(0, "PreProc", { fg = c.modifier })
hl(0, "Include", { fg = c.modifier })
hl(0, "Define", { fg = c.modifier })
hl(0, "Macro", { fg = c.macro_define })
hl(0, "PreCondit", { fg = c.modifier })
hl(0, "Type", { fg = c.type })
hl(0, "StorageClass", { fg = c.modifier })
hl(0, "Structure", { fg = c.type })
hl(0, "Typedef", { fg = c.type })
hl(0, "Special", { fg = c.macro })
hl(0, "SpecialChar", { fg = c.macro })
hl(0, "Tag", { fg = c.modifier })
hl(0, "Delimiter", { fg = c.text })
hl(0, "Debug", { fg = c.error })
hl(0, "Underlined", { fg = c.identifier, underline = true })
hl(0, "Ignore", { fg = c.ui_neutral })
hl(0, "Error", { fg = c.error, bold = true })
hl(0, "Todo", { fg = c.at_cursor, bg = c.macro, bold = true })

local links = {
  ["@comment"] = "Comment",
  ["@comment.documentation"] = "Comment",
  ["@comment.error"] = "Error",
  ["@comment.warning"] = "WarningMsg",
  ["@comment.todo"] = "Todo",
  ["@comment.note"] = "SpecialComment",
  ["@string"] = "String",
  ["@string.documentation"] = "String",
  ["@string.regexp"] = "String",
  ["@string.escape"] = "Special",
  ["@string.special"] = "Special",
  ["@character"] = "Character",
  ["@character.special"] = "Special",
  ["@boolean"] = "Boolean",
  ["@number"] = "Number",
  ["@number.float"] = "Float",
  ["@constant"] = "Constant",
  ["@constant.builtin"] = "Constant",
  ["@constant.macro"] = "Macro",
  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Constant",
  ["@variable.parameter"] = "Identifier",
  ["@variable.member"] = "Identifier",
  ["@property"] = "Identifier",
  ["@field"] = "Identifier",
  ["@function"] = "Function",
  ["@function.builtin"] = "Special",
  ["@function.call"] = "Function",
  ["@function.macro"] = "Macro",
  ["@function.method"] = "Function",
  ["@function.method.call"] = "Function",
  ["@constructor"] = "Type",
  ["@type"] = "Type",
  ["@type.builtin"] = "Type",
  ["@type.definition"] = "Type",
  ["@module"] = "Type",
  ["@attribute"] = "PreProc",
  ["@keyword"] = "Keyword",
  ["@keyword.function"] = "Keyword",
  ["@keyword.operator"] = "Keyword",
  ["@keyword.import"] = "PreProc",
  ["@keyword.return"] = "Keyword",
  ["@keyword.repeat"] = "Repeat",
  ["@keyword.conditional"] = "Conditional",
  ["@keyword.exception"] = "Exception",
  ["@keyword.modifier"] = "StorageClass",
  ["@keyword.type"] = "Keyword",
  ["@keyword.directive"] = "PreProc",
  ["@label"] = "Label",
  ["@operator"] = "Operator",
  ["@punctuation"] = "Delimiter",
  ["@punctuation.delimiter"] = "Delimiter",
  ["@punctuation.bracket"] = "Delimiter",
  ["@punctuation.special"] = "Special",
  ["@tag"] = "Keyword",
  ["@tag.attribute"] = "Identifier",
  ["@tag.delimiter"] = "Delimiter",
  ["@markup"] = "Normal",
  ["@markup.heading"] = "Title",
  ["@markup.heading.1"] = "Title",
  ["@markup.heading.2"] = "Title",
  ["@markup.heading.3"] = "Title",
  ["@markup.strong"] = "Normal",
  ["@markup.italic"] = "Normal",
  ["@markup.raw"] = "String",
  ["@markup.raw.block"] = "String",
  ["@markup.link"] = "Underlined",
  ["@markup.link.label"] = "Underlined",
  ["@markup.link.url"] = "Normal",
  ["@markup.list"] = "Delimiter",
  ["@markup.quote"] = "Comment",
  ["@lsp.type.class"] = "Type",
  ["@lsp.type.enum"] = "Type",
  ["@lsp.type.enumMember"] = "Constant",
  ["@lsp.type.interface"] = "Type",
  ["@lsp.type.struct"] = "Type",
  ["@lsp.type.namespace"] = "Type",
  ["@lsp.type.type"] = "Type",
  ["@lsp.type.typeParameter"] = "Type",
  ["@lsp.type.function"] = "Function",
  ["@lsp.type.method"] = "Function",
  ["@lsp.type.macro"] = "Macro",
  ["@lsp.type.parameter"] = "Identifier",
  ["@lsp.type.property"] = "Identifier",
  ["@lsp.type.variable"] = "Identifier",
  ["@lsp.type.comment"] = "Comment",
  ["@lsp.type.decorator"] = "PreProc",
  ["@lsp.typemod.enumMember"] = "Constant",
  ["YgKeyword"] = "Macro",
  ["YgType"] = "Type",
}

for group, target in pairs(links) do
  link(group, target)
end

hl(0, "@function.call.jai", { fg = c.text })
hl(0, "@function.jai", { fg = c.text })
hl(0, "@keyword.jai", { fg = c.keyword })
hl(0, "@keyword.repeat.jai", { fg = c.keyword })
hl(0, "@keyword.conditional.jai", { fg = c.keyword })
hl(0, "@keyword.function.jai", { fg = c.keyword })
hl(0, "@keyword.return.jai", { fg = c.keyword })
hl(0, "@keyword.modifier.jai", { fg = c.modifier })
hl(0, "@keyword.type.jai", { fg = c.keyword })
hl(0, "@keyword.operator.jai", { fg = c.text })
hl(0, "@operator.jai", { fg = c.text })
hl(0, "@punctuation.special.jai", { fg = c.modifier })
hl(0, "@punctuation.delimiter.jai", { fg = c.text })
hl(0, "@punctuation.bracket.jai", { fg = c.text })
hl(0, "@type.jai", { fg = c.type })
hl(0, "@type.builtin.jai", { fg = c.type })
hl(0, "@string.jai", { fg = c.string })
hl(0, "@number.jai", { fg = c.number })
hl(0, "@boolean.jai", { fg = c.value })
hl(0, "@comment.jai", { fg = c.comment })

hl(0, "DiagnosticError", { fg = c.error })
hl(0, "DiagnosticWarn", { fg = c.ui_warning })
hl(0, "DiagnosticInfo", { fg = c.identifier })
hl(0, "DiagnosticHint", { fg = c.ui_dim })
hl(0, "DiagnosticOk", { fg = c.cursor })
hl(0, "DiagnosticVirtualTextError", { fg = c.code_del, bg = c.diff_delete })
hl(0, "DiagnosticVirtualTextWarn", { fg = c.warning, bg = "#2b2519" })
hl(0, "DiagnosticVirtualTextInfo", { fg = c.identifier, bg = c.panel })
hl(0, "DiagnosticVirtualTextHint", { fg = c.ui_dim })
hl(0, "DiagnosticUnderlineError", { sp = c.error, undercurl = true })
hl(0, "DiagnosticUnderlineWarn", { sp = c.ui_warning, undercurl = true })
hl(0, "DiagnosticUnderlineInfo", { sp = c.identifier, undercurl = true })
hl(0, "DiagnosticUnderlineHint", { sp = c.ui_dim, undercurl = true })
hl(0, "DiagnosticSignError", { fg = c.error, bg = c.panel_deep })
hl(0, "DiagnosticSignWarn", { fg = c.ui_warning, bg = c.panel_deep })
hl(0, "DiagnosticSignInfo", { fg = c.identifier, bg = c.panel_deep })
hl(0, "DiagnosticSignHint", { fg = c.ui_dim, bg = c.panel_deep })

hl(0, "GitSignsAdd", { fg = c.code_add, bg = c.panel_deep })
hl(0, "GitSignsChange", { fg = c.warning, bg = c.panel_deep })
hl(0, "GitSignsDelete", { fg = c.code_del, bg = c.panel_deep })
hl(0, "GitSignsChangedelete", { fg = c.ui_warning, bg = c.panel_deep })
hl(0, "DiffAdd", { bg = c.diff_add })
hl(0, "DiffChange", { bg = c.panel })
hl(0, "DiffDelete", { fg = c.code_del, bg = c.diff_delete })
hl(0, "DiffText", { bg = c.list_cursor, bold = true })

hl(0, "TelescopeNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopeBorder", { fg = c.splitter, bg = c.back })
hl(0, "TelescopePromptNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopePromptBorder", { fg = c.splitter, bg = c.back })
hl(0, "TelescopePromptTitle", { fg = c.ui_dim, bg = c.back })
hl(0, "TelescopePromptPrefix", { fg = c.cursor, bg = c.back })
hl(0, "TelescopeResultsNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopeResultsBorder", { fg = c.splitter, bg = c.back })
hl(0, "TelescopeResultsTitle", { fg = c.ui_dim, bg = c.back })
hl(0, "TelescopePreviewNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopePreviewBorder", { fg = c.splitter, bg = c.back })
hl(0, "TelescopePreviewTitle", { fg = c.ui_dim, bg = c.back })
hl(0, "TelescopeSelection", { fg = c.text, bg = c.list_cursor })
hl(0, "TelescopeSelectionCaret", { fg = c.cursor, bg = c.list_cursor })
hl(0, "TelescopeMultiSelection", { fg = c.string, bg = c.list_hover })
hl(0, "TelescopeMatching", { fg = c.keyword, bold = true })

-- Back-cycle for nested scopes. hh.lua indexes these mod #back_cycle (6), so six
-- entries is the full cycle. Upstream leaves region_scope_* flat at #161616; this
-- lifts each nesting level slightly warmer off that base, toward the tan text.
-- The step is half what it was: the old ramp topped out at #2a271f, which read
-- as banding on deeply nested code.
local scope_bgs = {
  "#161616",
  "#181817",
  "#1a1918",
  "#1c1b19",
  "#1e1d1a",
  "#201f1b",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

-- Opt in to the nested-scope background cycle and the project #define indexer
-- (lua/hh/scope.lua, lua/hh/macros.lua). These used to be bootstrapped by
-- dofile-ing the whole hh colorscheme, which set ~400 highlight groups that
-- this file then immediately overwrote.
require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()

return c
