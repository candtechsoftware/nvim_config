vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "dosbox-black"

local hl = vim.api.nvim_set_hl

local c = {
  back = "#000000",

  panel = "#1a1a1a",
  panel_light = "#262626",
  panel_deep = "#333333",

  text = "#b1b2b9",
  comment = "#d04863",
  dim = "#616161",
  neutral = "#808080",

  keyword = "#f5fef8",
  type = "#eaf0e5",
  storage = "#e9f1e9",

  string = "#3fb6a6",
  number = "#7c80f8",
  special = "#f7ce82",

  status = "#787878",
  tab = "#8f8f8f",

  error_bg = "#250909",
  add_bg = "#092509",
  diff_bg = "#333333",

  pmenu_thumb = "#424242",
  wildmenu = "#525252",
}


-- Main
hl(0, "Normal", {
  fg = c.text,
  bg = c.back,
})

hl(0, "NormalNC", {
  fg = c.text,
  bg = c.back,
})

hl(0, "NormalFloat", {
  fg = c.text,
  bg = c.panel,
})


-- Cursor
hl(0, "Cursor", {
  reverse = true,
})

hl(0, "lCursor", {
  fg = c.back,
  bg = c.back,
})

-- 'guicursor' is global and every scheme in colors/ owns it; `hi clear` at the
-- top wipes the Cursor* groups it names, so blll has to redefine them or the
-- previous scheme's guicursor is left pointing at nothing. Without this block
-- blll fell back to Neovim's default, which is a thin bar in insert mode.
hl(0, "CursorNormal", { fg = c.back, bg = c.keyword })
hl(0, "CursorInsert", { fg = c.back, bg = c.special })
hl(0, "CursorVisual", { fg = c.back, bg = c.number })
hl(0, "CursorReplace", { fg = c.back, bg = c.comment })
hl(0, "CursorCommand", { fg = c.back, bg = c.string })
vim.opt.guicursor = {
  "n-c:block-CursorNormal",     -- normal / command -> white block
  "i-ci-ve:block-CursorInsert", -- insert -> amber block
  "v-V:block-CursorVisual",     -- visual -> periwinkle block
  "r-cr:block-CursorReplace",   -- replace -> red block
  "o:block-CursorNormal",       -- operator-pending -> white block
}

hl(0, "CursorLine", {
  bg = c.panel,
})

hl(0, "CursorColumn", {
  bg = c.panel,
})

hl(0, "CursorLineNr", {
  fg = "#707070",
})


-- Selection / search
hl(0, "Visual", {
  bg = c.panel_deep,
})

hl(0, "VisualNOS", {
  bg = c.panel_deep,
})

hl(0, "Search", {
  bg = c.panel_light,
})

hl(0, "IncSearch", {
  bg = c.panel_deep,
})

hl(0, "MatchParen", {
  bg = c.panel_deep,
})


-- Line / signs / folds
hl(0, "LineNr", {
  fg = c.dim,
})

hl(0, "SignColumn", {
  fg = c.dim,
})

hl(0, "FoldColumn", {
  fg = c.dim,
})

hl(0, "Folded", {
  fg = "#707070",
})


-- UI
hl(0, "ColorColumn", {
  bg = c.panel,
})

hl(0, "NonText", {
  fg = c.dim,
})

hl(0, "SpecialKey", {
  fg = c.dim,
})

hl(0, "Conceal", {
  fg = c.neutral,
})

hl(0, "Directory", {
  fg = "#8f8f8f",
})

hl(0, "Title", {
  fg = c.neutral,
})


-- Status line
hl(0, "StatusLine", {
  fg = c.back,
  bg = c.status,
})

hl(0, "StatusLineNC", {
  fg = "#707070",
  bg = c.panel_light,
})


-- Tabs
hl(0, "TabLine", {
  fg = c.back,
  bg = c.tab,
})

hl(0, "TabLineFill", {
  fg = "#e6e6f0",
  bg = "#8c8c8c",
})

hl(0, "TabLineSel", {
  fg = c.back,
  bg = c.tab,
  bold = true,
})


-- Separators
hl(0, "VertSplit", {
  fg = c.panel_deep,
})

hl(0, "WinSeparator", {
  fg = c.panel_deep,
})


-- Completion menu
hl(0, "Pmenu", {
  bg = c.panel,
})

hl(0, "PmenuSbar", {
  bg = c.panel_light,
})

hl(0, "PmenuSel", {
  bg = c.panel_deep,
})

hl(0, "PmenuThumb", {
  bg = c.pmenu_thumb,
})

hl(0, "WildMenu", {
  bg = c.wildmenu,
})


-- Messages
hl(0, "ModeMsg", {
  fg = c.text,
})

hl(0, "MoreMsg", {
  fg = c.text,
})

hl(0, "Question", {
  fg = c.text,
})

hl(0, "ErrorMsg", {
  bg = c.error_bg,
})

hl(0, "WarningMsg", {
  bg = c.error_bg,
})


-- Diff
hl(0, "DiffAdd", {
  bg = c.add_bg,
})

hl(0, "DiffChange", {
  bg = c.panel,
})

hl(0, "DiffDelete", {
  bg = c.error_bg,
})

hl(0, "DiffText", {
  bg = c.panel_deep,
})


-- Spell
hl(0, "SpellBad", {
  undercurl = true,
  bg = c.error_bg,
})

hl(0, "SpellCap", {
  undercurl = true,
})

hl(0, "SpellLocal", {
  undercurl = true,
  bg = c.add_bg,
})

hl(0, "SpellRare", {
  undercurl = true,
  bg = c.panel_light,
})


-- Syntax
hl(0, "Boolean", {
  fg = "#ecfef6",
})

hl(0, "Comment", {
  fg = c.comment,
})

hl(0, "Constant", {
  fg = c.neutral,
})

hl(0, "Number", {
  fg = c.number,
})

hl(0, "String", {
  fg = c.string,
})

hl(0, "Special", {
  fg = c.special,
})

hl(0, "Statement", {
  fg = c.keyword,
})

hl(0, "Conditional", {
  fg = c.keyword,
})

hl(0, "StorageClass", {
  fg = c.storage,
})

hl(0, "Type", {
  fg = c.type,
})

hl(0, "Identifier", {})

hl(0, "PreProc", {})

hl(0, "Underlined", {})

hl(0, "Ignore", {})

hl(0, "Todo", {
  standout = true,
})


-- Tree-sitter
local links = {
  ["@comment"] = "Comment",
  ["@comment.documentation"] = "Comment",

  ["@string"] = "String",
  ["@string.documentation"] = "String",
  ["@string.regexp"] = "String",
  ["@string.escape"] = "Special",
  ["@string.special"] = "Special",

  ["@character"] = "String",
  ["@character.special"] = "Special",

  ["@boolean"] = "Boolean",
  ["@number"] = "Number",
  ["@number.float"] = "Number",

  ["@constant"] = "Constant",
  ["@constant.builtin"] = "Constant",
  ["@constant.macro"] = "Constant",

  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Constant",
  ["@variable.parameter"] = "Identifier",
  ["@variable.member"] = "Identifier",

  ["@property"] = "Identifier",
  ["@field"] = "Identifier",

  ["@function"] = "Identifier",
  ["@function.builtin"] = "Special",
  ["@function.call"] = "Identifier",
  ["@function.method"] = "Identifier",
  ["@function.method.call"] = "Identifier",

  ["@constructor"] = "Type",

  ["@type"] = "Type",
  ["@type.builtin"] = "Type",
  ["@type.definition"] = "Type",

  ["@module"] = "Type",

  ["@attribute"] = "PreProc",

  ["@keyword"] = "Statement",
  ["@keyword.function"] = "Statement",
  ["@keyword.operator"] = "Statement",
  ["@keyword.import"] = "PreProc",
  ["@keyword.return"] = "Statement",
  ["@keyword.repeat"] = "Statement",
  ["@keyword.conditional"] = "Conditional",
  ["@keyword.exception"] = "Statement",
  ["@keyword.modifier"] = "StorageClass",
  ["@keyword.type"] = "Statement",
  ["@keyword.directive"] = "PreProc",

  ["@label"] = "Statement",
  ["@operator"] = "Statement",

  ["@punctuation"] = "Statement",
  ["@punctuation.delimiter"] = "Statement",
  ["@punctuation.bracket"] = "Statement",
  ["@punctuation.special"] = "Special",

  ["@markup"] = "Normal",
  ["@markup.heading"] = "Title",
  ["@markup.raw"] = "String",
  ["@markup.link"] = "Underlined",
  ["@markup.list"] = "Statement",
  ["@markup.quote"] = "Comment",
}

for group, target in pairs(links) do
  hl(0, group, { link = target })
end


-- Diagnostics
hl(0, "DiagnosticError", {
  bg = c.error_bg,
})

hl(0, "DiagnosticWarn", {
  bg = c.error_bg,
})

hl(0, "DiagnosticInfo", {
  fg = c.neutral,
})

hl(0, "DiagnosticHint", {
  fg = c.dim,
})

hl(0, "DiagnosticVirtualTextError", {
  bg = c.error_bg,
})

hl(0, "DiagnosticVirtualTextWarn", {
  bg = c.error_bg,
})

hl(0, "DiagnosticVirtualTextInfo", {
  bg = c.panel,
})

hl(0, "DiagnosticVirtualTextHint", {
  fg = c.dim,
})

hl(0, "DiagnosticUnderlineError", {
  undercurl = true,
})

hl(0, "DiagnosticUnderlineWarn", {
  undercurl = true,
})

hl(0, "DiagnosticUnderlineInfo", {
  undercurl = true,
})

hl(0, "DiagnosticUnderlineHint", {
  undercurl = true,
})


return c
