-- Candark colorscheme
-- Converted from 4coder theme

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "candark"

local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return {
        r = tonumber(hex:sub(1, 2), 16),
        g = tonumber(hex:sub(3, 4), 16),
        b = tonumber(hex:sub(5, 6), 16)
    }
end

local function to_hex(color)
    if type(color) == "number" then
        return string.format("#%06x", math.floor(color) % 0x1000000)
    end
    return color
end

-- Color definitions from new 4coder palette
local colors = {
    -- Main UI colors
    bar = to_hex(0x1f1f27),                    -- Status bar background
    base = to_hex(0xcb9401),                   -- Status bar text
    pop1 = to_hex(0x70971e),                  -- Prompts, search, goto
    pop2 = to_hex(0xcb9401),                  -- Annotations on list picker items
    back = to_hex(0x161616),                  -- Text area background
    margin = to_hex(0x0C0C0C),                -- Frame around inactive panel
    margin_hover = to_hex(0x00ff00),          -- Hover state
    margin_active = to_hex(0x0C0C0C),         -- Frame around list picker
    
    -- List picker colors
    list_item = "#000000",                     -- Background of list item
    list_item_hover = to_hex(0x171e20),       -- Mouse-hover background
    list_item_active = to_hex(0x2d3640),      -- Keyboard-hover background
    
    -- Cursor and highlighting
    cursor_green = to_hex(0x00EE00),          -- Primary cursor
    cursor_orange = to_hex(0xEE7700),         -- Secondary cursor
    at_cursor = to_hex(0x161616),             -- Text at cursor
    highlight_cursor_line = to_hex(0x1f1f27), -- Active line background
    highlight = to_hex(0x315268),             -- Active search background
    at_highlight = to_hex(0xc4b82b),          -- Active search text
    mark = to_hex(0x494949),                  -- Mark color
    
    -- Text colors
    text_default = to_hex(0xa08563),          -- Regular text
    comment = to_hex(0x686868),              -- Comment text
    comment_good = to_hex(0x00A000),         -- Good comment
    comment_bad = to_hex(0xA00000),          -- Bad comment
    keyword = to_hex(0xac7b0b),              -- Keyword text
    string = to_hex(0x6b8e23),              -- String constant
    number = to_hex(0x6b8e23),              -- Number constant
    boolean = to_hex(0x6b8e23),             -- Bool constant
    preproc = to_hex(0xdab98f),             -- Preprocessor
    include = to_hex(0xdab98f),             -- Include directive
    
    -- Special characters
    special_char = to_hex(0xff0000),         -- Special character
    ghost_char = to_hex(0x5b4d3c),          -- Ghost character
    highlight_junk = to_hex(0x3A0000),      -- Junk highlight
    highlight_white = to_hex(0x003A3A),     -- White highlight
    paste = to_hex(0xffbb00),               -- Paste color
    undo = to_hex(0x80005d),                -- Undo color
    
    -- Line numbers
    line_numbers_back = to_hex(0x101010),    -- Line number background
    line_numbers_text = to_hex(0x404040),    -- Line number text
    
    -- Text cycle colors
    text_cycle_1 = to_hex(0xc0a583),         -- Text cycle color 1
    text_cycle_2 = to_hex(0xb09573),         -- Text cycle color 2
    
    -- Fleury index colors
    type_color = to_hex(0xd8a51d),           -- Type identifiers
    function_color = to_hex(0xcc5735),       -- Function identifiers
    macro_color = to_hex(0x478980),          -- Macro identifiers
    coder_command = to_hex(0x23de33),        -- 4coder command
    
    -- Fleury syntax colors
    syntax_crap = to_hex(0x907553),          -- Braces, semicolons
    operators = to_hex(0x907553),            -- Operators
    brace_highlight = to_hex(0xb09573),      -- Brace highlighting
    brace_line = to_hex(0x9ba290) .. "30",   -- Brace lines
    brace_annotation = to_hex(0x9ba290) .. "60", -- Brace annotations
    
    -- Fleury additional colors
    cursor_macro = to_hex(0xde2368),         -- Macro recording cursor
    cursor_power = to_hex(0xefaf2f),         -- Power mode cursor
    token_highlight = to_hex(0x2f2f37),      -- Token highlight
    
    -- Plot cycle colors
    plot_cycle_1 = to_hex(0x03d3fc),         -- Plot color 1
    plot_cycle_2 = to_hex(0x22b80b),         -- Plot color 2
    plot_cycle_3 = to_hex(0xf0bb0c),         -- Plot color 3
    plot_cycle_4 = to_hex(0xf0500c),         -- Plot color 4
    
    -- Additional compatibility colors
    error_color = to_hex(0xff0000),          -- Error color
    none = "none",                           -- Transparent
}

-- Define highlight groups
local highlights = {
    -- UI Elements
    Normal = { fg = colors.text_default, bg = colors.back },
    NormalFloat = { fg = colors.text_default, bg = colors.margin },
    FloatBorder = { fg = colors.margin_hover, bg = colors.margin },
    Pmenu = { fg = colors.text_default, bg = colors.margin },
    PmenuSel = { fg = colors.text_default, bg = colors.margin_hover },
    PmenuSbar = { bg = colors.margin },
    PmenuThumb = { bg = colors.margin_hover },
    
    -- Cursor and selection
    Cursor = { fg = colors.at_cursor, bg = colors.cursor_green },
    CursorLine = { bg = colors.highlight_cursor_line },
    CursorColumn = { bg = colors.highlight_cursor_line },
    Visual = { bg = colors.highlight },
    VisualNOS = { bg = colors.highlight },
    
    -- Line numbers
    LineNr = { fg = colors.line_numbers_text, bg = colors.line_numbers_back },
    CursorLineNr = { fg = colors.base, bg = colors.line_numbers_back },
    
    -- Search and highlighting
    Search = { fg = colors.at_highlight, bg = colors.highlight },
    IncSearch = { fg = colors.at_highlight, bg = colors.highlight },
    MatchParen = { fg = colors.brace_highlight, bold = true },
    
    -- Syntax highlighting
    Comment = { fg = colors.comment, italic = true },
    Constant = { fg = colors.string },
    String = { fg = colors.string },
    Character = { fg = colors.string },
    Number = { fg = colors.number },
    Boolean = { fg = colors.boolean },
    Float = { fg = colors.number },
    
    Identifier = { fg = colors.text_default },
    Function = { fg = colors.function_color },
    
    Statement = { fg = colors.keyword },
    Conditional = { fg = colors.keyword },
    Repeat = { fg = colors.keyword },
    Label = { fg = colors.keyword },
    Operator = { fg = colors.operators },
    Keyword = { fg = colors.keyword },
    Exception = { fg = colors.keyword },
    
    PreProc = { fg = colors.preproc },
    Include = { fg = colors.include },
    Define = { fg = colors.macro_color },
    Macro = { fg = colors.macro_color },
    PreCondit = { fg = colors.preproc },
    
    -- Use type color for types
    Type = { fg = colors.type_color },
    StorageClass = { fg = colors.macro_color },
    Structure = { fg = colors.type_color },
    Typedef = { fg = colors.type_color },
    
    Special = { fg = colors.special_char },
    SpecialChar = { fg = colors.special_char },
    Tag = { fg = colors.keyword },
    Delimiter = { fg = colors.operators },
    SpecialComment = { fg = colors.keyword },
    Debug = { fg = colors.error_color },
    
    -- Error and warning
    Error = { fg = colors.error_color },
    ErrorMsg = { fg = colors.error_color },
    WarningMsg = { fg = colors.comment_bad },
    
    -- Status line
    StatusLine = { fg = colors.text_default, bg = colors.margin },
    StatusLineNC = { fg = colors.comment, bg = colors.margin },
    
    -- Tabs
    TabLine = { fg = colors.comment, bg = colors.margin },
    TabLineFill = { bg = colors.back },
    TabLineSel = { fg = colors.text_default, bg = colors.back },
    
    -- Vertical split
    VertSplit = { fg = colors.margin },
    WinSeparator = { fg = colors.margin },
    
    -- Folding
    Folded = { fg = colors.comment, bg = colors.margin },
    FoldColumn = { fg = colors.comment, bg = colors.line_numbers_back },
    
    -- Diff
    DiffAdd = { fg = colors.comment_good },
    DiffChange = { fg = colors.base },
    DiffDelete = { fg = colors.comment_bad },
    DiffText = { fg = colors.at_highlight },
    
    -- Treesitter highlights
    ["@comment"] = { link = "Comment" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { fg = colors.boolean },
    ["@constant.macro"] = { fg = colors.macro_color },
    ["@string"] = { link = "String" },
    ["@string.escape"] = { fg = colors.special_char },
    ["@character"] = { link = "Character" },
    ["@number"] = { link = "Number" },
    ["@boolean"] = { link = "Boolean" },
    ["@float"] = { link = "Float" },
    
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { fg = colors.function_color },
    ["@function.call"] = { fg = colors.function_color },
    ["@function.macro"] = { fg = colors.macro_color },
    ["@parameter"] = { fg = colors.text_default },
    ["@method"] = { link = "Function" },
    ["@method.call"] = { fg = colors.function_color },
    ["@field"] = { fg = colors.text_default },
    ["@property"] = { fg = colors.text_default },
    ["@constructor"] = { fg = colors.type_color },
    
    ["@conditional"] = { link = "Conditional" },
    ["@repeat"] = { link = "Repeat" },
    ["@label"] = { link = "Label" },
    ["@operator"] = { link = "Operator" },
    ["@keyword"] = { link = "Keyword" },
    ["@exception"] = { link = "Exception" },
    
    ["@variable"] = { fg = colors.text_default },
    ["@type"] = { fg = colors.type_color },
    ["@type.builtin"] = { fg = colors.type_color },
    ["@namespace"] = { fg = colors.type_color },
    ["@include"] = { link = "Include" },
    
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { fg = colors.brace_highlight },
    ["@punctuation.special"] = { link = "Special" },
    
    ["@tag"] = { link = "Tag" },
    ["@tag.attribute"] = { fg = colors.text_default },
    ["@tag.delimiter"] = { link = "Delimiter" },
    
    -- Language specific
    -- C
    ["@type.c"] = { fg = colors.type_color },
    ["@constant.c"] = { fg = colors.string },
    
    -- TypeScript/JavaScript
    ["@type.typescript"] = { fg = colors.type_color },
    ["@constructor.typescript"] = { fg = colors.type_color },
    ["@variable.typescript"] = { fg = colors.text_default },
    
    -- Zig
    ["@type.zig"] = { fg = colors.type_color },
    ["@keyword.zig"] = { fg = colors.keyword },
    ["@function.zig"] = { fg = colors.function_color },
    
    -- Jai (special keywords like #expand use macro color)
    ["@type.jai"] = { fg = colors.type_color },
    ["@keyword.jai"] = { fg = colors.keyword },
    ["@function.jai"] = { fg = colors.function_color },
    ["@function.call.jai"] = { fg = colors.function_color },
    ["@function.builtin.jai"] = { fg = colors.function_color },
    ["@method.jai"] = { fg = colors.function_color },
    ["@method.call.jai"] = { fg = colors.function_color },
    ["@variable.builtin.jai"] = { fg = colors.function_color },
    ["@identifier.jai"] = { fg = colors.text_default },
    ["@variable.jai"] = { fg = colors.text_default },
    ["@keyword.directive.jai"] = { fg = colors.macro_color },
    ["@preproc.jai"] = { fg = colors.macro_color },
    
    -- LSP semantic tokens
    ["@lsp.type.class"] = { fg = colors.type_color },
    ["@lsp.type.decorator"] = { fg = colors.macro_color },
    ["@lsp.type.enum"] = { fg = colors.type_color },
    ["@lsp.type.enumMember"] = { fg = colors.string },
    ["@lsp.type.function"] = { fg = colors.function_color },
    ["@lsp.type.interface"] = { fg = colors.type_color },
    ["@lsp.type.macro"] = { fg = colors.macro_color },
    ["@lsp.type.method"] = { fg = colors.function_color },
    ["@lsp.type.namespace"] = { fg = colors.type_color },
    ["@lsp.type.parameter"] = { fg = colors.text_default },
    ["@lsp.type.property"] = { fg = colors.text_default },
    ["@lsp.type.struct"] = { fg = colors.type_color },
    ["@lsp.type.type"] = { fg = colors.type_color },
    ["@lsp.type.typeParameter"] = { fg = colors.type_color },
    ["@lsp.type.variable"] = { fg = colors.text_default },
}

-- Apply highlights
for group, settings in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, settings)
end

-- Telescope specific highlights
vim.api.nvim_set_hl(0, "TelescopeNormal", { fg = colors.text_default, bg = colors.back })
vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = colors.margin_hover, bg = colors.back })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = colors.text_default, bg = colors.margin })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = colors.margin_hover, bg = colors.margin })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = colors.pop1, bg = colors.margin })
vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = colors.pop1, bg = colors.back })
vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = colors.pop1, bg = colors.back })
vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = colors.text_default, bg = colors.highlight_cursor_line })
vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = colors.pop1, bg = colors.highlight_cursor_line })
vim.api.nvim_set_hl(0, "TelescopeMultiSelection", { fg = colors.cursor_green, bg = colors.highlight_cursor_line })
vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.at_highlight, bold = true })