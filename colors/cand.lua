local colors = {
    -- Core UI colors (from Fleury theme)
    bar                   = "#000000",
    base                  = "#fcaa05",        -- amber-gold
    pop1                  = "#de8150",
    pop2                  = "#FF0000",
    back                  = "#020202",        -- rich-black
    margin                = "#222425",        -- dark-slate
    margin_hover          = "#63523d",        -- coffee-brown
    margin_active         = "#63523d",        -- coffee-brown
    cursor                = "#66bc11",        -- fresh-green (from Fleury)
    cursor_alt1           = "#e0741b",
    cursor_alt2           = "#1be094",
    cursor_alt3           = "#ba60c4",
    at_cursor             = "#0C0C0C",
    highlight_cursor_line = "#1e1e1e",        -- charcoal-gray-lite
    highlight             = "#303040",        -- gunmetal-blue
    at_highlight          = "#FF44DD",
    mark                  = "#494949",
    
    -- Text colors (from Fleury theme)
    text_default          = "#b99468",        -- light-bronze
    comment               = "#666666",        -- dim-gray
    comment_pop           = "#66bc11",        -- fresh-green
    comment_pop_alt       = "#db2828",
    keyword               = "#f0c674",        -- goldenrod
    str_constant          = "#ffaa00",        -- bright-orange
    char_constant         = "#ffaa00",        -- bright-orange
    int_constant          = "#ffaa00",        -- bright-orange
    float_constant        = "#ffaa00",        -- bright-orange
    bool_constant         = "#ffaa00",        -- bright-orange
    preproc               = "#dc7575",        -- dusty-rose
    include               = "#ffaa00",        -- bright-orange
    special_character     = "#FF0000",
    ghost_character       = "#4E5E46",
    highlight_junk        = "#3A0000",
    highlight_white       = "#003939",        -- lime-green (for region)
    paste                 = "#DDEE00",
    undo                  = "#00DDEE",
    line_numbers_back     = "#020202",        -- rich-black
    line_numbers_text     = "#404040",        -- medium-gray
    
    -- Fleury theme specific colors
    syntax_crap           = "#5c4d3c",
    operators             = "#bd2d2d",
    inactive_pane_overlay = "#44000000",
    inactive_pane_background = "#000000",
    file_progress_bar     = "#634323",
    brace_highlight       = "#8ffff2",        -- aqua-ice
    brace_line            = "#9ba290",        -- dusty-sage
    brace_annotation      = "#9ba290",        -- dusty-sage
    index_product_type    = "#edb211",        -- sunflower-yellow
    index_sum_type        = "#a7eb13",
    index_function        = "#de451f",        -- burnt-orange
    index_macro           = "#2895c7",        -- sky-blue (from Fleury)
    index_constant        = "#66bc11",        -- fresh-green
    index_comment_tag     = "#ffaa00",        -- bright-orange
    index_decl            = "#c9598a",
    cursor_macro          = "#de2368",
    cursor_power_mode     = "#efaf2f",
    cursor_inactive       = "#880000",
    plot_cycle1           = "#03d3fc",
    plot_cycle2           = "#22b80b",
    plot_cycle3           = "#f0bb0c",        -- golden-yellow
    plot_cycle4           = "#f0500c",        -- vivid-vermilion
    token_highlight       = "#f2d357",
    token_minor_highlight = "#d19045",
    error_annotation      = "#ff0000",        -- bright-red
    lego_grab             = "#efaf6f",
    lego_splat            = "#efaaef",
    comment_user_name     = "#ffdd23",
    
    -- Legacy mappings for compatibility (Fleury palette)
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
set(0, "MatchParen",       { bg = colors.brace_highlight })

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
set(0, "NormalFloat",       { fg = colors.text_default, bg = colors.margin })
set(0, "FloatBorder",       { fg = colors.margin_hover, bg = colors.margin })
set(0, "FloatTitle",        { fg = colors.base, bg = colors.margin })
set(0, "Pmenu",            { fg = colors.text_default, bg = colors.margin })
set(0, "PmenuSel",         { fg = colors.base, bg = colors.margin_active })
set(0, "PmenuSbar",        { bg = colors.margin })
set(0, "PmenuThumb",       { bg = colors.margin_hover })
set(0, "WinSeparator",     { fg = colors.margin })
set(0, "Winseparator",     { fg = colors.margin })

-- NetRW
set(0, "netrwCursorLine",  { bg = colors.highlight })
set(0, "netrwDir",         { fg = colors.index_sum_type })

-- Lazy.nvim interface
set(0, "LazyNormal",        { fg = colors.text_default, bg = colors.margin })
set(0, "LazyBorder",        { fg = colors.margin_hover, bg = colors.margin })
set(0, "LazyTitle",         { fg = colors.base, bg = colors.margin })
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
set(0, "@number",         { link = "Number" })
set(0, "@boolean",        { link = "Boolean" })
set(0, "@constant",       { link = "Constant" })
set(0, "@function",       { link = "Function" })
set(0, "@function.builtin", { link = "Function" })
set(0, "@variable",       { link = "Identifier" })
set(0, "@variable.builtin", { link = "Type" })
set(0, "@constant.builtin", { link = "Type" })
set(0, "@type",           { link = "Type" })
set(0, "@type.builtin",   { link = "Type" })
set(0, "@keyword",        { link = "Keyword" })
set(0, "@keyword.function", { link = "Keyword" })
set(0, "@punctuation.special", { fg = colors.function_ })
set(0, "@field",          { link = "Identifier" })
set(0, "@property",       { link = "Identifier" })
set(0, "@parameter",      { link = "Identifier" })
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

return colors
