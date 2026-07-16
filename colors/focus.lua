-- focus: the Focus editor's built-in (immutable "default") theme, ported from
-- focus/config/default.focus-config [colors].
-- Reuses hh's scope-highlighting and macro/indexer autocmds, then replaces the
-- visual palette. Unlike the other ports, this theme ships a real scope ramp
-- (region_scope_file/export/module), so back_cycle rides its own background ladder.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "focus"

local hl = vim.api.nvim_set_hl

local c = {
  back = "#15212a",       -- background0
  panel = "#10191f",      -- background1, splitter
  bg2 = "#18262f",        -- background2
  bg3 = "#1a2831",        -- background3, build panel
  bg4 = "#21333f",        -- background4
  title_bar = "#1c303a",  -- build_panel_title_bar
  heredoc = "#090e12",

  selection = "#1c4449",  -- selection_active
  search_active = "#8e772e",
  -- Alpha colors from the theme, pre-blended over their backdrop.
  soft_highlight = "#373f49", -- FCEDFC26 over back: ruler, indent guide, inactive search
  bracket = "#3d4a52",        -- E8FCFE30 over back
  list_cursor = "#1a4e53",    -- 33CCCC4C over panel
  list_hover = "#132a30",     -- 33CCCC19 over panel
  pane_border = "#17464a",    -- 19666688 over back

  cursor = "#26b2b2",         -- teal
  cursor_inactive = "#196666",
  letter_highlight = "#599999",
  at_cursor = "#15212a",

  text = "#bfc9db",       -- code_default / ui_default / punctuation (slate)
  identifier = "#bfc9db",
  comment = "#87919d",
  keyword = "#e67d74",    -- code_keyword / modifier / attribute / directive (salmon)
  type = "#82aaa3",       -- muted teal-green
  func = "#d0c5a9",       -- code_function
  string = "#d4bc7d",
  number = "#d699b5",     -- code_number / value / builtin_variable
  macro = "#e0ad82",      -- code_macro / note / operation / builtin_function
  highlight = "#e4d97d",  -- code_highlight / warning
  error = "#ff0000",

  ui_dim = "#87919d",
  ui_neutral = "#4c4c4c",
  ui_warning = "#f8ad34",
  ui_success = "#227722",

  region_header = "#1a5152",
  diff_add = "#193427",    -- region_success blended over back
  diff_delete = "#322127", -- region_error blended over back
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
hl(0, "CursorCommand", { fg = c.at_cursor, bg = c.macro })
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
hl(0, "FloatBorder", { fg = c.pane_border, bg = c.panel })
hl(0, "FloatTitle", { fg = c.cursor, bg = c.panel, bold = true })

hl(0, "CursorLine", { bg = c.bg2 })
hl(0, "CursorColumn", { bg = c.bg2 })
hl(0, "ColorColumn", { bg = c.bg2 })
hl(0, "Visual", { bg = c.selection })
hl(0, "VisualNOS", { bg = c.selection })
hl(0, "Search", { bg = c.soft_highlight })
hl(0, "IncSearch", { fg = c.at_cursor, bg = c.search_active })
hl(0, "CurSearch", { fg = c.at_cursor, bg = c.search_active })
hl(0, "Substitute", { fg = c.at_cursor, bg = c.highlight })
hl(0, "MatchParen", { bg = c.bracket, bold = true })

hl(0, "LineNr", { fg = c.ui_neutral, bg = c.panel })
hl(0, "CursorLineNr", { fg = c.letter_highlight, bg = c.panel, bold = true })
hl(0, "SignColumn", { bg = c.panel })
hl(0, "FoldColumn", { fg = c.ui_neutral, bg = c.panel })
hl(0, "Folded", { fg = c.ui_dim, bg = c.bg3 })

hl(0, "StatusLine", { fg = c.text, bg = c.title_bar })
hl(0, "StatusLineNC", { fg = c.ui_neutral, bg = c.panel })
hl(0, "StatusLineNormal", { fg = c.at_cursor, bg = c.cursor, bold = true })
hl(0, "StatusLineInsert", { fg = c.at_cursor, bg = c.ui_warning, bold = true })
hl(0, "StatusLineVisual", { fg = c.at_cursor, bg = c.number, bold = true })
hl(0, "StatusLineReplace", { fg = c.at_cursor, bg = c.error, bold = true })
hl(0, "StatusLineCommand", { fg = c.at_cursor, bg = c.macro, bold = true })
hl(0, "WinBar", { fg = c.text, bg = c.back })
hl(0, "WinBarNC", { fg = c.ui_dim, bg = c.back })
hl(0, "TabLine", { fg = c.ui_dim, bg = c.panel })
hl(0, "TabLineFill", { bg = c.panel })
hl(0, "TabLineSel", { fg = c.text, bg = c.back, bold = true })
hl(0, "VertSplit", { fg = c.pane_border, bg = c.back })
hl(0, "WinSeparator", { fg = c.pane_border, bg = c.back })

hl(0, "Pmenu", { fg = c.text, bg = c.panel })
hl(0, "PmenuSel", { fg = c.text, bg = c.list_cursor })
hl(0, "PmenuSbar", { bg = c.panel })
hl(0, "PmenuThumb", { bg = c.list_cursor })
-- Fuzzy-matched chars in the completion menu; see handmade.lua for why these
-- need an explicit fg rather than the bold-only default.
hl(0, "PmenuMatch", { fg = c.highlight })
hl(0, "PmenuMatchSel", { fg = c.highlight })
hl(0, "WildMenu", { fg = c.text, bg = c.list_cursor })
hl(0, "QuickFixLine", { bg = c.list_hover })

hl(0, "MsgArea", { fg = c.text })
hl(0, "ModeMsg", { fg = c.cursor })
hl(0, "MoreMsg", { fg = c.cursor })
hl(0, "Question", { fg = c.type })
hl(0, "ErrorMsg", { fg = c.error })
hl(0, "WarningMsg", { fg = c.ui_warning })

hl(0, "NonText", { fg = c.soft_highlight })
hl(0, "SpecialKey", { fg = c.soft_highlight })
hl(0, "Whitespace", { fg = c.soft_highlight })
hl(0, "Conceal", { fg = c.ui_neutral })
hl(0, "EndOfBuffer", { fg = c.back })
hl(0, "Directory", { fg = c.type })
hl(0, "Title", { fg = c.keyword, bold = true })

hl(0, "Comment", { fg = c.comment })
hl(0, "SpecialComment", { fg = c.macro })
hl(0, "Constant", { fg = c.number })
hl(0, "String", { fg = c.string })
hl(0, "Character", { fg = c.string })
hl(0, "Number", { fg = c.number })
hl(0, "Boolean", { fg = c.number })
hl(0, "Float", { fg = c.number })
hl(0, "Identifier", { fg = c.identifier })
hl(0, "Function", { fg = c.func })
hl(0, "Statement", { fg = c.keyword })
hl(0, "Conditional", { fg = c.keyword })
hl(0, "Repeat", { fg = c.keyword })
hl(0, "Label", { fg = c.keyword })
hl(0, "Keyword", { fg = c.keyword })
hl(0, "Exception", { fg = c.keyword })
hl(0, "Operator", { fg = c.macro })
hl(0, "PreProc", { fg = c.keyword })
hl(0, "Include", { fg = c.keyword })
hl(0, "Define", { fg = c.keyword })
hl(0, "Macro", { fg = c.macro })
hl(0, "PreCondit", { fg = c.keyword })
hl(0, "Type", { fg = c.type })
hl(0, "StorageClass", { fg = c.keyword })
hl(0, "Structure", { fg = c.type })
hl(0, "Typedef", { fg = c.type })
hl(0, "Special", { fg = c.macro })
hl(0, "SpecialChar", { fg = c.macro })
hl(0, "Tag", { fg = c.keyword })
hl(0, "Delimiter", { fg = c.text })
hl(0, "Debug", { fg = c.error })
hl(0, "Underlined", { fg = c.type, underline = true })
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
  ["@lsp.type.enumMember"] = "Identifier",
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
  ["@lsp.typemod.enumMember"] = "Identifier",
  ["YgKeyword"] = "Macro",
  ["YgType"] = "Type",
}

for group, target in pairs(links) do
  link(group, target)
end

hl(0, "@function.call.jai", { fg = c.func })
hl(0, "@function.jai", { fg = c.func })
hl(0, "@keyword.jai", { fg = c.keyword })
hl(0, "@keyword.repeat.jai", { fg = c.keyword })
hl(0, "@keyword.conditional.jai", { fg = c.keyword })
hl(0, "@keyword.function.jai", { fg = c.keyword })
hl(0, "@keyword.return.jai", { fg = c.keyword })
hl(0, "@keyword.modifier.jai", { fg = c.keyword })
hl(0, "@keyword.type.jai", { fg = c.keyword })
hl(0, "@keyword.operator.jai", { fg = c.macro })
hl(0, "@operator.jai", { fg = c.macro })
hl(0, "@punctuation.special.jai", { fg = c.keyword })
hl(0, "@punctuation.delimiter.jai", { fg = c.text })
hl(0, "@punctuation.bracket.jai", { fg = c.text })
hl(0, "@type.jai", { fg = c.type })
hl(0, "@type.builtin.jai", { fg = c.type })
hl(0, "@string.jai", { fg = c.string })
hl(0, "@number.jai", { fg = c.number })
hl(0, "@boolean.jai", { fg = c.number })
hl(0, "@comment.jai", { fg = c.comment })

hl(0, "DiagnosticError", { fg = c.error })
hl(0, "DiagnosticWarn", { fg = c.ui_warning })
hl(0, "DiagnosticInfo", { fg = c.cursor })
hl(0, "DiagnosticHint", { fg = c.ui_dim })
hl(0, "DiagnosticOk", { fg = c.code_add })
hl(0, "DiagnosticVirtualTextError", { fg = c.code_del, bg = c.diff_delete })
hl(0, "DiagnosticVirtualTextWarn", { fg = c.highlight, bg = "#2a2a22" })
hl(0, "DiagnosticVirtualTextInfo", { fg = c.cursor, bg = c.bg2 })
hl(0, "DiagnosticVirtualTextHint", { fg = c.ui_dim })
hl(0, "DiagnosticUnderlineError", { sp = c.error, undercurl = true })
hl(0, "DiagnosticUnderlineWarn", { sp = c.ui_warning, undercurl = true })
hl(0, "DiagnosticUnderlineInfo", { sp = c.cursor, undercurl = true })
hl(0, "DiagnosticUnderlineHint", { sp = c.ui_dim, undercurl = true })
hl(0, "DiagnosticSignError", { fg = c.error, bg = c.panel })
hl(0, "DiagnosticSignWarn", { fg = c.ui_warning, bg = c.panel })
hl(0, "DiagnosticSignInfo", { fg = c.cursor, bg = c.panel })
hl(0, "DiagnosticSignHint", { fg = c.ui_dim, bg = c.panel })

hl(0, "GitSignsAdd", { fg = c.code_add, bg = c.panel })
hl(0, "GitSignsChange", { fg = c.highlight, bg = c.panel })
hl(0, "GitSignsDelete", { fg = c.code_del, bg = c.panel })
hl(0, "GitSignsChangedelete", { fg = c.ui_warning, bg = c.panel })
hl(0, "DiffAdd", { bg = c.diff_add })
hl(0, "DiffChange", { bg = c.bg2 })
hl(0, "DiffDelete", { fg = c.code_del, bg = c.diff_delete })
hl(0, "DiffText", { bg = c.region_header, bold = true })

hl(0, "TelescopeNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopeBorder", { fg = c.pane_border, bg = c.back })
hl(0, "TelescopePromptNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopePromptBorder", { fg = c.pane_border, bg = c.back })
hl(0, "TelescopePromptTitle", { fg = c.ui_dim, bg = c.back })
hl(0, "TelescopePromptPrefix", { fg = c.cursor, bg = c.back })
hl(0, "TelescopeResultsNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopeResultsBorder", { fg = c.pane_border, bg = c.back })
hl(0, "TelescopeResultsTitle", { fg = c.ui_dim, bg = c.back })
hl(0, "TelescopePreviewNormal", { fg = c.text, bg = c.back })
hl(0, "TelescopePreviewBorder", { fg = c.pane_border, bg = c.back })
hl(0, "TelescopePreviewTitle", { fg = c.ui_dim, bg = c.back })
hl(0, "TelescopeSelection", { fg = c.text, bg = c.list_cursor })
hl(0, "TelescopeSelectionCaret", { fg = c.cursor, bg = c.list_cursor })
hl(0, "TelescopeMultiSelection", { fg = c.type, bg = c.list_hover })
hl(0, "TelescopeMatching", { fg = c.letter_highlight, bold = true })

hl(0, "HarpoonBorder", { fg = c.pane_border })
hl(0, "HarpoonWindow", { fg = c.text })
hl(0, "IblIndent", { fg = c.soft_highlight })
hl(0, "IblScope", { fg = c.cursor_inactive })
hl(0, "WhichKey", { fg = c.macro })
hl(0, "WhichKeyGroup", { fg = c.type })
hl(0, "WhichKeyDesc", { fg = c.text })
hl(0, "WhichKeySeperator", { fg = c.ui_neutral })
hl(0, "WhichKeyFloat", { bg = c.panel })
hl(0, "WhichKeyValue", { fg = c.number })

-- Back-cycle for nested scopes. hh.lua indexes these mod #back_cycle (6), so six
-- entries is the full cycle. This theme is the only one that defines real scope
-- colors upstream (region_scope_file/export/module), so the ramp rides its own
-- background ladder: background0 -> 2 -> 3 -> title_bar -> 4, plus one step out.
local scope_bgs = {
  "#15212a",
  "#18262f",
  "#1a2831",
  "#1c303a",
  "#21333f",
  "#26404e",
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
