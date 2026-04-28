-- Forgejo Dark colorscheme for Neovim
-- Palette ported from forgejo/web_src/css/themes/theme-forgejo-dark.css
-- with the body slightly darkened (#171e26 -> #10161e). Code-syntax
-- colors synthesized from the orange/steel accent ramp since chroma
-- styles are generated server-side, not committed to the repo.

local colors = {
    -- Backgrounds
    bg_body      = "#10161e",  -- darkened from #171e26
    bg_panel     = "#1d262f",
    bg_header    = "#242d38",
    bg_input     = "#161d26",
    bg_hl        = "#1a222b",
    bg_region    = "#2c3a4c",

    -- Foregrounds
    fg_bright    = "#ffffff",
    fg_main      = "#d2e0f0",
    fg_light     = "#c0cfe0",
    fg_dim       = "#8a98aa",

    -- Borders
    border       = "#445161",
    border_faint = "#2f3a47",

    -- Accent ramp (orange)
    primary      = "#fb923c",
    accent       = "#f97316",
    primary_soft = "#fdba74",

    -- Status
    success      = "#22c55e",
    success_bg   = "#1f6e3c",
    warning      = "#eab308",
    warning_bg   = "#a67a1d",
    err          = "#ef4444",
    err_bg       = "#783030",

    -- Code (orange/steel synthesis)
    code_keyword  = "#fb923c",
    code_string   = "#a3e635",
    code_number   = "#fbbf24",
    code_comment  = "#6b7c8e",
    code_type     = "#fdba74",
    code_function = "#fcd34d",
    code_variable = "#d2e0f0",
    code_operator = "#f97316",
    code_preproc  = "#f97316",
    code_builtin  = "#fb7185",
    code_constant = "#fbbf24",
    code_punct    = "#a8b3c0",
}

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "forgejo"

local set = vim.api.nvim_set_hl
local c = colors

-- ============================================================
-- Core UI
-- ============================================================
set(0, "Normal",       { fg = c.fg_main, bg = c.bg_body })
set(0, "NormalNC",     { fg = c.fg_main, bg = c.bg_body })
set(0, "NormalFloat",  { fg = c.fg_main, bg = c.bg_panel })
set(0, "FloatBorder",  { fg = c.border,  bg = c.bg_panel })
set(0, "FloatTitle",   { fg = c.primary, bg = c.bg_header, bold = true })
set(0, "WinSeparator", { fg = c.border_faint })
set(0, "VertSplit",    { fg = c.border_faint })
set(0, "StatusLine",   { fg = c.fg_bright, bg = c.bg_header })
set(0, "StatusLineNC", { fg = c.fg_dim,    bg = c.bg_panel })
set(0, "TabLine",      { fg = c.fg_dim,    bg = c.bg_panel })
set(0, "TabLineSel",   { fg = c.fg_bright, bg = c.bg_body, bold = true })
set(0, "TabLineFill",  { fg = c.fg_dim,    bg = c.bg_panel })
set(0, "LineNr",       { fg = c.fg_dim,    bg = c.bg_body })
set(0, "CursorLineNr", { fg = c.primary,   bg = c.bg_body, bold = true })
set(0, "SignColumn",   { fg = c.fg_dim,    bg = c.bg_body })
set(0, "CursorColumn", { bg = c.bg_hl })
set(0, "CursorLine",   { bg = c.bg_hl })
set(0, "Cursor",       { fg = c.bg_body, bg = c.primary })
set(0, "TermCursor",   { fg = c.bg_body, bg = c.primary })
set(0, "TermCursorNC", { fg = c.bg_body, bg = c.fg_dim })
set(0, "Visual",       { bg = c.bg_region })
set(0, "VisualNOS",    { bg = c.bg_input, fg = c.fg_main })
set(0, "Search",       { fg = c.bg_body,    bg = c.warning_bg })
set(0, "IncSearch",    { fg = c.bg_body,    bg = c.primary })
set(0, "CurSearch",    { fg = c.bg_body,    bg = c.primary })
set(0, "Substitute",   { link = "IncSearch" })
set(0, "MatchParen",   { fg = c.primary,    bg = c.border, bold = true })
set(0, "ColorColumn",  { bg = c.bg_panel })
set(0, "Folded",       { fg = c.fg_dim,     bg = c.bg_panel })
set(0, "FoldColumn",   { fg = c.fg_dim,     bg = c.bg_body })
set(0, "EndOfBuffer",  { fg = c.bg_body })
set(0, "NonText",      { fg = c.border_faint })
set(0, "Whitespace",   { fg = c.border_faint })
set(0, "SpecialKey",   { fg = c.border_faint })
set(0, "QuickFixLine", { fg = c.fg_main, bg = c.bg_region })
set(0, "qfLineNr",     { fg = c.warning })
set(0, "Directory",    { fg = c.primary, bold = true })
set(0, "Title",        { fg = c.primary, bold = true })
set(0, "Question",     { fg = c.success })
set(0, "MoreMsg",      { fg = c.fg_main })
set(0, "ModeMsg",      { fg = c.fg_main })
set(0, "WarningMsg",   { fg = c.warning })
set(0, "ErrorMsg",     { fg = c.err, bold = true })
set(0, "Pmenu",        { fg = c.fg_main, bg = c.bg_panel })
set(0, "PmenuSel",     { fg = c.fg_bright, bg = c.bg_region, bold = true })
set(0, "PmenuSbar",    { bg = c.bg_input })
set(0, "PmenuThumb",   { bg = c.border })
set(0, "WildMenu",     { fg = c.bg_body, bg = c.primary })
set(0, "WinBar",       { fg = c.fg_light, bg = c.bg_panel })
set(0, "WinBarNC",     { fg = c.fg_dim,   bg = c.bg_panel })

-- ============================================================
-- Syntax (legacy groups)
-- ============================================================
set(0, "Comment",      { fg = c.code_comment, italic = true })
set(0, "SpecialComment", { fg = c.primary_soft })
set(0, "Todo",         { fg = c.warning, bg = c.bg_panel, bold = true })
set(0, "String",       { fg = c.code_string })
set(0, "Character",    { fg = c.code_string })
set(0, "Number",       { fg = c.code_number })
set(0, "Float",        { fg = c.code_number })
set(0, "Boolean",      { fg = c.code_constant })
set(0, "Constant",     { fg = c.code_constant })
set(0, "Identifier",   { fg = c.code_variable })
set(0, "Function",     { fg = c.code_function })
set(0, "Statement",    { fg = c.code_keyword })
set(0, "Operator",     { fg = c.code_operator })
set(0, "Keyword",      { fg = c.code_keyword })
set(0, "Type",         { fg = c.code_type })
set(0, "Structure",    { fg = c.code_type })
set(0, "StorageClass", { fg = c.code_type })
set(0, "PreProc",      { fg = c.code_preproc })
set(0, "Include",      { fg = c.code_preproc })
set(0, "Define",       { fg = c.code_preproc })
set(0, "Macro",        { fg = c.code_preproc })
set(0, "PreCondit",    { fg = c.code_preproc })
set(0, "Conditional",  { fg = c.code_keyword })
set(0, "Repeat",       { fg = c.code_keyword })
set(0, "Label",        { fg = c.primary_soft })
set(0, "Special",      { fg = c.primary_soft })
set(0, "Delimiter",    { fg = c.code_punct })
set(0, "Underlined",   { underline = true })
set(0, "Bold",         { bold = true })
set(0, "Italic",       { italic = true })
set(0, "Error",        { fg = c.err, bold = true })

-- ============================================================
-- Treesitter
-- ============================================================
set(0, "@comment",            { link = "Comment" })
set(0, "@comment.todo",       { fg = c.warning, bg = c.bg_panel, bold = true })
set(0, "@comment.error",      { fg = c.err })
set(0, "@punctuation",        { link = "Delimiter" })
set(0, "@punctuation.bracket", { link = "Delimiter" })
set(0, "@punctuation.special", { fg = c.code_operator })
set(0, "@string",             { link = "String" })
set(0, "@string.regex",       { fg = c.code_string })
set(0, "@string.escape",      { fg = c.code_builtin })
set(0, "@character",          { link = "Character" })
set(0, "@character.special",  { fg = c.primary_soft })
set(0, "@number",             { link = "Number" })
set(0, "@number.float",       { link = "Float" })
set(0, "@boolean",            { link = "Boolean" })
set(0, "@constant",           { link = "Constant" })
set(0, "@constant.builtin",   { fg = c.code_builtin })
set(0, "@constant.macro",     { fg = c.code_preproc })
set(0, "@type",               { link = "Type" })
set(0, "@type.builtin",       { fg = c.code_type })
set(0, "@type.definition",    { fg = c.code_type, bold = true })
set(0, "@type.qualifier",     { fg = c.code_type })
set(0, "@attribute",          { fg = c.code_type })
set(0, "@variable",           { fg = c.code_variable })
set(0, "@variable.builtin",   { fg = c.code_builtin })
set(0, "@variable.parameter", { fg = c.code_variable, italic = true })
set(0, "@field",              { fg = c.code_variable })
set(0, "@property",           { fg = c.code_variable })
set(0, "@parameter",          { fg = c.code_variable, italic = true })
set(0, "@function",           { link = "Function" })
set(0, "@function.call",      { fg = c.code_function })
set(0, "@function.definition", { fg = c.code_function, bold = true })
set(0, "@function.builtin",   { fg = c.code_builtin })
set(0, "@function.macro",     { fg = c.code_preproc })
set(0, "@method",             { link = "Function" })
set(0, "@module",             { fg = c.code_preproc })
set(0, "@constructor",        { fg = c.code_type })
set(0, "@keyword",            { link = "Keyword" })
set(0, "@keyword.function",   { fg = c.code_keyword })
set(0, "@keyword.operator",   { fg = c.code_operator })
set(0, "@keyword.return",     { fg = c.code_keyword, bold = true })
set(0, "@keyword.conditional", { link = "Keyword" })
set(0, "@keyword.repeat",     { link = "Keyword" })
set(0, "@keyword.import",     { fg = c.code_preproc })
set(0, "@keyword.directive",  { fg = c.code_preproc })
set(0, "@operator",           { link = "Operator" })
set(0, "@tag",                { fg = c.primary })
set(0, "@tag.attribute",      { fg = c.code_type })
set(0, "@tag.delimiter",      { fg = c.code_punct })

-- ============================================================
-- LSP
-- ============================================================
set(0, "LspReferenceText",  { bg = c.bg_region })
set(0, "LspReferenceRead",  { bg = c.bg_region })
set(0, "LspReferenceWrite", { bg = c.bg_region })
set(0, "LspSignatureActiveParameter", { fg = c.fg_bright, bg = c.bg_region, bold = true })
set(0, "LspInlayHint",      { fg = c.fg_dim, bg = c.bg_panel })
set(0, "LspCodeLens",       { fg = c.fg_dim })
set(0, "LspCodeLensSeparator", { fg = c.fg_dim })

-- ============================================================
-- Diagnostics
-- ============================================================
set(0, "DiagnosticError", { fg = c.err })
set(0, "DiagnosticWarn",  { fg = c.warning })
set(0, "DiagnosticInfo",  { fg = c.primary_soft })
set(0, "DiagnosticHint",  { fg = c.fg_dim })
set(0, "DiagnosticOk",    { fg = c.success })
set(0, "DiagnosticUnderlineError", { undercurl = true, sp = c.err })
set(0, "DiagnosticUnderlineWarn",  { undercurl = true, sp = c.warning })
set(0, "DiagnosticUnderlineInfo",  { undercurl = true, sp = c.primary_soft })
set(0, "DiagnosticUnderlineHint",  { undercurl = true, sp = c.fg_dim })
set(0, "DiagnosticUnderlineOk",    { undercurl = true, sp = c.success })
set(0, "DiagnosticSignError", { fg = c.err,         bg = c.bg_body })
set(0, "DiagnosticSignWarn",  { fg = c.warning,     bg = c.bg_body })
set(0, "DiagnosticSignInfo",  { fg = c.primary_soft, bg = c.bg_body })
set(0, "DiagnosticSignHint",  { fg = c.fg_dim,      bg = c.bg_body })
set(0, "DiagnosticSignOk",    { fg = c.success,     bg = c.bg_body })

-- ============================================================
-- Diff & Git
-- ============================================================
set(0, "DiffAdd",     { fg = c.success, bg = c.success_bg })
set(0, "DiffDelete",  { fg = c.err,     bg = c.err_bg })
set(0, "DiffChange",  { fg = c.warning, bg = c.warning_bg })
set(0, "DiffText",    { fg = c.bg_body, bg = c.warning })
set(0, "DiffAdded",   { fg = c.success })
set(0, "DiffRemoved", { fg = c.err })
set(0, "DiffChanged", { fg = c.warning })
set(0, "GitSignsAdd",    { fg = c.success })
set(0, "GitSignsChange", { fg = c.warning })
set(0, "GitSignsDelete", { fg = c.err })
set(0, "GitSignsCurrentLineBlame", { fg = c.fg_dim })

-- ============================================================
-- Spell
-- ============================================================
set(0, "SpellBad",   { undercurl = true, sp = c.err })
set(0, "SpellCap",   { undercurl = true, sp = c.warning })
set(0, "SpellLocal", { undercurl = true, sp = c.success })
set(0, "SpellRare",  { undercurl = true, sp = c.primary_soft })

-- ============================================================
-- Telescope
-- ============================================================
set(0, "TelescopeNormal",          { fg = c.fg_main, bg = c.bg_body })
set(0, "TelescopeBorder",          { fg = c.border_faint, bg = c.bg_body })
set(0, "TelescopeSelection",       { fg = c.fg_bright, bg = c.bg_region, bold = true })
set(0, "TelescopeSelectionCaret",  { fg = c.primary, bg = c.bg_region, bold = true })
set(0, "TelescopeMultiSelection",  { fg = c.code_string, bg = c.bg_panel })
set(0, "TelescopeMatching",        { fg = c.primary, bold = true })
set(0, "TelescopeTitle",           { fg = c.primary, bold = true })

-- ============================================================
-- Which-key
-- ============================================================
set(0, "WhichKey",          { fg = c.primary, bold = true })
set(0, "WhichKeyGroup",     { fg = c.code_type })
set(0, "WhichKeyDesc",      { fg = c.fg_main })
set(0, "WhichKeySeparator", { fg = c.fg_dim })
set(0, "WhichKeyFloat",     { bg = c.bg_panel })

-- ============================================================
-- Indent guides
-- ============================================================
set(0, "IndentBlanklineChar",        { fg = c.border_faint })
set(0, "IndentBlanklineContextChar", { fg = c.primary })
set(0, "IblIndent",     { fg = c.border_faint })
set(0, "IblWhitespace", { fg = c.border_faint })
set(0, "IblScope",      { fg = c.primary })

-- ============================================================
-- Illuminate
-- ============================================================
set(0, "IlluminatedWordText",  { bg = c.bg_region })
set(0, "IlluminatedWordRead",  { bg = c.bg_region })
set(0, "IlluminatedWordWrite", { bg = c.bg_region })

return colors
