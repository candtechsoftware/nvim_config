local colors = {
    -- Core UI colors (from 4coder Fleury theme)
    bar                   = "#000000",        -- defcolor_bar
    base                  = "#fcaa05",        -- defcolor_base: amber-gold
    pop1                  = "#de8150",        -- defcolor_pop1
    pop2                  = "#FF0000",        -- defcolor_pop2
    back                  = "#020202",        -- defcolor_back: rich-black
    margin                = "#222425",        -- defcolor_margin: dark-slate
    margin_hover          = "#63523d",        -- defcolor_margin_hover: coffee-brown
    margin_active         = "#63523d",        -- defcolor_margin_active: coffee-brown
    list_item             = "#222425",        -- defcolor_list_item
    list_item_hover       = "#362e25",        -- defcolor_list_item_hover
    list_item_active      = "#63523d",        -- defcolor_list_item_active
    cursor                = "#00EE00",        -- defcolor_cursor[0]: bright green
    cursor_alt1           = "#e0741b",        -- defcolor_cursor[1]
    cursor_alt2           = "#1be094",        -- defcolor_cursor[2]
    cursor_alt3           = "#ba60c4",        -- defcolor_cursor[3]
    at_cursor             = "#0C0C0C",        -- defcolor_at_cursor
    highlight_cursor_line = "#1E1E1E",        -- defcolor_highlight_cursor_line
    highlight             = "#303040",        -- defcolor_highlight: gunmetal-blue
    at_highlight          = "#FF44DD",        -- defcolor_at_highlight
    mark                  = "#494949",        -- defcolor_mark

    -- Text colors (from 4coder Fleury theme)
    text_default          = "#b99468",        -- defcolor_text_default: light-bronze
    comment               = "#666666",        -- defcolor_comment: dim-gray
    comment_pop           = "#2ab34f",        -- defcolor_comment_pop[0]: green
    comment_pop_alt       = "#db2828",        -- defcolor_comment_pop[1]: red
    keyword               = "#f0c674",        -- defcolor_keyword: goldenrod
    str_constant          = "#ffa900",        -- defcolor_str_constant: bright-orange
    char_constant         = "#ffa900",        -- defcolor_char_constant
    int_constant          = "#ffa900",        -- defcolor_int_constant
    float_constant        = "#ffa900",        -- defcolor_float_constant
    bool_constant         = "#ffa900",        -- defcolor_bool_constant
    preproc               = "#dc7575",        -- defcolor_preproc: dusty-rose
    include               = "#ffa900",        -- defcolor_include: bright-orange
    special_character     = "#FF0000",        -- defcolor_special_character
    ghost_character       = "#4E5E46",        -- defcolor_ghost_character
    highlight_junk        = "#3A0000",        -- defcolor_highlight_junk
    highlight_white       = "#003A3A",        -- defcolor_highlight_white
    paste                 = "#DDEE00",        -- defcolor_paste
    undo                  = "#00DDEE",        -- defcolor_undo
    line_numbers_back     = "#101010",        -- defcolor_line_numbers_back
    line_numbers_text     = "#404040",        -- defcolor_line_numbers_text

    -- Fleury theme specific colors
    syntax_crap           = "#5c4d3c",        -- fleury_color_syntax_crap
    operators             = "#bd2d2d",        -- fleury_color_operators
    inactive_pane_overlay = "#44000000",      -- fleury_color_inactive_pane_overlay
    inactive_pane_background = "#000000",     -- fleury_color_inactive_pane_background
    file_progress_bar     = "#634323",        -- fleury_color_file_progress_bar
    brace_highlight       = "#8ffff2",        -- fleury_color_brace_highlight: aqua-ice
    brace_line            = "#9ba290",        -- fleury_color_brace_line: dusty-sage
    brace_annotation      = "#9ba290",        -- fleury_color_brace_annotation
    index_product_type    = "#edb211",        -- fleury_color_index_product_type: sunflower-yellow
    index_sum_type        = "#a7eb13",        -- fleury_color_index_sum_type
    index_function        = "#de451f",        -- fleury_color_index_function: burnt-orange
    index_macro           = "#2895c7",        -- fleury_color_index_macro: sky-blue
    index_constant        = "#6eb535",        -- fleury_color_index_constant: green
    index_comment_tag     = "#ffae00",        -- fleury_color_index_comment_tag
    index_decl            = "#c9598a",        -- fleury_color_index_decl
    cursor_macro          = "#de2368",        -- fleury_color_cursor_macro
    cursor_power_mode     = "#efaf2f",        -- fleury_color_cursor_power_mode
    cursor_inactive       = "#880000",        -- fleury_color_cursor_inactive
    plot_cycle1           = "#03d3fc",        -- fleury_color_plot_cycle[0]
    plot_cycle2           = "#22b80b",        -- fleury_color_plot_cycle[1]
    plot_cycle3           = "#f0bb0c",        -- fleury_color_plot_cycle[2]
    plot_cycle4           = "#f0500c",        -- fleury_color_plot_cycle[3]
    token_highlight       = "#f2d357",        -- fleury_color_token_highlight
    token_minor_highlight = "#d19045",        -- fleury_color_token_minor_highlight
    error_annotation      = "#ff0000",        -- fleury_color_error_annotation
    lego_grab             = "#efaf6f",        -- fleury_color_lego_grab
    lego_splat            = "#efaaef",        -- fleury_color_lego_splat
    comment_user_name     = "#ffdd23",        -- fleury_color_comment_user_name

    -- Legacy mappings for compatibility
    yellow     = "#f0c674",        -- goldenrod
    orange     = "#de451f",        -- burnt-orange
    red        = "#ff0000",        -- bright-red
    magenta    = "#FF44DD",
    blue       = "#2895c7",        -- sky-blue
    green      = "#6eb535",        -- fresh-green
    cyan       = "#8ffff2",        -- aqua-ice
    violet     = "#ba60c4",
    white      = "#b99468",        -- light-bronze
    error      = "#ff0000",        -- bright-red
    warning    = "#ffa900",        -- bright-orange

    -- Scope background cycle colors (defcolor_back_cycle)
    -- Mostly same as back, with red tint progression at higher levels
    back_cycle = {
        "#020202",  -- Level 1: same as back
        "#020202",  -- Level 2: same
        "#020202",  -- Level 3: same
        "#020202",  -- Level 4: same
        "#020202",  -- Level 5: same
        "#020202",  -- Level 6: same
        "#020202",  -- Level 7: same
        "#100202",  -- Level 8: slight red
        "#300202",  -- Level 9: more red
        "#500202",  -- Level 10: even more red
        "#700202",  -- Level 11: deep red
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
set(0, "MatchParen",       { fg = colors.base, bg = colors.margin_active, bold = true, underline = true })

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

-- Lualine integration
set(0, "StatusLine",        { fg = colors.back, bg = colors.text_default })
set(0, "StatusLineNC",      { fg = colors.comment, bg = colors.margin })

-- Treesitter highlights
set(0, "@comment",        { link = "Comment" })
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
set(0, "@variable.parameter", { fg = colors.text_default, italic = true })
set(0, "@variable.jai",  { link = "Identifier" })
set(0, "@parameter",      { fg = colors.text_default, italic = true })

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
set(0, "@punctuation.special", { fg = colors.operators })

-- Constructors
set(0, "@constructor",    { link = "Type" })

-- Language-specific overrides
set(0, "@keyword.lua",        { fg = colors.keyword })
set(0, "@keyword.jai",        { fg = colors.keyword })
set(0, "@keyword.type",       { fg = colors.keyword })
set(0, "@storageclass",       { fg = colors.keyword })
set(0, "@storageclass.jai",   { fg = colors.keyword })

-- Jai syntax highlighting overrides
set(0, "jaiStruct",           { fg = colors.keyword })
set(0, "jaiUnion",            { fg = colors.keyword })
set(0, "jaiEnum",             { fg = colors.keyword })
set(0, "jaiConstant",         { fg = colors.blue })

-- C syntax highlighting overrides
set(0, "@keyword.type.c",     { fg = colors.keyword })
set(0, "@type.builtin.c",     { fg = colors.keyword })

-- C macro highlights
set(0, "@lsp.type.macro.c",   { fg = colors.blue })

-- C function highlights (LSP semantic tokens)
set(0, "@lsp.type.function.c", { link = "Function" })
set(0, "@lsp.mod.globalScope.c", {})
set(0, "@lsp.typemod.function.globalScope.c", { link = "Function" })
set(0, "@lsp.mod.fileScope.c", {})
set(0, "@lsp.typemod.function.fileScope.c", { link = "Function" })

-- C enum member highlights (LSP semantic tokens)
set(0, "@lsp.type.enumMember.c", { fg = colors.blue })
set(0, "@lsp.mod.readonly.c", {})
set(0, "@lsp.typemod.enumMember.fileScope.c", { fg = colors.blue })
set(0, "@lsp.typemod.enumMember.readonly.c", { fg = colors.blue })

-- C++ Treesitter highlights
set(0, "@variable.cpp", { fg = colors.blue })
set(0, "@function.call.cpp", { fg = colors.blue })
set(0, "@constructor.cpp", { fg = colors.blue })

-- C++ Semantic Tokens
set(0, "@lsp.type.macro.cpp", { fg = colors.blue })
set(0, "@lsp.mod.globalScope.cpp", { fg = colors.blue })
set(0, "@lsp.typemod.macro.globalScope.cpp", { fg = colors.blue })

-- Scope highlight groups for nested scope backgrounds (like 4coder back_cycle)
for i, bg in ipairs(colors.back_cycle) do
    set(0, "CandScope" .. i, { bg = bg })
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

-- Store module globally so it can be accessed after colorscheme load
vim.g.cand_theme = M

-- Enable scope highlighting with optimized debouncing
M.setup_scope_highlight()

return M
