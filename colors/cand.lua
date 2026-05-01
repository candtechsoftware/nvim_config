local colors = {
    -- Core UI colors (from fleury-theme.el)
    bar                   = "#000000",        -- pure-black
    base                  = "#fcaa05",        -- amber-gold
    pop1                  = "#de8150",        -- pop1
    pop2                  = "#FF0000",        -- pop2
    back                  = "#020202",        -- rich-black
    margin                = "#222425",        -- dark-slate
    margin_hover          = "#63523d",        -- coffee-brown
    margin_active         = "#63523d",        -- coffee-brown
    list_item             = "#222425",        -- dark-slate
    list_item_hover       = "#362e25",        -- list hover
    list_item_active      = "#63523d",        -- coffee-brown
    cursor                = "#00EE00",        -- bright green
    cursor_alt1           = "#e0741b",        -- cursor alt
    cursor_alt2           = "#1be094",        -- cursor alt
    cursor_alt3           = "#ba60c4",        -- cursor alt
    at_cursor             = "#000000",        -- pure-black (fleury isearch fg)
    highlight_cursor_line = "#1e1e1e",        -- charcoal-gray-lite
    highlight             = "#303040",        -- gunmetal-blue
    at_highlight          = "#000000",        -- pure-black (fleury match fg)
    mark                  = "#494949",        -- mark
    paren_match_bg        = "#2f2f38",        -- sky-blue-lite (fleury show-paren-match)
    paren_mismatch_bg     = "#9ba290",        -- dusty-sage (fleury show-paren-mismatch)
    tooltip_bg            = "#63523d",        -- coffee-brown (fleury tooltip)
    mode_line_fg          = "#e7aa4d",        -- fleury mode-line-foreground-active
    mode_line_bg          = "#1a120b",        -- fleury mode-line-background-active
    mode_line_border      = "#161616",        -- fleury mode-line-border

    -- Text colors (from fleury-theme.el)
    text_default          = "#b99468",        -- light-bronze
    comment               = "#666666",        -- dim-gray
    comment_pop           = "#2ab34f",        -- comment pop green
    comment_pop_alt       = "#db2828",        -- comment pop red
    keyword               = "#f0c674",        -- goldenrod
    str_constant          = "#ffaa00",        -- bright-orange
    char_constant         = "#ffaa00",        -- bright-orange
    int_constant          = "#ffaa00",        -- bright-orange
    float_constant        = "#ffaa00",        -- bright-orange
    bool_constant         = "#ffaa00",        -- bright-orange
    preproc               = "#dc7575",        -- dusty-rose
    include               = "#ffaa00",        -- bright-orange
    special_character     = "#ff0000",        -- bright-red
    ghost_character       = "#4E5E46",        -- ghost
    highlight_junk        = "#3A0000",        -- junk
    highlight_white       = "#003939",        -- lime-green (fleury region)
    doc_face              = "#66bc11",        -- fresh-green (fleury font-lock-doc-face)
    golden_yellow         = "#f0bb0c",        -- golden-yellow (fleury match/lazy-highlight)
    vivid_vermilion       = "#f0500c",        -- vivid-vermilion (fleury isearch)
    paste                 = "#DDEE00",        -- paste
    undo                  = "#00DDEE",        -- undo
    line_numbers_back     = "#101010",        -- line numbers bg
    line_numbers_text     = "#404040",        -- medium-gray

    -- Fleury theme specific colors
    syntax_crap           = "#5c4d3c",        -- fleury syntax crap
    operators             = "#bd2d2d",        -- fleury operators
    inactive_pane_overlay = "#44000000",      -- inactive pane overlay
    inactive_pane_background = "#000000",     -- inactive pane bg
    file_progress_bar     = "#634323",        -- file progress bar
    brace_highlight       = "#8ffff2",        -- aqua-ice
    brace_line            = "#9ba290",        -- dusty-sage
    brace_annotation      = "#9ba290",        -- dusty-sage
    index_product_type    = "#edb211",        -- sunflower-yellow
    index_sum_type        = "#a7eb13",        -- sum type
    index_function        = "#de451f",        -- burnt-orange
    index_macro           = "#2895c7",        -- sky-blue
    index_constant        = "#6eb535",        -- fresh-green
    index_comment_tag     = "#ffae00",        -- comment tag
    index_decl            = "#c9598a",        -- decl
    cursor_macro          = "#de2368",        -- cursor macro
    cursor_power_mode     = "#efaf2f",        -- cursor power mode
    cursor_inactive       = "#880000",        -- cursor inactive
    plot_cycle1           = "#03d3fc",        -- plot cycle
    plot_cycle2           = "#22b80b",        -- plot cycle
    plot_cycle3           = "#f0bb0c",        -- plot cycle
    plot_cycle4           = "#f0500c",        -- plot cycle
    token_highlight       = "#f2d357",        -- token highlight
    token_minor_highlight = "#d19045",        -- token minor highlight
    error_annotation      = "#ff0000",        -- error annotation
    lego_grab             = "#efaf6f",        -- lego grab
    lego_splat            = "#efaaef",        -- lego splat
    comment_user_name     = "#ffdd23",        -- comment user name

    -- Legacy mappings
    yellow     = "#f0c674",        -- goldenrod
    orange     = "#de451f",        -- burnt-orange
    red        = "#ff0000",        -- bright-red
    magenta    = "#FF44DD",
    blue       = "#2895c7",        -- sky-blue
    green      = "#66bc11",        -- fresh-green
    cyan       = "#8ffff2",        -- aqua-ice
    violet     = "#ba60c4",
    white      = "#b99468",        -- light-bronze
    error      = "#ff0000",        -- bright-red
    warning    = "#ffaa00",        -- bright-orange

    -- Scope background cycle colors — subtle palette-tinted lifts above #020202
    -- Hues lean toward cand's amber/rose/sky-blue accents
    back_cycle = {
        "#0c040d",  -- purple
        "#040c05",  -- green
        "#04060e",  -- blue (sky-blue lean)
        "#0e0a02",  -- amber (signature gold)
        "#0e040a",  -- pink/rose
        "#040d0e",  -- cyan (aqua-ice)
        "#0a0a04",  -- olive
        "#050310",  -- violet
    },
}

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "cand"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal",           { fg = colors.text_default, bg = colors.back })
set(0, "Cursor",           { fg = colors.at_cursor, bg = colors.cursor })
set(0, "Visual",           { bg = colors.highlight_white })
set(0, "LineNr",           { fg = colors.line_numbers_text, bg = colors.line_numbers_back })
set(0, "CursorLineNr",     { fg = colors.text_default, bg = colors.line_numbers_back })
set(0, "CursorLine",       { bg = colors.highlight_cursor_line })
set(0, "ColorColumn",      { bg = colors.margin })
set(0, "VertSplit",        { fg = colors.margin })
set(0, "MatchParen",       { bg = colors.paren_match_bg })
set(0, "Search",           { fg = colors.at_highlight, bg = colors.golden_yellow })
set(0, "IncSearch",        { fg = colors.at_cursor, bg = colors.vivid_vermilion })
set(0, "CurSearch",        { fg = colors.at_cursor, bg = colors.vivid_vermilion })
set(0, "Substitute",       { fg = colors.back, bg = colors.paste })

-- Syntax
set(0, "Comment",          { fg = colors.comment })
set(0, "String",           { fg = colors.str_constant })
set(0, "Character",        { fg = colors.char_constant })
set(0, "Number",           { fg = colors.int_constant })
set(0, "Float",            { fg = colors.float_constant })
set(0, "Boolean",          { fg = colors.bool_constant })
set(0, "Constant",         { fg = colors.index_constant })
set(0, "Identifier",       { fg = colors.text_default })
set(0, "Function",         { fg = colors.index_function })
set(0, "Statement",        { fg = colors.keyword })
set(0, "Keyword",          { fg = colors.keyword })
set(0, "Type",             { fg = colors.index_product_type })
set(0, "PreProc",          { fg = colors.preproc })
set(0, "Include",          { fg = colors.include })
set(0, "Special",          { fg = colors.special_character })
set(0, "Operator",         { fg = colors.operators })
set(0, "WarningMsg",       { fg = colors.warning })
set(0, "Error",            { fg = colors.error_annotation })

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
set(0, "NormalFloat",       { fg = colors.text_default, bg = colors.list_item })
set(0, "FloatBorder",       { fg = colors.margin_hover, bg = colors.list_item })
set(0, "FloatTitle",        { fg = colors.base, bg = colors.list_item })
-- Tooltip (fleury tooltip face: coffee-brown bg, amber-gold fg)
set(0, "Tooltip",           { fg = colors.base, bg = colors.tooltip_bg })
set(0, "Pmenu",            { fg = colors.text_default, bg = colors.list_item })
set(0, "PmenuSel",         { fg = colors.base, bg = colors.list_item_active })
set(0, "PmenuSbar",        { bg = colors.list_item })
set(0, "PmenuThumb",       { bg = colors.list_item_hover })
set(0, "WinSeparator",     { fg = colors.margin })
set(0, "Winseparator",     { fg = colors.margin })

-- NetRW
set(0, "netrwCursorLine",  { bg = colors.highlight })
set(0, "netrwDir",         { fg = colors.blue })
set(0, "netrwExe",         { fg = colors.orange })

-- Lazy.nvim interface
set(0, "LazyNormal",        { fg = colors.text_default, bg = colors.list_item })
set(0, "LazyBorder",        { fg = colors.margin_hover, bg = colors.list_item })
set(0, "LazyTitle",         { fg = colors.base, bg = colors.list_item })
set(0, "LazyButton",        { fg = colors.text_default, bg = colors.highlight })
set(0, "LazyButtonActive", { fg = colors.base, bg = colors.margin_active })
set(0, "LazyH1",            { fg = colors.base })
set(0, "LazyH2",            { fg = colors.cyan })
set(0, "LazyComment",       { fg = colors.comment })
set(0, "LazyCommit",        { fg = colors.green })
set(0, "LazyCommitIssue",   { fg = colors.red })
set(0, "LazyCommitScope",   { fg = colors.blue })
set(0, "LazyCommitType",    { fg = colors.yellow })
set(0, "LazyDimmed",        { fg = colors.comment })
set(0, "LazyDir",           { fg = colors.cyan })
set(0, "LazyProgressDone",  { fg = colors.green })
set(0, "LazyProgressTodo",  { fg = colors.comment })
set(0, "LazyProp",          { fg = colors.index_decl })
set(0, "LazyReasonCmd",     { fg = colors.orange })
set(0, "LazyReasonEvent",   { fg = colors.yellow })
set(0, "LazyReasonFt",      { fg = colors.magenta })
set(0, "LazyReasonImport",  { fg = colors.violet })
set(0, "LazyReasonKeys",    { fg = colors.blue })
set(0, "LazyReasonPlugin",  { fg = colors.green })
set(0, "LazyReasonRuntime", { fg = colors.cyan })
set(0, "LazyReasonSource",  { fg = colors.red })
set(0, "LazyReasonStart",   { fg = colors.base })
set(0, "LazySpecial",       { fg = colors.index_function })
set(0, "LazyTaskError",     { fg = colors.error_annotation })
set(0, "LazyTaskOutput",    { fg = colors.text_default })
set(0, "LazyUrl",           { fg = colors.cyan })
set(0, "LazyValue",         { fg = colors.index_constant })

-- Lualine integration (fleury mode-line)
set(0, "StatusLine",        { fg = colors.mode_line_fg, bg = colors.mode_line_bg })
set(0, "StatusLineNC",      { fg = colors.mode_line_fg, bg = colors.back })

-- Treesitter highlights
set(0, "@comment",        { link = "Comment" })
set(0, "@comment.documentation", { fg = colors.doc_face })
set(0, "@string.documentation",  { fg = colors.doc_face })
set(0, "@string",         { link = "String" })
set(0, "@string.escape",  { fg = colors.special_character })
set(0, "@character",      { fg = colors.char_constant })
set(0, "@number",         { link = "Number" })
set(0, "@number.float",   { fg = colors.float_constant })
set(0, "@boolean",        { link = "Boolean" })
set(0, "@constant",       { link = "Constant" })
set(0, "@constant.builtin", { fg = colors.index_constant })

-- Functions
set(0, "@function",       { link = "Function" })
set(0, "@function.builtin", { link = "Function" })
set(0, "@function.call",  { fg = colors.index_function })
set(0, "@function.definition", { fg = colors.index_function, bold = true })
set(0, "@function.macro", { fg = colors.index_macro })

-- Variables
set(0, "@variable",       { link = "Identifier" })
set(0, "@variable.builtin", { fg = colors.index_constant })
set(0, "@variable.parameter", { fg = colors.text_default })
set(0, "@variable.jai",  { link = "Identifier" })
set(0, "@parameter",      { fg = colors.text_default })

-- Types
set(0, "@type",           { link = "Type" })
set(0, "@type.builtin",   { link = "Type" })
set(0, "@type.definition", { fg = colors.index_product_type, bold = true })

-- Keywords
set(0, "@keyword",        { link = "Keyword" })
set(0, "@keyword.function", { link = "Keyword" })
set(0, "@keyword.return", { fg = colors.keyword, bold = true })
set(0, "@keyword.conditional", { link = "Keyword" })
set(0, "@keyword.repeat", { link = "Keyword" })
set(0, "@keyword.import", { fg = colors.include })
set(0, "@keyword.directive", { fg = colors.preproc })
set(0, "@keyword.modifier", { link = "Keyword" })

-- Attributes & Macros
set(0, "@attribute",      { fg = colors.index_comment_tag })
set(0, "@module",         { fg = colors.include })

-- Fields & Properties
set(0, "@field",          { link = "Identifier" })
set(0, "@property",       { fg = colors.text_default })

-- Punctuation
set(0, "@punctuation.bracket",  { fg = colors.syntax_crap })
set(0, "@punctuation.delimiter", { fg = colors.syntax_crap })
set(0, "@punctuation.special", { fg = colors.operators })

-- Constructors
set(0, "@constructor",    { link = "Type" })

-- Language-specific overrides
set(0, "@keyword.lua",        { fg = colors.keyword })
set(0, "@keyword.type",       { fg = colors.keyword })
set(0, "@storageclass",       { fg = colors.keyword })

-- Jai treesitter highlights
set(0, "@keyword.jai",                  { fg = colors.keyword })
set(0, "@keyword.return.jai",           { fg = colors.keyword, bold = true })
set(0, "@keyword.conditional.jai",      { fg = colors.keyword })
set(0, "@keyword.conditional.ternary.jai", { fg = colors.keyword })
set(0, "@keyword.repeat.jai",           { fg = colors.keyword })
set(0, "@keyword.import.jai",           { fg = colors.include })
set(0, "@keyword.directive.jai",        { fg = colors.index_macro })
set(0, "@keyword.modifier.jai",         { fg = colors.keyword, italic = true })
set(0, "@storageclass.jai",             { fg = colors.keyword })
set(0, "@function.jai",                 { fg = colors.index_function, bold = true })
set(0, "@function.call.jai",            { fg = colors.index_function })
set(0, "@function.macro.jai",           { fg = colors.index_macro })
set(0, "@function.builtin.jai",         { fg = colors.index_function })
set(0, "@variable.jai",                 { fg = colors.text_default })
set(0, "@variable.builtin.jai",         { fg = colors.index_constant })
set(0, "@variable.parameter.jai",       { fg = colors.text_default })
set(0, "@type.jai",                     { fg = colors.index_product_type })
set(0, "@type.builtin.jai",             { fg = colors.index_product_type })
set(0, "@type.definition.jai",          { fg = colors.index_product_type, bold = true })
set(0, "@constant.jai",                 { fg = colors.index_constant })
set(0, "@constant.builtin.jai",         { fg = colors.index_constant })
set(0, "@property.jai",                 { fg = colors.text_default })
set(0, "@operator.jai",                 { fg = colors.operators })
set(0, "@attribute.jai",                { fg = colors.index_comment_tag })
set(0, "@module.jai",                   { fg = colors.include })
set(0, "@punctuation.bracket.jai",      { fg = colors.syntax_crap })
set(0, "@punctuation.delimiter.jai",    { fg = colors.syntax_crap })
set(0, "@string.jai",                   { fg = colors.str_constant })
set(0, "@string.escape.jai",            { fg = colors.special_character })
set(0, "@character.jai",                { fg = colors.char_constant })
set(0, "@number.jai",                   { fg = colors.int_constant })
set(0, "@number.float.jai",             { fg = colors.float_constant })
set(0, "@boolean.jai",                  { fg = colors.bool_constant })
set(0, "@comment.jai",                  { fg = colors.comment })

-- Jai vim syntax fallback highlights
set(0, "jaiStruct",                     { fg = colors.keyword })
set(0, "jaiUnion",                      { fg = colors.keyword })
set(0, "jaiEnum",                       { fg = colors.keyword })
set(0, "jaiFunction",                   { fg = colors.index_function, bold = true })
set(0, "jaiClass",                      { fg = colors.index_product_type })
set(0, "jaiDataType",                   { fg = colors.index_product_type })
set(0, "jaiConstant",                   { fg = colors.index_constant })
set(0, "jaiConstantDeclaration",        { fg = colors.index_constant })
set(0, "jaiVariableDeclaration",        { fg = colors.text_default })
set(0, "jaiForVariableDeclaration",     { fg = colors.text_default })
set(0, "jaiDirective",                  { fg = colors.index_macro })
set(0, "jaiTemplate",                   { fg = colors.cyan })
set(0, "jaiAutobake",                   { fg = colors.cyan })
set(0, "jaiTagNote",                    { fg = colors.index_comment_tag })
set(0, "jaiCommentNote",                { fg = colors.comment_pop })
set(0, "jaiIt",                         { fg = colors.index_constant })
set(0, "jaiCast",                       { fg = colors.keyword })
set(0, "jaiAutoCast",                   { fg = colors.keyword })
set(0, "jaiOperator",                   { fg = colors.operators })
set(0, "jaiNull",                       { fg = colors.index_constant })
set(0, "jaiSOA",                        { fg = colors.keyword, italic = true })
set(0, "jaiAOS",                        { fg = colors.keyword, italic = true })

-- C syntax highlighting overrides
set(0, "@keyword.type.c",     { fg = colors.keyword })
set(0, "@type.builtin.c",     { fg = colors.keyword })

-- C LSP semantic tokens
set(0, "@lsp.type.macro.c",   { fg = colors.index_macro })
set(0, "@lsp.type.function.c", { link = "Function" })
set(0, "@lsp.type.type.c",    { link = "Type" })
set(0, "@lsp.type.struct.c",  { link = "Type" })
set(0, "@lsp.type.enum.c",    { link = "Type" })
set(0, "@lsp.mod.globalScope.c", {})
set(0, "@lsp.typemod.function.globalScope.c", { link = "Function" })
set(0, "@lsp.mod.fileScope.c", {})
set(0, "@lsp.typemod.function.fileScope.c", { link = "Function" })

-- Enum member highlights (LSP semantic tokens)
set(0, "@lsp.type.enumMember", { fg = colors.index_constant })
set(0, "@lsp.typemod.enumMember", { fg = colors.index_constant })
set(0, "@lsp.typemod.enumMember.declaration", { fg = colors.index_constant })
set(0, "@lsp.typemod.enumMember.readonly", { fg = colors.index_constant })
set(0, "@lsp.type.enumMember.c", { fg = colors.index_constant })
set(0, "@lsp.mod.readonly.c", {})
set(0, "@lsp.typemod.enumMember.fileScope.c", { fg = colors.index_constant })
set(0, "@lsp.typemod.enumMember.readonly.c", { fg = colors.index_constant })

-- C++ syntax highlighting overrides
set(0, "@keyword.type.cpp",     { fg = colors.keyword })
set(0, "@type.builtin.cpp",     { fg = colors.keyword })

-- C++ Treesitter highlights (variable-use → sky-blue, matching fleury font-lock-variable-use-face)
set(0, "@variable.cpp", { fg = colors.blue })
set(0, "@function.call.cpp", { fg = colors.index_function })
set(0, "@constructor.cpp", { link = "Type" })

-- C++ LSP semantic tokens
set(0, "@lsp.type.macro.cpp", { fg = colors.index_macro })
set(0, "@lsp.type.function.cpp", { link = "Function" })
set(0, "@lsp.type.method.cpp",  { fg = colors.index_function })
set(0, "@lsp.type.type.cpp",    { link = "Type" })
set(0, "@lsp.type.class.cpp",   { link = "Type" })
set(0, "@lsp.type.struct.cpp",  { link = "Type" })
set(0, "@lsp.type.enum.cpp",    { link = "Type" })
set(0, "@lsp.type.namespace.cpp", { fg = colors.include })
set(0, "@lsp.type.typeParameter.cpp", { link = "Type" })
set(0, "@lsp.type.variable.cpp", { fg = colors.blue })
set(0, "@lsp.type.parameter.cpp", { fg = colors.text_default })
set(0, "@lsp.type.property.cpp", { fg = colors.text_default })
set(0, "@lsp.type.enumMember.cpp", { fg = colors.index_constant })
set(0, "@lsp.mod.globalScope.cpp", {})
set(0, "@lsp.typemod.macro.globalScope.cpp", { fg = colors.index_macro })

-- Yggdrasil/arc macro and type highlight groups
set(0, "YgKeyword", { fg = colors.index_macro })
set(0, "YgType", { fg = colors.index_product_type })

-- Scope highlight groups for nested scope backgrounds (like 4coder back_cycle)
for i, bg in ipairs(colors.back_cycle) do
    set(0, "CandScope" .. i, { bg = bg })
    set(0, "HHScope" .. i, { bg = bg })
end

-- Create module table for scope highlighting
local M = {}
M.colors = colors

-- Scope highlight namespace
local scope_ns = vim.api.nvim_create_namespace("cand_scope_highlight")

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

    local query
    local success = pcall(function()
        query = vim.treesitter.query.parse(lang, query_string)
    end)

    if not success or not query then
        return nil
    end

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
        local hl_group = "CandScope" .. cycle_idx

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

    local group = vim.api.nvim_create_augroup("CandScopeHighlight" .. bufnr, { clear = true })

    -- Cursor movement: debounced, uses cache
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = function()
            debounced_highlight(bufnr)
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
    pcall(vim.api.nvim_del_augroup_by_name, "CandScopeHighlight" .. bufnr)
    scope_cache[bufnr] = nil
    if debounce_timers[bufnr] then
        debounce_timers[bufnr]:stop()
        debounce_timers[bufnr]:close()
        debounce_timers[bufnr] = nil
    end
end

-- Auto-enable for supported filetypes
function M.setup_scope_highlight()
    local group = vim.api.nvim_create_augroup("CandScopeSetup", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "c", "cpp", "jai", "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
        callback = function(ev)
            vim.schedule(function()
                M.enable_scope_highlight(ev.buf)
            end)
        end,
    })

    -- Also enable for current buffer if it matches
    local ft = vim.bo.filetype
    if ft == "c" or ft == "cpp" or ft == "jai" or ft == "lua" or ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
        vim.schedule(function()
            M.enable_scope_highlight(vim.api.nvim_get_current_buf())
        end)
    end
end

-- Yggdrasil/arc macro highlighting for C/C++ (matchadd for priority over treesitter)
local yg_match_ids = {}

local function setup_yg_keywords()
    local winid = vim.api.nvim_get_current_win()
    if yg_match_ids[winid] then return end
    yg_match_ids[winid] = {}

    local function add_match(group, pattern)
        local id = vim.fn.matchadd(group, pattern, 100)
        table.insert(yg_match_ids[winid], id)
    end

    -- All yg/arc macros in one pattern (sky-blue)
    add_match("YgKeyword", "\\<\\(yg\\|arc\\)_\\(internal\\|inline\\|global\\|local_persist\\)\\>")

    -- All yg base types in one pattern (sunflower-yellow)
    add_match("YgType", "\\<\\([usb]\\(8\\|16\\|32\\|64\\)\\|f\\(32\\|64\\)\\|void\\|Vec[234]\\(F32\\|F64\\|S16\\|S32\\|S64\\)\\?\\|Mat[34]\\(F32\\)\\?\\|Quaternion\\(F32\\)\\?\\|Rng[12]\\(F32\\|U32\\|U64\\|S16\\|S32\\)\\?\\|Arena\\|Scratch\\|String8\\|R_Handle\\|Entity\\(Handle\\|Store\\|Pool\\|Kind\\|Flags\\)\\?\\|Direction8\\)\\>")

    -- Return type after yg/arc prefix macros (sunflower-yellow)
    add_match("YgType", "\\<\\(yg\\|arc\\)_\\(internal\\|inline\\)\\s\\+\\zs\\w\\+\\ze")

    -- Function declarations after yg/arc macros
    add_match("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(")
    add_match("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s*\\*\\s*\\zs\\w\\+\\ze\\s*(")
end

local yg_group = vim.api.nvim_create_augroup("CandYgKeywords", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = yg_group,
    pattern = { "c", "cpp", "objc", "objcpp" },
    callback = setup_yg_keywords,
})
vim.api.nvim_create_autocmd("WinEnter", {
    group = yg_group,
    callback = function()
        local ft = vim.bo.filetype
        if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
            setup_yg_keywords()
        end
    end,
})
vim.api.nvim_create_autocmd("WinClosed", {
    group = yg_group,
    callback = function(ev)
        local wid = tonumber(ev.match)
        if wid then yg_match_ids[wid] = nil end
    end,
})

-- Apply to current buffer if it's C/C++/ObjC
local ft = vim.bo.filetype
local ext = vim.fn.expand("%:e")
if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ext == "c" or ext == "h" or ext == "cpp" or ext == "hpp" or ext == "m" or ext == "mm" then
    setup_yg_keywords()
end

-- Store module globally so it can be accessed after colorscheme load
vim.g.cand_theme = M

-- Enable scope highlighting with optimized debouncing
M.setup_scope_highlight()

return M
