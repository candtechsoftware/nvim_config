-- abu — "just a phase"
-- Ported from the Emacs theme of the same name.

local colors = {
    bg              = "#191919",
    fg              = "#cdaa7d", -- burlywood3
    border          = "#090909",

    cursor_bg       = "#50ffa0",
    region_bg       = "#343c37",
    paren_match_bg  = "#536058",

    mc_cursor_bg    = "#5d6b63",

    prompt          = "#f06525",
    warning         = "#f06525",

    preproc         = "#e95410",
    keyword         = "#e95410",
    builtin         = "#e95410",

    string          = "#98c379",
    number          = "#759fbf",

    comment         = "#7f7f7f", -- gray50
    doc             = "#b3b3b3", -- gray70

    modeline_fg     = "#a0a0a0",
    modeline_bg     = "#090909",
    modeline_nc_bg  = "#131313",

    ivy1            = "#343c37",
    ivy2            = "#3e4842",
    ivy3            = "#48544d",
    ivy4            = "#536058",
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = "dark"
vim.g.colors_name = "abu"

local set = vim.api.nvim_set_hl

-- Frame
set(0, "Normal",         { fg = colors.fg, bg = colors.bg })
set(0, "NormalNC",       { fg = colors.fg, bg = colors.bg })
set(0, "NormalFloat",    { fg = colors.fg, bg = colors.bg })
set(0, "FloatBorder",    { fg = colors.border, bg = colors.bg })
set(0, "FloatTitle",     { fg = colors.fg, bg = colors.bg })
set(0, "VertSplit",      { fg = colors.border, bg = colors.bg })
set(0, "WinSeparator",   { fg = colors.border, bg = colors.bg })
set(0, "EndOfBuffer",    { fg = colors.bg })

set(0, "Cursor",         { bg = colors.cursor_bg })
set(0, "lCursor",        { bg = colors.cursor_bg })
set(0, "TermCursor",     { bg = colors.cursor_bg })

set(0, "Visual",         { bg = colors.region_bg })
set(0, "VisualNOS",      { bg = colors.region_bg })

set(0, "MatchParen",     { bg = colors.paren_match_bg })

set(0, "LineNr",         { fg = colors.comment, bg = colors.bg })
set(0, "CursorLineNr",   { fg = colors.fg, bg = colors.bg })
set(0, "SignColumn",     { fg = colors.fg, bg = colors.bg })
set(0, "FoldColumn",     { fg = colors.comment, bg = colors.bg })
set(0, "Folded",         { fg = colors.comment, bg = colors.bg })

set(0, "ModeMsg",        { fg = colors.modeline_fg })
set(0, "MsgArea",        { fg = colors.fg })
set(0, "MoreMsg",        { fg = colors.string })
set(0, "Question",       { fg = colors.string })
set(0, "WarningMsg",     { fg = colors.warning, bold = true })
set(0, "ErrorMsg",       { fg = colors.warning, bold = true })

-- minibuffer prompt
set(0, "Title",          { fg = colors.prompt, bold = true })
set(0, "Directory",      { fg = colors.prompt })

-- Mode line
set(0, "StatusLine",     { fg = colors.modeline_fg, bg = colors.modeline_bg })
set(0, "StatusLineNC",   { fg = colors.modeline_fg, bg = colors.modeline_nc_bg })
set(0, "TabLine",        { fg = colors.modeline_fg, bg = colors.modeline_nc_bg })
set(0, "TabLineSel",     { fg = colors.fg, bg = colors.modeline_bg })
set(0, "TabLineFill",    { fg = colors.modeline_fg, bg = colors.bg })

-- Pmenu / completion
set(0, "Pmenu",          { fg = colors.fg, bg = colors.modeline_nc_bg })
set(0, "PmenuSel",       { fg = colors.fg, bg = colors.ivy4 })
set(0, "PmenuSbar",      { bg = colors.modeline_nc_bg })
set(0, "PmenuThumb",     { bg = colors.ivy2 })

-- Search (ivy/swiper background-match palette)
set(0, "Search",         { bg = colors.ivy3 })
set(0, "IncSearch",      { bg = colors.ivy4 })
set(0, "CurSearch",      { bg = colors.ivy4 })
set(0, "Substitute",     { bg = colors.ivy3 })

-- Diff
set(0, "DiffAdd",        { fg = colors.string, bg = colors.bg })
set(0, "DiffChange",     { fg = colors.number, bg = colors.bg })
set(0, "DiffDelete",     { fg = colors.warning, bg = colors.bg })
set(0, "DiffText",       { fg = colors.fg, bg = colors.region_bg })

-- Spelling
set(0, "SpellBad",       { sp = colors.warning, undercurl = true })
set(0, "SpellCap",       { sp = colors.number, undercurl = true })
set(0, "SpellLocal",     { sp = colors.string, undercurl = true })
set(0, "SpellRare",      { sp = colors.doc, undercurl = true })

-- Code
set(0, "Comment",        { fg = colors.comment })
set(0, "SpecialComment", { fg = colors.doc })

set(0, "String",         { fg = colors.string })
set(0, "Character",      { fg = colors.string })
set(0, "Number",         { fg = colors.number })
set(0, "Float",          { fg = colors.number })
set(0, "Boolean",        { fg = colors.number })

set(0, "Identifier",     { fg = colors.fg })
set(0, "Function",       { fg = colors.fg })
set(0, "Type",           { fg = colors.fg })
set(0, "StorageClass",   { fg = colors.keyword })
set(0, "Structure",      { fg = colors.fg })
set(0, "Typedef",        { fg = colors.fg })
set(0, "Constant",       { fg = colors.fg })

set(0, "Statement",      { fg = colors.keyword })
set(0, "Conditional",    { fg = colors.keyword })
set(0, "Repeat",         { fg = colors.keyword })
set(0, "Label",          { fg = colors.keyword })
set(0, "Operator",       { fg = colors.fg })
set(0, "Keyword",        { fg = colors.keyword })
set(0, "Exception",      { fg = colors.keyword })

set(0, "PreProc",        { fg = colors.preproc, bold = true })
set(0, "Include",        { fg = colors.preproc, bold = true })
set(0, "Define",         { fg = colors.preproc, bold = true })
set(0, "Macro",          { fg = colors.preproc, bold = true })
set(0, "PreCondit",      { fg = colors.preproc, bold = true })

set(0, "Special",        { fg = colors.fg })
set(0, "SpecialChar",    { fg = colors.fg })
set(0, "Tag",            { fg = colors.fg })
set(0, "Delimiter",      { fg = colors.fg })
set(0, "Debug",          { fg = colors.warning })

set(0, "Underlined",     { underline = true })
set(0, "Todo",           { fg = colors.warning, bold = true })
set(0, "Error",          { fg = colors.warning, bold = true })

-- Treesitter
set(0, "@comment",                 { link = "Comment" })
set(0, "@comment.documentation",   { fg = colors.doc })
set(0, "@string.documentation",    { fg = colors.doc })
set(0, "@string",                  { link = "String" })
set(0, "@string.escape",           { fg = colors.fg })
set(0, "@character",               { link = "Character" })
set(0, "@number",                  { link = "Number" })
set(0, "@number.float",            { link = "Float" })
set(0, "@boolean",                 { link = "Boolean" })

set(0, "@constant",                { link = "Constant" })
set(0, "@constant.builtin",        { fg = colors.builtin })
set(0, "@constant.macro",          { fg = colors.preproc, bold = true })

set(0, "@variable",                { link = "Identifier" })
set(0, "@variable.builtin",        { fg = colors.builtin })
set(0, "@variable.parameter",      { fg = colors.fg })
set(0, "@variable.member",         { fg = colors.fg })

set(0, "@function",                { link = "Function" })
set(0, "@function.builtin",        { fg = colors.builtin })
set(0, "@function.call",           { fg = colors.fg })
set(0, "@function.macro",          { fg = colors.preproc, bold = true })

set(0, "@type",                    { link = "Type" })
set(0, "@type.builtin",            { fg = colors.builtin })
set(0, "@type.definition",         { fg = colors.fg })

set(0, "@keyword",                 { link = "Keyword" })
set(0, "@keyword.function",        { link = "Keyword" })
set(0, "@keyword.return",          { link = "Keyword" })
set(0, "@keyword.conditional",     { link = "Keyword" })
set(0, "@keyword.repeat",          { link = "Keyword" })
set(0, "@keyword.import",          { fg = colors.preproc, bold = true })
set(0, "@keyword.directive",       { fg = colors.preproc, bold = true })
set(0, "@keyword.modifier",        { link = "Keyword" })
set(0, "@keyword.exception",       { link = "Keyword" })

set(0, "@attribute",               { fg = colors.preproc, bold = true })
set(0, "@module",                  { fg = colors.fg })
set(0, "@property",                { fg = colors.fg })
set(0, "@field",                   { fg = colors.fg })

set(0, "@punctuation.bracket",     { fg = colors.fg })
set(0, "@punctuation.delimiter",   { fg = colors.fg })
set(0, "@punctuation.special",     { fg = colors.fg })

set(0, "@constructor",             { fg = colors.fg })
set(0, "@operator",                { link = "Operator" })

-- Multiple cursors (mc/cursor-face)
set(0, "MultiCursor",              { bg = colors.mc_cursor_bg })

-- Diagnostics
set(0, "DiagnosticError",          { fg = colors.warning })
set(0, "DiagnosticWarn",           { fg = colors.warning })
set(0, "DiagnosticInfo",           { fg = colors.number })
set(0, "DiagnosticHint",           { fg = colors.string })
set(0, "DiagnosticOk",             { fg = colors.string })
set(0, "DiagnosticUnderlineError", { sp = colors.warning, undercurl = true })
set(0, "DiagnosticUnderlineWarn",  { sp = colors.warning, undercurl = true })
set(0, "DiagnosticUnderlineInfo",  { sp = colors.number, undercurl = true })
set(0, "DiagnosticUnderlineHint",  { sp = colors.string, undercurl = true })

-- NetRW
set(0, "netrwDir",                 { fg = colors.fg })
set(0, "netrwExe",                 { fg = colors.keyword })
