-- HH theme for Neovim
-- Based on 4coder Fleury-style colors
-- Dark background (#0c0c0c), mode-based cursors, scope highlighting

local M = {}

-- Color palette (matched to 4coder Fleury theme)
local colors = {
  -- Core background/foreground
  bar_bg = "#1f1f27",        -- defcolor_bar: Status bar background
  base = "#cb9401",          -- defcolor_base: Status bar text / golden accent
  pop1 = "#70971e",          -- defcolor_pop1: Color of prompts
  pop2 = "#cb9401",          -- defcolor_pop2: Annotations
  back = "#0c0c0c",          -- defcolor_back: Text area background
  margin = "#0c0c0c",        -- defcolor_margin: Frame around inactive panel
  margin_hover = "#00ff00",  -- defcolor_margin_hover
  margin_active = "#0c0c0c", -- defcolor_margin_active

  -- List/hover colors
  list_item_hover = "#171e20",  -- defcolor_list_item_hover
  list_item_active = "#2d3640", -- defcolor_list_item_active

  -- Cursor colors for different modes
  cursor_normal = "#00ee00",   -- defcolor_cursor[0]: Green for normal mode
  cursor_insert = "#ee7700",   -- defcolor_cursor[1]: Orange for insert mode
  cursor_visual = "#cb9401",   -- Gold for visual mode
  cursor_replace = "#ff0000",  -- Red for replace mode
  cursor_command = "#70971e",  -- Olive for command mode
  cursor_inactive = "#404040", -- fleury_color_cursor_inactive

  at_cursor = "#0c0c0c",       -- defcolor_at_cursor
  highlight_line = "#1f1f27",  -- defcolor_highlight_cursor_line
  highlight = "#315268",       -- defcolor_highlight: Search highlight background
  at_highlight = "#c4b82b",    -- defcolor_at_highlight: Search highlight text
  mark = "#494949",            -- defcolor_mark

  -- Text colors
  text_default = "#a08563",  -- defcolor_text_default: Regular text (warm tan)
  comment = "#686868",       -- defcolor_comment: Comments (gray)
  comment_pop1 = "#00a000",  -- defcolor_comment_pop[0]: Green highlight in comments
  comment_pop2 = "#a00000",  -- defcolor_comment_pop[1]: Red highlight in comments
  keyword = "#ac7b0b",       -- defcolor_keyword: Keywords (amber)
  string = "#6b8e23",        -- defcolor_str_constant: String constants (olive)
  constant = "#6b8e23",      -- defcolor_int/float/bool_constant
  preproc = "#dab98f",       -- defcolor_preproc: Preprocessor (light tan)

  -- Special colors
  special = "#ff0000",       -- defcolor_special_character
  ghost = "#5b4d3c",         -- defcolor_ghost_character
  highlight_junk = "#3a0000", -- defcolor_highlight_junk
  highlight_white = "#003a3a", -- defcolor_highlight_white
  paste = "#ffbb00",         -- defcolor_paste
  undo = "#80005d",          -- defcolor_undo

  -- Line numbers
  line_numbers_bg = "#101010",   -- defcolor_line_numbers_back
  line_numbers_text = "#404040", -- defcolor_line_numbers_text

  -- Indexer/semantic colors (fleury_color_index_*)
  index_type = "#d8a51d",         -- fleury_color_index_product_type/sum_type: Types (gold)
  index_function = "#cc5735",     -- fleury_color_index_function: Functions (rust red)
  index_constant = "#478980",     -- fleury_color_index_constant: Constants (teal)
  index_macro = "#478980",        -- fleury_color_index_macro: Macros (teal)
  index_decl = "#c04047",         -- fleury_color_index_decl: Declarations (red)
  index_4coder_command = "#23de33", -- fleury_color_index_4coder_command
  index_comment_tag = "#00ff00", -- fleury_color_index_comment_tag

  -- Error/diagnostic
  error = "#ff0000",              -- fleury_color_error_annotation

  -- Operator/syntax
  syntax_crap = "#907553",        -- fleury_color_syntax_crap: Braces, semicolons (brown)
  operators = "#907553",          -- fleury_color_operators: Operators (brown)

  -- Pane colors
  inactive_pane_overlay = "#000000", -- fleury_color_inactive_pane_overlay (transparent in original)
  inactive_pane_bg = "#0c0c0c",      -- fleury_color_inactive_pane_background
  file_progress_bar = "#232323",     -- fleury_color_file_progress_bar

  -- Brace matching
  brace_highlight = "#b09573",   -- fleury_color_brace_highlight: Active brace
  brace_line = "#9ba290",        -- fleury_color_brace_line: Brace connection lines
  brace_annotation = "#9ba290",  -- fleury_color_brace_annotation
  token_highlight = "#2f2f37",   -- fleury_color_token_highlight

  -- Cycle colors for text variations
  text_cycle1 = "#c0a583",       -- defcolor_text_cycle[0]
  text_cycle2 = "#b09573",       -- defcolor_text_cycle[1]

  -- Mode colors
  cursor_macro = "#de2368",      -- fleury_color_cursor_macro: Macro recording (pink)
  cursor_power = "#efaf2f",      -- fleury_color_cursor_power_mode: Power mode

  -- Plot cycle colors
  plot_cycle = { "#03d3fc", "#22b80b", "#f0bb0c", "#f0500c" },

  -- Custom yggdrasil macros (teal, same as index_macro from casey theme)
  yg_keyword = "#478980",

  -- Scope background cycle colors (like 4coder's defcolor_back_cycle)
  -- Moderate tints visible against #0c0c0c background
  back_cycle = {
    "#161419",  -- Level 1: purple/magenta tint
    "#141816",  -- Level 2: green tint
    "#141618",  -- Level 3: blue tint
    "#181614",  -- Level 4: amber/orange tint
    "#181418",  -- Level 5: pink tint
    "#141818",  -- Level 6: cyan tint
    "#161614",  -- Level 7: olive tint
    "#161419",  -- Level 8: violet tint
  },
}

function M.setup()
  -- Reset highlighting
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "hh"
  vim.o.background = "dark"
  vim.o.termguicolors = true

  local hl = vim.api.nvim_set_hl

  -- UI Elements
  hl(0, "Normal", { fg = colors.text_default, bg = colors.back })
  hl(0, "NormalFloat", { fg = colors.text_default, bg = colors.list_item_hover })
  hl(0, "FloatBorder", { fg = colors.syntax_crap, bg = colors.list_item_hover })
  hl(0, "FloatTitle", { fg = colors.base, bg = colors.list_item_hover })

  -- Mode-specific cursor highlight groups
  hl(0, "CursorNormal", { fg = colors.at_cursor, bg = colors.cursor_normal })
  hl(0, "CursorInsert", { fg = colors.at_cursor, bg = colors.cursor_insert })
  hl(0, "CursorVisual", { fg = colors.at_cursor, bg = colors.cursor_visual })
  hl(0, "CursorReplace", { fg = colors.at_cursor, bg = colors.cursor_replace })
  hl(0, "CursorCommand", { fg = colors.at_cursor, bg = colors.cursor_command })

  -- Set guicursor with mode-specific colors (all block cursors)
  vim.opt.guicursor = {
    "n-c:block-CursorNormal",           -- Normal/Command: green block
    "i-ci-ve:block-CursorInsert",       -- Insert: orange block
    "v-V:block-CursorVisual",           -- Visual: gold block
    "r-cr:block-CursorReplace",         -- Replace: red block
    "o:block-CursorNormal",             -- Operator-pending: green block
  }

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
  hl(0, "StatusLineNormal", { fg = colors.back, bg = colors.cursor_normal, bold = true })
  hl(0, "StatusLineInsert", { fg = colors.back, bg = colors.cursor_insert, bold = true })
  hl(0, "StatusLineVisual", { fg = colors.back, bg = colors.cursor_visual, bold = true })
  hl(0, "StatusLineReplace", { fg = colors.back, bg = colors.cursor_replace, bold = true })
  hl(0, "StatusLineCommand", { fg = colors.back, bg = colors.cursor_command, bold = true })
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
  hl(0, "CurSearch", { fg = colors.at_cursor, bg = colors.cursor_normal })
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
  hl(0, "WarningMsg", { fg = colors.cursor_insert })

  -- Folding
  hl(0, "Folded", { fg = colors.comment, bg = colors.highlight_line })
  hl(0, "FoldColumn", { fg = colors.comment, bg = colors.line_numbers_bg })

  -- Diff mode
  hl(0, "DiffAdd", { bg = "#0c1a0c" })
  hl(0, "DiffChange", { bg = "#1a1a0c" })
  hl(0, "DiffDelete", { fg = colors.error, bg = "#1a0c0c" })
  hl(0, "DiffText", { bg = "#2a2a14", bold = true })

  -- Spell checking
  hl(0, "SpellBad", { sp = colors.error, undercurl = true })
  hl(0, "SpellCap", { sp = colors.cursor_insert, undercurl = true })
  hl(0, "SpellLocal", { sp = colors.pop1, undercurl = true })
  hl(0, "SpellRare", { sp = colors.cursor_visual, undercurl = true })

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
  hl(0, "Constant", { fg = colors.constant })  -- Olive for all constants
  hl(0, "String", { fg = colors.string })
  hl(0, "Character", { fg = colors.string })
  hl(0, "Number", { fg = colors.constant })
  hl(0, "Boolean", { fg = colors.constant })   -- Olive for booleans (matches defcolor_bool_constant)
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
  hl(0, "Todo", { fg = colors.cursor_normal, bg = colors.highlight_line, bold = true })

  -- Treesitter highlight groups
  hl(0, "@variable", { fg = colors.text_default })
  hl(0, "@variable.builtin", { fg = colors.constant })  -- Olive
  hl(0, "@variable.parameter", { fg = colors.text_cycle1 })
  hl(0, "@variable.member", { fg = colors.text_default })

  hl(0, "@constant", { fg = colors.constant })         -- Olive
  hl(0, "@constant.builtin", { fg = colors.constant }) -- Olive
  hl(0, "@constant.macro", { fg = colors.index_macro })

  hl(0, "@module", { fg = colors.index_type })
  hl(0, "@module.builtin", { fg = colors.index_type })
  hl(0, "@label", { fg = colors.keyword })

  hl(0, "@string", { fg = colors.string })
  hl(0, "@string.documentation", { fg = colors.string })
  hl(0, "@string.regexp", { fg = colors.cursor_insert })
  hl(0, "@string.escape", { fg = colors.special })
  hl(0, "@string.special", { fg = colors.special })
  hl(0, "@string.special.symbol", { fg = colors.constant })  -- Olive
  hl(0, "@string.special.path", { fg = colors.string })
  hl(0, "@string.special.url", { fg = colors.index_function, underline = true })

  hl(0, "@character", { fg = colors.string })
  hl(0, "@character.special", { fg = colors.special })

  hl(0, "@boolean", { fg = colors.constant })  -- Olive (defcolor_bool_constant)
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
  hl(0, "@comment.warning", { fg = colors.cursor_insert, bold = true })
  hl(0, "@comment.todo", { fg = colors.cursor_normal, bold = true })
  hl(0, "@comment.note", { fg = colors.pop1, bold = true })

  hl(0, "@markup", { fg = colors.text_default })
  hl(0, "@markup.strong", { bold = true })
  hl(0, "@markup.italic", { italic = true })
  hl(0, "@markup.strikethrough", { strikethrough = true })
  hl(0, "@markup.underline", { underline = true })

  hl(0, "@markup.heading", { fg = colors.base, bold = true })
  hl(0, "@markup.heading.1", { fg = colors.base, bold = true })
  hl(0, "@markup.heading.2", { fg = colors.cursor_visual, bold = true })
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
  hl(0, "@markup.list.checked", { fg = colors.cursor_normal })
  hl(0, "@markup.list.unchecked", { fg = colors.comment })

  hl(0, "@tag", { fg = colors.keyword })
  hl(0, "@tag.attribute", { fg = colors.text_cycle1 })
  hl(0, "@tag.delimiter", { fg = colors.syntax_crap })

  -- Jai-specific
  hl(0, "@keyword.jai", { fg = colors.keyword })
  hl(0, "@keyword.repeat.jai", { fg = colors.keyword })
  hl(0, "@keyword.conditional.jai", { fg = colors.keyword })
  hl(0, "@keyword.function.jai", { fg = colors.keyword })
  hl(0, "@keyword.return.jai", { fg = colors.keyword })
  hl(0, "@keyword.modifier.jai", { fg = colors.keyword })
  hl(0, "@keyword.type.jai", { fg = colors.keyword })
  hl(0, "@keyword.operator.jai", { fg = colors.operators })
  hl(0, "@storageclass.jai", { fg = colors.keyword })
  hl(0, "@function.jai", { fg = colors.index_function })
  hl(0, "@function.call.jai", { fg = colors.index_function })
  hl(0, "@operator.jai", { fg = colors.operators })
  hl(0, "@punctuation.special.jai", { fg = colors.operators })
  hl(0, "@punctuation.delimiter.jai", { fg = colors.operators })
  hl(0, "@punctuation.bracket.jai", { fg = colors.syntax_crap })
  hl(0, "@variable.jai", { fg = colors.text_default })
  hl(0, "@variable.builtin.jai", { fg = colors.constant })  -- Olive
  hl(0, "@variable.parameter.jai", { fg = colors.text_cycle1 })
  hl(0, "@constant.jai", { fg = colors.constant })  -- Olive
  hl(0, "@constant.builtin.jai", { fg = colors.constant })  -- Olive
  hl(0, "@type.jai", { fg = colors.index_type })
  hl(0, "@type.builtin.jai", { fg = colors.index_type })
  hl(0, "@string.jai", { fg = colors.string })
  hl(0, "@number.jai", { fg = colors.constant })
  hl(0, "@boolean.jai", { fg = colors.constant })  -- Olive
  hl(0, "@comment.jai", { fg = colors.comment, italic = true })

  -- LSP semantic tokens
  hl(0, "@lsp.type.class", { fg = colors.index_type })
  hl(0, "@lsp.type.comment", { fg = colors.comment })
  hl(0, "@lsp.type.decorator", { fg = colors.preproc })
  hl(0, "@lsp.type.enum", { fg = colors.index_type })
  hl(0, "@lsp.type.enumMember", { fg = colors.constant })  -- Olive for enum members
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
  hl(0, "DiagnosticWarn", { fg = colors.cursor_insert })
  hl(0, "DiagnosticInfo", { fg = colors.pop1 })
  hl(0, "DiagnosticHint", { fg = colors.comment })
  hl(0, "DiagnosticOk", { fg = colors.cursor_normal })

  hl(0, "DiagnosticVirtualTextError", { fg = colors.error, bg = "#180c0c" })
  hl(0, "DiagnosticVirtualTextWarn", { fg = colors.cursor_insert, bg = "#18120c" })
  hl(0, "DiagnosticVirtualTextInfo", { fg = colors.pop1, bg = "#0c180c" })
  hl(0, "DiagnosticVirtualTextHint", { fg = colors.comment })

  hl(0, "DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
  hl(0, "DiagnosticUnderlineWarn", { sp = colors.cursor_insert, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo", { sp = colors.pop1, undercurl = true })
  hl(0, "DiagnosticUnderlineHint", { sp = colors.comment, undercurl = true })

  hl(0, "DiagnosticFloatingError", { fg = colors.error })
  hl(0, "DiagnosticFloatingWarn", { fg = colors.cursor_insert })
  hl(0, "DiagnosticFloatingInfo", { fg = colors.pop1 })
  hl(0, "DiagnosticFloatingHint", { fg = colors.comment })

  hl(0, "DiagnosticSignError", { fg = colors.error, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignWarn", { fg = colors.cursor_insert, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignInfo", { fg = colors.pop1, bg = colors.line_numbers_bg })
  hl(0, "DiagnosticSignHint", { fg = colors.comment, bg = colors.line_numbers_bg })

  -- Git signs
  hl(0, "GitSignsAdd", { fg = colors.cursor_normal, bg = colors.line_numbers_bg })
  hl(0, "GitSignsChange", { fg = colors.cursor_visual, bg = colors.line_numbers_bg })
  hl(0, "GitSignsDelete", { fg = colors.error, bg = colors.line_numbers_bg })
  hl(0, "GitSignsChangedelete", { fg = colors.cursor_insert, bg = colors.line_numbers_bg })

  -- Telescope
  hl(0, "TelescopeNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopeBorder", { fg = colors.line_numbers_text, bg = colors.back })
  hl(0, "TelescopePromptNormal", { fg = colors.text_cycle1, bg = colors.back })
  hl(0, "TelescopePromptBorder", { fg = colors.line_numbers_text, bg = colors.back })
  hl(0, "TelescopePromptTitle", { fg = colors.comment, bg = colors.back })
  hl(0, "TelescopePromptPrefix", { fg = colors.pop1, bg = colors.back })
  hl(0, "TelescopeResultsNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopeResultsBorder", { fg = colors.line_numbers_text, bg = colors.back })
  hl(0, "TelescopeResultsTitle", { fg = colors.comment, bg = colors.back })
  hl(0, "TelescopePreviewNormal", { fg = colors.text_default, bg = colors.back })
  hl(0, "TelescopePreviewBorder", { fg = colors.line_numbers_text, bg = colors.back })
  hl(0, "TelescopePreviewTitle", { fg = colors.comment, bg = colors.back })
  hl(0, "TelescopeSelection", { fg = colors.text_cycle1, bg = colors.highlight_line })
  hl(0, "TelescopeSelectionCaret", { fg = colors.base, bg = colors.highlight_line })
  hl(0, "TelescopeMultiSelection", { fg = colors.pop1, bg = colors.highlight_line })
  hl(0, "TelescopeMatching", { fg = colors.base, bold = true })

  -- Harpoon
  hl(0, "HarpoonBorder", { fg = colors.syntax_crap })
  hl(0, "HarpoonWindow", { fg = colors.text_default })

  -- Matching parentheses
  hl(0, "MatchParen", { fg = colors.brace_highlight, bold = true })

  -- Indent guides
  hl(0, "IblIndent", { fg = colors.ghost })
  hl(0, "IblScope", { fg = colors.syntax_crap })

  -- Which-key
  hl(0, "WhichKey", { fg = colors.index_function })
  hl(0, "WhichKeyGroup", { fg = colors.index_type })
  hl(0, "WhichKeyDesc", { fg = colors.text_default })
  hl(0, "WhichKeySeperator", { fg = colors.syntax_crap })
  hl(0, "WhichKeyFloat", { bg = colors.list_item_hover })
  hl(0, "WhichKeyValue", { fg = colors.constant })  -- Olive

  -- C/C++ specific for enum values
  hl(0, "@lsp.typemod.enumMember", { fg = colors.constant })  -- Olive
  hl(0, "@lsp.typemod.enumMember.declaration", { fg = colors.constant })  -- Olive

  -- Objective-C/C++ specific highlighting
  hl(0, "@keyword.objc", { fg = colors.keyword })
  hl(0, "@keyword.directive.objc", { fg = colors.preproc })     -- @interface, @implementation, @end
  hl(0, "@keyword.import.objc", { fg = colors.preproc })        -- @import
  hl(0, "@keyword.modifier.objc", { fg = colors.keyword })      -- @property modifiers
  hl(0, "@type.objc", { fg = colors.index_type })
  hl(0, "@type.builtin.objc", { fg = colors.index_type })       -- id, NSString, etc.
  hl(0, "@function.method.objc", { fg = colors.index_function })
  hl(0, "@function.call.objc", { fg = colors.index_function })
  hl(0, "@variable.member.objc", { fg = colors.text_default })
  hl(0, "@punctuation.special.objc", { fg = colors.operators }) -- @ symbol, brackets in message sends
  hl(0, "@string.objc", { fg = colors.string })                 -- @"string"
  hl(0, "@constant.builtin.objc", { fg = colors.constant })     -- nil, YES, NO

  -- Yggdrasil macros (yg_internal, yg_inline) - teal
  hl(0, "YgKeyword", { fg = colors.yg_keyword })
  -- Also override @keyword.modifier for yg_* (set via treesitter queries)
  -- Note: This makes ALL @keyword.modifier teal, which is fine since static/const etc
  -- should also be this color per casey theme (syntax_crap/operators color)

  -- Yggdrasil types (Vec3, u32, f32, etc.) - gold like index_type
  hl(0, "YgType", { fg = colors.index_type })

  -- Scope highlight groups for nested scope backgrounds (like 4coder back_cycle)
  for i, bg in ipairs(colors.back_cycle) do
    hl(0, "HHScope" .. i, { bg = bg })
  end
end

-- Export colors for use in statusline etc
M.colors = colors

-- Function to get cursor color based on mode
function M.get_cursor_color(mode)
  local mode_colors = {
    n = colors.cursor_normal,
    i = colors.cursor_insert,
    v = colors.cursor_visual,
    V = colors.cursor_visual,
    ["\22"] = colors.cursor_visual,  -- Ctrl-V (block visual)
    R = colors.cursor_replace,
    c = colors.cursor_command,
  }
  return mode_colors[mode] or colors.cursor_normal
end

-- Scope highlight namespace
local scope_ns = vim.api.nvim_create_namespace("hh_scope_highlight")

-- Cache for scope data per buffer to avoid unnecessary redraws
local scope_cache = {}

-- Different queries for different languages
local scope_queries = {
  c = [[
    (compound_statement) @scope
  ]],
  cpp = [[
    (compound_statement) @scope
  ]],
  objc = [[
    (compound_statement) @scope
  ]],
  objcpp = [[
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

-- Cached compiled queries (query strings never change, no need to recompile)
local compiled_queries = {}

-- Parse all scopes in a buffer (called on text change, not cursor move)
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

  if not compiled_queries[lang] then
    local success, q = pcall(vim.treesitter.query.parse, lang, query_string)
    if not success then return nil end
    compiled_queries[lang] = q
  end
  local query = compiled_queries[lang]

  -- Collect all scopes
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

-- Find scopes containing a specific line
local function find_containing_scopes(all_scopes, cursor_row)
  if not all_scopes then return {} end

  local containing = {}
  for _, scope in ipairs(all_scopes) do
    if cursor_row >= scope.start_row and cursor_row <= scope.end_row then
      table.insert(containing, scope)
    end
  end

  -- Sort by size (smallest/innermost first)
  table.sort(containing, function(a, b)
    return a.size < b.size
  end)

  return containing
end

-- Generate a fingerprint for the current scope state
local function scope_fingerprint(scopes)
  if not scopes or #scopes == 0 then return "" end
  local parts = {}
  for _, s in ipairs(scopes) do
    table.insert(parts, s.start_row .. ":" .. s.end_row)
  end
  return table.concat(parts, ",")
end

-- Apply scope highlights (only redraws if scopes actually changed)
function M.highlight_scopes(bufnr, winid, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  winid = winid or vim.api.nvim_get_current_win()

  -- Initialize cache for this buffer if needed
  if not scope_cache[bufnr] then
    scope_cache[bufnr] = {
      all_scopes = nil,
      last_fingerprint = "",
      dirty = true,
    }
  end

  local cache = scope_cache[bufnr]

  -- Reparse scopes if dirty (text changed)
  if cache.dirty or not cache.all_scopes then
    cache.all_scopes = parse_scopes(bufnr)
    cache.dirty = false
  end

  -- Get cursor position
  local cursor = vim.api.nvim_win_get_cursor(winid)
  local cursor_row = cursor[1] - 1  -- 0-indexed

  -- Find scopes containing cursor
  local containing_scopes = find_containing_scopes(cache.all_scopes, cursor_row)
  local fingerprint = scope_fingerprint(containing_scopes)

  -- Skip redraw if scopes haven't changed (cursor moved within same scope)
  if not force and fingerprint == cache.last_fingerprint then
    return
  end

  cache.last_fingerprint = fingerprint

  -- Clear and reapply highlights
  vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)

  -- Apply highlights - innermost scope gets first color, outer scopes get subsequent colors
  for depth, scope in ipairs(containing_scopes) do
    local cycle_idx = ((depth - 1) % #colors.back_cycle) + 1
    local hl_group = "HHScope" .. cycle_idx

    for line = scope.start_row, scope.end_row do
      vim.api.nvim_buf_set_extmark(bufnr, scope_ns, line, 0, {
        line_hl_group = hl_group,
        priority = 100 - depth,  -- Inner scopes have higher priority
      })
    end
  end
end

-- Mark buffer scopes as dirty (needs reparse)
local function mark_dirty(bufnr)
  if scope_cache[bufnr] then
    scope_cache[bufnr].dirty = true
  end
end

-- Debounce timer per buffer
local debounce_timers = {}
local DEBOUNCE_MS = 50  -- 50ms debounce for cursor movement

-- Debounced highlight update
local function debounced_highlight(bufnr)
  -- Cancel any pending timer for this buffer
  if debounce_timers[bufnr] then
    debounce_timers[bufnr]:stop()
    debounce_timers[bufnr] = nil
  end

  -- Create new timer
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

-- Enable scope highlighting for a buffer
function M.enable_scope_highlight(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Initialize cache
  scope_cache[bufnr] = {
    all_scopes = nil,
    last_fingerprint = "",
    dirty = true,
  }

  -- Initial highlight (immediate, not debounced)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.highlight_scopes(bufnr, nil, true)
    end
  end)

  local group = vim.api.nvim_create_augroup("HHScopeHighlight" .. bufnr, { clear = true })

  -- Cursor movement: debounced, uses cache
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      debounced_highlight(bufnr)
    end,
  })

  -- Buffer/window enter: force re-highlight (extmarks may have been cleared)
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

  -- Text changes: mark dirty, then debounced update
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      mark_dirty(bufnr)
      debounced_highlight(bufnr)
    end,
  })

  -- Clean up cache when buffer is deleted
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

-- Disable scope highlighting for a buffer
function M.disable_scope_highlight(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
  pcall(vim.api.nvim_del_augroup_by_name, "HHScopeHighlight" .. bufnr)
  scope_cache[bufnr] = nil
  if debounce_timers[bufnr] then
    debounce_timers[bufnr]:stop()
    debounce_timers[bufnr]:close()
    debounce_timers[bufnr] = nil
  end
end

-- Auto-enable for supported filetypes
function M.setup_scope_highlight()
  local group = vim.api.nvim_create_augroup("HHScopeSetup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "c", "cpp", "objc", "objcpp", "jai", "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function(ev)
      vim.schedule(function()
        M.enable_scope_highlight(ev.buf)
      end)
    end,
  })

  -- Re-highlight all active scope buffers on colorscheme change
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

  -- Also enable for current buffer if it matches
  local ft = vim.bo.filetype
  if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ft == "jai" or ft == "lua" or ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
    vim.schedule(function()
      M.enable_scope_highlight(vim.api.nvim_get_current_buf())
    end)
  end
end

M.setup()

-- Track yg match IDs per window to avoid clearing other matches
local yg_match_ids = {}

-- Setup yg_* keyword and type highlighting for C/C++ files (uses matchadd for priority over treesitter)
local function setup_yg_keywords()
  local winid = vim.api.nvim_get_current_win()

  -- Clear only our previous matches for this window
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

  -- Yggdrasil macros (teal)
  add_match("YgKeyword", "\\<yg_internal\\>")
  add_match("YgKeyword", "\\<yg_inline\\>")
  add_match("YgKeyword", "\\<yg_global\\>")
  add_match("YgKeyword", "\\<yg_local_persist\\>")

  -- Arc macros (teal, same as yg)
  add_match("YgKeyword", "\\<arc_internal\\>")
  add_match("YgKeyword", "\\<arc_inline\\>")
  add_match("YgKeyword", "\\<arc_global\\>")
  add_match("YgKeyword", "\\<arc_local_persist\\>")

  -- Yggdrasil base types (gold)
  add_match("YgType", "\\<[usb]\\(8\\|16\\|32\\|64\\)\\>")  -- u8, s16, b32, etc.
  add_match("YgType", "\\<f\\(32\\|64\\)\\>")              -- f32, f64
  add_match("YgType", "\\<void\\>")                        -- void
  add_match("YgType", "\\<Vec[234]\\(F32\\|F64\\|S16\\|S32\\|S64\\)\\?\\>")  -- Vec2, Vec3F32, etc.
  add_match("YgType", "\\<Mat[34]\\(F32\\)\\?\\>")           -- Mat3, Mat4F32
  add_match("YgType", "\\<Quaternion\\(F32\\)\\?\\>")      -- Quaternion, QuaternionF32
  add_match("YgType", "\\<Rng[12]\\(F32\\|U32\\|U64\\|S16\\|S32\\)\\?\\>")  -- Rng1F32, Rng2S32, etc.
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

  -- Return type after yg_internal/yg_inline (gold, like static would show the return type)
  add_match("YgType", "\\<yg_internal\\s\\+\\zs\\w\\+\\ze")
  add_match("YgType", "\\<yg_inline\\s\\+\\zs\\w\\+\\ze")
  add_match("YgType", "\\<arc_internal\\s\\+\\zs\\w\\+\\ze")
  add_match("YgType", "\\<arc_inline\\s\\+\\zs\\w\\+\\ze")

  -- Function declarations after ark_*/yg_* macros (rust-red)
  -- Pattern: PREFIX TYPE FUNCNAME( or PREFIX TYPE *FUNCNAME(
  add_match("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(")
  add_match("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s*\\*\\s*\\zs\\w\\+\\ze\\s*(")
end

local yg_group = vim.api.nvim_create_augroup("YgKeywords", { clear = true })
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

-- Apply to current buffer if it's C/C++/ObjC
local ft = vim.bo.filetype
local ext = vim.fn.expand("%:e")
if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ext == "c" or ext == "h" or ext == "cpp" or ext == "hpp" or ext == "m" or ext == "mm" then
  setup_yg_keywords()
end

-- Store module globally so it can be accessed after colorscheme load
vim.g.hh_theme = M

-- Enable scope highlighting with optimized debouncing
M.setup_scope_highlight()

return M
