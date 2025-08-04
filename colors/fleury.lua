-- Fleury colorscheme for Neovim
-- Based on the Emacs fleury theme
-- Rewritten from scratch

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "fleury"
vim.opt.termguicolors = true

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Color palette (from Emacs theme)
local colors = {
  NONE = "NONE",
  rich_black = "#020202",
  light_bronze = "#b99468",
  lime_green = "#003a3a",
  charcoal_gray = "#212121",
  charcoal_gray_lite = "#1e1e1e",
  gunmetal_blue = "#303040",
  dark_slate = "#222425",
  amber_gold = "#fcaa05",
  medium_gray = "#404040",
  jet_black = "#121212",
  dim_gray = "#666666",
  goldenrod = "#f0c674",
  bright_orange = "#ffaa00",
  dusty_rose = "#dc7575",
  sunflower_yellow = "#edb211",
  burnt_orange = "#de451f",
  sky_blue = "#2895c7",
  sky_blue_lite = "#2f2f38",
  bright_red = "#ff0000",
  fresh_green = "#2ab34f",
  lime_green_alt = "#002928",
  vivid_vermilion = "#f0500c",
  golden_yellow = "#f0bb0c",
  pure_black = "#000000",
  aqua_ice = "#8ffff2",
  dusty_sage = "#9ba290",
  coffee_brown = "#63523d",
}

-- Editor highlights
hi("Normal", { fg = colors.light_bronze, bg = colors.rich_black })
hi("NormalFloat", { fg = colors.light_bronze, bg = colors.rich_black })
hi("Comment", { fg = colors.dim_gray })
hi("Constant", { fg = colors.bright_orange })
hi("String", { fg = colors.bright_orange })
hi("Character", { fg = colors.bright_orange })
hi("Number", { fg = colors.bright_orange })
hi("Boolean", { fg = colors.bright_orange })
hi("Float", { fg = colors.bright_orange })
hi("Identifier", { fg = colors.light_bronze })
hi("Function", { fg = colors.burnt_orange })
hi("Statement", { fg = colors.goldenrod })
hi("Conditional", { fg = colors.goldenrod })
hi("Repeat", { fg = colors.goldenrod })
hi("Label", { fg = colors.goldenrod })
hi("Operator", { fg = colors.light_bronze })
hi("Keyword", { fg = colors.goldenrod })
hi("Exception", { fg = colors.goldenrod })
hi("PreProc", { fg = colors.dusty_rose })
hi("Include", { fg = colors.dusty_rose })
hi("Define", { fg = colors.dusty_rose })
hi("Title", { fg = colors.light_bronze })
hi("Macro", { fg = colors.dusty_rose })
hi("PreCondit", { fg = colors.dusty_rose })
hi("Type", { fg = colors.sunflower_yellow })
hi("StorageClass", { fg = colors.goldenrod })
hi("Structure", { fg = colors.sunflower_yellow })
hi("Typedef", { fg = colors.sunflower_yellow })
hi("Special", { fg = colors.dusty_rose })
hi("SpecialComment", { fg = colors.fresh_green })

-- Visual
hi("Visual", { bg = colors.lime_green })
hi("VisualNOS", { bg = colors.lime_green })

-- Cursor and lines
hi("Cursor", { bg = colors.fresh_green, fg = colors.NONE })
hi("CursorLine", { bg = colors.charcoal_gray_lite })
hi("CursorColumn", { bg = colors.charcoal_gray_lite })
hi("CursorLineNr", { fg = colors.light_bronze, bg = colors.charcoal_gray_lite, bold = true })
hi("LineNr", { fg = colors.medium_gray, bg = colors.rich_black })

-- Search
hi("Search", { fg = colors.pure_black, bg = colors.vivid_vermilion })
hi("IncSearch", { fg = colors.pure_black, bg = colors.golden_yellow })

-- Status line
hi("StatusLine", { fg = colors.light_bronze, bg = colors.dark_slate })
hi("StatusLineNC", { fg = colors.medium_gray, bg = colors.jet_black })
hi("TabLine", { bg = colors.jet_black, fg = colors.medium_gray })
hi("TabLineFill", { bg = colors.jet_black })
hi("TabLineSel", { fg = colors.light_bronze, bg = colors.dark_slate })

-- Popup menus
hi("Pmenu", { fg = colors.light_bronze, bg = colors.dark_slate })
hi("PmenuSel", { fg = colors.pure_black, bg = colors.amber_gold })
hi("PmenuSbar", { bg = colors.medium_gray })
hi("PmenuThumb", { bg = colors.light_bronze })

-- Splits and borders
hi("VertSplit", { fg = colors.dark_slate })
hi("WinSeparator", { fg = colors.dark_slate })

-- Errors and warnings
hi("Error", { fg = colors.bright_red, bold = true })
hi("ErrorMsg", { fg = colors.bright_red })
hi("WarningMsg", { fg = colors.coffee_brown, bold = true })

-- Diff
hi("DiffAdd", { bg = "#003a00" })
hi("DiffChange", { bg = "#3a3a00" })
hi("DiffDelete", { bg = "#3a0000" })
hi("DiffText", { bg = "#5a5a00" })

-- Folding
hi("Folded", { fg = colors.dim_gray })
hi("FoldColumn", { fg = colors.NONE })

-- Matching
hi("MatchParen", { bg = colors.sky_blue_lite })

-- Spell
hi("SpellBad", { fg = colors.bright_red, underline = true })
hi("SpellCap", { fg = colors.amber_gold })
hi("SpellLocal", { fg = colors.amber_gold })
hi("SpellRare", { fg = colors.amber_gold })

-- Other
hi("ColorColumn", { bg = colors.rich_black })
hi("SignColumn", { bg = colors.rich_black })
hi("Directory", { fg = colors.sunflower_yellow })
hi("EndOfBuffer", { fg = colors.rich_black })
hi("NonText", { fg = colors.dim_gray })
hi("SpecialKey", { fg = colors.dim_gray })
hi("Question", { fg = colors.sky_blue })
hi("MoreMsg", { fg = colors.light_bronze })
hi("WildMenu", { fg = colors.pure_black, bg = colors.amber_gold })
hi("Conceal", { fg = colors.dim_gray })
hi("Terminal", { fg = colors.light_bronze, bg = colors.rich_black })

-- Tree-sitter highlights
hi("@boolean", { fg = colors.bright_orange })
hi("@define", { fg = colors.dusty_rose })
hi("@comment", { fg = colors.dim_gray })
hi("@error", { fg = colors.bright_red })
hi("@punctuation.delimiter", { fg = colors.light_bronze })
hi("@punctuation.bracket", { fg = colors.light_bronze })
hi("@punctuation.special", { fg = colors.light_bronze })
hi("@constant", { fg = colors.bright_orange })
hi("@constant.builtin", { fg = colors.bright_orange })
hi("@string", { fg = colors.bright_orange })
hi("@character", { fg = colors.bright_orange })
hi("@number", { fg = colors.bright_orange })
hi("@namespace", { fg = colors.light_bronze })
hi("@function.builtin", { fg = colors.burnt_orange })
hi("@function", { fg = colors.burnt_orange })
hi("@function.macro", { fg = colors.burnt_orange })
hi("@parameter", { fg = colors.sky_blue })
hi("@parameter.reference", { fg = colors.sky_blue })
hi("@method", { fg = colors.burnt_orange })
hi("@field", { fg = colors.light_bronze })
hi("@property", { fg = colors.light_bronze })
hi("@constructor", { fg = colors.burnt_orange })
hi("@conditional", { fg = colors.goldenrod })
hi("@repeat", { fg = colors.goldenrod })
hi("@label", { fg = colors.goldenrod })
hi("@keyword", { fg = colors.goldenrod })
hi("@keyword.return", { fg = colors.goldenrod })
hi("@keyword.export", { fg = colors.goldenrod })
hi("@keyword.function", { fg = colors.goldenrod })
hi("@keyword.operator", { fg = colors.goldenrod })
hi("@include", { fg = colors.dusty_rose })
hi("@operator", { fg = colors.light_bronze })
hi("@exception", { fg = colors.goldenrod })
hi("@type", { fg = colors.sunflower_yellow })
hi("@type.builtin", { fg = colors.sunflower_yellow })
hi("@type.definition", { fg = colors.sunflower_yellow })
hi("@structure", { fg = colors.sunflower_yellow })
hi("@variable", { fg = colors.light_bronze })
hi("@variable.member", { fg = colors.light_bronze })
hi("@variable.builtin", { fg = colors.light_bronze })
hi("@text", { fg = colors.bright_orange })
hi("@strong", { fg = colors.bright_orange })
hi("@emphasis", { fg = colors.bright_orange })
hi("@underline", { fg = colors.bright_orange })
hi("@title", { fg = colors.bright_orange })
hi("@literal", { fg = colors.bright_orange })
hi("@uri", { fg = colors.bright_orange })
hi("@tag", { fg = colors.light_bronze })
hi("@tag.delimiter", { fg = colors.light_bronze })
hi("@tag.attribute", { fg = colors.light_bronze })

-- LSP semantic tokens
hi("@lsp.type.class", { fg = colors.sunflower_yellow })
hi("@lsp.type.decorator", { fg = colors.dusty_rose })
hi("@lsp.type.enum", { fg = colors.sunflower_yellow })
hi("@lsp.type.enumMember", { fg = colors.bright_orange })
hi("@lsp.type.function", { fg = colors.burnt_orange })
hi("@lsp.type.interface", { fg = colors.sunflower_yellow })
hi("@lsp.type.macro", { fg = colors.dusty_rose })
hi("@lsp.type.method", { fg = colors.burnt_orange })
hi("@lsp.type.namespace", { fg = colors.light_bronze })
hi("@lsp.type.parameter", { fg = colors.sky_blue })
hi("@lsp.type.property", { fg = colors.light_bronze })
hi("@lsp.type.struct", { fg = colors.sunflower_yellow })
hi("@lsp.type.type", { fg = colors.sunflower_yellow })
hi("@lsp.type.typeParameter", { fg = colors.sunflower_yellow })
hi("@lsp.type.variable", { fg = colors.light_bronze })

-- Diagnostics
hi("DiagnosticError", { fg = colors.bright_red })
hi("DiagnosticWarn", { fg = colors.coffee_brown })
hi("DiagnosticInfo", { fg = colors.sky_blue })
hi("DiagnosticHint", { fg = colors.dim_gray })

-- Additional highlights for better compatibility
hi("FloatBorder", { fg = colors.dark_slate })
hi("NormalNC", { fg = colors.light_bronze, bg = colors.rich_black })
hi("MsgArea", { fg = colors.light_bronze, bg = colors.rich_black })
hi("MsgSeparator", { fg = colors.dark_slate })