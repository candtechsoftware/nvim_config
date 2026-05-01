-- dream — port of Protesilaos's ef-dream Emacs theme
-- Legible dark purple/grey theme with gold and nuanced colors.

local M = {}

local p = {
  -- Backgrounds / foregrounds
  bg_main         = "#232025",
  bg_dim          = "#322f34",
  bg_alt          = "#3b393e",
  bg_active       = "#5b595e",
  bg_inactive     = "#3a373c",
  bg_popup        = "#2e2a31",
  bg_hl_line      = "#412f4f",
  bg_region       = "#544a50",
  bg_completion   = "#503240",
  bg_paren_match  = "#885566",
  bg_hover        = "#795056",
  bg_hover_2      = "#665f7a",
  bg_mode_active  = "#675072",
  fg_mode_active  = "#fedeff",
  border          = "#635850",
  cursor          = "#f3c09a",

  fg_main         = "#efd5c5",
  fg_dim          = "#8f8886",
  fg_alt          = "#b0a0cf",

  -- Accents
  red             = "#ff6f6f",
  red_warmer      = "#ff7a5f",
  red_cooler      = "#e47980",
  red_faint       = "#f3a0a0",
  green           = "#51b04f",
  green_warmer    = "#7fce5f",
  green_cooler    = "#3fc489",
  green_faint     = "#a9c99f",
  yellow          = "#c0b24f",
  yellow_warmer   = "#d09950",
  yellow_cooler   = "#deb07a",
  yellow_faint    = "#caa89f",
  blue            = "#57b0ff",
  blue_warmer     = "#80aadf",
  blue_cooler     = "#12b4ff",
  blue_faint      = "#a0a0cf",
  magenta         = "#ffaacf",
  magenta_warmer  = "#f498c0",
  magenta_cooler  = "#d0b0ff",
  magenta_faint   = "#e3b0c0",
  cyan            = "#6fb3c0",
  cyan_warmer     = "#8fcfd0",
  cyan_cooler     = "#65c5a8",
  cyan_faint      = "#99bfcf",

  -- Intense / subtle backgrounds
  bg_red_intense    = "#a02f50",
  bg_green_intense  = "#30682f",
  bg_yellow_intense = "#8f665f",
  bg_blue_intense   = "#4f509f",
  bg_magenta_intense= "#885997",
  bg_cyan_intense   = "#0280b9",

  bg_red_subtle     = "#6f202a",
  bg_green_subtle   = "#2a532f",
  bg_yellow_subtle  = "#62432a",
  bg_blue_subtle    = "#3a3e73",
  bg_magenta_subtle = "#66345a",
  bg_cyan_subtle    = "#334d69",

  -- Diff
  bg_added          = "#304a4f",
  bg_added_faint    = "#16383f",
  bg_added_refine   = "#2f6767",
  fg_added          = "#a0d0f0",
  bg_changed        = "#51512f",
  bg_changed_faint  = "#40332f",
  bg_changed_refine = "#64651f",
  fg_changed        = "#dada90",
  bg_removed        = "#5a3142",
  bg_removed_faint  = "#4a2034",
  bg_removed_refine = "#782a4a",
  fg_removed        = "#f0bfcf",

  -- Diagnostics
  bg_err            = "#501a2d",
  bg_warning        = "#4e3930",
  bg_info           = "#0f3f4f",

  -- Scope nesting cycle — palette-tinted lifts above #232025 (purple-grey)
  back_cycle = {
    "#2a2030", -- purple (dream's signature)
    "#202b22", -- green
    "#202230", -- blue
    "#322620", -- amber/gold (yellow-cooler lean)
    "#322028", -- pink (magenta lean)
    "#202e30", -- cyan
    "#2a2a20", -- olive
    "#241f33", -- violet
  },
}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.g.colors_name = "dream"
  vim.o.background = "dark"
  vim.o.termguicolors = true

  local hl = vim.api.nvim_set_hl

  -- UI
  hl(0, "Normal",       { fg = p.fg_main, bg = p.bg_main })
  hl(0, "NormalFloat",  { fg = p.fg_main, bg = p.bg_popup })
  hl(0, "FloatBorder",  { fg = p.border, bg = p.bg_popup })
  hl(0, "FloatTitle",   { fg = p.yellow_cooler, bg = p.bg_popup, bold = true })
  hl(0, "EndOfBuffer",  { fg = p.bg_main })
  hl(0, "Cursor",       { fg = p.bg_main, bg = p.cursor })
  hl(0, "CursorLine",   { bg = p.bg_hl_line })
  hl(0, "CursorColumn", { bg = p.bg_hl_line })
  hl(0, "ColorColumn",  { bg = p.bg_dim })
  hl(0, "Visual",       { bg = p.bg_region })
  hl(0, "VisualNOS",    { bg = p.bg_region })
  hl(0, "MatchParen",   { bg = p.bg_paren_match, bold = true })

  -- Line numbers
  hl(0, "LineNr",       { fg = p.fg_dim, bg = p.bg_main })
  hl(0, "CursorLineNr", { fg = p.yellow_cooler, bg = p.bg_hl_line, bold = true })
  hl(0, "SignColumn",   { bg = p.bg_main })
  hl(0, "FoldColumn",   { fg = p.fg_dim, bg = p.bg_main })
  hl(0, "Folded",       { fg = p.fg_dim, bg = p.bg_dim })

  -- Statusline / tabs
  hl(0, "StatusLine",   { fg = p.fg_mode_active, bg = p.bg_mode_active })
  hl(0, "StatusLineNC", { fg = p.fg_dim, bg = p.bg_inactive })
  hl(0, "WinBar",       { fg = p.fg_main, bg = p.bg_main })
  hl(0, "WinBarNC",     { fg = p.fg_dim, bg = p.bg_main })
  hl(0, "TabLine",      { fg = p.fg_dim, bg = p.bg_inactive })
  hl(0, "TabLineFill",  { bg = p.bg_inactive })
  hl(0, "TabLineSel",   { fg = p.fg_mode_active, bg = p.bg_mode_active, bold = true })
  hl(0, "VertSplit",    { fg = p.border, bg = p.bg_main })
  hl(0, "WinSeparator", { fg = p.border, bg = p.bg_main })

  -- Search
  hl(0, "Search",       { bg = p.bg_warning, fg = p.fg_main })
  hl(0, "IncSearch",    { bg = p.bg_yellow_intense, fg = p.fg_main, bold = true })
  hl(0, "CurSearch",    { bg = p.bg_yellow_intense, fg = p.fg_main, bold = true })
  hl(0, "Substitute",   { bg = p.bg_red_intense, fg = p.fg_main })

  -- Popup menu
  hl(0, "Pmenu",        { fg = p.fg_main, bg = p.bg_popup })
  hl(0, "PmenuSel",     { fg = p.fg_main, bg = p.bg_completion, bold = true })
  hl(0, "PmenuSbar",    { bg = p.bg_dim })
  hl(0, "PmenuThumb",   { bg = p.bg_active })

  -- Messages
  hl(0, "ModeMsg",      { fg = p.cyan })
  hl(0, "MoreMsg",      { fg = p.cyan })
  hl(0, "Question",     { fg = p.cyan })
  hl(0, "ErrorMsg",     { fg = p.red })
  hl(0, "WarningMsg",   { fg = p.yellow_warmer })
  hl(0, "MsgArea",      { fg = p.fg_main })

  -- Special
  hl(0, "NonText",      { fg = p.fg_dim })
  hl(0, "SpecialKey",   { fg = p.fg_dim })
  hl(0, "Whitespace",   { fg = p.fg_dim })
  hl(0, "Conceal",      { fg = p.fg_dim })
  hl(0, "Directory",    { fg = p.cyan_warmer })
  hl(0, "Title",        { fg = p.yellow_cooler, bold = true })
  hl(0, "WildMenu",     { fg = p.fg_main, bg = p.bg_completion })
  hl(0, "QuickFixLine", { bg = p.bg_hl_line })

  -- Diff
  hl(0, "DiffAdd",      { bg = p.bg_added_faint })
  hl(0, "DiffChange",   { bg = p.bg_changed_faint })
  hl(0, "DiffDelete",   { fg = p.fg_removed, bg = p.bg_removed_faint })
  hl(0, "DiffText",     { bg = p.bg_changed_refine, bold = true })

  -- Spell
  hl(0, "SpellBad",   { sp = p.red, undercurl = true })
  hl(0, "SpellCap",   { sp = p.yellow_warmer, undercurl = true })
  hl(0, "SpellLocal", { sp = p.cyan, undercurl = true })
  hl(0, "SpellRare",  { sp = p.magenta, undercurl = true })

  -- Syntax (legacy)
  hl(0, "Comment",      { fg = p.blue_faint, italic = true })
  hl(0, "Constant",     { fg = p.blue_warmer })
  hl(0, "String",       { fg = p.red_faint })
  hl(0, "Character",    { fg = p.red_faint })
  hl(0, "Number",       { fg = p.blue_warmer })
  hl(0, "Boolean",      { fg = p.blue_warmer })
  hl(0, "Float",        { fg = p.blue_warmer })

  hl(0, "Identifier",   { fg = p.yellow_cooler })
  hl(0, "Function",     { fg = p.cyan_warmer })

  hl(0, "Statement",    { fg = p.yellow_cooler })
  hl(0, "Conditional",  { fg = p.yellow_cooler })
  hl(0, "Repeat",       { fg = p.yellow_cooler })
  hl(0, "Label",        { fg = p.yellow_cooler })
  hl(0, "Operator",     { fg = p.fg_main })
  hl(0, "Keyword",      { fg = p.yellow_cooler })
  hl(0, "Exception",    { fg = p.red_cooler })

  hl(0, "PreProc",      { fg = p.cyan_cooler })
  hl(0, "Include",      { fg = p.cyan_cooler })
  hl(0, "Define",       { fg = p.cyan_cooler })
  hl(0, "Macro",        { fg = p.cyan_cooler })
  hl(0, "PreCondit",    { fg = p.cyan_cooler })

  hl(0, "Type",         { fg = p.green_faint })
  hl(0, "StorageClass", { fg = p.yellow_cooler })
  hl(0, "Structure",    { fg = p.green_faint })
  hl(0, "Typedef",      { fg = p.green_faint })

  hl(0, "Special",      { fg = p.magenta_warmer })
  hl(0, "SpecialChar",  { fg = p.cyan_cooler })
  hl(0, "Tag",          { fg = p.magenta_warmer })
  hl(0, "Delimiter",    { fg = p.fg_dim })
  hl(0, "SpecialComment", { fg = p.cyan, italic = true })
  hl(0, "Debug",        { fg = p.red_warmer })

  hl(0, "Underlined",   { fg = p.yellow_cooler, underline = true })
  hl(0, "Ignore",       { fg = p.fg_dim })
  hl(0, "Error",        { fg = p.red, bold = true })
  hl(0, "Todo",         { fg = p.yellow_warmer, bold = true })

  -- Treesitter
  hl(0, "@variable",            { fg = p.magenta })
  hl(0, "@variable.builtin",    { fg = p.magenta_faint })
  hl(0, "@variable.parameter",  { fg = p.fg_alt })
  hl(0, "@variable.member",     { fg = p.magenta_faint })

  hl(0, "@constant",            { fg = p.blue_warmer })
  hl(0, "@constant.builtin",    { fg = p.blue_warmer })
  hl(0, "@constant.macro",      { fg = p.cyan_cooler })

  hl(0, "@module",              { fg = p.green_faint })
  hl(0, "@module.builtin",      { fg = p.green_faint })
  hl(0, "@label",               { fg = p.yellow_cooler })

  hl(0, "@string",              { fg = p.red_faint })
  hl(0, "@string.documentation", { fg = p.yellow_faint })
  hl(0, "@string.regexp",       { fg = p.red_cooler })
  hl(0, "@string.escape",       { fg = p.cyan_cooler })
  hl(0, "@string.special",      { fg = p.magenta_warmer })
  hl(0, "@string.special.url",  { fg = p.yellow_cooler, underline = true })

  hl(0, "@character",           { fg = p.red_faint })
  hl(0, "@character.special",   { fg = p.magenta_warmer })

  hl(0, "@boolean",             { fg = p.blue_warmer })
  hl(0, "@number",              { fg = p.blue_warmer })
  hl(0, "@number.float",        { fg = p.blue_warmer })

  hl(0, "@type",                { fg = p.green_faint })
  hl(0, "@type.builtin",        { fg = p.green_faint })
  hl(0, "@type.definition",     { fg = p.green_faint })

  hl(0, "@attribute",           { fg = p.cyan_cooler })
  hl(0, "@property",            { fg = p.magenta_faint })

  hl(0, "@function",            { fg = p.cyan_warmer })
  hl(0, "@function.builtin",    { fg = p.cyan_warmer })
  hl(0, "@function.call",       { fg = p.cyan_faint })
  hl(0, "@function.macro",      { fg = p.cyan_cooler })
  hl(0, "@function.method",     { fg = p.cyan_warmer })
  hl(0, "@function.method.call", { fg = p.cyan_faint })

  hl(0, "@constructor",         { fg = p.green_faint })
  hl(0, "@operator",            { fg = p.fg_main })

  hl(0, "@keyword",             { fg = p.yellow_cooler })
  hl(0, "@keyword.coroutine",   { fg = p.yellow_cooler })
  hl(0, "@keyword.function",    { fg = p.yellow_cooler })
  hl(0, "@keyword.operator",    { fg = p.yellow_cooler })
  hl(0, "@keyword.import",      { fg = p.cyan_cooler })
  hl(0, "@keyword.type",        { fg = p.yellow_cooler })
  hl(0, "@keyword.modifier",    { fg = p.yellow_cooler })
  hl(0, "@keyword.repeat",      { fg = p.yellow_cooler })
  hl(0, "@keyword.return",      { fg = p.yellow_cooler })
  hl(0, "@keyword.debug",       { fg = p.red_warmer })
  hl(0, "@keyword.exception",   { fg = p.red_cooler })
  hl(0, "@keyword.conditional", { fg = p.yellow_cooler })
  hl(0, "@keyword.directive",   { fg = p.cyan_cooler })

  hl(0, "@punctuation",            { fg = p.fg_dim })
  hl(0, "@punctuation.delimiter",  { fg = p.fg_dim })
  hl(0, "@punctuation.bracket",    { fg = p.fg_dim })
  hl(0, "@punctuation.special",    { fg = p.magenta_warmer })

  hl(0, "@comment",                { fg = p.blue_faint, italic = true })
  hl(0, "@comment.documentation",  { fg = p.yellow_faint, italic = true })
  hl(0, "@comment.error",          { fg = p.red, bold = true })
  hl(0, "@comment.warning",        { fg = p.yellow_warmer, bold = true })
  hl(0, "@comment.todo",           { fg = p.yellow_warmer, bold = true })
  hl(0, "@comment.note",           { fg = p.cyan, bold = true })

  hl(0, "@markup",                 { fg = p.fg_main })
  hl(0, "@markup.strong",          { bold = true })
  hl(0, "@markup.italic",          { italic = true })
  hl(0, "@markup.strikethrough",   { strikethrough = true })
  hl(0, "@markup.underline",       { underline = true })
  hl(0, "@markup.heading",         { fg = p.yellow_cooler, bold = true })
  hl(0, "@markup.heading.1",       { fg = p.yellow_cooler, bold = true })
  hl(0, "@markup.heading.2",       { fg = p.magenta, bold = true })
  hl(0, "@markup.heading.3",       { fg = p.blue_warmer, bold = true })
  hl(0, "@markup.heading.4",       { fg = p.red_cooler, bold = true })
  hl(0, "@markup.heading.5",       { fg = p.magenta_cooler, bold = true })
  hl(0, "@markup.heading.6",       { fg = p.green_cooler, bold = true })
  hl(0, "@markup.quote",           { fg = p.fg_dim, italic = true })
  hl(0, "@markup.link",            { fg = p.yellow_cooler, underline = true })
  hl(0, "@markup.link.label",      { fg = p.magenta_warmer })
  hl(0, "@markup.link.url",        { fg = p.yellow_cooler, underline = true })
  hl(0, "@markup.raw",             { fg = p.blue_warmer })
  hl(0, "@markup.raw.block",       { fg = p.blue_warmer })
  hl(0, "@markup.list",            { fg = p.fg_dim })
  hl(0, "@markup.list.checked",    { fg = p.green_cooler })
  hl(0, "@markup.list.unchecked",  { fg = p.fg_dim })

  hl(0, "@tag",                    { fg = p.yellow_cooler })
  hl(0, "@tag.attribute",          { fg = p.fg_alt })
  hl(0, "@tag.delimiter",          { fg = p.fg_dim })

  -- LSP semantic tokens
  hl(0, "@lsp.type.class",         { fg = p.green_faint })
  hl(0, "@lsp.type.comment",       { fg = p.blue_faint })
  hl(0, "@lsp.type.decorator",     { fg = p.cyan_cooler })
  hl(0, "@lsp.type.enum",          { fg = p.green_faint })
  hl(0, "@lsp.type.enumMember",    { fg = p.blue_warmer })
  hl(0, "@lsp.type.function",      { fg = p.cyan_warmer })
  hl(0, "@lsp.type.interface",     { fg = p.green_faint })
  hl(0, "@lsp.type.macro",         { fg = p.cyan_cooler })
  hl(0, "@lsp.type.method",        { fg = p.cyan_warmer })
  hl(0, "@lsp.type.namespace",     { fg = p.green_faint })
  hl(0, "@lsp.type.parameter",     { fg = p.fg_alt })
  hl(0, "@lsp.type.property",      { fg = p.magenta_faint })
  hl(0, "@lsp.type.struct",        { fg = p.green_faint })
  hl(0, "@lsp.type.type",          { fg = p.green_faint })
  hl(0, "@lsp.type.typeParameter", { fg = p.green_faint })
  hl(0, "@lsp.type.variable",      { fg = p.magenta })

  -- Diagnostics
  hl(0, "DiagnosticError", { fg = p.red })
  hl(0, "DiagnosticWarn",  { fg = p.yellow_warmer })
  hl(0, "DiagnosticInfo",  { fg = p.cyan })
  hl(0, "DiagnosticHint",  { fg = p.fg_dim })
  hl(0, "DiagnosticOk",    { fg = p.green_cooler })

  hl(0, "DiagnosticVirtualTextError", { fg = p.red,           bg = p.bg_err })
  hl(0, "DiagnosticVirtualTextWarn",  { fg = p.yellow_warmer, bg = p.bg_warning })
  hl(0, "DiagnosticVirtualTextInfo",  { fg = p.cyan,          bg = p.bg_info })
  hl(0, "DiagnosticVirtualTextHint",  { fg = p.fg_dim })

  hl(0, "DiagnosticUnderlineError", { sp = p.red,           undercurl = true })
  hl(0, "DiagnosticUnderlineWarn",  { sp = p.yellow_warmer, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo",  { sp = p.cyan,          undercurl = true })
  hl(0, "DiagnosticUnderlineHint",  { sp = p.fg_dim,        undercurl = true })

  hl(0, "DiagnosticSignError", { fg = p.red,           bg = p.bg_main })
  hl(0, "DiagnosticSignWarn",  { fg = p.yellow_warmer, bg = p.bg_main })
  hl(0, "DiagnosticSignInfo",  { fg = p.cyan,          bg = p.bg_main })
  hl(0, "DiagnosticSignHint",  { fg = p.fg_dim,        bg = p.bg_main })

  -- Git signs
  hl(0, "GitSignsAdd",          { fg = p.green_cooler, bg = p.bg_main })
  hl(0, "GitSignsChange",       { fg = p.yellow,       bg = p.bg_main })
  hl(0, "GitSignsDelete",       { fg = p.red,          bg = p.bg_main })
  hl(0, "GitSignsChangedelete", { fg = p.yellow_warmer, bg = p.bg_main })

  -- Telescope
  hl(0, "TelescopeNormal",          { fg = p.fg_main, bg = p.bg_popup })
  hl(0, "TelescopeBorder",          { fg = p.border,  bg = p.bg_popup })
  hl(0, "TelescopePromptNormal",    { fg = p.fg_main, bg = p.bg_popup })
  hl(0, "TelescopePromptBorder",    { fg = p.border,  bg = p.bg_popup })
  hl(0, "TelescopePromptTitle",     { fg = p.yellow_cooler, bg = p.bg_popup, bold = true })
  hl(0, "TelescopePromptPrefix",    { fg = p.magenta, bg = p.bg_popup })
  hl(0, "TelescopeResultsNormal",   { fg = p.fg_main, bg = p.bg_popup })
  hl(0, "TelescopeResultsBorder",   { fg = p.border,  bg = p.bg_popup })
  hl(0, "TelescopeResultsTitle",    { fg = p.fg_dim,  bg = p.bg_popup })
  hl(0, "TelescopePreviewNormal",   { fg = p.fg_main, bg = p.bg_popup })
  hl(0, "TelescopePreviewBorder",   { fg = p.border,  bg = p.bg_popup })
  hl(0, "TelescopePreviewTitle",    { fg = p.fg_dim,  bg = p.bg_popup })
  hl(0, "TelescopeSelection",       { fg = p.fg_main, bg = p.bg_completion })
  hl(0, "TelescopeSelectionCaret",  { fg = p.yellow_cooler, bg = p.bg_completion })
  hl(0, "TelescopeMultiSelection",  { fg = p.cyan, bg = p.bg_completion })
  hl(0, "TelescopeMatching",        { fg = p.yellow_cooler, bold = true })

  -- Harpoon
  hl(0, "HarpoonBorder", { fg = p.border })
  hl(0, "HarpoonWindow", { fg = p.fg_main, bg = p.bg_popup })

  -- Indent guides
  hl(0, "IblIndent", { fg = p.bg_dim })
  hl(0, "IblScope",  { fg = p.fg_dim })

  -- Which-key
  hl(0, "WhichKey",          { fg = p.cyan_warmer })
  hl(0, "WhichKeyGroup",     { fg = p.green_faint })
  hl(0, "WhichKeyDesc",      { fg = p.fg_main })
  hl(0, "WhichKeySeperator", { fg = p.fg_dim })
  hl(0, "WhichKeyFloat",     { bg = p.bg_popup })
  hl(0, "WhichKeyValue",     { fg = p.blue_warmer })

  -- Nested scope background cycle (consumed by hh.lua's scope highlighter)
  for i, bg in ipairs(p.back_cycle) do
    hl(0, "HHScope" .. i, { bg = bg })
  end
end

M.colors = p
M.setup()

return M
