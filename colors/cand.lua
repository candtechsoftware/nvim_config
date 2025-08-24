local colors = {
  yellow     = "#E6DB74",
  orange     = "#FD971F",
  red        = "#F92672",
  magenta    = "#FD5FF0",
  blue       = "#66D9EF",
  green      = "#A6E22E",
  cyan       = "#A1EFE4",
  violet     = "#AE81FF",

  background = "#1e1e1e",
  gutter     = "#062625",
  selection  = "#0000ff",
  text       = "#d0b892",
  comment    = "#53d549",
  punctuation= "#8cde94",
  keyword    = "#ffffff",
  variable   = "#d0b892",
  function_  = "#d0b892",
  string     = "#3ad0b5",
  constant   = "#87ffde",
  macro      = "#8cde94",
  number     = "#87ffde",
  white      = "#ffffff",
  error      = "#ff0000",
  warning    = "#ffaa00",
  highlight  = "#0b3335",
  line_fg    = "#126367",
  lualine_fg = "#12251b",
  lualine_bg = "#d3b58e",

  dimmed_keyword = "#b0b0b0",
  dimmed_function = "#cccccc",
  dimmed_variable = "#a0b8c8",
  dimmed_string = "#2fa89e",
  dimmed_type = "#79c4a6",
}

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "cand"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal",           { fg = colors.text, bg = colors.background })
set(0, "Cursor",           { bg = colors.white })
set(0, "Visual",           { bg = colors.selection })
set(0, "LineNr",           { fg = colors.line_fg, bg = colors.background })
set(0, "CursorLineNr",     { fg = colors.white, bg = colors.background })
set(0, "CursorLine",       { bg = colors.highlight })
set(0, "ColorColumn",      { bg = colors.highlight })
set(0, "VertSplit",        { fg = colors.line_fg })
set(0, "MatchParen",       { bg = colors.selection })

-- Syntax
set(0, "Comment",          { fg = colors.comment })
set(0, "String",           { fg = colors.string })
set(0, "Number",           { fg = colors.number })
set(0, "Boolean",          { fg = colors.constant })
set(0, "Constant",         { fg = colors.constant })
set(0, "Identifier",       { fg = colors.variable })
set(0, "Function",         { fg = colors.function_ })
set(0, "Statement",        { fg = colors.keyword })
set(0, "Keyword",          { fg = colors.keyword })
set(0, "Type",             { fg = colors.punctuation })
set(0, "PreProc",          { fg = colors.macro })
set(0, "Special",          { fg = colors.orange })
set(0, "WarningMsg",       { fg = colors.warning })
set(0, "Error",            { fg = colors.error })

-- Diagnostics
set(0, "DiagnosticError",  { fg = colors.red })
set(0, "DiagnosticWarn",   { fg = colors.warning })
set(0, "DiagnosticInfo",   { fg = colors.blue })
set(0, "DiagnosticHint",   { fg = colors.cyan })

-- Rainbow delimiters (optional)
set(0, "rainbowcol1", { fg = colors.violet })
set(0, "rainbowcol2", { fg = colors.blue })
set(0, "rainbowcol3", { fg = colors.green })
set(0, "rainbowcol4", { fg = colors.yellow })
set(0, "rainbowcol5", { fg = colors.orange })
set(0, "rainbowcol6", { fg = colors.red })

-- Floating windows (hover screens)
set(0, "NormalFloat",       { fg = colors.text, bg = "#2a2a2a" })
set(0, "FloatBorder",       { fg = colors.line_fg, bg = "#2a2a2a" })
set(0, "FloatTitle",        { fg = colors.white, bg = "#2a2a2a" })
set(0, "Pmenu",            { fg = colors.text, bg = "#2a2a2a" })
set(0, "PmenuSel",         { fg = colors.white, bg = colors.selection })
set(0, "PmenuSbar",        { bg = "#2a2a2a" })
set(0, "PmenuThumb",       { bg = colors.line_fg })
set(0, "WinSeparator",     { fg = colors.line_fg })
set(0, "Winseparator",     { fg = colors.line_fg })

-- Lazy.nvim interface
set(0, "LazyNormal",        { fg = colors.text, bg = "#2a2a2a" })
set(0, "LazyBorder",        { fg = colors.line_fg, bg = "#2a2a2a" })
set(0, "LazyTitle",         { fg = colors.white, bg = "#2a2a2a" })
set(0, "LazyButton",        { fg = colors.text, bg = colors.highlight })
set(0, "LazyButtonActive", { fg = colors.white, bg = colors.selection })
set(0, "LazyH1",            { fg = colors.white })
set(0, "LazyH2",            { fg = colors.cyan })
set(0, "LazyComment",       { fg = colors.comment })
set(0, "LazyCommit",        { fg = colors.green })
set(0, "LazyCommitIssue",   { fg = colors.red })
set(0, "LazyCommitScope",   { fg = colors.blue })
set(0, "LazyCommitType",    { fg = colors.yellow })
set(0, "LazyDimmed",        { fg = colors.line_fg })
set(0, "LazyDir",           { fg = colors.cyan })
set(0, "LazyProgressDone",  { fg = colors.green })
set(0, "LazyProgressTodo",  { fg = colors.line_fg })
set(0, "LazyProp",          { fg = colors.punctuation })
set(0, "LazyReasonCmd",     { fg = colors.orange })
set(0, "LazyReasonEvent",   { fg = colors.yellow })
set(0, "LazyReasonFt",      { fg = colors.magenta })
set(0, "LazyReasonImport",  { fg = colors.violet })
set(0, "LazyReasonKeys",    { fg = colors.blue })
set(0, "LazyReasonPlugin",  { fg = colors.green })
set(0, "LazyReasonRuntime", { fg = colors.cyan })
set(0, "LazyReasonSource",  { fg = colors.red })
set(0, "LazyReasonStart",   { fg = colors.white })
set(0, "LazySpecial",       { fg = colors.function_ })
set(0, "LazyTaskError",     { fg = colors.error })
set(0, "LazyTaskOutput",    { fg = colors.text })
set(0, "LazyUrl",           { fg = colors.cyan })
set(0, "LazyValue",         { fg = colors.constant })

-- Lualine integration
set(0, "StatusLine",        { fg = colors.lualine_fg, bg = colors.lualine_bg })
set(0, "StatusLineNC",      { fg = colors.line_fg, bg = colors.gutter })

-- Treesitter highlights
set(0, "@comment",        { link = "Comment" })
set(0, "@string",         { link = "String" })
set(0, "@number",         { link = "Number" })
set(0, "@boolean",        { link = "Boolean" })
set(0, "@constant",       { link = "Constant" })
set(0, "@function",       { link = "Function" })
set(0, "@function.builtin", { link = "Function" })
set(0, "@variable",       { link = "Identifier" })
set(0, "@variable.builtin", { link = "Type" })
set(0, "@constant.builtin", { link = "Type" })
set(0, "@type",           { link = "Type" })
set(0, "@type.builtin",   { link = "Type" })
set(0, "@keyword",        { link = "Keyword" })
set(0, "@keyword.function", { link = "Keyword" })
set(0, "@punctuation.special", { fg = colors.function_ })
set(0, "@field",          { link = "Identifier" })
set(0, "@property",       { link = "Identifier" })
set(0, "@parameter",      { link = "Identifier" })
set(0, "@constructor",    { link = "Type" })

return colors