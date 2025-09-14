local colors = {
    -- Core UI colors
    bar                   = "#000000",
    base                  = "#fcaa05",
    pop1                  = "#de8150",
    pop2                  = "#FF0000",
    back                  = "#101010",
    margin                = "#222425",
    margin_hover          = "#63523d",
    margin_active         = "#63523d",
    cursor                = "#00EE00",
    cursor_alt1           = "#e0741b",
    cursor_alt2           = "#1be094",
    cursor_alt3           = "#ba60c4",
    at_cursor             = "#0C0C0C",
    highlight_cursor_line = "#1E1E1E",
    highlight             = "#303040",
    at_highlight          = "#FF44DD",
    mark                  = "#494949",
    
    -- Text colors
    text_default          = "#b99468",
    comment               = "#666666",
    comment_pop           = "#2ab34f",
    comment_pop_alt       = "#db2828",
    keyword               = "#f0c674",
    str_constant          = "#ffa900",
    char_constant         = "#ffa900",
    int_constant          = "#ffa900",
    float_constant        = "#ffa900",
    bool_constant         = "#ffa900",
    preproc               = "#dc7575",
    include               = "#ffa900",
    special_character     = "#FF0000",
    ghost_character       = "#4E5E46",
    highlight_junk        = "#3A0000",
    highlight_white       = "#003A3A",
    paste                 = "#DDEE00",
    undo                  = "#00DDEE",
    line_numbers_back     = "#101010",
    line_numbers_text     = "#404040",
    
    -- Fleury theme specific colors
    syntax_crap           = "#5c4d3c",
    operators             = "#bd2d2d",
    inactive_pane_overlay = "#44000000",
    inactive_pane_background = "#000000",
    file_progress_bar     = "#634323",
    brace_highlight       = "#8ffff2",
    brace_line            = "#9ba290",
    brace_annotation      = "#9ba290",
    index_product_type    = "#edb211",
    index_sum_type        = "#a7eb13",
    index_function        = "#de451f",
    index_macro           = "#66D9EF",
    index_constant        = "#6eb535",
    index_comment_tag     = "#ffae00",
    index_decl            = "#c9598a",
    cursor_macro          = "#de2368",
    cursor_power_mode     = "#efaf2f",
    cursor_inactive       = "#880000",
    plot_cycle1           = "#03d3fc",
    plot_cycle2           = "#22b80b",
    plot_cycle3           = "#f0bb0c",
    plot_cycle4           = "#f0500c",
    token_highlight       = "#f2d357",
    token_minor_highlight = "#d19045",
    error_annotation      = "#ff0000",
    lego_grab             = "#efaf6f",
    lego_splat            = "#efaaef",
    comment_user_name     = "#ffdd23",
    
    -- Legacy mappings for compatibility
    yellow     = "#f0c674",
    orange     = "#de8150",
    red        = "#FF0000",
    magenta    = "#FF44DD",
    blue       = "#66D9EF",
    green      = "#a7eb13",
    cyan       = "#8ffff2",
    violet     = "#ba60c4",
    white      = "#b99468",
    error      = "#ff0000",
    warning    = "#ffa900",
}

vim.cmd("highlight clear")
vim.o.background = "dark"
vim.g.colors_name = "cand"

local set = vim.api.nvim_set_hl

-- Core UI
set(0, "Normal",           { fg = colors.text_default, bg = colors.back })
set(0, "Cursor",           { fg = colors.at_cursor, bg = colors.cursor })
set(0, "Visual",           { bg = colors.highlight })
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
set(0, "jaiEnum",             { fg = colors.keyword })

return colors
