-- bl colorscheme - Casey's 4coder theme for Neovim
-- Based on theme-casey.4coder from Handmade Hero
local colors = {
    -- Core background colors (Casey)
    background = "#0C0C0C",
    background_dark = "#080808",
    background_light = "#1f1f27",
    background_highlight = "#2f2f37",

    -- Text colors (Casey)
    text = "#a08563",
    text_dim = "#686868",
    text_bright = "#c0a583",

    -- UI elements (Casey)
    cursor = "#00EE00",
    cursor_inactive = "#404040",
    char_under_cursor = "#0C0C0C",
    cursor_line = "#1f1f27",
    selection = "#315268",
    selection_inactive = "#2d3640",
    selection_highlight = "#171e20",
    token_highlight = "#2f2f37",
    line_nr = "#404040",
    line_nr_active = "#a08563",
    line_nr_bg = "#101010",

    -- Syntax colors (Casey)
    comment = "#686868",
    string = "#6b8e23",
    keyword = "#ac7b0b",
    func = "#cc5735",
    variable = "#a08563",
    constant = "#478980",
    number = "#6b8e23",
    punctuation = "#907553",
    macro = "#478980",
    operator = "#907553",
    type = "#d8a51d",
    preproc = "#dab98f",

    -- Status/feedback
    error = "#ff0000",
    warning = "#ffaa00",
    success = "#00A000",
    info = "#478980",
    hint = "#404040",

    -- Diff colors
    diff_add = "#1a4a1a",
    diff_delete = "#3A0000",
    diff_change = "#4a4a2a",
    code_addition = "#33B333",
    code_deletion = "#E64D4D",

    -- Search (Casey)
    search = "#c4b82b",
    search_bg = "#315268",
    search_current = "#e4d97d",

    -- Splitter/borders
    border = "#1f1f27",
    border_hover = "#333333",
    border_dim = "#101010",

    -- Scope/region highlighting
    region_scope_export = "#0C0C0C",
    region_scope_file = "#0a0a0a",
    region_scope_module = "#0e0e0e",
    region_header = "#1f1f27",
    region_success = "#226022",
    region_warning = "#986032",
    region_error = "#772222",
    region_heredoc = "#080808",

    -- Bracket/brace highlighting (Casey/Fleury)
    bracket_highlight = "#b09573",
    brace_line = "#9ba290",
    brace_annotation = "#9ba290",

    -- Paste/undo animation
    paste_animation = "#ffbb00",
    undo_animation = "#80005d",
}

colors.none = "NONE"

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "bl"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal", { fg = colors.text, bg = colors.background })
set(0, "NormalNC", { fg = colors.text, bg = colors.background_dark })
set(0, "NormalFloat", { fg = colors.text, bg = colors.background_dark })
set(0, "FloatBorder", { fg = colors.border, bg = colors.background_dark })
set(0, "FloatTitle", { fg = colors.text_bright, bg = colors.background_light })
set(0, "WinSeparator", { fg = colors.border })
set(0, "VertSplit", { fg = colors.border })
set(0, "StatusLine", { fg = colors.background, bg = colors.text })
set(0, "StatusLineNC", { fg = colors.text_dim, bg = colors.background_light })
set(0, "TabLine", { fg = colors.text_dim, bg = colors.background_light })
set(0, "TabLineSel", { fg = colors.background, bg = colors.text })
set(0, "TabLineFill", { fg = colors.text_dim, bg = colors.background_dark })
set(0, "LineNr", { fg = colors.line_nr, bg = colors.line_nr_bg })
set(0, "CursorLineNr", { fg = colors.line_nr_active, bg = colors.cursor_line })
set(0, "SignColumn", { fg = colors.line_nr, bg = colors.background })
set(0, "CursorColumn", { bg = colors.cursor_line })
set(0, "CursorLine", { bg = colors.cursor_line })
set(0, "Cursor", { fg = colors.char_under_cursor, bg = colors.cursor })
set(0, "TermCursor", { fg = colors.char_under_cursor, bg = colors.cursor })
set(0, "TermCursorNC", { fg = colors.char_under_cursor, bg = colors.cursor_inactive })
set(0, "Visual", { bg = colors.selection })
set(0, "VisualNOS", { bg = colors.selection_inactive })
set(0, "Search", { fg = colors.search, bg = colors.search_bg })
set(0, "IncSearch", { fg = colors.background, bg = colors.search_current })
set(0, "CurSearch", { fg = colors.background, bg = colors.search_current })
set(0, "MatchParen", { fg = colors.bracket_highlight, bg = colors.background_highlight, bold = true })
set(0, "ColorColumn", { bg = colors.background_light })
set(0, "Folded", { fg = colors.text_dim, bg = colors.background_light })
set(0, "FoldColumn", { fg = colors.line_nr, bg = colors.background })
set(0, "EndOfBuffer", { fg = colors.background })
set(0, "NonText", { fg = colors.border_dim })
set(0, "Whitespace", { fg = colors.border_dim })
set(0, "SpecialKey", { fg = colors.border_dim })
set(0, "QuickFixLine", { fg = colors.text, bg = colors.background_highlight })
set(0, "qfLineNr", { fg = colors.warning })
set(0, "Directory", { fg = colors.constant })
set(0, "Title", { fg = colors.keyword, bold = true })
set(0, "Question", { fg = colors.success })
set(0, "MoreMsg", { fg = colors.text })
set(0, "ModeMsg", { fg = colors.text })
set(0, "WarningMsg", { fg = colors.warning })
set(0, "ErrorMsg", { fg = colors.error })
set(0, "Pmenu", { fg = colors.text, bg = colors.background_light })
set(0, "PmenuSel", { fg = colors.background, bg = colors.constant })
set(0, "PmenuSbar", { bg = colors.background_dark })
set(0, "PmenuThumb", { bg = colors.line_nr })
set(0, "WildMenu", { fg = colors.background, bg = colors.selection })
set(0, "CursorLineFold", { bg = colors.cursor_line })
set(0, "CursorLineSign", { bg = colors.cursor_line })
set(0, "WinBar", { fg = colors.text_bright, bg = colors.background_dark })
set(0, "WinBarNC", { fg = colors.text_dim, bg = colors.background_dark })

-- Syntax highlighting
set(0, "Comment", { fg = colors.comment })
set(0, "SpecialComment", { fg = colors.comment, bold = true })
set(0, "Todo", { fg = colors.warning, bg = colors.background_light, bold = true })
set(0, "String", { fg = colors.string })
set(0, "Character", { fg = colors.string })
set(0, "Number", { fg = colors.number })
set(0, "Float", { fg = colors.number })
set(0, "Boolean", { fg = colors.constant })
set(0, "Constant", { fg = colors.constant })
set(0, "Identifier", { fg = colors.variable })
set(0, "Function", { fg = colors.func })
set(0, "Statement", { fg = colors.keyword })
set(0, "Operator", { fg = colors.operator })
set(0, "Keyword", { fg = colors.keyword })
set(0, "Type", { fg = colors.type })
set(0, "Structure", { fg = colors.type })
set(0, "StorageClass", { fg = colors.type })
set(0, "PreProc", { fg = colors.preproc })
set(0, "Include", { fg = colors.preproc })
set(0, "Define", { fg = colors.macro })
set(0, "Macro", { fg = colors.macro })
set(0, "PreCondit", { fg = colors.preproc })
set(0, "Conditional", { fg = colors.keyword })
set(0, "Repeat", { fg = colors.keyword })
set(0, "Label", { fg = colors.constant })
set(0, "Special", { fg = colors.punctuation })
set(0, "Delimiter", { fg = colors.punctuation })
set(0, "Underlined", { underline = true })
set(0, "Bold", { bold = true })
set(0, "Italic", { italic = true })
set(0, "Error", { fg = colors.error })

-- Treesitter highlights
set(0, "@comment", { link = "Comment" })
set(0, "@comment.todo", { fg = colors.warning, bg = colors.background_light, bold = true })
set(0, "@comment.error", { fg = colors.error })
set(0, "@punctuation", { link = "Delimiter" })
set(0, "@punctuation.bracket", { fg = colors.punctuation })
set(0, "@punctuation.special", { fg = colors.punctuation })
set(0, "@string", { link = "String" })
set(0, "@string.regex", { fg = colors.string })
set(0, "@string.escape", { fg = colors.constant })
set(0, "@character", { link = "Character" })
set(0, "@character.special", { fg = colors.constant })
set(0, "@number", { link = "Number" })
set(0, "@number.float", { link = "Float" })
set(0, "@float", { link = "Float" })
set(0, "@boolean", { link = "Boolean" })
set(0, "@constant", { link = "Constant" })
set(0, "@constant.builtin", { fg = colors.constant })
set(0, "@constant.macro", { fg = colors.macro })
set(0, "@type", { link = "Type" })
set(0, "@type.builtin", { fg = colors.type })
set(0, "@type.definition", { fg = colors.type, bold = true })
set(0, "@type.qualifier", { fg = colors.type })
set(0, "@attribute", { fg = colors.preproc })
set(0, "@variable", { fg = colors.variable })
set(0, "@variable.builtin", { fg = colors.constant })
set(0, "@variable.parameter", { fg = colors.variable, italic = true })
set(0, "@variable.jai", { link = "@variable" })
set(0, "@field", { fg = colors.variable })
set(0, "@property", { fg = colors.variable })
set(0, "@parameter", { fg = colors.variable, italic = true })
set(0, "@parameter.reference", { fg = colors.variable })
set(0, "@function", { link = "Function" })
set(0, "@function.call", { fg = colors.func })
set(0, "@function.definition", { fg = colors.func, bold = true })
set(0, "@function.builtin", { fg = colors.func })
set(0, "@function.macro", { fg = colors.macro })
set(0, "@method", { link = "Function" })
set(0, "@module", { fg = colors.preproc })
set(0, "@constructor", { fg = colors.type })
set(0, "@keyword", { link = "Keyword" })
set(0, "@keyword.function", { fg = colors.keyword })
set(0, "@keyword.operator", { fg = colors.operator })
set(0, "@keyword.return", { fg = colors.keyword, bold = true })
set(0, "@keyword.conditional", { link = "Keyword" })
set(0, "@keyword.repeat", { link = "Keyword" })
set(0, "@keyword.import", { fg = colors.preproc })
set(0, "@keyword.directive", { fg = colors.preproc })
set(0, "@keyword.modifier", { fg = colors.type })
set(0, "@operator", { link = "Operator" })
set(0, "@tag", { fg = colors.keyword })
set(0, "@tag.attribute", { fg = colors.preproc })
set(0, "@tag.delimiter", { fg = colors.punctuation })

-- Jai-specific
set(0, "@keyword.jai", { fg = colors.keyword })
set(0, "@storageclass.jai", { fg = colors.type })
set(0, "@function.jai", { fg = colors.func })
set(0, "@function.call.jai", { fg = colors.func })
set(0, "@operator.jai", { fg = colors.operator })
set(0, "@punctuation.special.jai", { fg = colors.punctuation })
set(0, "@punctuation.delimiter.jai", { fg = colors.punctuation })
set(0, "@variable.builtin.jai", { fg = colors.constant })
set(0, "@constant.builtin.jai", { fg = colors.constant })

-- LSP
set(0, "LspReferenceText", { bg = colors.background_highlight })
set(0, "LspReferenceRead", { bg = colors.background_highlight })
set(0, "LspReferenceWrite", { bg = colors.background_highlight })
set(0, "LspSignatureActiveParameter", { fg = colors.text, bg = colors.selection_dim, bold = true })
set(0, "LspInlayHint", { fg = colors.line_nr, bg = colors.background_light })
set(0, "LspCodeLens", { fg = colors.line_nr })
set(0, "LspCodeLensSeparator", { fg = colors.line_nr })

-- Diagnostics
set(0, "DiagnosticError", { fg = colors.error })
set(0, "DiagnosticWarn", { fg = colors.warning })
set(0, "DiagnosticInfo", { fg = colors.info })
set(0, "DiagnosticHint", { fg = colors.hint })
set(0, "DiagnosticOk", { fg = colors.success })
set(0, "DiagnosticVirtualTextError", { fg = colors.error, bold = true })
set(0, "DiagnosticVirtualTextWarn", { fg = colors.background, bg = colors.warning, bold = true })
set(0, "DiagnosticVirtualTextInfo", { fg = colors.background, bg = colors.info })
set(0, "DiagnosticVirtualTextHint", { fg = colors.background, bg = colors.success })
set(0, "DiagnosticVirtualTextOk", { fg = colors.success })
set(0, "DiagnosticUnderlineError", { undercurl = true, sp = colors.error })
set(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warning })
set(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = colors.info })
set(0, "DiagnosticUnderlineHint", { undercurl = true, sp = colors.hint })
set(0, "DiagnosticUnderlineOk", { undercurl = true, sp = colors.success })
set(0, "DiagnosticSignError", { fg = colors.error, bg = colors.background })
set(0, "DiagnosticSignWarn", { fg = colors.warning, bg = colors.background })
set(0, "DiagnosticSignInfo", { fg = colors.info, bg = colors.background })
set(0, "DiagnosticSignHint", { fg = colors.hint, bg = colors.background })
set(0, "DiagnosticSignOk", { fg = colors.success, bg = colors.background })

-- Diff & Git
set(0, "DiffAdd", { fg = colors.success, bg = colors.diff_add })
set(0, "DiffDelete", { fg = colors.error, bg = colors.diff_delete })
set(0, "DiffChange", { fg = colors.warning, bg = colors.diff_change })
set(0, "DiffText", { fg = colors.background, bg = colors.warning })
set(0, "DiffAdded", { fg = colors.success })
set(0, "DiffRemoved", { fg = colors.error })
set(0, "DiffChanged", { fg = colors.warning })
set(0, "GitSignsAdd", { fg = colors.success })
set(0, "GitSignsChange", { fg = colors.warning })
set(0, "GitSignsDelete", { fg = colors.error })
set(0, "GitSignsCurrentLineBlame", { fg = colors.line_nr })

-- Spell checking
set(0, "SpellBad", { undercurl = true, sp = colors.error })
set(0, "SpellCap", { undercurl = true, sp = colors.warning })
set(0, "SpellLocal", { undercurl = true, sp = colors.success })
set(0, "SpellRare", { undercurl = true, sp = colors.info })

-- Telescope
set(0, "TelescopeNormal", { fg = colors.text, bg = colors.background })
set(0, "TelescopeBorder", { fg = colors.border, bg = colors.background })
set(0, "TelescopeSelection", { fg = colors.background, bg = colors.constant, bold = true })
set(0, "TelescopeSelectionCaret", { fg = colors.keyword, bg = colors.constant, bold = true })
set(0, "TelescopeMultiSelection", { fg = colors.background, bg = colors.success })
set(0, "TelescopeMatching", { fg = colors.warning })
set(0, "TelescopeTitle", { fg = colors.text_bright })

-- Trouble / build panel
set(0, "TroubleNormal", { fg = colors.text, bg = colors.background_dark })
set(0, "TroubleNormalNC", { fg = colors.text, bg = colors.background_dark })
set(0, "TroubleFoldIcon", { fg = colors.line_nr })
set(0, "TroubleIndent", { fg = colors.border_dim })
set(0, "TroubleText", { fg = colors.text })
set(0, "TroubleCount", { fg = colors.warning })
set(0, "TroubleFile", { fg = colors.variable })
set(0, "TroubleLocation", { fg = colors.line_nr })
set(0, "TroublePreview", { fg = colors.text, bg = colors.background_light })

-- Which-key & cmp
set(0, "WhichKey", { fg = colors.text })
set(0, "WhichKeyGroup", { fg = colors.constant })
set(0, "WhichKeyDesc", { fg = colors.variable })
set(0, "WhichKeySeparator", { fg = colors.line_nr })
set(0, "WhichKeyFloat", { bg = colors.background_dark })
set(0, "CmpItemAbbr", { fg = colors.text })
set(0, "CmpItemAbbrMatch", { fg = colors.warning })
set(0, "CmpItemAbbrMatchFuzzy", { fg = colors.warning })
set(0, "CmpItemMenu", { fg = colors.line_nr })
set(0, "CmpItemKind", { fg = colors.text })
set(0, "CmpItemKindFunction", { fg = colors.func })
set(0, "CmpItemKindMethod", { fg = colors.func })
set(0, "CmpItemKindVariable", { fg = colors.variable })
set(0, "CmpItemKindField", { fg = colors.variable })
set(0, "CmpItemKindProperty", { fg = colors.variable })
set(0, "CmpItemKindValue", { fg = colors.constant })
set(0, "CmpItemKindEnum", { fg = colors.type })
set(0, "CmpItemKindEnumMember", { fg = colors.constant })
set(0, "CmpItemKindKeyword", { fg = colors.keyword })
set(0, "CmpItemKindText", { fg = colors.comment })
set(0, "CmpItemKindClass", { fg = colors.type })
set(0, "CmpItemKindInterface", { fg = colors.type })
set(0, "CmpItemKindModule", { fg = colors.preproc })
set(0, "CmpItemKindSnippet", { fg = colors.constant })
set(0, "CmpItemKindColor", { fg = colors.warning })
set(0, "CmpItemKindFile", { fg = colors.variable })
set(0, "CmpItemKindFolder", { fg = colors.variable })
set(0, "CmpItemKindReference", { fg = colors.constant })

-- Indent guides
set(0, "IndentBlanklineChar", { fg = colors.border_dim })
set(0, "IndentBlanklineContextChar", { fg = colors.border })
set(0, "IblIndent", { fg = colors.border_dim })
set(0, "IblWhitespace", { fg = colors.border_dim })
set(0, "IblScope", { fg = colors.border })

-- Illuminated word / token highlight
set(0, "IlluminatedWordText", { bg = colors.token_highlight })
set(0, "IlluminatedWordRead", { bg = colors.token_highlight })
set(0, "IlluminatedWordWrite", { bg = colors.token_highlight })

-- Scope/region highlighting (Focus/HH paradigm)
set(0, "FocusRegionScopeExport", { fg = colors.macro, bg = colors.region_scope_export })
set(0, "FocusRegionScopeFile", { fg = colors.variable, bg = colors.region_scope_file })
set(0, "FocusRegionScopeModule", { fg = colors.variable, bg = colors.region_scope_module })
set(0, "FocusRegionHeader", { fg = colors.region_header, bold = true })
set(0, "FocusRegionSuccess", { fg = colors.region_success })
set(0, "FocusRegionWarning", { fg = colors.region_warning })
set(0, "FocusRegionError", { fg = colors.region_error })
set(0, "FocusRegionHeredoc", { fg = colors.string, bg = colors.region_heredoc })
set(0, "FocusRegionAddition", { fg = colors.code_addition, bg = colors.diff_add })
set(0, "FocusRegionDeletion", { fg = colors.code_deletion, bg = colors.diff_delete })

-- Region aliases
set(0, "RegionScopeExport", { link = "FocusRegionScopeExport" })
set(0, "RegionScopeFile", { link = "FocusRegionScopeFile" })
set(0, "RegionScopeModule", { link = "FocusRegionScopeModule" })
set(0, "RegionHeader", { link = "FocusRegionHeader" })
set(0, "RegionSuccess", { link = "FocusRegionSuccess" })
set(0, "RegionWarning", { link = "FocusRegionWarning" })
set(0, "RegionError", { link = "FocusRegionError" })
set(0, "RegionHeredoc", { link = "FocusRegionHeredoc" })
set(0, "RegionAddition", { link = "FocusRegionAddition" })
set(0, "RegionDeletion", { link = "FocusRegionDeletion" })

-- Elext/Lexical scope aliases
set(0, "ElextScopeExport", { link = "FocusRegionScopeExport" })
set(0, "ElextScopeFile", { link = "FocusRegionScopeFile" })
set(0, "ElextScopeModule", { link = "FocusRegionScopeModule" })
set(0, "ElextRegionHeader", { link = "FocusRegionHeader" })
set(0, "ElextRegionSuccess", { link = "FocusRegionSuccess" })
set(0, "ElextRegionWarning", { link = "FocusRegionWarning" })
set(0, "ElextRegionError", { link = "FocusRegionError" })
set(0, "ElextRegionHeredoc", { link = "FocusRegionHeredoc" })
set(0, "LexicalScopeExport", { link = "FocusRegionScopeExport" })
set(0, "LexicalScopeFile", { link = "FocusRegionScopeFile" })
set(0, "LexicalScopeModule", { link = "FocusRegionScopeModule" })

-- Bracket/brace scope highlighting
set(0, "BraceHighlight", { fg = colors.bracket_highlight })
set(0, "BraceLine", { fg = colors.brace_line })
set(0, "BraceAnnotation", { fg = colors.brace_annotation })

return colors
