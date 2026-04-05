-- JBN colorscheme - jblow-nostalgia (Emacs) ported to Neovim
-- Based on https://github.com/Prikaz98/jblow-nostalgia
-- Dark background (#292929), white keywords, yellow comments, warm tan text
local M = {}

local colors = {
    -- Core backgrounds
    background0 = "#0e0e0e",
    background1 = "#181818",
    background2 = "#1f1f1f",
    background3 = "#1f1f1f",
    selection_active = "#0000FF",
    selection_inactive = "#0000FF80",
    selection_highlight = "#4a4a6a",
    search_result_active = "#4a4a6a",
    search_result_inactive = "#3a3a5a40",
    scrollbar = "#D3B58Da4",
    scrollbar_hover = "#D3B58DFF",
    scrollbar_background = "#2929294C",
    cursor = "#FFFFFF",
    cursor_inactive = "#FFFFFF80",
    paste_animation = "#D89B754C",
    splitter = "#D3B58D",
    letter_highlight = "#FFFFFF",
    list_cursor_lite = "#D3B58D19",
    list_cursor = "#D3B58Da4",
    shadow_dark = "#29292933",

    -- UI colors
    ui_default = "#D3B58D",
    ui_dim = "#D3B58D65",
    ui_neutral = "#4C4C4C",
    ui_warning = "#E4D97D",
    ui_warning_dim = "#986032",
    ui_error = "#772222",
    ui_error_bright = "#FF0000",
    ui_success = "#A9ECB6",

    -- Region colors
    region_scope = "#303030",
    region_success = "#226022",
    region_warning = "#986032",
    region_error = "#772222",
    region_heredoc = "#2a2a35",

    -- Code colors - matched to Emacs jblow-nostalgia
    code_default = "#B89B73",       -- text: warm tan (darkened)
    code_comment = "#FFFF00",       -- comments: yellow
    code_type = "#98FB98",          -- type: pale green
    code_function = "#FFFFFF",      -- functions: white
    code_punctuation = "#D3B58D",   -- punctuation: tan
    code_operation = "#D3B58D",     -- operators: tan
    code_string_literal = "#BEBEBE", -- strings: gray
    code_value = "#BFC9DB",         -- constants: light blue-gray
    code_highlight = "#D3B58D",
    code_error = "#FF0000",
    code_keyword = "#FFFFFF",       -- keywords: white
    code_warning = "#E4D97D",
    code_invalid = "#FF0000",
    code_identifier = "#D3B58D",    -- variables: tan (Emacs uses #BFC9DB for var names, tan for use)
    code_variable_name = "#BFC9DB", -- variable declarations
    code_note = "#D3B58D",
    code_number = "#D699B5",        -- numbers: pink
    code_multiline_comment = "#FFFF00",
    code_modifier = "#FFFFFF",      -- storage class: white
    code_attribute = "#D3B58D",
    code_enum_variant = "#BFC9DB",
    code_macro = "#E67D74",         -- macros/preprocessor: coral red
    code_builtin_variable = "#BFC9DB",
    code_builtin_function = "#FFFFFF",
    code_builtin_exception = "#D3B58D",
    code_directive = "#E67D74",     -- preprocessor: coral red
    code_directive_modifier = "#E67D74",

    -- Line numbers
    line_fg = "#126367",

    -- Cursor line
    cursor_line_highlight = "#1a1a1a",

    -- Scope background cycle colors - neutral grays, closer to black
    back_cycle = {
        "#101010", -- Level 1
        "#111111", -- Level 2
        "#131313", -- Level 3
        "#141414", -- Level 4
        "#161616", -- Level 5
        "#171717", -- Level 6
        "#191919", -- Level 7
        "#1a1a1a", -- Level 8
    },

    -- Diff
    code_addition = "#A9ECB6",
    code_deletion = "#E64D4D",
    region_addition = "#2260224C",
    region_deletion = "#7722224C",

    -- Extra
    yellow = "#EFFF18",
    orange = "#FD971F",
    indent_guide = "#D3B58D26",
    build_panel_background = "#0e0e0e",
}

-- Strip alpha channel from all colors (Neovim expects 6-char hex, not 8-char with alpha)
for key, value in pairs(colors) do
    if type(value) == "string" and value:match("^#%x%x%x%x%x%x%x%x$") then
        colors[key] = value:sub(1, 7)
    end
end

colors.none = "NONE"

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "jbn"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal", { fg = colors.code_default, bg = colors.background0 })
set(0, "NormalNC", { fg = colors.code_default, bg = colors.background0 })
set(0, "NormalFloat", { fg = colors.code_default, bg = colors.background1 })
set(0, "FloatBorder", { fg = colors.splitter, bg = colors.background1 })
set(0, "FloatTitle", { fg = colors.code_default, bg = colors.background1 })
set(0, "WinSeparator", { fg = colors.splitter })
set(0, "VertSplit", { fg = colors.splitter })
set(0, "StatusLine", { fg = colors.background0, bg = colors.ui_default })
set(0, "StatusLineNC", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "TabLine", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "TabLineSel", { fg = colors.background0, bg = colors.ui_default })
set(0, "TabLineFill", { fg = colors.ui_dim, bg = colors.background1 })
set(0, "LineNr", { fg = colors.line_fg, bg = colors.background0 })
set(0, "CursorLineNr", { fg = "#FFFFFF", bg = colors.background0 })
set(0, "SignColumn", { fg = colors.ui_dim, bg = colors.background0 })
set(0, "CursorColumn", { bg = colors.background2 })
set(0, "CursorLine", { bg = colors.cursor_line_highlight })
set(0, "Visual", { bg = colors.selection_active })
set(0, "VisualNOS", { bg = colors.selection_inactive, fg = colors.code_default })
set(0, "Search", { fg = colors.background0, bg = colors.search_result_active })
set(0, "IncSearch", { fg = colors.background0, bg = colors.search_result_active })
set(0, "CurSearch", { fg = colors.background0, bg = colors.search_result_active })
set(0, "MatchParen", { fg = colors.background0, bg = colors.code_highlight })
set(0, "ColorColumn", { bg = colors.background2 })
set(0, "Folded", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "FoldColumn", { fg = colors.ui_dim, bg = colors.background0 })
set(0, "EndOfBuffer", { fg = colors.background0 })
set(0, "NonText", { fg = colors.shadow_dark })
set(0, "Whitespace", { fg = colors.indent_guide })
set(0, "SpecialKey", { fg = colors.indent_guide })
set(0, "QuickFixLine", { fg = colors.code_default, bg = colors.selection_highlight })
set(0, "qfLineNr", { fg = colors.ui_warning })
set(0, "Directory", { fg = colors.ui_default })
set(0, "Title", { fg = colors.code_default })
set(0, "Question", { fg = colors.ui_success })
set(0, "MoreMsg", { fg = colors.ui_default })
set(0, "ModeMsg", { fg = colors.ui_default })
set(0, "WarningMsg", { fg = colors.ui_warning })
set(0, "ErrorMsg", { fg = colors.ui_error_bright })
set(0, "Pmenu", { fg = colors.code_default, bg = colors.background2 })
set(0, "PmenuSel", { fg = colors.background0, bg = colors.selection_highlight })
set(0, "PmenuSbar", { bg = colors.scrollbar_background })
set(0, "PmenuThumb", { bg = colors.scrollbar })
set(0, "PmenuExtra", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "PmenuExtraSel", { fg = colors.ui_dim, bg = colors.selection_highlight })
set(0, "WildMenu", { fg = colors.background0, bg = colors.selection_active })
set(0, "CursorLineFold", { bg = colors.cursor_line_highlight })
set(0, "CursorLineSign", { bg = colors.cursor_line_highlight })
set(0, "WinBar", { fg = colors.code_default, bg = colors.background1 })
set(0, "WinBarNC", { fg = colors.ui_dim, bg = colors.background1 })

-- Syntax
set(0, "Comment", { fg = colors.code_comment })
set(0, "SpecialComment", { fg = colors.code_comment })
set(0, "Todo", { fg = colors.ui_warning, bg = colors.background2 })
set(0, "String", { fg = colors.code_string_literal })
set(0, "Character", { fg = colors.code_string_literal })
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
set(0, "Structure", { fg = colors.code_keyword })
set(0, "StorageClass", { fg = colors.code_modifier })
set(0, "PreProc", { fg = colors.code_directive })
set(0, "Include", { fg = colors.code_directive })
set(0, "Define", { fg = colors.code_macro })
set(0, "Macro", { fg = colors.code_macro })
set(0, "PreCondit", { fg = colors.code_directive_modifier })
set(0, "Conditional", { fg = colors.code_keyword })
set(0, "Repeat", { fg = colors.code_keyword })
set(0, "Label", { fg = colors.code_keyword })
set(0, "Special", { fg = colors.code_string_literal })
set(0, "Delimiter", { fg = colors.code_punctuation })
set(0, "Underlined", { underline = true })
set(0, "Bold", {})
set(0, "Italic", {})
set(0, "Error", { fg = colors.code_error })

-- Treesitter
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
set(0, "@type.definition", { fg = colors.code_type })
set(0, "@type.qualifier", { fg = colors.code_modifier })
set(0, "@attribute", { fg = colors.code_attribute })
set(0, "@variable", { fg = colors.code_identifier })
set(0, "@variable.builtin", { fg = colors.code_builtin_variable })
set(0, "@variable.parameter", { fg = colors.code_identifier })
set(0, "@variable.jai", { link = "@variable" })
set(0, "@field", { fg = colors.code_identifier })
set(0, "@property", { fg = colors.code_identifier })
set(0, "@parameter", { fg = colors.code_identifier })
set(0, "@parameter.reference", { fg = colors.code_identifier })
set(0, "@function", { link = "Function" })
set(0, "@function.call", { fg = colors.code_default })
set(0, "@function.definition", { fg = colors.code_function })
set(0, "@function.builtin", { fg = colors.code_builtin_function })
set(0, "@function.macro", { fg = colors.code_macro })
set(0, "@method", { link = "Function" })
set(0, "@module", { fg = colors.code_directive })
set(0, "@constructor", { fg = colors.code_enum_variant })
set(0, "@keyword", { link = "Keyword" })
set(0, "@keyword.function", { link = "Keyword" })
set(0, "@keyword.operator", { link = "Keyword" })
set(0, "@keyword.return", { link = "Keyword" })
set(0, "@keyword.conditional", { link = "Keyword" })
set(0, "@keyword.repeat", { link = "Keyword" })
set(0, "@keyword.import", { link = "Keyword" })
set(0, "@keyword.import.c", { fg = colors.code_directive })
set(0, "@keyword.directive", { fg = colors.code_directive })
set(0, "@keyword.directive.define", { fg = colors.code_directive })
set(0, "@keyword.modifier", { fg = colors.code_modifier })
set(0, "@operator", { link = "Operator" })
set(0, "@tag", { fg = colors.code_keyword })
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
set(0, "LspSignatureActiveParameter", { fg = colors.code_default, bg = colors.selection_active })
set(0, "LspInlayHint", { fg = colors.ui_dim, bg = colors.background2 })
set(0, "LspCodeLens", { fg = colors.ui_dim })
set(0, "LspCodeLensSeparator", { fg = colors.ui_dim })

-- LSP semantic tokens
set(0, "@lsp.type.class", { fg = colors.code_type })
set(0, "@lsp.type.enum", { fg = colors.code_type })
set(0, "@lsp.type.enumMember", { fg = colors.code_enum_variant })
set(0, "@lsp.type.function", { link = "Function" })
set(0, "@lsp.type.interface", { fg = colors.code_type })
set(0, "@lsp.type.macro", { fg = colors.code_macro })
set(0, "@lsp.type.method", { link = "Function" })
set(0, "@lsp.type.namespace", { fg = colors.code_type })
set(0, "@lsp.type.parameter", { fg = colors.code_identifier })
set(0, "@lsp.type.property", { fg = colors.code_identifier })
set(0, "@lsp.type.struct", { fg = colors.code_type })
set(0, "@lsp.type.type", { fg = colors.code_type })
set(0, "@lsp.type.typeParameter", { fg = colors.code_type })
set(0, "@lsp.type.variable", { fg = colors.code_identifier })
set(0, "@lsp.typemod.enumMember", { fg = colors.code_enum_variant })
set(0, "@lsp.typemod.enumMember.declaration", { fg = colors.code_enum_variant })
set(0, "@lsp.typemod.enumMember.readonly", { fg = colors.code_enum_variant })

-- Diagnostics
set(0, "DiagnosticError", { fg = colors.ui_error })
set(0, "DiagnosticWarn", { fg = colors.ui_warning })
set(0, "DiagnosticInfo", { fg = colors.ui_default })
set(0, "DiagnosticHint", { fg = colors.ui_dim })
set(0, "DiagnosticOk", { fg = colors.ui_success })
set(0, "DiagnosticVirtualTextError", { fg = colors.ui_error })
set(0, "DiagnosticVirtualTextWarn", { fg = colors.ui_warning, bg = colors.region_warning })
set(0, "DiagnosticVirtualTextInfo", { fg = colors.ui_default, bg = colors.background2 })
set(0, "DiagnosticVirtualTextHint", { fg = colors.ui_dim, bg = colors.background2 })
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
set(0, "TelescopeSelection", { fg = colors.code_keyword, bg = colors.selection_active })
set(0, "TelescopeSelectionCaret", { fg = colors.ui_success })
set(0, "TelescopeMatching", { fg = colors.code_highlight })
set(0, "TelescopeTitle", { fg = colors.code_default })

-- Trouble
set(0, "TroubleNormal", { fg = colors.code_default, bg = colors.build_panel_background })
set(0, "TroubleNormalNC", { fg = colors.code_default, bg = colors.build_panel_background })
set(0, "TroubleFoldIcon", { fg = colors.ui_dim })
set(0, "TroubleIndent", { fg = colors.indent_guide })
set(0, "TroubleText", { fg = colors.code_default })
set(0, "TroubleCount", { fg = colors.ui_warning })
set(0, "TroubleFile", { fg = colors.code_identifier })
set(0, "TroubleLocation", { fg = colors.ui_dim })
set(0, "TroublePreview", { fg = colors.code_default, bg = colors.background2 })

-- Which-key & cmp
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

-- Illuminated word
set(0, "IlluminatedWordText", { bg = colors.selection_highlight })
set(0, "IlluminatedWordRead", { bg = colors.selection_highlight })
set(0, "IlluminatedWordWrite", { bg = colors.selection_highlight })

-- Rainbow delimiters (from Emacs theme)
set(0, "rainbowcol1", { fg = "#AE81FF" })  -- violet
set(0, "rainbowcol2", { fg = "#7FEFD1" })  -- blue/teal
set(0, "rainbowcol3", { fg = "#A9ECB6" })  -- green
set(0, "rainbowcol4", { fg = "#EFFF18" })  -- yellow
set(0, "rainbowcol5", { fg = "#FD971F" })  -- orange
set(0, "rainbowcol6", { fg = "#F92672" })  -- red

-- Scope highlight groups for nested scope backgrounds
for i, bg in ipairs(colors.back_cycle) do
    set(0, "JBNScope" .. i, { bg = bg })
end

-- Export colors
M.colors = colors

-- Scope highlight namespace
local scope_ns = vim.api.nvim_create_namespace("jbn_scope_highlight")

-- Cache for scope data per buffer
local scope_cache = {}

-- Scope queries for different languages
local scope_queries = {
    c = [[
        (compound_statement) @scope
    ]],
    cpp = [[
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

-- Parse all scopes in a buffer
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

    local query
    local success = pcall(function()
        query = vim.treesitter.query.parse(lang, query_string)
    end)

    if not success or not query then
        return nil
    end

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

-- Apply scope highlights
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
        local hl_group = "JBNScope" .. cycle_idx

        for line = scope.start_row, scope.end_row do
            vim.api.nvim_buf_set_extmark(bufnr, scope_ns, line, 0, {
                line_hl_group = hl_group,
                priority = 100 - depth,
            })
        end
    end
end

-- Mark buffer scopes as dirty
local function mark_dirty(bufnr)
    if scope_cache[bufnr] then
        scope_cache[bufnr].dirty = true
    end
end

-- Debounce timer per buffer
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

-- Enable scope highlighting for a buffer
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

    local group = vim.api.nvim_create_augroup("JBNScopeHighlight" .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = function()
            debounced_highlight(bufnr)
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

-- Disable scope highlighting for a buffer
function M.disable_scope_highlight(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
    pcall(vim.api.nvim_del_augroup_by_name, "JBNScopeHighlight" .. bufnr)
    scope_cache[bufnr] = nil
    if debounce_timers[bufnr] then
        debounce_timers[bufnr]:stop()
        debounce_timers[bufnr]:close()
        debounce_timers[bufnr] = nil
    end
end

-- Auto-enable for supported filetypes
function M.setup_scope_highlight()
    local group = vim.api.nvim_create_augroup("JBNScopeSetup", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "c", "cpp", "jai", "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(ev)
            vim.schedule(function()
                M.enable_scope_highlight(ev.buf)
            end)
        end,
    })

    local ft = vim.bo.filetype
    if ft == "c" or ft == "cpp" or ft == "jai" or ft == "lua" or ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
        vim.schedule(function()
            M.enable_scope_highlight(vim.api.nvim_get_current_buf())
        end)
    end
end

-- Store module globally
vim.g.jbn_theme = M

-- Enable scope highlighting
M.setup_scope_highlight()

return M
