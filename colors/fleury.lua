-- Fleury-inspired theme for Neovim
-- Based on 4coder Fleury theme colors
-- Dark theme with warm accents

local M = {}

-- Color palette from 4coder config
local colors = {
  -- Core background/foreground
  bar_bg = "#1f1f27",        -- Status bar background
  base = "#cb9401",          -- Status bar text / golden accent
  pop1 = "#70971e",          -- Olive green for prompts
  pop2 = "#cb9401",          -- Annotations
  back = "#0c0c0c",          -- Main background
  margin = "#0c0c0c",        -- Frame colors

  -- List/hover colors
  list_item_hover = "#171e20",
  list_item_active = "#2d3640",

  -- Cursor and highlights
  cursor = "#00ee00",        -- Bright green cursor
  cursor2 = "#ee7700",       -- Orange cursor variant
  cursor3 = "#cb9401",       -- Gold cursor variant
  cursor4 = "#70971e",       -- Olive cursor variant
  at_cursor = "#0c0c0c",
  highlight_line = "#1f1f27",
  highlight = "#315268",     -- Search highlight background
  at_highlight = "#c4b82b",  -- Search highlight text
  mark = "#494949",

  -- Text colors
  text_default = "#a08563",  -- Regular text (warm tan)
  comment = "#686868",       -- Comments (gray)
  keyword = "#ac7b0b",       -- Keywords (amber)
  string = "#6b8e23",        -- String constants (olive)
  constant = "#6b8e23",      -- Other constants
  preproc = "#dab98f",       -- Preprocessor (light tan)

  -- Special colors
  special = "#ff0000",       -- Special characters
  ghost = "#5b4d3c",         -- Ghost characters
  paste = "#ffbb00",         -- Paste highlight
  undo = "#80005d",          -- Undo highlight

  -- Line numbers
  line_numbers_bg = "#101010",
  line_numbers_text = "#404040",

  -- Indexer/semantic colors
  index_type = "#d8a51d",         -- Types (gold)
  index_function = "#cc5735",     -- Functions (rust red)
  index_constant = "#478980",     -- Constants (teal)
  index_macro = "#478980",        -- Macros (teal)
  index_decl = "#c04047",         -- Declarations (red)

  -- Error/diagnostic
  error = "#ff0000",

  -- Operator/syntax
  syntax_crap = "#907553",        -- Braces, semicolons (brown)
  operators = "#907553",          -- Operators (brown)

  -- Brace matching
  brace_highlight = "#b09573",   -- Active brace (light brown)
  brace_line = "#9ba290",        -- Brace connection lines
  token_highlight = "#2f2f37",   -- Token highlighting

  -- Cycle colors for text variations
  text_cycle1 = "#c0a583",
  text_cycle2 = "#b09573",

  -- Mode colors
  cursor_macro = "#de2368",      -- Macro recording (pink)
  cursor_power = "#efaf2f",      -- Power mode (bright yellow)
}

function M.setup()
  -- Reset highlighting
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "fleury"
  vim.o.background = "dark"
  vim.o.termguicolors = true

  local hl = vim.api.nvim_set_hl

  -- UI Elements
  hl(0, "Normal", { fg = colors.text_default, bg = colors.back })
  hl(0, "NormalFloat", { fg = colors.text_default, bg = colors.list_item_hover })
  hl(0, "FloatBorder", { fg = colors.syntax_crap, bg = colors.list_item_hover })
  hl(0, "FloatTitle", { fg = colors.base, bg = colors.list_item_hover })

  -- Cursor and selection
  hl(0, "Cursor", { fg = colors.at_cursor, bg = colors.cursor })           -- Normal: green
  hl(0, "CursorInsert", { fg = colors.at_cursor, bg = colors.cursor3 })    -- Insert: gold
  hl(0, "CursorVisual", { fg = colors.at_cursor, bg = colors.cursor2 })    -- Visual: orange
  hl(0, "CursorReplace", { fg = colors.at_cursor, bg = colors.error })     -- Replace: red
  hl(0, "CursorIM", { fg = colors.at_cursor, bg = colors.cursor2 })
  hl(0, "CursorLine", { bg = colors.highlight_line })
  hl(0, "CursorColumn", { bg = colors.highlight_line })
  hl(0, "ColorColumn", { bg = colors.highlight_line })
  hl(0, "Visual", { bg = colors.highlight })
  hl(0, "VisualNOS", { bg = colors.highlight })

  -- Line numbers
  hl(0, "LineNr", { fg = colors.line_numbers_text, bg = colors.line_numbers_bg })
  hl(0, "CursorLineNr", { fg = colors.base, bg = colors.line_numbers_bg, bold = true })
  hl(0, "SignColumn", { bg = colors.line_numbers_bg })

  -- Status line
  hl(0, "StatusLine", { fg = colors.base, bg = colors.bar_bg })
  hl(0, "StatusLineNC", { fg = colors.line_numbers_text, bg = colors.bar_bg })
  -- Mode-specific statusline colors
  hl(0, "StatusLineNormal", { fg = colors.back, bg = colors.cursor, bold = true })      -- Green
  hl(0, "StatusLineInsert", { fg = colors.back, bg = colors.cursor3, bold = true })     -- Gold
  hl(0, "StatusLineVisual", { fg = colors.back, bg = colors.cursor2, bold = true })     -- Orange
  hl(0, "StatusLineReplace", { fg = colors.back, bg = colors.error, bold = true })      -- Red
  hl(0, "StatusLineCommand", { fg = colors.back, bg = colors.pop1, bold = true })       -- Olive green
  hl(0, "WinBar", { fg = colors.text_default, bg = colors.back })
  hl(0, "WinBarNC", { fg = colors.comment, bg = colors.back })

  -- Tab line
  hl(0, "TabLine", { fg = colors.text_default, bg = colors.bar_bg })
  hl(0, "TabLineFill", { bg = colors.bar_bg })
  hl(0, "TabLineSel", { fg = colors.base, bg = colors.back, bold = true })

  -- Splits and borders
  hl(0, "VertSplit", { fg = colors.margin, bg = colors.back })
  hl(0, "WinSeparator", { fg = colors.margin, bg = colors.back })

  -- Search and substitution
  hl(0, "Search", { fg = colors.at_highlight, bg = colors.highlight })
  hl(0, "IncSearch", { fg = colors.at_cursor, bg = colors.base })
  hl(0, "CurSearch", { fg = colors.at_cursor, bg = colors.cursor })
  hl(0, "Substitute", { fg = colors.back, bg = colors.paste })

  -- Popup menu
  hl(0, "Pmenu", { fg = colors.text_default, bg = colors.list_item_hover })
  hl(0, "PmenuSel", { fg = colors.at_highlight, bg = colors.list_item_active })
  hl(0, "PmenuSbar", { bg = colors.bar_bg })
  hl(0, "PmenuThumb", { bg = colors.mark })

  -- Messages
  hl(0, "MsgArea", { fg = colors.text_default })
  hl(0, "ModeMsg", { fg = colors.pop1 })
  hl(0, "MoreMsg", { fg = colors.pop1 })
  hl(0, "Question", { fg = colors.pop1 })
  hl(0, "ErrorMsg", { fg = colors.error })
  hl(0, "WarningMsg", { fg = colors.cursor2 })

  -- Folding
  hl(0, "Folded", { fg = colors.comment, bg = colors.highlight_line })
  hl(0, "FoldColumn", { fg = colors.comment, bg = colors.line_numbers_bg })

  -- Diff mode
  hl(0, "DiffAdd", { bg = "#1a2f1a" })
  hl(0, "DiffChange", { bg = "#2f2f1a" })
  hl(0, "DiffDelete", { fg = colors.error, bg = "#2f1a1a" })
  hl(0, "DiffText", { bg = "#3f3f2a", bold = true })

  -- Spell checking
  hl(0, "SpellBad", { sp = colors.error, undercurl = true })
  hl(0, "SpellCap", { sp = colors.cursor2, undercurl = true })
  hl(0, "SpellLocal", { sp = colors.pop1, undercurl = true })
  hl(0, "SpellRare", { sp = colors.cursor3, undercurl = true })

  -- Special
  hl(0, "NonText", { fg = colors.ghost })
  hl(0, "SpecialKey", { fg = colors.ghost })
  hl(0, "Whitespace", { fg = colors.ghost })
  hl(0, "Directory", { fg = colors.index_type })
  hl(0, "Title", { fg = colors.base, bold = true })
  hl(0, "Conceal", { fg = colors.ghost })
  hl(0, "EndOfBuffer", { fg = colors.back })

  -- Wild menu
  hl(0, "WildMenu", { fg = colors.at_highlight, bg = colors.list_item_active })

  -- Quick fix
  hl(0, "QuickFixLine", { bg = colors.list_item_active })

  -- Syntax highlighting
  hl(0, "Comment", { fg = colors.comment, italic = true })
  hl(0, "Constant", { fg = colors.constant })
  hl(0, "String", { fg = colors.string })
  hl(0, "Character", { fg = colors.string })
  hl(0, "Number", { fg = colors.constant })
  hl(0, "Boolean", { fg = colors.constant })
  hl(0, "Float", { fg = colors.constant })

  hl(0, "Identifier", { fg = colors.text_default })
  hl(0, "Function", { fg = colors.index_function })

  hl(0, "Statement", { fg = colors.keyword })
  hl(0, "Conditional", { fg = colors.keyword })
  hl(0, "Repeat", { fg = colors.keyword })
  hl(0, "Label", { fg = colors.keyword })
  hl(0, "Operator", { fg = colors.operators })
  hl(0, "Keyword", { fg = colors.keyword })
  hl(0, "Exception", { fg = colors.keyword })

  hl(0, "PreProc", { fg = colors.preproc })
  hl(0, "Include", { fg = colors.preproc })
  hl(0, "Define", { fg = colors.preproc })
  hl(0, "Macro", { fg = colors.index_macro })
  hl(0, "PreCondit", { fg = colors.preproc })

  hl(0, "Type", { fg = colors.index_type })
  hl(0, "StorageClass", { fg = colors.keyword })
  hl(0, "Structure", { fg = colors.index_type })
  hl(0, "Typedef", { fg = colors.index_type })

  hl(0, "Special", { fg = colors.special })
  hl(0, "SpecialChar", { fg = colors.special })
  hl(0, "Tag", { fg = colors.pop2 })
  hl(0, "Delimiter", { fg = colors.syntax_crap })
  hl(0, "SpecialComment", { fg = colors.pop1, italic = true })
  hl(0, "Debug", { fg = colors.error })

  hl(0, "Underlined", { fg = colors.index_function, underline = true })
  hl(0, "Ignore", { fg = colors.ghost })
  hl(0, "Error", { fg = colors.error, bold = true })
  hl(0, "Todo", { fg = colors.cursor, bg = colors.highlight_line, bold = true })

  -- Treesitter highlight groups
  hl(0, "@variable", { fg = colors.text_default })
  hl(0, "@variable.builtin", { fg = colors.index_constant })
  hl(0, "@variable.parameter", { fg = colors.text_cycle1 })
  hl(0, "@variable.member", { fg = colors.text_default })

  hl(0, "@constant", { fg = colors.constant })
  hl(0, "@constant.builtin", { fg = colors.constant })
  hl(0, "@constant.macro", { fg = colors.index_macro })

  hl(0, "@module", { fg = colors.index_type })
  hl(0, "@module.builtin", { fg = colors.index_type })
  hl(0, "@label", { fg = colors.keyword })

  hl(0, "@string", { fg = colors.string })
  hl(0, "@string.documentation", { fg = colors.string })
  hl(0, "@string.regexp", { fg = colors.cursor2 })
  hl(0, "@string.escape", { fg = colors.special })
  hl(0, "@string.special", { fg = colors.special })
  hl(0, "@string.special.symbol", { fg = colors.index_constant })
  hl(0, "@string.special.path", { fg = colors.string })
  hl(0, "@string.special.url", { fg = colors.index_function, underline = true })

  hl(0, "@character", { fg = colors.string })
  hl(0, "@character.special", { fg = colors.special })

  hl(0, "@boolean", { fg = colors.constant })
  hl(0, "@number", { fg = colors.constant })
  hl(0, "@number.float", { fg = colors.constant })

  hl(0, "@type", { fg = colors.index_type })
  hl(0, "@type.builtin", { fg = colors.index_type })
  hl(0, "@type.definition", { fg = colors.index_type })

  hl(0, "@attribute", { fg = colors.preproc })
  hl(0, "@attribute.builtin", { fg = colors.preproc })
  hl(0, "@property", { fg = colors.text_default })

  hl(0, "@function", { fg = colors.index_function })
  hl(0, "@function.builtin", { fg = colors.index_function })
  hl(0, "@function.call", { fg = colors.index_function })
  hl(0, "@function.macro", { fg = colors.index_macro })
  hl(0, "@function.method", { fg = colors.index_function })
  hl(0, "@function.method.call", { fg = colors.index_function })

  hl(0, "@constructor", { fg = colors.index_type })
  hl(0, "@operator", { fg = colors.operators })

  hl(0, "@keyword", { fg = colors.keyword })
  hl(0, "@keyword.coroutine", { fg = colors.keyword })
  hl(0, "@keyword.function", { fg = colors.keyword })
  hl(0, "@keyword.operator", { fg = colors.operators })
  hl(0, "@keyword.import", { fg = colors.preproc })
  hl(0, "@keyword.type", { fg = colors.keyword })
  hl(0, "@keyword.modifier", { fg = colors.keyword })
  hl(0, "@keyword.repeat", { fg = colors.keyword })
  hl(0, "@keyword.return", { fg = colors.keyword })
  hl(0, "@keyword.debug", { fg = colors.error })
  hl(0, "@keyword.exception", { fg = colors.keyword })
  hl(0, "@keyword.conditional", { fg = colors.keyword })
  hl(0, "@keyword.directive", { fg = colors.preproc })
  hl(0, "@keyword.directive.define", { fg = colors.preproc })

  hl(0, "@punctuation", { fg = colors.syntax_crap })
  hl(0, "@punctuation.delimiter", { fg = colors.syntax_crap })
  hl(0, "@punctuation.bracket", { fg = colors.syntax_crap })
  hl(0, "@punctuation.special", { fg = colors.special })

  hl(0, "@comment", { fg = colors.comment, italic = true })
  hl(0, "@comment.documentation", { fg = colors.comment, italic = true })
  hl(0, "@comment.error", { fg = colors.error, bold = true })
  hl(0, "@comment.warning", { fg = colors.cursor2, bold = true })
  hl(0, "@comment.todo", { fg = colors.cursor, bold = true })
  hl(0, "@comment.note", { fg = colors.pop1, bold = true })

  hl(0, "@markup", { fg = colors.text_default })
  hl(0, "@markup.strong", { bold = true })
  hl(0, "@markup.italic", { italic = true })
  hl(0, "@markup.strikethrough", { strikethrough = true })
  hl(0, "@markup.underline", { underline = true })

  hl(0, "@markup.heading", { fg = colors.base, bold = true })
  hl(0, "@markup.heading.1", { fg = colors.base, bold = true })
  hl(0, "@markup.heading.2", { fg = colors.cursor3, bold = true })
  hl(0, "@markup.heading.3", { fg = colors.pop1, bold = true })
  hl(0, "@markup.heading.4", { fg = colors.index_type, bold = true })
  hl(0, "@markup.heading.5", { fg = colors.index_function, bold = true })
  hl(0, "@markup.heading.6", { fg = colors.text_cycle1, bold = true })

  hl(0, "@markup.quote", { fg = colors.comment, italic = true })
  hl(0, "@markup.math", { fg = colors.index_constant })

  hl(0, "@markup.link", { fg = colors.index_function, underline = true })
  hl(0, "@markup.link.label", { fg = colors.pop2 })
  hl(0, "@markup.link.url", { fg = colors.index_function, underline = true })

  hl(0, "@markup.raw", { fg = colors.string })
  hl(0, "@markup.raw.block", { fg = colors.string })

  hl(0, "@markup.list", { fg = colors.syntax_crap })
  hl(0, "@markup.list.checked", { fg = colors.cursor })
  hl(0, "@markup.list.unchecked", { fg = colors.comment })

  hl(0, "@tag", { fg = colors.keyword })
  hl(0, "@tag.attribute", { fg = colors.text_cycle1 })
  hl(0, "@tag.delimiter", { fg = colors.syntax_crap })

  -- LSP semantic tokens
  hl(0, "@lsp.type.class", { fg = colors.index_type })
  hl(0, "@lsp.type.comment", { fg = colors.comment })
  hl(0, "@lsp.type.decorator", { fg = colors.preproc })
  hl(0, "@lsp.type.enum", { fg = colors.index_type })
  hl(0, "@lsp.type.enumMember", { fg = colors.index_constant })
  hl(0, "@lsp.type.function", { fg = colors.index_function })
  hl(0, "@lsp.type.interface", { fg = colors.index_type })
  hl(0, "@lsp.type.macro", { fg = colors.index_macro })
  hl(0, "@lsp.type.method", { fg = colors.index_function })
  hl(0, "@lsp.type.namespace", { fg = colors.index_type })
  hl(0, "@lsp.type.parameter", { fg = colors.text_cycle1 })
  hl(0, "@lsp.type.property", { fg = colors.text_default })
  hl(0, "@lsp.type.struct", { fg = colors.index_type })
  hl(0, "@lsp.type.type", { fg = colors.index_type })
  hl(0, "@lsp.type.typeParameter", { fg = colors.index_type })
  hl(0, "@lsp.type.variable", { fg = colors.text_default })

  -- Diagnostics
  hl(0, "DiagnosticError", { fg = colors.error })
  hl(0, "DiagnosticWarn", { fg = colors.cursor2 })
  hl(0, "DiagnosticInfo", { fg = colors.pop1 })
  hl(0, "DiagnosticHint", { fg = colors.comment })
  hl(0, "DiagnosticOk", { fg = colors.cursor })

  hl(0, "DiagnosticVirtualTextError", { fg = colors.error, bg = "#1a0c0c" })
  hl(0, "DiagnosticVirtualTextWarn", { fg = colors.cursor2, bg = "#1a130c" })
  hl(0, "DiagnosticVirtualTextInfo", { fg = colors.pop1, bg = "#0c1a0c" })
  hl(0, "DiagnosticVirtualTextHint", { fg = colors.comment })

  hl(0, "DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
  hl(0, "DiagnosticUnderlineWarn", { sp = colors.cursor2, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo", { sp = colors.pop1, undercurl = true })
  hl(0, "DiagnosticUnderlineHint", { sp = colors.comment, undercurl = true })

  hl(0, "DiagnosticFloatingError", { fg = colors.error })
  hl(0, "DiagnosticFloatingWarn", { fg = colors.cursor2 })
  hl(0, "DiagnosticFloatingInfo", { fg = colors.pop1 })
  hl(0, "DiagnosticFloatingHint", { fg = colors.comment })

  hl(0, "DiagnosticSignError", { fg = colors.error, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignWarn", { fg = colors.cursor2, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignInfo", { fg = colors.pop1, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignHint", { fg = colors.comment, bg = colors.line_numbers_bg })

  -- Git signs (for plugins like gitsigns.nvim)
  hl(0, "GitSignsAdd", { fg = colors.cursor, bg = colors.line_numbers_bg })
  hl(0, "GitSignsChange", { fg = colors.cursor3, bg = colors.line_numbers_bg })
  hl(0, "GitSignsDelete", { fg = colors.error, bg = colors.line_numbers_bg })
  hl(0, "GitSignsChangedelete", { fg = colors.cursor2, bg = colors.line_numbers_bg })

  -- Telescope - more unified and subtle
  hl(0, "TelescopeNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopeBorder", { fg = colors.line_numbers_text, bg = colors.back })  -- Darker, more subtle borders
  hl(0, "TelescopePromptNormal", { fg = colors.text_cycle1, bg = colors.back })  -- Keep prompt in same background
  hl(0, "TelescopePromptBorder", { fg = colors.line_numbers_text, bg = colors.back })  -- Subtle border
  hl(0, "TelescopePromptTitle", { fg = colors.comment, bg = colors.back })  -- Subtle title
  hl(0, "TelescopePromptPrefix", { fg = colors.pop1, bg = colors.back })  -- Just the prompt symbol stands out
  hl(0, "TelescopeResultsNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopeResultsBorder", { fg = colors.line_numbers_text, bg = colors.back })
  hl(0, "TelescopeResultsTitle", { fg = colors.comment, bg = colors.back })  -- Subtle title
  hl(0, "TelescopePreviewNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopePreviewBorder", { fg = colors.line_numbers_text, bg = colors.back })
  hl(0, "TelescopePreviewTitle", { fg = colors.comment, bg = colors.back })  -- Subtle title
  hl(0, "TelescopeSelection", { fg = colors.text_cycle1, bg = colors.highlight_line })  -- More subtle selection
  hl(0, "TelescopeSelectionCaret", { fg = colors.base, bg = colors.highlight_line })  -- Golden caret
  hl(0, "TelescopeMultiSelection", { fg = colors.pop1, bg = colors.highlight_line })
  hl(0, "TelescopeMatching", { fg = colors.base, bold = true })  -- Golden for matches

  -- Harpoon
  hl(0, "HarpoonBorder", { fg = colors.syntax_crap })
  hl(0, "HarpoonWindow", { fg = colors.text_default })

  -- Matching parentheses
  hl(0, "MatchParen", { fg = colors.brace_highlight, bold = true })

  -- Indent guides (if using indent-blankline.nvim)
  hl(0, "IblIndent", { fg = colors.ghost })
  hl(0, "IblScope", { fg = colors.syntax_crap })

  -- Which-key (if installed)
  hl(0, "WhichKey", { fg = colors.index_function })
  hl(0, "WhichKeyGroup", { fg = colors.index_type })
  hl(0, "WhichKeyDesc", { fg = colors.text_default })
  hl(0, "WhichKeySeperator", { fg = colors.syntax_crap })
  hl(0, "WhichKeyFloat", { bg = colors.list_item_hover })
  hl(0, "WhichKeyValue", { fg = colors.constant })

  -- Jai-specific highlights (if you work with Jai)
  hl(0, "@keyword.jai", { fg = colors.keyword })
  hl(0, "@keyword.directive.jai", { fg = colors.preproc })
  hl(0, "@storageclass.jai", { fg = colors.keyword })
  hl(0, "@keyword.type.jai", { fg = colors.keyword })
  hl(0, "@type.jai", { fg = colors.index_type })
  hl(0, "@function.call.jai", { fg = colors.index_function })
  hl(0, "@punctuation.special.jai", { fg = colors.preproc })
  hl(0, "@operator.jai", { fg = colors.operators })
end

M.setup()

return M