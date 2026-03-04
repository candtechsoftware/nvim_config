-- CC colorscheme: HH dark background + JB syntax colors + HH mode cursors/features
local M = {}

local colors = {
  -- Core backgrounds - HH's dark background
  back = "#0c0c0c",
  back1 = "#1f1f27",
  back2 = "#171e20",
  bar_bg = "#1f1f27",

  -- Selection / search - HH style
  selection_active = "#315268",
  selection_inactive = "#31526880",
  selection_highlight = "#315268",
  search_result_active = "#315268",
  search_result_inactive = "#31526840",

  -- Scrollbar
  scrollbar = "#d1b897a4",
  scrollbar_hover = "#d1b897",
  scrollbar_bg = "#0c0c0c4C",

  -- Cursor colors - HH mode-based
  cursor_normal = "#00ee00",
  cursor_insert = "#ee7700",
  cursor_visual = "#cb9401",
  cursor_replace = "#ff0000",
  cursor_command = "#70971e",
  cursor_inactive = "#404040",
  at_cursor = "#0c0c0c",

  -- Cursor line - HH style
  cursor_line = "#1f1f27",

  -- Splitter / border
  splitter = "#404040",

  -- Text colors - JB warm tan
  text_default = "#d1b897",
  text_cycle1 = "#d1b897",
  text_dim = "#d1b89765",
  text_neutral = "#4C4C4C",

  -- Line numbers - HH style
  line_numbers_text = "#404040",
  line_numbers_bg = "#101010",

  -- Syntax - JB's colors
  comment = "#44b340",           -- JB green comments
  keyword = "#ffffff",           -- JB white keywords
  string = "#2ec09c",            -- JB teal strings
  constant = "#7ad0c6",          -- JB light teal constants
  number = "#7ad0c6",            -- JB light teal numbers
  type = "#8cde94",              -- JB mid green types
  func = "#d1b897",              -- JB tan functions (same as default)
  macro = "#8cde94",             -- JB mid green macros
  preproc = "#8cde94",           -- JB mid green preprocessor
  operators = "#d1b897",         -- JB tan operators
  punctuation = "#d1b897",       -- JB tan punctuation
  modifier = "#ffffff",          -- JB white for storage class
  special = "#2ec09c",           -- JB teal for special
  ghost = "#5b4d3c",             -- HH ghost chars

  -- Brace / match
  brace_highlight = "#d1b897",
  token_highlight = "#2f2f37",

  -- HH indexer semantics
  index_constant = "#7ad0c6",
  index_macro = "#8cde94",

  -- Diagnostics / UI
  error = "#ff0000",
  error_dim = "#772222",
  warning = "#ffaa00",
  warning_dim = "#986032",
  success = "#44b340",
  info = "#70971e",
  hint = "#686868",

  -- Regions
  region_addition = "#2260224C",
  region_deletion = "#7722224C",

  -- Diff
  diff_add_bg = "#0c1a0c",
  diff_change_bg = "#1a1a0c",
  diff_delete_bg = "#1a0c0c",
  diff_text_bg = "#2a2a14",

  -- Paste/undo (HH)
  paste = "#ffbb00",
  undo = "#80005d",

  -- Yggdrasil
  yg_keyword = "#478980",

  -- Scope background cycle - HH's dark base with varied tints
  back_cycle = {
    "#161419",
    "#141816",
    "#141618",
    "#181614",
    "#181418",
    "#141818",
    "#161614",
    "#161419",
  },

  -- Rainbow delimiters
  rainbow = {
    "#AE81FF",  -- violet
    "#66D9EF",  -- blue
    "#A6E22E",  -- green
    "#E6DB74",  -- yellow
    "#FD971F",  -- orange
    "#F92672",  -- red
  },

  -- Plot cycle (HH)
  plot_cycle = { "#03d3fc", "#22b80b", "#f0bb0c", "#f0500c" },
}

-- Strip alpha channel from all colors
for key, value in pairs(colors) do
  if type(value) == "string" and value:match("^#%x%x%x%x%x%x%x%x$") then
    colors[key] = value:sub(1, 7)
  end
end

colors.none = "NONE"

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "cc"
  vim.o.background = "dark"
  vim.o.termguicolors = true

  local hl = vim.api.nvim_set_hl

  -- Core UI
  hl(0, "Normal", { fg = colors.text_default, bg = colors.back })
  hl(0, "NormalNC", { fg = colors.text_default, bg = colors.back })
  hl(0, "NormalFloat", { fg = colors.text_default, bg = colors.back1 })
  hl(0, "FloatBorder", { fg = colors.splitter, bg = colors.back1 })
  hl(0, "FloatTitle", { fg = colors.text_cycle1, bg = colors.back1 })
  hl(0, "WinSeparator", { fg = colors.splitter })
  hl(0, "VertSplit", { fg = colors.splitter })

  -- Mode-specific cursor highlight groups (HH)
  hl(0, "CursorNormal", { fg = colors.at_cursor, bg = colors.cursor_normal })
  hl(0, "CursorInsert", { fg = colors.at_cursor, bg = colors.cursor_insert })
  hl(0, "CursorVisual", { fg = colors.at_cursor, bg = colors.cursor_visual })
  hl(0, "CursorReplace", { fg = colors.at_cursor, bg = colors.cursor_replace })
  hl(0, "CursorCommand", { fg = colors.at_cursor, bg = colors.cursor_command })

  vim.opt.guicursor = {
    "n-c:block-CursorNormal",
    "i-ci-ve:block-CursorInsert",
    "v-V:block-CursorVisual",
    "r-cr:block-CursorReplace",
    "o:block-CursorNormal",
  }

  -- Status line - HH mode-colored style on JB bg
  hl(0, "StatusLine", { fg = colors.text_cycle1, bg = colors.bar_bg })
  hl(0, "StatusLineNC", { fg = colors.text_dim, bg = colors.bar_bg })
  hl(0, "StatusLineNormal", { fg = colors.back, bg = colors.cursor_normal, bold = true })
  hl(0, "StatusLineInsert", { fg = colors.back, bg = colors.cursor_insert, bold = true })
  hl(0, "StatusLineVisual", { fg = colors.back, bg = colors.cursor_visual, bold = true })
  hl(0, "StatusLineReplace", { fg = colors.back, bg = colors.cursor_replace, bold = true })
  hl(0, "StatusLineCommand", { fg = colors.back, bg = colors.cursor_command, bold = true })

  -- Tab line
  hl(0, "TabLine", { fg = colors.text_dim, bg = colors.bar_bg })
  hl(0, "TabLineSel", { fg = colors.text_cycle1, bg = colors.back, bold = true })
  hl(0, "TabLineFill", { bg = colors.bar_bg })

  -- Line numbers
  hl(0, "LineNr", { fg = colors.line_numbers_text, bg = colors.line_numbers_bg })
  hl(0, "CursorLineNr", { fg = colors.text_cycle1, bg = colors.line_numbers_bg, bold = true })
  hl(0, "SignColumn", { bg = colors.line_numbers_bg })

  -- Cursor line/column
  hl(0, "CursorLine", { bg = colors.cursor_line })
  hl(0, "CursorColumn", { bg = colors.cursor_line })
  hl(0, "ColorColumn", { bg = colors.cursor_line })
  hl(0, "CursorLineFold", { bg = colors.cursor_line })
  hl(0, "CursorLineSign", { bg = colors.cursor_line })

  -- Selection
  hl(0, "Visual", { bg = colors.selection_active })
  hl(0, "VisualNOS", { bg = colors.selection_inactive })

  -- Search
  hl(0, "Search", { fg = colors.back, bg = colors.search_result_active })
  hl(0, "IncSearch", { fg = colors.at_cursor, bg = colors.cursor_visual })
  hl(0, "CurSearch", { fg = colors.at_cursor, bg = colors.cursor_normal })
  hl(0, "Substitute", { fg = colors.back, bg = colors.paste })

  -- Matching parentheses
  hl(0, "MatchParen", { fg = colors.brace_highlight, bold = true })

  -- Folding
  hl(0, "Folded", { fg = colors.text_dim, bg = colors.back2 })
  hl(0, "FoldColumn", { fg = colors.text_dim, bg = colors.line_numbers_bg })

  -- End of buffer / non-text
  hl(0, "EndOfBuffer", { fg = colors.back })
  hl(0, "NonText", { fg = colors.ghost })
  hl(0, "Whitespace", { fg = colors.ghost })
  hl(0, "SpecialKey", { fg = colors.ghost })
  hl(0, "Conceal", { fg = colors.ghost })

  -- Popup menu
  hl(0, "Pmenu", { fg = colors.text_default, bg = colors.back2 })
  hl(0, "PmenuSel", { fg = colors.back, bg = colors.selection_highlight })
  hl(0, "PmenuSbar", { bg = colors.scrollbar_bg })
  hl(0, "PmenuThumb", { bg = colors.scrollbar })
  hl(0, "PmenuExtra", { fg = colors.text_dim, bg = colors.back2 })
  hl(0, "PmenuExtraSel", { fg = colors.text_dim, bg = colors.selection_highlight })
  hl(0, "WildMenu", { fg = colors.back, bg = colors.selection_active })

  -- Quick fix
  hl(0, "QuickFixLine", { bg = colors.selection_highlight })
  hl(0, "qfLineNr", { fg = colors.warning })

  -- Messages
  hl(0, "MsgArea", { fg = colors.text_default })
  hl(0, "ModeMsg", { fg = colors.info })
  hl(0, "MoreMsg", { fg = colors.text_default })
  hl(0, "Question", { fg = colors.success })
  hl(0, "WarningMsg", { fg = colors.warning })
  hl(0, "ErrorMsg", { fg = colors.error })
  hl(0, "Directory", { fg = colors.type })
  hl(0, "Title", { fg = colors.text_cycle1, bold = true })

  -- Win bar
  hl(0, "WinBar", { fg = colors.text_default, bg = colors.back })
  hl(0, "WinBarNC", { fg = colors.hint, bg = colors.back })

  -- Syntax highlighting
  hl(0, "Comment", { fg = colors.comment })
  hl(0, "SpecialComment", { fg = colors.info, italic = true })
  hl(0, "Todo", { fg = colors.cursor_normal, bg = colors.back2, bold = true })
  hl(0, "String", { fg = colors.string })
  hl(0, "Character", { fg = colors.string })
  hl(0, "Number", { fg = colors.number })
  hl(0, "Float", { fg = colors.number })
  hl(0, "Boolean", { fg = colors.constant })
  hl(0, "Constant", { fg = colors.constant })
  hl(0, "Identifier", { fg = colors.text_default })
  hl(0, "Function", { fg = colors.func })
  hl(0, "Statement", { fg = colors.keyword })
  hl(0, "Operator", { fg = colors.operators })
  hl(0, "Keyword", { fg = colors.keyword })
  hl(0, "Conditional", { fg = colors.keyword })
  hl(0, "Repeat", { fg = colors.keyword })
  hl(0, "Label", { fg = colors.keyword })
  hl(0, "Exception", { fg = colors.keyword })
  hl(0, "Type", { fg = colors.type })
  hl(0, "Structure", { fg = colors.type })
  hl(0, "StorageClass", { fg = colors.modifier })
  hl(0, "Typedef", { fg = colors.type })
  hl(0, "PreProc", { fg = colors.preproc })
  hl(0, "Include", { fg = colors.preproc })
  hl(0, "Define", { fg = colors.preproc })
  hl(0, "Macro", { fg = colors.macro })
  hl(0, "PreCondit", { fg = colors.preproc })
  hl(0, "Special", { fg = colors.string })
  hl(0, "SpecialChar", { fg = colors.special })
  hl(0, "Tag", { fg = colors.cursor_visual })
  hl(0, "Delimiter", { fg = colors.punctuation })
  hl(0, "Debug", { fg = colors.error })
  hl(0, "Underlined", { underline = true })
  hl(0, "Bold", { bold = true })
  hl(0, "Italic", { italic = true })
  hl(0, "Ignore", { fg = colors.ghost })
  hl(0, "Error", { fg = colors.error, bold = true })

  -- Treesitter highlights
  hl(0, "@comment", { fg = colors.comment })
  hl(0, "@comment.documentation", { fg = colors.comment })
  hl(0, "@comment.error", { fg = colors.error, bold = true })
  hl(0, "@comment.warning", { fg = colors.cursor_insert, bold = true })
  hl(0, "@comment.todo", { fg = colors.cursor_normal, bold = true })
  hl(0, "@comment.note", { fg = colors.info, bold = true })

  hl(0, "@punctuation", { fg = colors.punctuation })
  hl(0, "@punctuation.bracket", { fg = colors.punctuation })
  hl(0, "@punctuation.delimiter", { fg = colors.punctuation })
  hl(0, "@punctuation.special", { fg = colors.special })

  hl(0, "@string", { fg = colors.string })
  hl(0, "@string.documentation", { fg = colors.string })
  hl(0, "@string.regex", { fg = colors.cursor_insert })
  hl(0, "@string.regexp", { fg = colors.cursor_insert })
  hl(0, "@string.escape", { fg = colors.modifier })
  hl(0, "@string.special", { fg = colors.special })
  hl(0, "@string.special.symbol", { fg = colors.constant })
  hl(0, "@string.special.path", { fg = colors.string })
  hl(0, "@string.special.url", { fg = colors.func, underline = true })

  hl(0, "@character", { fg = colors.string })
  hl(0, "@character.special", { fg = colors.special })

  hl(0, "@number", { fg = colors.number })
  hl(0, "@number.float", { fg = colors.number })
  hl(0, "@float", { fg = colors.number })
  hl(0, "@boolean", { fg = colors.constant })

  hl(0, "@constant", { fg = colors.constant })
  hl(0, "@constant.builtin", { fg = colors.constant })
  hl(0, "@constant.macro", { fg = colors.macro })

  hl(0, "@type", { fg = colors.type })
  hl(0, "@type.builtin", { fg = colors.type })
  hl(0, "@type.definition", { fg = colors.type })
  hl(0, "@type.qualifier", { fg = colors.modifier })

  hl(0, "@attribute", { fg = colors.preproc })
  hl(0, "@attribute.builtin", { fg = colors.preproc })
  hl(0, "@property", { fg = colors.text_default })

  hl(0, "@variable", { fg = colors.text_default })
  hl(0, "@variable.builtin", { fg = colors.constant })
  hl(0, "@variable.parameter", { fg = colors.text_cycle1 })
  hl(0, "@variable.member", { fg = colors.text_default })
  hl(0, "@field", { fg = colors.text_default })
  hl(0, "@parameter", { fg = colors.text_cycle1 })
  hl(0, "@parameter.reference", { fg = colors.text_default })

  hl(0, "@function", { fg = colors.func })
  hl(0, "@function.call", { fg = colors.func })
  hl(0, "@function.definition", { fg = colors.func, bold = true })
  hl(0, "@function.builtin", { fg = colors.func })
  hl(0, "@function.macro", { fg = colors.macro })
  hl(0, "@function.method", { fg = colors.func })
  hl(0, "@function.method.call", { fg = colors.func })
  hl(0, "@method", { fg = colors.func })
  hl(0, "@constructor", { fg = colors.type })

  hl(0, "@module", { fg = colors.type })
  hl(0, "@module.builtin", { fg = colors.type })
  hl(0, "@label", { fg = colors.keyword })

  hl(0, "@keyword", { fg = colors.keyword })
  hl(0, "@keyword.coroutine", { fg = colors.keyword })
  hl(0, "@keyword.function", { fg = colors.keyword })
  hl(0, "@keyword.operator", { fg = colors.operators })
  hl(0, "@keyword.import", { fg = colors.preproc })
  hl(0, "@keyword.import.c", { fg = colors.preproc })
  hl(0, "@keyword.type", { fg = colors.keyword })
  hl(0, "@keyword.modifier", { fg = colors.keyword })
  hl(0, "@keyword.repeat", { fg = colors.keyword })
  hl(0, "@keyword.return", { fg = colors.keyword })
  hl(0, "@keyword.debug", { fg = colors.error })
  hl(0, "@keyword.exception", { fg = colors.keyword })
  hl(0, "@keyword.conditional", { fg = colors.keyword })
  hl(0, "@keyword.directive", { fg = colors.preproc })
  hl(0, "@keyword.directive.define", { fg = colors.preproc })

  hl(0, "@operator", { fg = colors.operators })

  hl(0, "@tag", { fg = colors.keyword })
  hl(0, "@tag.attribute", { fg = colors.text_cycle1 })
  hl(0, "@tag.delimiter", { fg = colors.punctuation })

  -- Markup
  hl(0, "@markup", { fg = colors.text_default })
  hl(0, "@markup.strong", { bold = true })
  hl(0, "@markup.italic", { italic = true })
  hl(0, "@markup.strikethrough", { strikethrough = true })
  hl(0, "@markup.underline", { underline = true })
  hl(0, "@markup.heading", { fg = colors.text_cycle1, bold = true })
  hl(0, "@markup.heading.1", { fg = colors.text_cycle1, bold = true })
  hl(0, "@markup.heading.2", { fg = colors.cursor_visual, bold = true })
  hl(0, "@markup.heading.3", { fg = colors.info, bold = true })
  hl(0, "@markup.heading.4", { fg = colors.type, bold = true })
  hl(0, "@markup.heading.5", { fg = colors.func, bold = true })
  hl(0, "@markup.heading.6", { fg = colors.text_default, bold = true })
  hl(0, "@markup.quote", { fg = colors.comment, italic = true })
  hl(0, "@markup.math", { fg = colors.index_constant })
  hl(0, "@markup.link", { fg = colors.func, underline = true })
  hl(0, "@markup.link.label", { fg = colors.cursor_visual })
  hl(0, "@markup.link.url", { fg = colors.func, underline = true })
  hl(0, "@markup.raw", { fg = colors.string })
  hl(0, "@markup.raw.block", { fg = colors.string })
  hl(0, "@markup.list", { fg = colors.punctuation })
  hl(0, "@markup.list.checked", { fg = colors.cursor_normal })
  hl(0, "@markup.list.unchecked", { fg = colors.hint })

  -- Jai-specific
  hl(0, "@keyword.jai", { fg = colors.keyword })
  hl(0, "@keyword.repeat.jai", { fg = colors.keyword })
  hl(0, "@keyword.conditional.jai", { fg = colors.keyword })
  hl(0, "@keyword.function.jai", { fg = colors.keyword })
  hl(0, "@keyword.return.jai", { fg = colors.keyword })
  hl(0, "@keyword.modifier.jai", { fg = colors.keyword })
  hl(0, "@keyword.type.jai", { fg = colors.keyword })
  hl(0, "@keyword.operator.jai", { fg = colors.operators })
  hl(0, "@storageclass.jai", { fg = colors.modifier })
  hl(0, "@function.jai", { fg = colors.func })
  hl(0, "@function.call.jai", { fg = colors.func })
  hl(0, "@operator.jai", { fg = colors.operators })
  hl(0, "@punctuation.special.jai", { fg = colors.operators })
  hl(0, "@punctuation.delimiter.jai", { fg = colors.operators })
  hl(0, "@punctuation.bracket.jai", { fg = colors.punctuation })
  hl(0, "@variable.jai", { fg = colors.text_default })
  hl(0, "@variable.builtin.jai", { fg = colors.constant })
  hl(0, "@variable.parameter.jai", { fg = colors.text_cycle1 })
  hl(0, "@constant.jai", { fg = colors.constant })
  hl(0, "@constant.builtin.jai", { fg = colors.constant })
  hl(0, "@type.jai", { fg = colors.type })
  hl(0, "@type.builtin.jai", { fg = colors.type })
  hl(0, "@string.jai", { fg = colors.string })
  hl(0, "@number.jai", { fg = colors.number })
  hl(0, "@boolean.jai", { fg = colors.constant })
  hl(0, "@comment.jai", { fg = colors.comment })

  -- LSP semantic tokens
  hl(0, "@lsp.type.class", { fg = colors.type })
  hl(0, "@lsp.type.comment", { fg = colors.comment })
  hl(0, "@lsp.type.decorator", { fg = colors.preproc })
  hl(0, "@lsp.type.enum", { fg = colors.type })
  hl(0, "@lsp.type.enumMember", { fg = colors.constant })
  hl(0, "@lsp.type.function", { fg = colors.func })
  hl(0, "@lsp.type.interface", { fg = colors.type })
  hl(0, "@lsp.type.macro", { fg = colors.macro })
  hl(0, "@lsp.type.method", { fg = colors.func })
  hl(0, "@lsp.type.namespace", { fg = colors.type })
  hl(0, "@lsp.type.parameter", { fg = colors.text_cycle1 })
  hl(0, "@lsp.type.property", { fg = colors.text_default })
  hl(0, "@lsp.type.struct", { fg = colors.type })
  hl(0, "@lsp.type.type", { fg = colors.type })
  hl(0, "@lsp.type.typeParameter", { fg = colors.type })
  hl(0, "@lsp.type.variable", { fg = colors.text_default })
  hl(0, "@lsp.typemod.enumMember", { fg = colors.constant })
  hl(0, "@lsp.typemod.enumMember.declaration", { fg = colors.constant })

  -- LSP references
  hl(0, "LspReferenceText", { bg = colors.selection_highlight })
  hl(0, "LspReferenceRead", { bg = colors.selection_highlight })
  hl(0, "LspReferenceWrite", { bg = colors.selection_highlight })
  hl(0, "LspSignatureActiveParameter", { fg = colors.text_default, bg = colors.selection_active, bold = true })
  hl(0, "LspInlayHint", { fg = colors.text_dim, bg = colors.back2 })
  hl(0, "LspCodeLens", { fg = colors.text_dim })
  hl(0, "LspCodeLensSeparator", { fg = colors.text_dim })

  -- Diagnostics
  hl(0, "DiagnosticError", { fg = colors.error })
  hl(0, "DiagnosticWarn", { fg = colors.warning })
  hl(0, "DiagnosticInfo", { fg = colors.info })
  hl(0, "DiagnosticHint", { fg = colors.hint })
  hl(0, "DiagnosticOk", { fg = colors.success })

  hl(0, "DiagnosticVirtualTextError", { fg = colors.error, bg = "#180c0c" })
  hl(0, "DiagnosticVirtualTextWarn", { fg = colors.warning, bg = colors.warning_dim })
  hl(0, "DiagnosticVirtualTextInfo", { fg = colors.info, bg = colors.back2 })
  hl(0, "DiagnosticVirtualTextHint", { fg = colors.hint })
  hl(0, "DiagnosticVirtualTextOk", { fg = colors.success, bg = colors.region_addition })

  hl(0, "DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
  hl(0, "DiagnosticUnderlineWarn", { sp = colors.warning, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo", { sp = colors.info, undercurl = true })
  hl(0, "DiagnosticUnderlineHint", { sp = colors.hint, undercurl = true })
  hl(0, "DiagnosticUnderlineOk", { sp = colors.success, undercurl = true })

  hl(0, "DiagnosticFloatingError", { fg = colors.error })
  hl(0, "DiagnosticFloatingWarn", { fg = colors.warning })
  hl(0, "DiagnosticFloatingInfo", { fg = colors.info })
  hl(0, "DiagnosticFloatingHint", { fg = colors.hint })

  hl(0, "DiagnosticSignError", { fg = colors.error, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignWarn", { fg = colors.warning, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignInfo", { fg = colors.info, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignHint", { fg = colors.hint, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignOk", { fg = colors.success, bg = colors.line_numbers_bg })

  -- Diff & Git
  hl(0, "DiffAdd", { bg = colors.diff_add_bg })
  hl(0, "DiffChange", { bg = colors.diff_change_bg })
  hl(0, "DiffDelete", { fg = colors.error, bg = colors.diff_delete_bg })
  hl(0, "DiffText", { bg = colors.diff_text_bg, bold = true })
  hl(0, "DiffAdded", { fg = colors.success })
  hl(0, "DiffRemoved", { fg = colors.error })
  hl(0, "DiffChanged", { fg = colors.warning })
  hl(0, "GitSignsAdd", { fg = colors.success, bg = colors.line_numbers_bg })
  hl(0, "GitSignsChange", { fg = colors.cursor_visual, bg = colors.line_numbers_bg })
  hl(0, "GitSignsDelete", { fg = colors.error, bg = colors.line_numbers_bg })
  hl(0, "GitSignsChangedelete", { fg = colors.cursor_insert, bg = colors.line_numbers_bg })
  hl(0, "GitSignsCurrentLineBlame", { fg = colors.text_dim })

  -- Spell checking
  hl(0, "SpellBad", { sp = colors.error, undercurl = true })
  hl(0, "SpellCap", { sp = colors.warning, undercurl = true })
  hl(0, "SpellLocal", { sp = colors.success, undercurl = true })
  hl(0, "SpellRare", { sp = colors.cursor_visual, undercurl = true })

  -- Telescope
  hl(0, "TelescopeNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopeBorder", { fg = colors.splitter, bg = colors.back })
  hl(0, "TelescopePromptNormal", { fg = colors.text_cycle1, bg = colors.back })
  hl(0, "TelescopePromptBorder", { fg = colors.splitter, bg = colors.back })
  hl(0, "TelescopePromptTitle", { fg = colors.hint, bg = colors.back })
  hl(0, "TelescopePromptPrefix", { fg = colors.info, bg = colors.back })
  hl(0, "TelescopeResultsNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopeResultsBorder", { fg = colors.splitter, bg = colors.back })
  hl(0, "TelescopeResultsTitle", { fg = colors.hint, bg = colors.back })
  hl(0, "TelescopePreviewNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopePreviewBorder", { fg = colors.splitter, bg = colors.back })
  hl(0, "TelescopePreviewTitle", { fg = colors.hint, bg = colors.back })
  hl(0, "TelescopeSelection", { fg = colors.text_cycle1, bg = colors.cursor_line })
  hl(0, "TelescopeSelectionCaret", { fg = colors.cursor_visual, bg = colors.cursor_line })
  hl(0, "TelescopeMultiSelection", { fg = colors.info, bg = colors.cursor_line })
  hl(0, "TelescopeMatching", { fg = colors.text_cycle1, bold = true })

  -- Harpoon
  hl(0, "HarpoonBorder", { fg = colors.punctuation })
  hl(0, "HarpoonWindow", { fg = colors.text_default })

  -- Trouble
  hl(0, "TroubleNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TroubleNormalNC", { fg = colors.text_default, bg = colors.back })
  hl(0, "TroubleFoldIcon", { fg = colors.text_dim })
  hl(0, "TroubleIndent", { fg = colors.ghost })
  hl(0, "TroubleText", { fg = colors.text_default })
  hl(0, "TroubleCount", { fg = colors.warning })
  hl(0, "TroubleFile", { fg = colors.text_default })
  hl(0, "TroubleLocation", { fg = colors.text_dim })
  hl(0, "TroublePreview", { fg = colors.text_default, bg = colors.back2 })

  -- Which-key
  hl(0, "WhichKey", { fg = colors.func })
  hl(0, "WhichKeyGroup", { fg = colors.type })
  hl(0, "WhichKeyDesc", { fg = colors.text_default })
  hl(0, "WhichKeySeparator", { fg = colors.text_dim })
  hl(0, "WhichKeySeperator", { fg = colors.text_dim })
  hl(0, "WhichKeyFloat", { bg = colors.back1 })
  hl(0, "WhichKeyValue", { fg = colors.constant })

  -- Completion menu
  hl(0, "CmpItemAbbr", { fg = colors.text_default })
  hl(0, "CmpItemAbbrMatch", { fg = colors.text_cycle1 })
  hl(0, "CmpItemAbbrMatchFuzzy", { fg = colors.text_cycle1 })
  hl(0, "CmpItemMenu", { fg = colors.text_dim })
  hl(0, "CmpItemKind", { fg = colors.text_default })
  hl(0, "CmpItemKindFunction", { fg = colors.func })
  hl(0, "CmpItemKindMethod", { fg = colors.func })
  hl(0, "CmpItemKindVariable", { fg = colors.text_default })
  hl(0, "CmpItemKindField", { fg = colors.text_default })
  hl(0, "CmpItemKindProperty", { fg = colors.text_default })
  hl(0, "CmpItemKindValue", { fg = colors.constant })
  hl(0, "CmpItemKindEnum", { fg = colors.type })
  hl(0, "CmpItemKindEnumMember", { fg = colors.constant })
  hl(0, "CmpItemKindKeyword", { fg = colors.keyword })
  hl(0, "CmpItemKindText", { fg = colors.comment })
  hl(0, "CmpItemKindClass", { fg = colors.type })
  hl(0, "CmpItemKindInterface", { fg = colors.type })
  hl(0, "CmpItemKindModule", { fg = colors.type })
  hl(0, "CmpItemKindSnippet", { fg = colors.macro })
  hl(0, "CmpItemKindColor", { fg = colors.text_cycle1 })
  hl(0, "CmpItemKindFile", { fg = colors.text_default })
  hl(0, "CmpItemKindFolder", { fg = colors.text_default })
  hl(0, "CmpItemKindReference", { fg = colors.macro })

  -- Indent guides
  hl(0, "IndentBlanklineChar", { fg = colors.ghost })
  hl(0, "IndentBlanklineContextChar", { fg = colors.text_cycle1 })
  hl(0, "IblIndent", { fg = colors.ghost })
  hl(0, "IblWhitespace", { fg = colors.ghost })
  hl(0, "IblScope", { fg = colors.punctuation })

  -- Illuminated word
  hl(0, "IlluminatedWordText", { bg = colors.selection_highlight })
  hl(0, "IlluminatedWordRead", { bg = colors.selection_highlight })
  hl(0, "IlluminatedWordWrite", { bg = colors.selection_highlight })

  -- Rainbow delimiters
  for i, c in ipairs(colors.rainbow) do
    hl(0, "rainbowcol" .. i, { fg = c })
  end

  -- Objective-C/C++ specific (from HH)
  hl(0, "@keyword.objc", { fg = colors.keyword })
  hl(0, "@keyword.directive.objc", { fg = colors.preproc })
  hl(0, "@keyword.import.objc", { fg = colors.preproc })
  hl(0, "@keyword.modifier.objc", { fg = colors.keyword })
  hl(0, "@type.objc", { fg = colors.type })
  hl(0, "@type.builtin.objc", { fg = colors.type })
  hl(0, "@function.method.objc", { fg = colors.func })
  hl(0, "@function.call.objc", { fg = colors.func })
  hl(0, "@variable.member.objc", { fg = colors.text_default })
  hl(0, "@punctuation.special.objc", { fg = colors.operators })
  hl(0, "@string.objc", { fg = colors.string })
  hl(0, "@constant.builtin.objc", { fg = colors.constant })

  -- Yggdrasil/Ark highlights
  hl(0, "YgKeyword", { fg = colors.yg_keyword })
  hl(0, "YgType", { fg = colors.type })

  -- Region/scope groups (from JB)
  hl(0, "FocusRegionScopeExport", { fg = colors.text_default, bg = colors.back1 })
  hl(0, "FocusRegionScopeFile", { fg = colors.text_default, bg = colors.back1 })
  hl(0, "FocusRegionScopeModule", { fg = colors.text_default, bg = colors.back1 })
  hl(0, "FocusRegionHeader", { fg = colors.text_cycle1, bold = true })
  hl(0, "FocusRegionSuccess", { fg = colors.success })
  hl(0, "FocusRegionWarning", { fg = colors.warning_dim })
  hl(0, "FocusRegionError", { fg = colors.error_dim })
  hl(0, "FocusRegionAddition", { fg = colors.success, bg = colors.region_addition })
  hl(0, "FocusRegionDeletion", { fg = colors.error, bg = colors.region_deletion })
  hl(0, "RegionScopeExport", { link = "FocusRegionScopeExport" })
  hl(0, "RegionScopeFile", { link = "FocusRegionScopeFile" })
  hl(0, "RegionScopeModule", { link = "FocusRegionScopeModule" })
  hl(0, "RegionHeader", { link = "FocusRegionHeader" })
  hl(0, "RegionSuccess", { link = "FocusRegionSuccess" })
  hl(0, "RegionWarning", { link = "FocusRegionWarning" })
  hl(0, "RegionError", { link = "FocusRegionError" })
  hl(0, "RegionAddition", { link = "FocusRegionAddition" })
  hl(0, "RegionDeletion", { link = "FocusRegionDeletion" })

  -- Scope highlight groups for nested scope backgrounds
  for i, bg in ipairs(colors.back_cycle) do
    hl(0, "CCScope" .. i, { bg = bg })
  end
end

-- Export colors
M.colors = colors

-- Mode cursor color helper (from HH)
function M.get_cursor_color(mode)
  local mode_colors = {
    n = colors.cursor_normal,
    i = colors.cursor_insert,
    v = colors.cursor_visual,
    V = colors.cursor_visual,
    ["\22"] = colors.cursor_visual,
    R = colors.cursor_replace,
    c = colors.cursor_command,
  }
  return mode_colors[mode] or colors.cursor_normal
end

-- Scope highlight namespace
local scope_ns = vim.api.nvim_create_namespace("cc_scope_highlight")

-- Cache for scope data per buffer
local scope_cache = {}

-- Different queries for different languages
local scope_queries = {
  c = [[(compound_statement) @scope]],
  cpp = [[(compound_statement) @scope]],
  objc = [[(compound_statement) @scope]],
  objcpp = [[(compound_statement) @scope]],
  jai = [[(block) @scope]],
  lua = [[
    (function_definition) @scope
    (if_statement) @scope
    (for_statement) @scope
    (while_statement) @scope
  ]],
  typescript = [[(statement_block) @scope]],
  tsx = [[(statement_block) @scope]],
  javascript = [[(statement_block) @scope]],
}

-- Cached compiled queries
local compiled_queries = {}

local function parse_scopes(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return nil end

  local tree = parser:parse()[1]
  if not tree then return nil end

  local root = tree:root()
  local lang = parser:lang()

  local query_string = scope_queries[lang]
  if not query_string then return nil end

  if not compiled_queries[lang] then
    local success, q = pcall(vim.treesitter.query.parse, lang, query_string)
    if not success then return nil end
    compiled_queries[lang] = q
  end
  local query = compiled_queries[lang]

  local all_scopes = {}
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
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
    local hl_group = "CCScope" .. cycle_idx

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

  local group = vim.api.nvim_create_augroup("CCScopeHighlight" .. bufnr, { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      debounced_highlight(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if scope_cache[bufnr] then
        scope_cache[bufnr].last_fingerprint = ""
      end
      M.highlight_scopes(bufnr, nil, true)
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
  pcall(vim.api.nvim_del_augroup_by_name, "CCScopeHighlight" .. bufnr)
  scope_cache[bufnr] = nil
  if debounce_timers[bufnr] then
    debounce_timers[bufnr]:stop()
    debounce_timers[bufnr]:close()
    debounce_timers[bufnr] = nil
  end
end

function M.setup_scope_highlight()
  local group = vim.api.nvim_create_augroup("CCScopeSetup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "c", "cpp", "objc", "objcpp", "jai", "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function(ev)
      vim.schedule(function()
        M.enable_scope_highlight(ev.buf)
      end)
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      for bufnr, _ in pairs(scope_cache) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          scope_cache[bufnr].last_fingerprint = ""
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              M.highlight_scopes(bufnr, nil, true)
            end
          end)
        end
      end
    end,
  })

  local ft = vim.bo.filetype
  if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ft == "jai" or ft == "lua" or ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
    vim.schedule(function()
      M.enable_scope_highlight(vim.api.nvim_get_current_buf())
    end)
  end
end

M.setup()

-- Yggdrasil/Ark keyword and type highlighting (from HH)
local yg_match_ids = {}

local function setup_yg_keywords()
  local winid = vim.api.nvim_get_current_win()

  if yg_match_ids[winid] then
    for _, id in ipairs(yg_match_ids[winid]) do
      pcall(vim.fn.matchdelete, id, winid)
    end
  end
  yg_match_ids[winid] = {}

  local function add_match(group, pattern)
    local id = vim.fn.matchadd(group, pattern, 100)
    table.insert(yg_match_ids[winid], id)
  end

  add_match("YgKeyword", "\\<yg_internal\\>")
  add_match("YgKeyword", "\\<yg_inline\\>")
  add_match("YgKeyword", "\\<yg_global\\>")
  add_match("YgKeyword", "\\<yg_local_persist\\>")
  add_match("YgKeyword", "\\<ark_internal\\>")
  add_match("YgKeyword", "\\<ark_inline\\>")
  add_match("YgKeyword", "\\<ark_global\\>")
  add_match("YgKeyword", "\\<ark_local_persist\\>")

  add_match("YgType", "\\<[usb]\\(8\\|16\\|32\\|64\\)\\>")
  add_match("YgType", "\\<f\\(32\\|64\\)\\>")
  add_match("YgType", "\\<void\\>")
  add_match("YgType", "\\<Vec[234]\\(F32\\|F64\\|S16\\|S32\\|S64\\)\\?\\>")
  add_match("YgType", "\\<Mat[34]\\(F32\\)\\?\\>")
  add_match("YgType", "\\<Quaternion\\(F32\\)\\?\\>")
  add_match("YgType", "\\<Rng[12]\\(F32\\|U32\\|U64\\|S16\\|S32\\)\\?\\>")
  add_match("YgType", "\\<Arena\\>")
  add_match("YgType", "\\<Scratch\\>")
  add_match("YgType", "\\<String8\\>")
  add_match("YgType", "\\<R_Handle\\>")
  add_match("YgType", "\\<EntityHandle\\>")
  add_match("YgType", "\\<EntityStore\\>")
  add_match("YgType", "\\<EntityPool\\>")
  add_match("YgType", "\\<EntityKind\\>")
  add_match("YgType", "\\<EntityFlags\\>")
  add_match("YgType", "\\<Entity\\>")
  add_match("YgType", "\\<Direction8\\>")

  add_match("YgType", "\\<yg_internal\\s\\+\\zs\\w\\+\\ze")
  add_match("YgType", "\\<yg_inline\\s\\+\\zs\\w\\+\\ze")
  add_match("YgType", "\\<ark_internal\\s\\+\\zs\\w\\+\\ze")
  add_match("YgType", "\\<ark_inline\\s\\+\\zs\\w\\+\\ze")

  add_match("Function", "\\<\\(ark\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(")
  add_match("Function", "\\<\\(ark\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s*\\*\\s*\\zs\\w\\+\\ze\\s*(")
end

local yg_group = vim.api.nvim_create_augroup("CCYgKeywords", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
  group = yg_group,
  pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.m", "*.mm" },
  callback = setup_yg_keywords,
})
vim.api.nvim_create_autocmd("FileType", {
  group = yg_group,
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = setup_yg_keywords,
})

local ft = vim.bo.filetype
local ext = vim.fn.expand("%:e")
if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ext == "c" or ext == "h" or ext == "cpp" or ext == "hpp" or ext == "m" or ext == "mm" then
  setup_yg_keywords()
end

-- Store module globally
vim.g.cc_theme = M

-- Enable scope highlighting
M.setup_scope_highlight()

return M
