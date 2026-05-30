-- hmin: minimal variant of the hh theme
-- Reuses hh's scope-highlight + macro-indexer machinery, but collapses the busy
-- rainbow syntax palette into a near-monochrome warm set:
--   * one foreground for code, dim grey comments, one gold accent (keywords/types),
--     one muted sage for literals (strings/numbers)
-- The mode-based block cursor is kept and re-affirmed: it changes color per mode
--   normal = green, insert = orange, visual = gold, replace = red, command = olive.

-- Load hh first to install its scope highlighting, macro indexer and autocmds.
-- (require() can't find files under colors/, so resolve the path off runtimepath.)
local hh_path = vim.api.nvim_get_runtime_file("colors/hh.lua", false)[1]
if hh_path then
  pcall(dofile, hh_path)
end

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.colors_name = "hmin"

local hl = vim.api.nvim_set_hl

-- Minimal palette ---------------------------------------------------------
local c = {
  back     = "#050505", -- text area background
  back2    = "#0b0b0b", -- floats / popups
  bar      = "#0c0c0e", -- status / tab bar
  line_bg  = "#070707", -- gutter background

  fg       = "#b3a994", -- main code text (warm tan-grey)
  fg_dim   = "#7c756a", -- punctuation / preproc / dim ui
  comment  = "#55514a", -- comments
  ghost    = "#3a382f", -- non-text / whitespace

  gold     = "#b8923a", -- the one accent: keywords, types, headings
  sage     = "#8a8d6b", -- literals: strings, numbers, constants

  sel      = "#16222c", -- visual selection
  sel_soft = "#10181f", -- cursorline / menus
  search   = "#2a3a30", -- search background

  error    = "#a85442", -- muted red
  warn     = "#b8923a", -- reuse gold
  ok       = "#6f8f4a", -- muted green

  -- Mode cursor colors (vivid on purpose — the per-mode cursor cue)
  cur_normal  = "#00ee00",
  cur_insert  = "#ee7700",
  cur_visual  = "#cb9401",
  cur_replace = "#ff0000",
  cur_command = "#70971e",
}

-- Mode-based block cursor (re-affirmed so :colorscheme hmin works standalone) --
hl(0, "CursorNormal",  { fg = c.back, bg = c.cur_normal })
hl(0, "CursorInsert",  { fg = c.back, bg = c.cur_insert })
hl(0, "CursorVisual",  { fg = c.back, bg = c.cur_visual })
hl(0, "CursorReplace", { fg = c.back, bg = c.cur_replace })
hl(0, "CursorCommand", { fg = c.back, bg = c.cur_command })
vim.opt.guicursor = {
  "n-c:block-CursorNormal",      -- normal / command -> green block
  "i-ci-ve:block-CursorInsert",  -- insert -> orange block
  "v-V:block-CursorVisual",      -- visual -> gold block
  "r-cr:block-CursorReplace",    -- replace -> red block
  "o:block-CursorNormal",        -- operator-pending -> green block
}

-- Core UI -----------------------------------------------------------------
hl(0, "Normal",       { fg = c.fg, bg = c.back })
hl(0, "NormalFloat",  { fg = c.fg, bg = c.back2 })
hl(0, "FloatBorder",  { fg = c.fg_dim, bg = c.back2 })
hl(0, "FloatTitle",   { fg = c.gold, bg = c.back2 })
hl(0, "NormalNC",     { fg = c.fg, bg = c.back })

hl(0, "CursorLine",   { bg = c.sel_soft })
hl(0, "CursorColumn", { bg = c.sel_soft })
hl(0, "ColorColumn",  { bg = c.sel_soft })
hl(0, "Visual",       { bg = c.sel })
hl(0, "VisualNOS",    { bg = c.sel })

hl(0, "LineNr",       { fg = c.ghost, bg = c.line_bg })
hl(0, "CursorLineNr", { fg = c.gold, bg = c.line_bg, bold = true })
hl(0, "SignColumn",   { bg = c.line_bg })
hl(0, "FoldColumn",   { fg = c.comment, bg = c.line_bg })
hl(0, "Folded",       { fg = c.comment, bg = c.sel_soft })

hl(0, "StatusLine",   { fg = c.fg, bg = c.bar })
hl(0, "StatusLineNC", { fg = c.fg_dim, bg = c.bar })
hl(0, "WinBar",       { fg = c.fg, bg = c.back })
hl(0, "WinBarNC",     { fg = c.comment, bg = c.back })
hl(0, "TabLine",      { fg = c.fg_dim, bg = c.bar })
hl(0, "TabLineFill",  { bg = c.bar })
hl(0, "TabLineSel",   { fg = c.gold, bg = c.back, bold = true })

hl(0, "VertSplit",    { fg = c.bar, bg = c.back })
hl(0, "WinSeparator", { fg = c.bar, bg = c.back })

hl(0, "Search",       { fg = c.fg, bg = c.search })
hl(0, "IncSearch",    { fg = c.back, bg = c.cur_normal })
hl(0, "CurSearch",    { fg = c.back, bg = c.cur_normal })
hl(0, "Substitute",   { fg = c.back, bg = c.warn })
hl(0, "MatchParen",   { fg = c.gold, bold = true })

hl(0, "Pmenu",        { fg = c.fg, bg = c.back2 })
hl(0, "PmenuSel",     { fg = c.gold, bg = c.sel })
hl(0, "PmenuSbar",    { bg = c.bar })
hl(0, "PmenuThumb",   { bg = c.fg_dim })
hl(0, "WildMenu",     { fg = c.gold, bg = c.sel })
hl(0, "QuickFixLine", { bg = c.sel })

hl(0, "NonText",      { fg = c.ghost })
hl(0, "SpecialKey",   { fg = c.ghost })
hl(0, "Whitespace",   { fg = c.ghost })
hl(0, "Conceal",      { fg = c.ghost })
hl(0, "EndOfBuffer",  { fg = c.back })
hl(0, "Directory",    { fg = c.gold })
hl(0, "Title",        { fg = c.gold, bold = true })

hl(0, "ModeMsg",      { fg = c.fg_dim })
hl(0, "MoreMsg",      { fg = c.fg_dim })
hl(0, "Question",     { fg = c.fg_dim })
hl(0, "ErrorMsg",     { fg = c.error })
hl(0, "WarningMsg",   { fg = c.warn })

-- Syntax (collapsed) ------------------------------------------------------
hl(0, "Comment",      { fg = c.comment, italic = true })
hl(0, "SpecialComment", { fg = c.comment, italic = true })

hl(0, "String",       { fg = c.sage })
hl(0, "Character",    { fg = c.sage })
hl(0, "Number",       { fg = c.sage })
hl(0, "Float",        { fg = c.sage })
hl(0, "Boolean",      { fg = c.sage })
hl(0, "Constant",     { fg = c.sage })

hl(0, "Identifier",   { fg = c.fg })
hl(0, "Function",     { fg = c.fg })  -- functions stay plain (minimal)

hl(0, "Statement",    { fg = c.gold })
hl(0, "Conditional",  { fg = c.gold })
hl(0, "Repeat",       { fg = c.gold })
hl(0, "Label",        { fg = c.gold })
hl(0, "Keyword",      { fg = c.gold })
hl(0, "Exception",    { fg = c.gold })
hl(0, "Operator",     { fg = c.fg_dim })
hl(0, "StorageClass", { fg = c.gold })

hl(0, "Type",         { fg = c.gold })
hl(0, "Structure",    { fg = c.gold })
hl(0, "Typedef",      { fg = c.gold })

hl(0, "PreProc",      { fg = c.fg_dim })
hl(0, "Include",      { fg = c.fg_dim })
hl(0, "Define",       { fg = c.fg_dim })
hl(0, "Macro",        { fg = c.fg_dim })
hl(0, "PreCondit",    { fg = c.fg_dim })

hl(0, "Special",      { fg = c.gold })
hl(0, "SpecialChar",  { fg = c.gold })
hl(0, "Delimiter",    { fg = c.fg_dim })
hl(0, "Tag",          { fg = c.gold })
hl(0, "Debug",        { fg = c.error })
hl(0, "Underlined",   { fg = c.fg, underline = true })
hl(0, "Ignore",       { fg = c.ghost })
hl(0, "Error",        { fg = c.error, bold = true })
hl(0, "Todo",         { fg = c.gold, bg = c.sel_soft, bold = true })

-- Treesitter: link everything down to the collapsed base groups -----------
local links = {
  ["@comment"]              = "Comment",
  ["@comment.documentation"] = "Comment",
  ["@comment.error"]        = "Error",
  ["@comment.warning"]      = "WarningMsg",
  ["@comment.todo"]         = "Todo",
  ["@comment.note"]         = "SpecialComment",

  ["@string"]               = "String",
  ["@string.documentation"] = "String",
  ["@string.regexp"]        = "String",
  ["@string.escape"]        = "Special",
  ["@string.special"]       = "Special",
  ["@character"]            = "Character",
  ["@character.special"]    = "Special",
  ["@boolean"]              = "Boolean",
  ["@number"]               = "Number",
  ["@number.float"]         = "Float",
  ["@constant"]             = "Constant",
  ["@constant.builtin"]     = "Constant",
  ["@constant.macro"]       = "PreProc",

  ["@variable"]             = "Identifier",
  ["@variable.builtin"]     = "Constant",
  ["@variable.parameter"]   = "Identifier",
  ["@variable.member"]      = "Identifier",
  ["@property"]             = "Identifier",
  ["@field"]                = "Identifier",

  ["@function"]             = "Function",
  ["@function.builtin"]     = "Function",
  ["@function.call"]        = "Function",
  ["@function.macro"]       = "PreProc",
  ["@function.method"]      = "Function",
  ["@function.method.call"] = "Function",
  ["@constructor"]          = "Type",

  ["@type"]                 = "Type",
  ["@type.builtin"]         = "Type",
  ["@type.definition"]      = "Type",
  ["@module"]               = "Type",
  ["@attribute"]            = "PreProc",

  ["@keyword"]              = "Keyword",
  ["@keyword.function"]     = "Keyword",
  ["@keyword.operator"]     = "Operator",
  ["@keyword.import"]       = "PreProc",
  ["@keyword.return"]       = "Keyword",
  ["@keyword.repeat"]       = "Repeat",
  ["@keyword.conditional"]  = "Conditional",
  ["@keyword.exception"]    = "Exception",
  ["@keyword.modifier"]     = "StorageClass",
  ["@keyword.type"]         = "Keyword",
  ["@keyword.directive"]    = "PreProc",
  ["@label"]                = "Label",

  ["@operator"]             = "Operator",
  ["@punctuation"]          = "Delimiter",
  ["@punctuation.delimiter"] = "Delimiter",
  ["@punctuation.bracket"]  = "Delimiter",
  ["@punctuation.special"]  = "Special",

  ["@tag"]                  = "Keyword",
  ["@tag.attribute"]        = "Identifier",
  ["@tag.delimiter"]        = "Delimiter",

  -- LSP semantic tokens
  ["@lsp.type.class"]       = "Type",
  ["@lsp.type.enum"]        = "Type",
  ["@lsp.type.enumMember"]  = "Constant",
  ["@lsp.type.interface"]   = "Type",
  ["@lsp.type.struct"]      = "Type",
  ["@lsp.type.namespace"]   = "Type",
  ["@lsp.type.type"]        = "Type",
  ["@lsp.type.typeParameter"] = "Type",
  ["@lsp.type.function"]    = "Function",
  ["@lsp.type.method"]      = "Function",
  ["@lsp.type.macro"]       = "PreProc",
  ["@lsp.type.parameter"]   = "Identifier",
  ["@lsp.type.property"]    = "Identifier",
  ["@lsp.type.variable"]    = "Identifier",
  ["@lsp.type.comment"]     = "Comment",
  ["@lsp.type.decorator"]   = "PreProc",
  ["@lsp.typemod.enumMember"] = "Constant",

  -- Markup
  ["@markup"]               = "Normal",
  ["@markup.heading"]       = "Title",
  ["@markup.raw"]           = "String",
  ["@markup.link"]          = "Underlined",
  ["@markup.list"]          = "Delimiter",
  ["@markup.quote"]         = "Comment",

  -- Yggdrasil custom groups from hh -> collapse to minimal
  ["YgKeyword"]             = "Keyword",
  ["YgType"]                = "Type",
}
for group, target in pairs(links) do
  hl(0, group, { link = target })
end

-- Diagnostics (muted) -----------------------------------------------------
hl(0, "DiagnosticError", { fg = c.error })
hl(0, "DiagnosticWarn",  { fg = c.warn })
hl(0, "DiagnosticInfo",  { fg = c.fg_dim })
hl(0, "DiagnosticHint",  { fg = c.comment })
hl(0, "DiagnosticOk",    { fg = c.ok })
hl(0, "DiagnosticVirtualTextError", { fg = c.error })
hl(0, "DiagnosticVirtualTextWarn",  { fg = c.warn })
hl(0, "DiagnosticVirtualTextInfo",  { fg = c.fg_dim })
hl(0, "DiagnosticVirtualTextHint",  { fg = c.comment })
hl(0, "DiagnosticUnderlineError", { sp = c.error, undercurl = true })
hl(0, "DiagnosticUnderlineWarn",  { sp = c.warn, undercurl = true })
hl(0, "DiagnosticUnderlineInfo",  { sp = c.fg_dim, undercurl = true })
hl(0, "DiagnosticUnderlineHint",  { sp = c.comment, undercurl = true })
hl(0, "DiagnosticSignError", { fg = c.error, bg = c.line_bg })
hl(0, "DiagnosticSignWarn",  { fg = c.warn, bg = c.line_bg })
hl(0, "DiagnosticSignInfo",  { fg = c.fg_dim, bg = c.line_bg })
hl(0, "DiagnosticSignHint",  { fg = c.comment, bg = c.line_bg })

-- Git signs ---------------------------------------------------------------
hl(0, "GitSignsAdd",    { fg = c.ok, bg = c.line_bg })
hl(0, "GitSignsChange", { fg = c.gold, bg = c.line_bg })
hl(0, "GitSignsDelete", { fg = c.error, bg = c.line_bg })
hl(0, "DiffAdd",    { bg = "#0a100a" })
hl(0, "DiffChange", { bg = "#100e08" })
hl(0, "DiffDelete", { fg = c.error, bg = "#100808" })
hl(0, "DiffText",   { bg = "#1a1608", bold = true })

-- Telescope ---------------------------------------------------------------
hl(0, "TelescopeNormal",         { fg = c.fg, bg = c.back })
hl(0, "TelescopeBorder",         { fg = c.fg_dim, bg = c.back })
hl(0, "TelescopePromptNormal",   { fg = c.fg, bg = c.back })
hl(0, "TelescopePromptBorder",   { fg = c.fg_dim, bg = c.back })
hl(0, "TelescopePromptPrefix",   { fg = c.gold, bg = c.back })
hl(0, "TelescopeResultsNormal",  { fg = c.fg, bg = c.back })
hl(0, "TelescopeResultsBorder",  { fg = c.fg_dim, bg = c.back })
hl(0, "TelescopePreviewNormal",  { fg = c.fg, bg = c.back })
hl(0, "TelescopePreviewBorder",  { fg = c.fg_dim, bg = c.back })
hl(0, "TelescopeSelection",      { fg = c.gold, bg = c.sel })
hl(0, "TelescopeSelectionCaret", { fg = c.gold, bg = c.sel })
hl(0, "TelescopeMatching",       { fg = c.gold, bold = true })

-- Indent / misc -----------------------------------------------------------
hl(0, "IblIndent",  { fg = c.ghost })
hl(0, "IblScope",   { fg = c.fg_dim })
hl(0, "WhichKey",       { fg = c.gold })
hl(0, "WhichKeyGroup",  { fg = c.fg_dim })
hl(0, "WhichKeyDesc",   { fg = c.fg })
hl(0, "WhichKeyFloat",  { bg = c.back2 })

-- Scope background cycle: collapse hh's rainbow tints into one faint lift --
for i = 1, 8 do
  hl(0, "HHScope" .. i, { bg = "#0b0b0b" })
end

return c
