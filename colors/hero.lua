-- hero: warm Fleury/4coder-inspired theme
-- Based on the provided defcolor_* palette. Opts in to the shared scope
-- highlighter and macro indexer (see the bottom of this file).

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "hero"

local hl = vim.api.nvim_set_hl

local c = {
  bar = "#1f1f27",
  base = "#cb9401",
  pop1 = "#70971e",
  pop2 = "#cb9401",
  back = "#0c0c0c",
  margin = "#0c0c0c",
  margin_hover = "#00ff00",

  list_hover = "#171e20",
  list_active = "#2d3640",
  cursor_normal = "#00ee00",
  cursor_insert = "#ee7700",
  cursor_visual = "#cb9401",
  cursor_replace = "#ff0000",
  cursor_command = "#70971e",
  cursor_macro = "#de2368",
  cursor_power = "#efaf2f",
  at_cursor = "#0c0c0c",

  cursor_line = "#1f1f27",
  highlight = "#315268",
  at_highlight = "#c4b82b",
  mark = "#494949",

  text = "#a08563",
  comment = "#686868",
  keyword = "#ac7b0b",
  constant = "#6b8e23",
  preproc = "#dab98f",
  special = "#ff0000",
  ghost = "#5b4d3c",
  paste = "#ffbb00",
  undo = "#80005d",

  text_cycle1 = "#c0a583",
  text_cycle2 = "#b09573",
  line_bg = "#101010",
  line_text = "#404040",

  index_type = "#d8a51d",
  index_function = "#cc5735",
  index_constant = "#478980",
  index_macro = "#478980",
  index_command = "#23de33",
  index_decl = "#c04047",
  syntax_crap = "#907553",
  operators = "#907553",
  brace = "#b09573",
  brace_line = "#9ba290",
  token = "#2f2f37",

  diff_add = "#071207",
  diff_change = "#161306",
  diff_delete = "#160707",
  diff_text = "#241c08",
}

local function link(group, target)
  hl(0, group, { link = target })
end

hl(0, "CursorNormal", { fg = c.at_cursor, bg = c.cursor_normal })
hl(0, "CursorInsert", { fg = c.at_cursor, bg = c.cursor_insert })
hl(0, "CursorVisual", { fg = c.at_cursor, bg = c.cursor_visual })
hl(0, "CursorReplace", { fg = c.at_cursor, bg = c.cursor_replace })
hl(0, "CursorCommand", { fg = c.at_cursor, bg = c.cursor_command })
vim.opt.guicursor = {
  "n-c:block-CursorNormal",
  "i-ci-ve:block-CursorInsert",
  "v-V:block-CursorVisual",
  "r-cr:block-CursorReplace",
  "o:block-CursorNormal",
}

hl(0, "Normal", { fg = c.text, bg = c.back })
hl(0, "NormalNC", { fg = c.text, bg = c.back })
hl(0, "NormalFloat", { fg = c.text, bg = c.list_hover })
hl(0, "FloatBorder", { fg = c.syntax_crap, bg = c.list_hover })
hl(0, "FloatTitle", { fg = c.base, bg = c.list_hover, bold = true })

hl(0, "CursorLine", { bg = c.cursor_line })
hl(0, "CursorColumn", { bg = c.cursor_line })
hl(0, "ColorColumn", { bg = c.cursor_line })
hl(0, "Visual", { bg = c.highlight })
hl(0, "VisualNOS", { bg = c.highlight })
hl(0, "Search", { fg = c.at_highlight, bg = c.highlight })
hl(0, "IncSearch", { fg = c.at_cursor, bg = c.cursor_normal })
hl(0, "CurSearch", { fg = c.at_cursor, bg = c.cursor_normal })
hl(0, "Substitute", { fg = c.back, bg = c.paste })
hl(0, "MatchParen", { fg = c.brace, bold = true })

hl(0, "LineNr", { fg = c.line_text, bg = c.line_bg })
hl(0, "CursorLineNr", { fg = c.base, bg = c.line_bg, bold = true })
hl(0, "SignColumn", { bg = c.line_bg })
hl(0, "FoldColumn", { fg = c.comment, bg = c.line_bg })
hl(0, "Folded", { fg = c.comment, bg = c.cursor_line })

hl(0, "StatusLine", { fg = c.base, bg = c.bar })
hl(0, "StatusLineNC", { fg = c.line_text, bg = c.bar })
hl(0, "StatusLineNormal", { fg = c.back, bg = c.cursor_normal, bold = true })
hl(0, "StatusLineInsert", { fg = c.back, bg = c.cursor_insert, bold = true })
hl(0, "StatusLineVisual", { fg = c.back, bg = c.cursor_visual, bold = true })
hl(0, "StatusLineReplace", { fg = c.back, bg = c.cursor_replace, bold = true })
hl(0, "StatusLineCommand", { fg = c.back, bg = c.cursor_command, bold = true })
hl(0, "WinBar", { fg = c.text, bg = c.back })
hl(0, "WinBarNC", { fg = c.comment, bg = c.back })
hl(0, "TabLine", { fg = c.text, bg = c.bar })
hl(0, "TabLineFill", { bg = c.bar })
hl(0, "TabLineSel", { fg = c.base, bg = c.back, bold = true })
hl(0, "VertSplit", { fg = c.margin, bg = c.back })
hl(0, "WinSeparator", { fg = c.margin, bg = c.back })

hl(0, "Pmenu", { fg = c.text, bg = c.list_hover })
hl(0, "PmenuSel", { fg = c.at_highlight, bg = c.list_active })
hl(0, "PmenuSbar", { bg = c.bar })
hl(0, "PmenuThumb", { bg = c.mark })
hl(0, "WildMenu", { fg = c.at_highlight, bg = c.list_active })
hl(0, "QuickFixLine", { bg = c.list_active })

hl(0, "MsgArea", { fg = c.text })
hl(0, "ModeMsg", { fg = c.pop1 })
hl(0, "MoreMsg", { fg = c.pop1 })
hl(0, "Question", { fg = c.pop1 })
hl(0, "ErrorMsg", { fg = c.special })
hl(0, "WarningMsg", { fg = c.cursor_insert })

hl(0, "NonText", { fg = c.ghost })
hl(0, "SpecialKey", { fg = c.ghost })
hl(0, "Whitespace", { fg = c.ghost })
hl(0, "Conceal", { fg = c.ghost })
hl(0, "EndOfBuffer", { fg = c.back })
hl(0, "Directory", { fg = c.index_type })
hl(0, "Title", { fg = c.base, bold = true })

hl(0, "Comment", { fg = c.comment, italic = true })
hl(0, "SpecialComment", { fg = c.pop1, italic = true })
hl(0, "Constant", { fg = c.constant })
hl(0, "String", { fg = c.constant })
hl(0, "Character", { fg = c.constant })
hl(0, "Number", { fg = c.constant })
hl(0, "Boolean", { fg = c.constant })
hl(0, "Float", { fg = c.constant })
hl(0, "Identifier", { fg = c.text })
hl(0, "Function", { fg = c.index_function })
hl(0, "Statement", { fg = c.keyword })
hl(0, "Conditional", { fg = c.keyword })
hl(0, "Repeat", { fg = c.keyword })
hl(0, "Label", { fg = c.keyword })
hl(0, "Keyword", { fg = c.keyword })
hl(0, "Exception", { fg = c.keyword })
hl(0, "Operator", { fg = c.operators })
hl(0, "PreProc", { fg = c.preproc })
hl(0, "Include", { fg = c.preproc })
hl(0, "Define", { fg = c.preproc })
hl(0, "Macro", { fg = c.index_macro })
hl(0, "PreCondit", { fg = c.preproc })
hl(0, "Type", { fg = c.index_type })
hl(0, "StorageClass", { fg = c.keyword })
hl(0, "Structure", { fg = c.index_type })
hl(0, "Typedef", { fg = c.index_type })
hl(0, "Special", { fg = c.special })
hl(0, "SpecialChar", { fg = c.special })
hl(0, "Tag", { fg = c.pop2 })
hl(0, "Delimiter", { fg = c.syntax_crap })
hl(0, "Debug", { fg = c.special })
hl(0, "Underlined", { fg = c.index_function, underline = true })
hl(0, "Ignore", { fg = c.ghost })
hl(0, "Error", { fg = c.special, bold = true })
hl(0, "Todo", { fg = c.cursor_normal, bg = c.cursor_line, bold = true })

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
  ["@function.builtin"] = "Function",
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
  ["@keyword.operator"] = "Operator",
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
  ["@markup.raw"] = "String",
  ["@markup.link"] = "Underlined",
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

hl(0, "@function.call", { fg = c.index_function })
hl(0, "@function.method.call", { fg = c.index_function })
hl(0, "@function.call.jai", { fg = c.index_function })
hl(0, "@function.jai", { fg = c.index_function })
hl(0, "@keyword.jai", { fg = c.keyword })
hl(0, "@keyword.repeat.jai", { fg = c.keyword })
hl(0, "@keyword.conditional.jai", { fg = c.keyword })
hl(0, "@keyword.function.jai", { fg = c.keyword })
hl(0, "@keyword.return.jai", { fg = c.keyword })
hl(0, "@keyword.modifier.jai", { fg = c.keyword })
hl(0, "@keyword.type.jai", { fg = c.keyword })
hl(0, "@keyword.operator.jai", { fg = c.operators })
hl(0, "@operator.jai", { fg = c.operators })
hl(0, "@punctuation.special.jai", { fg = c.operators })
hl(0, "@punctuation.delimiter.jai", { fg = c.operators })
hl(0, "@punctuation.bracket.jai", { fg = c.syntax_crap })
hl(0, "@type.jai", { fg = c.index_type })
hl(0, "@type.builtin.jai", { fg = c.index_type })
hl(0, "@string.jai", { fg = c.constant })
hl(0, "@number.jai", { fg = c.constant })
hl(0, "@boolean.jai", { fg = c.constant })
hl(0, "@comment.jai", { fg = c.comment, italic = true })

hl(0, "DiagnosticError", { fg = c.special })
hl(0, "DiagnosticWarn", { fg = c.cursor_insert })
hl(0, "DiagnosticInfo", { fg = c.pop1 })
hl(0, "DiagnosticHint", { fg = c.comment })
hl(0, "DiagnosticOk", { fg = c.cursor_normal })
hl(0, "DiagnosticVirtualTextError", { fg = c.special, bg = c.diff_delete })
hl(0, "DiagnosticVirtualTextWarn", { fg = c.cursor_insert, bg = "#160d07" })
hl(0, "DiagnosticVirtualTextInfo", { fg = c.pop1, bg = "#071207" })
hl(0, "DiagnosticVirtualTextHint", { fg = c.comment })
hl(0, "DiagnosticUnderlineError", { sp = c.special, undercurl = true })
hl(0, "DiagnosticUnderlineWarn", { sp = c.cursor_insert, undercurl = true })
hl(0, "DiagnosticUnderlineInfo", { sp = c.pop1, undercurl = true })
hl(0, "DiagnosticUnderlineHint", { sp = c.comment, undercurl = true })
hl(0, "DiagnosticSignError", { fg = c.special, bg = c.line_bg })
hl(0, "DiagnosticSignWarn", { fg = c.cursor_insert, bg = c.line_bg })
hl(0, "DiagnosticSignInfo", { fg = c.pop1, bg = c.line_bg })
hl(0, "DiagnosticSignHint", { fg = c.comment, bg = c.line_bg })

hl(0, "GitSignsAdd", { fg = c.cursor_normal, bg = c.line_bg })
hl(0, "GitSignsChange", { fg = c.cursor_visual, bg = c.line_bg })
hl(0, "GitSignsDelete", { fg = c.special, bg = c.line_bg })
hl(0, "GitSignsChangedelete", { fg = c.cursor_insert, bg = c.line_bg })
hl(0, "DiffAdd", { bg = c.diff_add })
hl(0, "DiffChange", { bg = c.diff_change })
hl(0, "DiffDelete", { fg = c.special, bg = c.diff_delete })
hl(0, "DiffText", { bg = c.diff_text, bold = true })

hl(0, "TelescopeNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopeBorder", { fg = c.line_text, bg = c.back })
hl(0, "TelescopePromptNormal", { fg = c.text_cycle1, bg = c.back })
hl(0, "TelescopePromptBorder", { fg = c.line_text, bg = c.back })
hl(0, "TelescopePromptTitle", { fg = c.comment, bg = c.back })
hl(0, "TelescopePromptPrefix", { fg = c.pop1, bg = c.back })
hl(0, "TelescopeResultsNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopeResultsBorder", { fg = c.line_text, bg = c.back })
hl(0, "TelescopeResultsTitle", { fg = c.comment, bg = c.back })
hl(0, "TelescopePreviewNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopePreviewBorder", { fg = c.line_text, bg = c.back })
hl(0, "TelescopePreviewTitle", { fg = c.comment, bg = c.back })
hl(0, "TelescopeSelection", { fg = c.text_cycle1, bg = c.cursor_line })
hl(0, "TelescopeSelectionCaret", { fg = c.base, bg = c.cursor_line })
hl(0, "TelescopeMultiSelection", { fg = c.pop1, bg = c.cursor_line })
hl(0, "TelescopeMatching", { fg = c.base, bold = true })

hl(0, "HarpoonBorder", { fg = c.syntax_crap })
hl(0, "HarpoonWindow", { fg = c.text })
hl(0, "IblIndent", { fg = c.ghost })
hl(0, "IblScope", { fg = c.syntax_crap })
hl(0, "WhichKey", { fg = c.index_function })
hl(0, "WhichKeyGroup", { fg = c.index_type })
hl(0, "WhichKeyDesc", { fg = c.text })
hl(0, "WhichKeySeperator", { fg = c.syntax_crap })
hl(0, "WhichKeyFloat", { bg = c.list_hover })
hl(0, "WhichKeyValue", { fg = c.constant })

local scope_bgs = {
  "#0c0c0c",
  "#12100d",
  "#181410",
  "#1e1813",
  "#241c15",
  "#2a2018",
  "#30251b",
  "#36291e",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

-- Opt in to the nested-scope background cycle and the project #define indexer.
-- cycle_len is taken from the table above, so all eight steps are used — the
-- old engine hard-coded a modulo of 6 and silently ignored the last two.
require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()

return c
