-- Fleury colorscheme for Neovim
-- Ported from fleury-theme.el by Shams Parvez Arka
-- Adds nested-scope back_cycle highlighting derived from cand.lua

local colors = {
    -- Core palette (verbatim from fleury-theme.el)
    rich_black         = "#020202",
    light_bronze       = "#b99468",
    charcoal_gray      = "#212121",
    charcoal_gray_lite = "#1e1e1e",
    gunmetal_blue      = "#303040",
    dark_slate         = "#222425",
    amber_gold         = "#fcaa05",
    medium_gray        = "#404040",
    jet_black          = "#121212",
    dim_gray           = "#666666",
    goldenrod          = "#f0c674",
    bright_orange      = "#ffaa00",
    dusty_rose         = "#dc7575",
    sunflower_yellow   = "#edb211",
    burnt_orange       = "#de451f",
    sky_blue           = "#2895c7",
    sky_blue_lite      = "#2f2f38",
    bright_red         = "#ff0000",
    fresh_green        = "#66bc11",
    lime_green         = "#003939",
    vivid_vermilion    = "#f0500c",
    golden_yellow      = "#f0bb0c",
    pure_black         = "#000000",
    aqua_ice           = "#8ffff2",
    dusty_sage         = "#9ba290",
    coffee_brown       = "#63523d",

    mode_line_fg       = "#e7aa4d",
    mode_line_bg       = "#1a120b",
    mode_line_border   = "#161616",

    -- Supporting UI shades
    line_numbers_back  = "#101010",
    list_item          = "#1a120b",
    list_item_hover    = "#2b1e12",
    list_item_active   = "#3a2a18",
    ghost_character    = "#4e4638",

    -- back_cycle: warm fleury tint ramping from rich-black toward dark bronze.
    -- Innermost scope uses index 1 (no tint); outer wrappers deepen.
    back_cycle = {
        "#020202",
        "#060503",
        "#0a0804",
        "#0e0a05",
        "#120d06",
        "#170f07",
        "#1b1208",
        "#20150a",
        "#25180b",
        "#2a1b0c",
        "#2f1e0d",
    },
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.g.colors_name = "fleury"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal",           { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "NormalNC",         { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "Cursor",           { fg = colors.pure_black, bg = colors.fresh_green })
set(0, "Visual",           { bg = colors.lime_green })
set(0, "LineNr",           { fg = colors.medium_gray, bg = colors.rich_black })
set(0, "CursorLineNr",     { fg = colors.light_bronze, bg = colors.charcoal_gray_lite })
set(0, "CursorLine",       { bg = colors.charcoal_gray_lite })
set(0, "ColorColumn",      { bg = colors.dark_slate })
set(0, "VertSplit",        { fg = colors.dark_slate })
set(0, "WinSeparator",     { fg = colors.dark_slate })
set(0, "Winseparator",     { fg = colors.dark_slate })
set(0, "SignColumn",       { bg = colors.rich_black })
set(0, "FoldColumn",       { fg = colors.dim_gray, bg = colors.rich_black })
set(0, "Folded",           { fg = colors.dim_gray, bg = colors.charcoal_gray_lite })
set(0, "EndOfBuffer",      { fg = colors.rich_black })
set(0, "NonText",          { fg = colors.ghost_character })
set(0, "Whitespace",       { fg = colors.ghost_character })
set(0, "SpecialKey",       { fg = colors.ghost_character })
set(0, "Conceal",          { fg = colors.ghost_character })
set(0, "Directory",        { fg = colors.sunflower_yellow })
set(0, "Title",            { fg = colors.amber_gold, bold = true })
set(0, "MatchParen",       { bg = colors.sky_blue_lite })
set(0, "MinibufferPrompt", { fg = colors.amber_gold, bold = true })

-- Search
set(0, "Search",           { fg = colors.pure_black, bg = colors.golden_yellow })
set(0, "IncSearch",        { fg = colors.pure_black, bg = colors.vivid_vermilion })
set(0, "CurSearch",        { fg = colors.pure_black, bg = colors.vivid_vermilion })
set(0, "Substitute",       { fg = colors.rich_black, bg = colors.golden_yellow })

-- Syntax
set(0, "Comment",          { fg = colors.dim_gray })
set(0, "String",           { fg = colors.bright_orange })
set(0, "Character",        { fg = colors.bright_orange })
set(0, "Number",           { fg = colors.bright_orange })
set(0, "Float",            { fg = colors.bright_orange })
set(0, "Boolean",          { fg = colors.bright_orange })
set(0, "Constant",         { fg = colors.bright_orange })
set(0, "Identifier",       { fg = colors.light_bronze })
set(0, "Function",         { fg = colors.burnt_orange })
set(0, "Statement",        { fg = colors.goldenrod })
set(0, "Keyword",          { fg = colors.goldenrod })
set(0, "Conditional",      { fg = colors.goldenrod })
set(0, "Repeat",           { fg = colors.goldenrod })
set(0, "Label",            { fg = colors.goldenrod })
set(0, "Exception",        { fg = colors.goldenrod })
set(0, "StorageClass",     { fg = colors.goldenrod })
set(0, "Structure",        { fg = colors.sunflower_yellow })
set(0, "Typedef",          { fg = colors.sunflower_yellow })
set(0, "Type",             { fg = colors.sunflower_yellow })
set(0, "PreProc",          { fg = colors.dusty_rose })
set(0, "Include",          { fg = colors.bright_orange })
set(0, "Define",           { fg = colors.dusty_rose })
set(0, "Macro",            { fg = colors.sky_blue })
set(0, "PreCondit",        { fg = colors.dusty_rose })
set(0, "Special",          { fg = colors.bright_red })
set(0, "SpecialChar",      { fg = colors.bright_red })
set(0, "Tag",              { fg = colors.sunflower_yellow })
set(0, "Delimiter",        { fg = colors.light_bronze })
set(0, "SpecialComment",   { fg = colors.fresh_green })
set(0, "Debug",            { fg = colors.bright_red })
set(0, "Operator",         { fg = colors.dusty_rose })
set(0, "Underlined",       { fg = colors.burnt_orange, underline = true })
set(0, "Ignore",           { fg = colors.ghost_character })
set(0, "Error",            { fg = colors.bright_red, bold = true })
set(0, "ErrorMsg",         { fg = colors.bright_red })
set(0, "WarningMsg",       { fg = colors.bright_orange })
set(0, "Todo",             { fg = colors.fresh_green, bg = colors.charcoal_gray_lite, bold = true })

-- Messages
set(0, "ModeMsg",          { fg = colors.amber_gold })
set(0, "MoreMsg",          { fg = colors.fresh_green })
set(0, "Question",         { fg = colors.fresh_green })
set(0, "MsgArea",          { fg = colors.light_bronze })

-- Diagnostics
set(0, "DiagnosticError",  { fg = colors.bright_red })
set(0, "DiagnosticWarn",   { fg = colors.bright_orange })
set(0, "DiagnosticInfo",   { fg = colors.sky_blue })
set(0, "DiagnosticHint",   { fg = colors.aqua_ice })
set(0, "DiagnosticOk",     { fg = colors.fresh_green })

set(0, "DiagnosticUnderlineError", { sp = colors.bright_red, undercurl = true })
set(0, "DiagnosticUnderlineWarn",  { sp = colors.bright_orange, undercurl = true })
set(0, "DiagnosticUnderlineInfo",  { sp = colors.sky_blue, undercurl = true })
set(0, "DiagnosticUnderlineHint",  { sp = colors.aqua_ice, undercurl = true })

set(0, "DiagnosticVirtualTextError", { fg = colors.bright_red, bg = "#1a0c0c" })
set(0, "DiagnosticVirtualTextWarn",  { fg = colors.bright_orange, bg = "#1a130c" })
set(0, "DiagnosticVirtualTextInfo",  { fg = colors.sky_blue, bg = colors.rich_black })
set(0, "DiagnosticVirtualTextHint",  { fg = colors.aqua_ice, bg = colors.rich_black })

set(0, "DiagnosticSignError", { fg = colors.bright_red, bg = colors.rich_black })
set(0, "DiagnosticSignWarn",  { fg = colors.bright_orange, bg = colors.rich_black })
set(0, "DiagnosticSignInfo",  { fg = colors.sky_blue, bg = colors.rich_black })
set(0, "DiagnosticSignHint",  { fg = colors.aqua_ice, bg = colors.rich_black })

-- Rainbow delimiters
set(0, "rainbowcol1", { fg = colors.goldenrod })
set(0, "rainbowcol2", { fg = colors.sky_blue })
set(0, "rainbowcol3", { fg = colors.fresh_green })
set(0, "rainbowcol4", { fg = colors.sunflower_yellow })
set(0, "rainbowcol5", { fg = colors.burnt_orange })
set(0, "rainbowcol6", { fg = colors.bright_red })

-- Floats / popups / tooltip
set(0, "NormalFloat",   { fg = colors.light_bronze, bg = colors.list_item })
set(0, "FloatBorder",   { fg = colors.coffee_brown, bg = colors.list_item })
set(0, "FloatTitle",    { fg = colors.amber_gold, bg = colors.list_item })
set(0, "Tooltip",       { fg = colors.amber_gold, bg = colors.coffee_brown })
set(0, "Pmenu",         { fg = colors.light_bronze, bg = colors.list_item })
set(0, "PmenuSel",      { fg = colors.amber_gold, bg = colors.list_item_active })
set(0, "PmenuSbar",     { bg = colors.list_item })
set(0, "PmenuThumb",    { bg = colors.list_item_hover })
set(0, "WildMenu",      { fg = colors.amber_gold, bg = colors.list_item_active })
set(0, "QuickFixLine",  { bg = colors.list_item_active })

-- Diff
set(0, "DiffAdd",     { bg = "#102010" })
set(0, "DiffChange",  { bg = "#201d10" })
set(0, "DiffDelete", { fg = colors.bright_red, bg = "#201010" })
set(0, "DiffText",    { bg = "#302810", bold = true })

-- Spell
set(0, "SpellBad",   { sp = colors.bright_red, undercurl = true })
set(0, "SpellCap",   { sp = colors.bright_orange, undercurl = true })
set(0, "SpellLocal", { sp = colors.fresh_green, undercurl = true })
set(0, "SpellRare",  { sp = colors.amber_gold, undercurl = true })

-- NetRW
set(0, "netrwCursorLine", { bg = colors.charcoal_gray_lite })
set(0, "netrwDir",        { fg = colors.sky_blue })
set(0, "netrwExe",        { fg = colors.burnt_orange })

-- Status line (fleury mode-line with border box)
set(0, "StatusLine",   { fg = colors.mode_line_fg, bg = colors.mode_line_bg })
set(0, "StatusLineNC", { fg = colors.mode_line_fg, bg = colors.rich_black })
set(0, "TabLine",      { fg = colors.light_bronze, bg = colors.mode_line_bg })
set(0, "TabLineFill",  { bg = colors.mode_line_bg })
set(0, "TabLineSel",   { fg = colors.amber_gold, bg = colors.rich_black, bold = true })
set(0, "WinBar",       { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "WinBarNC",     { fg = colors.dim_gray, bg = colors.rich_black })

-- Treesitter
set(0, "@comment",               { link = "Comment" })
set(0, "@comment.documentation", { fg = colors.fresh_green })
set(0, "@string",                { link = "String" })
set(0, "@string.documentation",  { fg = colors.fresh_green })
set(0, "@string.escape",         { fg = colors.bright_red })
set(0, "@character",             { link = "Character" })
set(0, "@number",                { link = "Number" })
set(0, "@number.float",          { link = "Float" })
set(0, "@boolean",               { link = "Boolean" })
set(0, "@constant",              { link = "Constant" })
set(0, "@constant.builtin",      { fg = colors.bright_orange })

set(0, "@function",            { link = "Function" })
set(0, "@function.builtin",    { link = "Function" })
set(0, "@function.call",       { fg = colors.burnt_orange })
set(0, "@function.definition", { fg = colors.burnt_orange, bold = true })
set(0, "@function.macro",      { fg = colors.sky_blue })

set(0, "@variable",           { link = "Identifier" })
set(0, "@variable.builtin",   { fg = colors.bright_orange })
set(0, "@variable.parameter", { fg = colors.light_bronze })
set(0, "@parameter",          { fg = colors.light_bronze })

set(0, "@type",            { link = "Type" })
set(0, "@type.builtin",    { link = "Type" })
set(0, "@type.definition", { fg = colors.sunflower_yellow, bold = true })

set(0, "@keyword",             { link = "Keyword" })
set(0, "@keyword.function",    { link = "Keyword" })
set(0, "@keyword.return",      { fg = colors.goldenrod, bold = true })
set(0, "@keyword.conditional", { link = "Keyword" })
set(0, "@keyword.repeat",      { link = "Keyword" })
set(0, "@keyword.import",      { fg = colors.bright_orange })
set(0, "@keyword.directive",   { fg = colors.dusty_rose })
set(0, "@keyword.modifier",    { link = "Keyword" })

set(0, "@attribute",  { fg = colors.sunflower_yellow })
set(0, "@module",     { fg = colors.bright_orange })
set(0, "@field",      { link = "Identifier" })
set(0, "@property",   { fg = colors.light_bronze })

set(0, "@punctuation.bracket",   { fg = colors.light_bronze })
set(0, "@punctuation.delimiter", { fg = colors.light_bronze })
set(0, "@punctuation.special",   { fg = colors.dusty_rose })

set(0, "@constructor",  { link = "Type" })
set(0, "@storageclass", { fg = colors.goldenrod })

-- Language-specific Lua tweaks
set(0, "@keyword.lua",  { fg = colors.goldenrod })
set(0, "@keyword.type", { fg = colors.goldenrod })

-- Jai treesitter
set(0, "@keyword.jai",                      { fg = colors.goldenrod })
set(0, "@keyword.return.jai",               { fg = colors.goldenrod, bold = true })
set(0, "@keyword.conditional.jai",          { fg = colors.goldenrod })
set(0, "@keyword.conditional.ternary.jai",  { fg = colors.goldenrod })
set(0, "@keyword.repeat.jai",               { fg = colors.goldenrod })
set(0, "@keyword.import.jai",               { fg = colors.bright_orange })
set(0, "@keyword.directive.jai",            { fg = colors.sky_blue })
set(0, "@keyword.modifier.jai",             { fg = colors.goldenrod, italic = true })
set(0, "@storageclass.jai",                 { fg = colors.goldenrod })
set(0, "@function.jai",                     { fg = colors.burnt_orange, bold = true })
set(0, "@function.call.jai",                { fg = colors.burnt_orange })
set(0, "@function.macro.jai",               { fg = colors.sky_blue })
set(0, "@function.builtin.jai",             { fg = colors.burnt_orange })
set(0, "@variable.jai",                     { fg = colors.light_bronze })
set(0, "@variable.builtin.jai",             { fg = colors.bright_orange })
set(0, "@variable.parameter.jai",           { fg = colors.light_bronze })
set(0, "@type.jai",                         { fg = colors.sunflower_yellow })
set(0, "@type.builtin.jai",                 { fg = colors.sunflower_yellow })
set(0, "@type.definition.jai",              { fg = colors.sunflower_yellow, bold = true })
set(0, "@constant.jai",                     { fg = colors.bright_orange })
set(0, "@constant.builtin.jai",             { fg = colors.bright_orange })
set(0, "@property.jai",                     { fg = colors.light_bronze })
set(0, "@operator.jai",                     { fg = colors.dusty_rose })
set(0, "@attribute.jai",                    { fg = colors.sunflower_yellow })
set(0, "@module.jai",                       { fg = colors.bright_orange })
set(0, "@punctuation.bracket.jai",          { fg = colors.light_bronze })
set(0, "@punctuation.delimiter.jai",        { fg = colors.light_bronze })
set(0, "@string.jai",                       { fg = colors.bright_orange })
set(0, "@string.escape.jai",                { fg = colors.bright_red })
set(0, "@character.jai",                    { fg = colors.bright_orange })
set(0, "@number.jai",                       { fg = colors.bright_orange })
set(0, "@number.float.jai",                 { fg = colors.bright_orange })
set(0, "@boolean.jai",                      { fg = colors.bright_orange })
set(0, "@comment.jai",                      { fg = colors.dim_gray })

-- Jai vim-syntax fallbacks (used by syntax/jai.vim)
set(0, "jaiStruct",                 { fg = colors.goldenrod })
set(0, "jaiUnion",                  { fg = colors.goldenrod })
set(0, "jaiEnum",                   { fg = colors.goldenrod })
set(0, "jaiFunction",               { fg = colors.burnt_orange, bold = true })
set(0, "jaiClass",                  { fg = colors.sunflower_yellow })
set(0, "jaiDataType",               { fg = colors.sunflower_yellow })
set(0, "jaiConstant",               { fg = colors.bright_orange })
set(0, "jaiConstantDeclaration",    { fg = colors.bright_orange })
set(0, "jaiVariableDeclaration",    { fg = colors.light_bronze })
set(0, "jaiForVariableDeclaration", { fg = colors.light_bronze })
set(0, "jaiDirective",              { fg = colors.sky_blue })
set(0, "jaiTemplate",               { fg = colors.aqua_ice })
set(0, "jaiAutobake",               { fg = colors.aqua_ice })
set(0, "jaiTagNote",                { fg = colors.sunflower_yellow })
set(0, "jaiCommentNote",            { fg = colors.fresh_green })
set(0, "jaiIt",                     { fg = colors.bright_orange })
set(0, "jaiCast",                   { fg = colors.goldenrod })
set(0, "jaiAutoCast",               { fg = colors.goldenrod })
set(0, "jaiOperator",               { fg = colors.dusty_rose })
set(0, "jaiNull",                   { fg = colors.bright_orange })
set(0, "jaiSOA",                    { fg = colors.goldenrod, italic = true })
set(0, "jaiAOS",                    { fg = colors.goldenrod, italic = true })

-- C overrides + LSP
set(0, "@keyword.type.c", { fg = colors.goldenrod })
set(0, "@type.builtin.c", { fg = colors.goldenrod })
set(0, "@lsp.type.macro.c",    { fg = colors.sky_blue })
set(0, "@lsp.type.function.c", { link = "Function" })
set(0, "@lsp.type.type.c",     { link = "Type" })
set(0, "@lsp.type.struct.c",   { link = "Type" })
set(0, "@lsp.type.enum.c",     { link = "Type" })
set(0, "@lsp.mod.globalScope.c", {})
set(0, "@lsp.typemod.function.globalScope.c", { link = "Function" })
set(0, "@lsp.mod.fileScope.c", {})
set(0, "@lsp.typemod.function.fileScope.c", { link = "Function" })

-- Enum member (LSP semantic tokens)
set(0, "@lsp.type.enumMember",                  { fg = colors.bright_orange })
set(0, "@lsp.typemod.enumMember",               { fg = colors.bright_orange })
set(0, "@lsp.typemod.enumMember.declaration",   { fg = colors.bright_orange })
set(0, "@lsp.typemod.enumMember.readonly",      { fg = colors.bright_orange })
set(0, "@lsp.type.enumMember.c",                { fg = colors.bright_orange })
set(0, "@lsp.mod.readonly.c",                   {})
set(0, "@lsp.typemod.enumMember.fileScope.c",   { fg = colors.bright_orange })
set(0, "@lsp.typemod.enumMember.readonly.c",    { fg = colors.bright_orange })

-- C++ overrides + LSP (variable-use → sky-blue per fleury font-lock-variable-use-face)
set(0, "@keyword.type.cpp",  { fg = colors.goldenrod })
set(0, "@type.builtin.cpp",  { fg = colors.goldenrod })
set(0, "@variable.cpp",      { fg = colors.sky_blue })
set(0, "@function.call.cpp", { fg = colors.burnt_orange })
set(0, "@constructor.cpp",   { link = "Type" })

set(0, "@lsp.type.macro.cpp",         { fg = colors.sky_blue })
set(0, "@lsp.type.function.cpp",      { link = "Function" })
set(0, "@lsp.type.method.cpp",        { fg = colors.burnt_orange })
set(0, "@lsp.type.type.cpp",          { link = "Type" })
set(0, "@lsp.type.class.cpp",         { link = "Type" })
set(0, "@lsp.type.struct.cpp",        { link = "Type" })
set(0, "@lsp.type.enum.cpp",          { link = "Type" })
set(0, "@lsp.type.namespace.cpp",     { fg = colors.bright_orange })
set(0, "@lsp.type.typeParameter.cpp", { link = "Type" })
set(0, "@lsp.type.variable.cpp",      { fg = colors.sky_blue })
set(0, "@lsp.type.parameter.cpp",     { fg = colors.light_bronze })
set(0, "@lsp.type.property.cpp",      { fg = colors.light_bronze })
set(0, "@lsp.type.enumMember.cpp",    { fg = colors.bright_orange })
set(0, "@lsp.mod.globalScope.cpp",    {})
set(0, "@lsp.typemod.macro.globalScope.cpp", { fg = colors.sky_blue })

-- Yggdrasil/arc macro groups
set(0, "YgKeyword", { fg = colors.sky_blue })
set(0, "YgType",    { fg = colors.sunflower_yellow })

-- Lazy.nvim
set(0, "LazyNormal",        { fg = colors.light_bronze, bg = colors.list_item })
set(0, "LazyBorder",        { fg = colors.coffee_brown, bg = colors.list_item })
set(0, "LazyTitle",         { fg = colors.amber_gold, bg = colors.list_item })
set(0, "LazyButton",        { fg = colors.light_bronze, bg = colors.charcoal_gray_lite })
set(0, "LazyButtonActive",  { fg = colors.amber_gold, bg = colors.list_item_active })
set(0, "LazyH1",            { fg = colors.amber_gold })
set(0, "LazyH2",            { fg = colors.aqua_ice })
set(0, "LazyComment",       { fg = colors.dim_gray })
set(0, "LazyCommit",        { fg = colors.fresh_green })
set(0, "LazyCommitIssue",   { fg = colors.bright_red })
set(0, "LazyCommitScope",   { fg = colors.sky_blue })
set(0, "LazyCommitType",    { fg = colors.goldenrod })
set(0, "LazyDimmed",        { fg = colors.dim_gray })
set(0, "LazyDir",           { fg = colors.aqua_ice })
set(0, "LazyProgressDone",  { fg = colors.fresh_green })
set(0, "LazyProgressTodo",  { fg = colors.dim_gray })
set(0, "LazyProp",          { fg = colors.dusty_rose })
set(0, "LazyReasonCmd",     { fg = colors.burnt_orange })
set(0, "LazyReasonEvent",   { fg = colors.goldenrod })
set(0, "LazyReasonFt",      { fg = colors.dusty_rose })
set(0, "LazyReasonImport",  { fg = colors.bright_orange })
set(0, "LazyReasonKeys",    { fg = colors.sky_blue })
set(0, "LazyReasonPlugin",  { fg = colors.fresh_green })
set(0, "LazyReasonRuntime", { fg = colors.aqua_ice })
set(0, "LazyReasonSource",  { fg = colors.bright_red })
set(0, "LazyReasonStart",   { fg = colors.amber_gold })
set(0, "LazySpecial",       { fg = colors.burnt_orange })
set(0, "LazyTaskError",     { fg = colors.bright_red })
set(0, "LazyTaskOutput",    { fg = colors.light_bronze })
set(0, "LazyUrl",           { fg = colors.aqua_ice })
set(0, "LazyValue",         { fg = colors.bright_orange })

-- Telescope
set(0, "TelescopeNormal",         { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "TelescopeBorder",         { fg = colors.medium_gray, bg = colors.rich_black })
set(0, "TelescopePromptNormal",   { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "TelescopePromptBorder",   { fg = colors.medium_gray, bg = colors.rich_black })
set(0, "TelescopePromptTitle",    { fg = colors.dim_gray, bg = colors.rich_black })
set(0, "TelescopePromptPrefix",   { fg = colors.amber_gold, bg = colors.rich_black })
set(0, "TelescopeResultsNormal",  { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "TelescopeResultsBorder",  { fg = colors.medium_gray, bg = colors.rich_black })
set(0, "TelescopeResultsTitle",   { fg = colors.dim_gray, bg = colors.rich_black })
set(0, "TelescopePreviewNormal",  { fg = colors.light_bronze, bg = colors.rich_black })
set(0, "TelescopePreviewBorder",  { fg = colors.medium_gray, bg = colors.rich_black })
set(0, "TelescopePreviewTitle",   { fg = colors.dim_gray, bg = colors.rich_black })
set(0, "TelescopeSelection",      { fg = colors.amber_gold, bg = colors.charcoal_gray_lite })
set(0, "TelescopeSelectionCaret", { fg = colors.amber_gold, bg = colors.charcoal_gray_lite })
set(0, "TelescopeMultiSelection", { fg = colors.fresh_green, bg = colors.charcoal_gray_lite })
set(0, "TelescopeMatching",       { fg = colors.amber_gold, bold = true })

-- Harpoon
set(0, "HarpoonBorder", { fg = colors.coffee_brown })
set(0, "HarpoonWindow", { fg = colors.light_bronze })

-- Git signs
set(0, "GitSignsAdd",          { fg = colors.fresh_green, bg = colors.rich_black })
set(0, "GitSignsChange",       { fg = colors.amber_gold, bg = colors.rich_black })
set(0, "GitSignsDelete",       { fg = colors.bright_red, bg = colors.rich_black })
set(0, "GitSignsChangedelete", { fg = colors.bright_orange, bg = colors.rich_black })

-- Scope highlight groups (derived from back_cycle)
for i, bg in ipairs(colors.back_cycle) do
    set(0, "FleuryScope" .. i, { bg = bg })
end

-- ---------------------------------------------------------------------------
-- Scope highlighting module (adapted from cand.lua)
-- ---------------------------------------------------------------------------

local M = {}
M.colors = colors

local scope_ns = vim.api.nvim_create_namespace("fleury_scope_highlight")
local scope_cache = {}

local scope_queries = {
    c = [[
        (compound_statement) @scope
    ]],
    cpp = [[
        (compound_statement) @scope
    ]],
    jai = [[
        (block) @scope
    ]],
    lua = [[
        (function_definition) @scope
        (if_statement) @scope
        (for_statement) @scope
        (while_statement) @scope
    ]],
    typescript = [[
        (statement_block) @scope
    ]],
    tsx = [[
        (statement_block) @scope
    ]],
    javascript = [[
        (statement_block) @scope
    ]],
}

local function parse_scopes(bufnr)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
        return nil
    end

    local tree = parser:parse()[1]
    if not tree then return nil end

    local root = tree:root()
    local lang = parser:lang()

    local query_string = scope_queries[lang]
    if not query_string then return nil end

    local query
    local success = pcall(function()
        query = vim.treesitter.query.parse(lang, query_string)
    end)

    if not success or not query then
        return nil
    end

    local all_scopes = {}
    for _, node in query:iter_captures(root, bufnr, 0, -1) do
        local start_row, _, end_row, _ = node:range()
        table.insert(all_scopes, {
            start_row = start_row,
            end_row = end_row,
            size = end_row - start_row,
        })
    end

    return all_scopes
end

local function find_containing_scopes(all_scopes, cursor_row)
    if not all_scopes then return {} end

    local containing = {}
    for _, scope in ipairs(all_scopes) do
        if cursor_row >= scope.start_row and cursor_row <= scope.end_row then
            table.insert(containing, scope)
        end
    end

    table.sort(containing, function(a, b)
        return a.size < b.size
    end)

    return containing
end

local function scope_fingerprint(scopes)
    if not scopes or #scopes == 0 then return "" end
    local parts = {}
    for _, s in ipairs(scopes) do
        table.insert(parts, s.start_row .. ":" .. s.end_row)
    end
    return table.concat(parts, ",")
end

function M.highlight_scopes(bufnr, winid, force)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    winid = winid or vim.api.nvim_get_current_win()

    if not scope_cache[bufnr] then
        scope_cache[bufnr] = {
            all_scopes = nil,
            last_fingerprint = "",
            dirty = true,
        }
    end

    local cache = scope_cache[bufnr]

    if cache.dirty or not cache.all_scopes then
        cache.all_scopes = parse_scopes(bufnr)
        cache.dirty = false
    end

    local cursor = vim.api.nvim_win_get_cursor(winid)
    local cursor_row = cursor[1] - 1

    local containing_scopes = find_containing_scopes(cache.all_scopes, cursor_row)
    local fingerprint = scope_fingerprint(containing_scopes)

    if not force and fingerprint == cache.last_fingerprint then
        return
    end

    cache.last_fingerprint = fingerprint

    vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)

    for depth, scope in ipairs(containing_scopes) do
        local cycle_idx = ((depth - 1) % #colors.back_cycle) + 1
        local hl_group = "FleuryScope" .. cycle_idx

        for line = scope.start_row, scope.end_row do
            vim.api.nvim_buf_set_extmark(bufnr, scope_ns, line, 0, {
                line_hl_group = hl_group,
                priority = 100 - depth,
            })
        end
    end
end

local function mark_dirty(bufnr)
    if scope_cache[bufnr] then
        scope_cache[bufnr].dirty = true
    end
end

local debounce_timers = {}
local DEBOUNCE_MS = 50

local function debounced_highlight(bufnr)
    if debounce_timers[bufnr] then
        debounce_timers[bufnr]:stop()
        debounce_timers[bufnr] = nil
    end

    local timer = vim.uv.new_timer()
    debounce_timers[bufnr] = timer

    timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            M.highlight_scopes(bufnr)
        end
        if debounce_timers[bufnr] == timer then
            debounce_timers[bufnr] = nil
        end
        timer:stop()
        timer:close()
    end))
end

function M.enable_scope_highlight(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    scope_cache[bufnr] = {
        all_scopes = nil,
        last_fingerprint = "",
        dirty = true,
    }

    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            M.highlight_scopes(bufnr, nil, true)
        end
    end)

    local group = vim.api.nvim_create_augroup("FleuryScopeHighlight" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = function()
            debounced_highlight(bufnr)
        end,
    })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = bufnr,
        callback = function()
            mark_dirty(bufnr)
            debounced_highlight(bufnr)
        end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        buffer = bufnr,
        callback = function()
            scope_cache[bufnr] = nil
            if debounce_timers[bufnr] then
                debounce_timers[bufnr]:stop()
                debounce_timers[bufnr]:close()
                debounce_timers[bufnr] = nil
            end
        end,
    })
end

function M.disable_scope_highlight(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
    pcall(vim.api.nvim_del_augroup_by_name, "FleuryScopeHighlight" .. bufnr)
    scope_cache[bufnr] = nil
    if debounce_timers[bufnr] then
        debounce_timers[bufnr]:stop()
        debounce_timers[bufnr]:close()
        debounce_timers[bufnr] = nil
    end
end

function M.setup_scope_highlight()
    local group = vim.api.nvim_create_augroup("FleuryScopeSetup", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "c", "cpp", "jai", "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(ev)
            vim.schedule(function()
                M.enable_scope_highlight(ev.buf)
            end)
        end,
    })

    local ft = vim.bo.filetype
    if ft == "c" or ft == "cpp" or ft == "jai" or ft == "lua" or ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
        vim.schedule(function()
            M.enable_scope_highlight(vim.api.nvim_get_current_buf())
        end)
    end
end

-- Yggdrasil/arc macro matchadd block (ported from cand.lua)
local yg_match_ids = {}

local function setup_yg_keywords()
    local winid = vim.api.nvim_get_current_win()
    if yg_match_ids[winid] then return end
    yg_match_ids[winid] = {}

    local function add_match(group, pattern)
        local id = vim.fn.matchadd(group, pattern, 100)
        table.insert(yg_match_ids[winid], id)
    end

    add_match("YgKeyword", "\\<\\(yg\\|arc\\)_\\(internal\\|inline\\|global\\|local_persist\\)\\>")

    add_match("YgType", "\\<\\([usb]\\(8\\|16\\|32\\|64\\)\\|f\\(32\\|64\\)\\|void\\|Vec[234]\\(F32\\|F64\\|S16\\|S32\\|S64\\)\\?\\|Mat[34]\\(F32\\)\\?\\|Quaternion\\(F32\\)\\?\\|Rng[12]\\(F32\\|U32\\|U64\\|S16\\|S32\\)\\?\\|Arena\\|Scratch\\|String8\\|R_Handle\\|Entity\\(Handle\\|Store\\|Pool\\|Kind\\|Flags\\)\\?\\|Direction8\\)\\>")

    add_match("YgType", "\\<\\(yg\\|arc\\)_\\(internal\\|inline\\)\\s\\+\\zs\\w\\+\\ze")

    add_match("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(")
    add_match("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s*\\*\\s*\\zs\\w\\+\\ze\\s*(")
end

local yg_group = vim.api.nvim_create_augroup("FleuryYgKeywords", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = yg_group,
    pattern = { "c", "cpp", "objc", "objcpp" },
    callback = setup_yg_keywords,
})
vim.api.nvim_create_autocmd("WinEnter", {
    group = yg_group,
    callback = function()
        local ft = vim.bo.filetype
        if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
            setup_yg_keywords()
        end
    end,
})
vim.api.nvim_create_autocmd("WinClosed", {
    group = yg_group,
    callback = function(ev)
        local wid = tonumber(ev.match)
        if wid then yg_match_ids[wid] = nil end
    end,
})

local ft = vim.bo.filetype
local ext = vim.fn.expand("%:e")
if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ext == "c" or ext == "h" or ext == "cpp" or ext == "hpp" or ext == "m" or ext == "mm" then
    setup_yg_keywords()
end

vim.g.fleury_theme = M

M.setup_scope_highlight()

return M
