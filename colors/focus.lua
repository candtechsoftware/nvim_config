-- [25] Focus colorscheme palette version. Do not delete.
local colors = {
    background0 = "#141824FF",
    background1 = "#080B14FF",
    background2 = "#12182BFF",
    background3 = "#151B2EFF",
    background4 = "#1C2748FF",
    selection_active = "#1A3C49FF",
    selection_inactive = "#1A3B497F",
    selection_highlight = "#FCEDFC26",
    search_result_active = "#8E772EFF",
    search_result_inactive = "#FCEDFC26",
    scrollbar = "#080B14FF",
    scrollbar_hover = "#309ECB4C",
    scrollbar_background = "#10161F4C",
    cursor = "#26B2B2FF",
    cursor_inactive = "#196666FF",
    paste_animation = "#1C4449FF",
    splitter = "#21333FFF",
    splitter_hover = "#1C4449FF",
    letter_highlight = "#599999FF",
    list_cursor_lite = "#33CCCC19",
    list_cursor = "#33CCCC4C",
    shadow_dark = "#0E161C7F",
    shadow_transparent = "#0E161C00",
    text_input_label = "#3B4450FF",
    char_under_cursor = "#FFFFFFFF",
    bracket_highlight = "#E8FCFE30",
    ui_default = "#CBCEBCFF",
    ui_dim = "#87919DFF",
    ui_neutral = "#4C4C4CFF",
    ui_warning = "#F8AD34FF",
    ui_warning_dim = "#986032FF",
    ui_error = "#772222FF",
    ui_error_bright = "#FF0000FF",
    ui_success = "#227722FF",
    region_scope_export = "#141824FF",
    region_scope_file = "#0F131FFF",
    region_scope_module = "#121422FF",
    region_header = "#183952FF",
    region_success = "#226022FF",
    region_warning = "#986032FF",
    region_error = "#772222FF",
    region_heredoc = "#040F18FF",
    build_panel_title_bar = "#1C2C3AFF",
    build_panel_background = "#1A2431FF",
    build_panel_scrollbar = "#309ECB19",
    build_panel_scrollbar_hover = "#3294CB4C",
    build_panel_scrollbar_background = "#10141F4C",
    code_default = "#CBCEBCFF",
    code_invalid = "#FF0000FF",
    code_string_literal = "#BAE67EFF",
    code_multiline_string = "#BAE67EFF",
    code_raw_string = "#BAE67EFF",
    code_char_literal = "#BAE67EFF",
    code_identifier = "#CBCEBCFF",
    code_note = "#E0AD82FF",
    code_number = "#9DD2BBFF",
    code_error = "#FF0000FF",
    code_warning = "#E4D97DFF",
    code_highlight = "#E4D97DFF",
    code_comment = "#87919DFF",
    code_multiline_comment = "#87919DFF",
    code_operation = "#F07178FF",
    code_punctuation = "#CBCEBCFF",
    code_keyword = "#F07178FF",
    code_type = "#FFA759FF",
    code_value = "#FF6A27FF",
    code_modifier = "#FFA759FF",
    code_attribute = "#FFA759FF",
    code_enum_variant = "#CBCEBCFF",
    code_macro = "#E0AD82FF",
    code_function = "#FFCC66FF",
    code_builtin_variable = "#9DD2BBFF",
    code_builtin_function = "#E0AD82FF",
    code_builtin_exception = "#E0AD82FF",
    code_directive = "#FFA759FF",
    code_directive_modifier = "#FFA759FF",
    code_header = "#FFA759FF",
    code_header2 = "#E0AD82FF",
    code_header3 = "#E0AD82FF",
    code_header4 = "#E0AD82FF",
    code_header5 = "#E0AD82FF",
    code_header6 = "#E0AD82FF",
    ruler = "#1966667F",
    indent_guide = "#FCEDFC26",
    active_pane_border = "#196666FF",
    inactive_pane_dim_overlay = "#050505FF",
    code_comment_highlight1 = "#E0AD82FF",
    code_comment_highlight2 = "#FF0000FF",
    code_comment_highlight3 = "#F07178FF",
    code_comment_highlight4 = "#FF6A27FF",
    cursor_line_highlight = "#1C2748FF",
    color_preview_title_bar = "#1C2748FF",
    code_addition = "#33B333FF",
    code_deletion = "#E64D4DFF",
    region_addition = "#2260224C",
    region_deletion = "#7722224C",

    -- Scope nesting cycle — palette-tinted lifts above #141824 (deep blue-grey)
    back_cycle = {
        "#1c1828", -- purple
        "#16201c", -- mossy green
        "#161a30", -- blue (focus's signature hue)
        "#241e18", -- amber
        "#241828", -- pink
        "#162228", -- cyan
        "#1e1e16", -- olive
        "#181828", -- violet
    },
}

-- Strip alpha channel from all colors (Neovim expects 6-char hex, not 8-char with alpha)
for key, value in pairs(colors) do
    if type(value) == "string" and value:match("^#%x%x%x%x%x%x%x%x$") then
        colors[key] = value:sub(1, 7) -- Keep only #RRGGBB
    end
end

colors.none = "NONE"

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "focus"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal", { fg = colors.code_default, bg = colors.background0 })
set(0, "NormalNC", { fg = colors.code_default, bg = colors.background1 })
set(0, "NormalFloat", { fg = colors.code_default, bg = colors.background1 })
set(0, "FloatBorder", { fg = colors.splitter, bg = colors.background1 })
set(0, "FloatTitle", { fg = colors.text_input_label, bg = colors.color_preview_title_bar })
set(0, "WinSeparator", { fg = colors.splitter })
set(0, "VertSplit", { fg = colors.splitter })
set(0, "StatusLine", { fg = colors.background0, bg = colors.ui_default })
set(0, "StatusLineNC", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "TabLine", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "TabLineSel", { fg = colors.background0, bg = colors.ui_default })
set(0, "TabLineFill", { fg = colors.ui_dim, bg = colors.background1 })
set(0, "LineNr", { fg = colors.ui_dim, bg = colors.background0 })
set(0, "CursorLineNr", { fg = colors.code_default, bg = colors.background0 })
set(0, "SignColumn", { fg = colors.ui_dim, bg = colors.background0 })
set(0, "CursorColumn", { bg = colors.background2 })
set(0, "CursorLine", { bg = colors.cursor_line_highlight })
set(0, "Cursor", { fg = colors.char_under_cursor, bg = colors.cursor })
set(0, "TermCursor", { fg = colors.char_under_cursor, bg = colors.cursor })
set(0, "TermCursorNC", { fg = colors.char_under_cursor, bg = colors.cursor_inactive })
set(0, "Visual", { bg = colors.selection_active })
set(0, "VisualNOS", { bg = colors.selection_inactive, fg = colors.code_default })
set(0, "Search", { fg = colors.background0, bg = colors.search_result_active })
set(0, "IncSearch", { fg = colors.char_under_cursor, bg = colors.cursor })
set(0, "CurSearch", { fg = colors.char_under_cursor, bg = colors.cursor })
set(0, "Substitute", { link = "IncSearch" })
set(0, "MatchParen", { fg = colors.background0, bg = colors.bracket_highlight })
set(0, "ColorColumn", { bg = colors.background2 })
set(0, "Folded", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "FoldColumn", { fg = colors.ui_dim, bg = colors.background0 })
set(0, "EndOfBuffer", { fg = colors.background0 })
set(0, "NonText", { fg = colors.shadow_dark })
set(0, "Whitespace", { fg = colors.indent_guide })
set(0, "SpecialKey", { fg = colors.indent_guide })
set(0, "QuickFixLine", { fg = colors.code_default, bg = colors.list_cursor })
set(0, "qfLineNr", { fg = colors.ui_warning })
set(0, "Directory", { fg = colors.ui_default })
set(0, "Title", { fg = colors.text_input_label })
set(0, "Question", { fg = colors.ui_success })
set(0, "MoreMsg", { fg = colors.ui_default })
set(0, "ModeMsg", { fg = colors.ui_default })
set(0, "WarningMsg", { fg = colors.ui_warning })
set(0, "ErrorMsg", { fg = colors.white })
set(0, "Pmenu", { fg = colors.code_default, bg = colors.background2 })
set(0, "PmenuSel", { fg = colors.background0, bg = colors.selection_highlight })
set(0, "PmenuSbar", { bg = colors.scrollbar_background })
set(0, "PmenuThumb", { bg = colors.scrollbar })
set(0, "WildMenu", { fg = colors.background0, bg = colors.selection_active })
set(0, "CursorLineFold", { bg = colors.cursor_line_highlight })
set(0, "CursorLineSign", { bg = colors.cursor_line_highlight })
set(0, "ColorSchemePreview", { fg = colors.code_default, bg = colors.color_preview_title_bar })
set(0, "WinBar", { fg = colors.text_input_label, bg = colors.background1 })
set(0, "WinBarNC", { fg = colors.ui_dim, bg = colors.background1 })

-- Syntax
set(0, "Comment", { fg = colors.code_comment })
set(0, "SpecialComment", { fg = colors.code_comment_highlight1 })
set(0, "Todo", { fg = colors.ui_warning, bg = colors.background2 })
set(0, "String", { fg = colors.code_string_literal })
set(0, "Character", { fg = colors.code_char_literal })
set(0, "Number", { fg = colors.code_number })
set(0, "Float", { fg = colors.code_number })
set(0, "Boolean", { fg = colors.code_value })
set(0, "Constant", { fg = colors.code_value })
set(0, "Identifier", { fg = colors.code_identifier })
set(0, "Function", { fg = colors.code_function })
set(0, "Statement", { fg = colors.code_keyword })
set(0, "Operator", { fg = colors.code_operation })
set(0, "Keyword", { fg = colors.code_keyword })
set(0, "Type", { fg = colors.code_type })
set(0, "Structure", { fg = colors.code_type })
set(0, "StorageClass", { fg = colors.code_modifier })
set(0, "PreProc", { fg = colors.code_directive })
set(0, "Include", { fg = colors.code_directive })
set(0, "Define", { fg = colors.code_macro })
set(0, "Macro", { fg = colors.code_macro })
set(0, "PreCondit", { fg = colors.code_directive_modifier })
set(0, "Conditional", { fg = colors.code_keyword })
set(0, "Repeat", { fg = colors.code_keyword })
set(0, "Label", { fg = colors.code_note })
set(0, "Special", { fg = colors.code_note })
set(0, "Delimiter", { fg = colors.code_punctuation })
set(0, "Underlined", { underline = true })
set(0, "Bold", { bold = true })
set(0, "Italic", { italic = true })
set(0, "Error", { fg = colors.code_error })

-- Treesitter and semantic tokens
set(0, "@comment", { link = "Comment" })
set(0, "@comment.todo", { fg = colors.ui_warning, bg = colors.background2 })
set(0, "@comment.error", { fg = colors.ui_error })
set(0, "@punctuation", { link = "Delimiter" })
set(0, "@punctuation.bracket", { link = "Delimiter" })
set(0, "@punctuation.special", { fg = colors.code_punctuation })
set(0, "@string", { link = "String" })
set(0, "@string.regex", { fg = colors.code_string_literal })
set(0, "@string.escape", { fg = colors.code_modifier })
set(0, "@character", { link = "Character" })
set(0, "@character.special", { fg = colors.code_note })
set(0, "@number", { link = "Number" })
set(0, "@number.float", { link = "Float" })
set(0, "@float", { link = "Float" })
set(0, "@boolean", { link = "Boolean" })
set(0, "@constant", { link = "Constant" })
set(0, "@constant.builtin", { fg = colors.code_builtin_variable })
set(0, "@constant.macro", { fg = colors.code_macro })
set(0, "@type", { link = "Type" })
set(0, "@type.builtin", { fg = colors.code_type })
set(0, "@type.definition", { fg = colors.code_type, bold = true })
set(0, "@type.qualifier", { fg = colors.code_modifier })
set(0, "@attribute", { fg = colors.code_attribute })
set(0, "@variable", { fg = colors.code_identifier })
set(0, "@variable.builtin", { fg = colors.code_builtin_variable })
set(0, "@variable.parameter", { fg = colors.code_identifier, italic = true })
set(0, "@variable.jai", { link = "@variable" })
set(0, "@field", { fg = colors.code_identifier })
set(0, "@property", { fg = colors.code_identifier })
set(0, "@parameter", { fg = colors.code_identifier, italic = true })
set(0, "@parameter.reference", { fg = colors.code_identifier })
set(0, "@function", { link = "Function" })
set(0, "@function.call", { fg = colors.code_function })
set(0, "@function.definition", { fg = colors.code_function, bold = true })
set(0, "@function.builtin", { fg = colors.code_builtin_function })
set(0, "@function.macro", { fg = colors.code_macro })
set(0, "@method", { link = "Function" })
set(0, "@module", { fg = colors.code_directive })
set(0, "@constructor", { fg = colors.code_enum_variant })
set(0, "@keyword", { link = "Keyword" })
set(0, "@keyword.function", { fg = colors.code_keyword })
set(0, "@keyword.operator", { fg = colors.code_operation })
set(0, "@keyword.return", { fg = colors.code_keyword, bold = true })
set(0, "@keyword.conditional", { link = "Keyword" })
set(0, "@keyword.repeat", { link = "Keyword" })
set(0, "@keyword.import", { fg = colors.code_directive })
set(0, "@keyword.directive", { fg = colors.code_directive })
set(0, "@keyword.modifier", { fg = colors.code_modifier })
set(0, "@operator", { link = "Operator" })
set(0, "@tag", { fg = colors.code_header })
set(0, "@tag.attribute", { fg = colors.code_attribute })
set(0, "@tag.delimiter", { fg = colors.code_punctuation })

-- Jai-specific
set(0, "@keyword.jai", { fg = colors.code_keyword })
set(0, "@storageclass.jai", { fg = colors.code_modifier })
set(0, "@function.jai", { fg = colors.code_function })
set(0, "@function.call.jai", { fg = colors.code_function })
set(0, "@operator.jai", { fg = colors.code_operation })
set(0, "@punctuation.special.jai", { fg = colors.code_operation })
set(0, "@punctuation.delimiter.jai", { fg = colors.code_operation })
set(0, "@variable.builtin.jai", { fg = colors.code_builtin_variable })
set(0, "@constant.builtin.jai", { fg = colors.code_builtin_variable })

-- LSP
set(0, "LspReferenceText", { bg = colors.selection_highlight })
set(0, "LspReferenceRead", { bg = colors.selection_highlight })
set(0, "LspReferenceWrite", { bg = colors.selection_highlight })
set(0, "LspSignatureActiveParameter", { fg = colors.code_default, bg = colors.selection_active, bold = true })
set(0, "LspInlayHint", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "LspCodeLens", { fg = colors.ui_dim })
set(0, "LspCodeLensSeparator", { fg = colors.ui_dim })

-- Diagnostics
set(0, "DiagnosticError", { fg = colors.ui_error })
set(0, "DiagnosticWarn", { fg = colors.ui_warning })
set(0, "DiagnosticInfo", { fg = colors.ui_default })
set(0, "DiagnosticHint", { fg = colors.ui_dim })
set(0, "DiagnosticOk", { fg = colors.ui_success })
set(0, "DiagnosticVirtualTextError", { fg = "#ff6b6b", bold = true })
set(0, "DiagnosticVirtualTextWarn", { fg = "#000000", bg = "#fabd2f", bold = true })
set(0, "DiagnosticVirtualTextInfo", { fg = "#000000", bg = "#83a598" })
set(0, "DiagnosticVirtualTextHint", { fg = "#000000", bg = "#8ec07c" })
set(0, "DiagnosticVirtualTextOk", { fg = colors.ui_success, bg = colors.region_addition })
set(0, "DiagnosticUnderlineError", { undercurl = true, sp = colors.ui_error_bright })
set(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = colors.ui_warning })
set(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = colors.ui_default })
set(0, "DiagnosticUnderlineHint", { undercurl = true, sp = colors.ui_dim })
set(0, "DiagnosticUnderlineOk", { undercurl = true, sp = colors.ui_success })
set(0, "DiagnosticSignError", { fg = colors.ui_error, bg = colors.background0 })
set(0, "DiagnosticSignWarn", { fg = colors.ui_warning, bg = colors.background0 })
set(0, "DiagnosticSignInfo", { fg = colors.ui_default, bg = colors.background0 })
set(0, "DiagnosticSignHint", { fg = colors.ui_dim, bg = colors.background0 })
set(0, "DiagnosticSignOk", { fg = colors.ui_success, bg = colors.background0 })

-- Diff & Git
set(0, "DiffAdd", { fg = colors.ui_success, bg = colors.region_addition })
set(0, "DiffDelete", { fg = colors.ui_error, bg = colors.region_deletion })
set(0, "DiffChange", { fg = colors.ui_warning, bg = colors.search_result_inactive })
set(0, "DiffText", { fg = colors.background0, bg = colors.code_highlight })
set(0, "DiffAdded", { fg = colors.ui_success })
set(0, "DiffRemoved", { fg = colors.ui_error })
set(0, "DiffChanged", { fg = colors.ui_warning })
set(0, "GitSignsAdd", { fg = colors.code_addition })
set(0, "GitSignsChange", { fg = colors.code_highlight })
set(0, "GitSignsDelete", { fg = colors.code_deletion })
set(0, "GitSignsCurrentLineBlame", { fg = colors.ui_dim })

-- Spell checking
set(0, "SpellBad", { undercurl = true, sp = colors.ui_error })
set(0, "SpellCap", { undercurl = true, sp = colors.ui_warning })
set(0, "SpellLocal", { undercurl = true, sp = colors.ui_success })
set(0, "SpellRare", { undercurl = true, sp = colors.code_note })

-- Telescope
set(0, "TelescopeNormal", { fg = colors.code_default, bg = colors.background0 })
set(0, "TelescopeBorder", { fg = colors.splitter, bg = colors.background0 })
set(0, "TelescopeSelection", { fg = "#000000", bg = "#61afef", bold = true })
set(0, "TelescopeSelectionCaret", { fg = "#ffffff", bg = "#61afef", bold = true })
set(0, "TelescopeMultiSelection", { fg = "#000000", bg = "#98c379" })
set(0, "TelescopeMatching", { fg = colors.code_highlight })
set(0, "TelescopeTitle", { fg = colors.text_input_label })

-- Trouble / build panel style integrations
set(0, "TroubleNormal", { fg = colors.code_default, bg = colors.build_panel_background })
set(0, "TroubleNormalNC", { fg = colors.code_default, bg = colors.build_panel_background })
set(0, "TroubleFoldIcon", { fg = colors.ui_dim })
set(0, "TroubleIndent", { fg = colors.indent_guide })
set(0, "TroubleText", { fg = colors.code_default })
set(0, "TroubleCount", { fg = colors.ui_warning })
set(0, "TroubleFile", { fg = colors.code_identifier })
set(0, "TroubleLocation", { fg = colors.ui_dim })
set(0, "TroublePreview", { fg = colors.code_default, bg = colors.background2 })

-- Which-key & cmp UI helpers
set(0, "WhichKey", { fg = colors.ui_default })
set(0, "WhichKeyGroup", { fg = colors.code_note })
set(0, "WhichKeyDesc", { fg = colors.code_identifier })
set(0, "WhichKeySeparator", { fg = colors.ui_dim })
set(0, "WhichKeyFloat", { bg = colors.background1 })
set(0, "CmpItemAbbr", { fg = colors.code_default })
set(0, "CmpItemAbbrMatch", { fg = colors.code_highlight })
set(0, "CmpItemAbbrMatchFuzzy", { fg = colors.code_highlight })
set(0, "CmpItemMenu", { fg = colors.ui_dim })
set(0, "CmpItemKind", { fg = colors.ui_default })
set(0, "CmpItemKindFunction", { fg = colors.code_builtin_function })
set(0, "CmpItemKindMethod", { fg = colors.code_builtin_function })
set(0, "CmpItemKindVariable", { fg = colors.code_identifier })
set(0, "CmpItemKindField", { fg = colors.code_identifier })
set(0, "CmpItemKindProperty", { fg = colors.code_identifier })
set(0, "CmpItemKindValue", { fg = colors.code_value })
set(0, "CmpItemKindEnum", { fg = colors.code_enum_variant })
set(0, "CmpItemKindEnumMember", { fg = colors.code_enum_variant })
set(0, "CmpItemKindKeyword", { fg = colors.code_keyword })
set(0, "CmpItemKindText", { fg = colors.code_comment })
set(0, "CmpItemKindClass", { fg = colors.code_type })
set(0, "CmpItemKindInterface", { fg = colors.code_type })
set(0, "CmpItemKindModule", { fg = colors.code_directive })
set(0, "CmpItemKindSnippet", { fg = colors.code_note })
set(0, "CmpItemKindColor", { fg = colors.code_highlight })
set(0, "CmpItemKindFile", { fg = colors.code_identifier })
set(0, "CmpItemKindFolder", { fg = colors.code_identifier })
set(0, "CmpItemKindReference", { fg = colors.code_note })

-- Indent guides
set(0, "IndentBlanklineChar", { fg = colors.indent_guide })
set(0, "IndentBlanklineContextChar", { fg = colors.code_highlight })
set(0, "IblIndent", { fg = colors.indent_guide })
set(0, "IblWhitespace", { fg = colors.indent_guide })
set(0, "IblScope", { fg = colors.code_highlight })

-- Illuminated word / references
set(0, "IlluminatedWordText", { bg = colors.selection_highlight })
set(0, "IlluminatedWordRead", { bg = colors.selection_highlight })
set(0, "IlluminatedWordWrite", { bg = colors.selection_highlight })

-- Elext / lexical scope groups
set(0, "FocusRegionScopeExport", { fg = colors.code_note, bg = colors.region_scope_export })
set(0, "FocusRegionScopeFile", { fg = colors.code_identifier, bg = colors.region_scope_file })
set(0, "FocusRegionScopeModule", { fg = colors.code_identifier, bg = colors.region_scope_module })
set(0, "FocusRegionHeader", { fg = colors.region_header, bold = true })
set(0, "FocusRegionSuccess", { fg = colors.region_success })
set(0, "FocusRegionWarning", { fg = colors.region_warning })
set(0, "FocusRegionError", { fg = colors.region_error })
set(0, "FocusRegionHeredoc", { fg = colors.region_heredoc })
set(0, "FocusRegionAddition", { fg = colors.ui_success, bg = colors.region_addition })
set(0, "FocusRegionDeletion", { fg = colors.ui_error, bg = colors.region_deletion })
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

-- Nested scope background cycle (consumed by hh.lua's scope highlighter)
for i, bg in ipairs(colors.back_cycle) do
    set(0, "HHScope" .. i, { bg = bg })
end

return colors
