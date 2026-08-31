vim.cmd("hi clear")

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "min"

-- min: ddd with the syntax accents collapsed to two. Keywords and preprocessor
-- directives and strings are the only colored things on screen; types,
-- identifiers, functions, constants and comments are all one plain tone, so the
-- buffer reads as text with the control flow picked out of it. Both accents are
-- lifted from colors/handmade.lua.
local c = {
  bg = "#0a0a0a",
  fg = "burlywood3",

  yellow = "#b8860b", -- goldenrod keywords, from colors/handmade.lua
  green = "#6b8e23",  -- olive strings, from colors/handmade.lua
  gray = "gray50",    -- status text

  -- Chrome. Neutral greys on purpose: the only warm thing on screen is text
  -- and the scope back-cycle.
  border = "#030303",
  bar = "#000000",
  bar_nc = "#050505",
  sel = "#333333",    -- visual, search, popup
  sel_hi = "#4d4d4d", -- matching paren, popup selection
  line = "#141414",   -- cursor line, on in the directory listing only
  blue = "#7d9cb0",   -- insert-mode cursor, warnings
  rose = "#b55f75",   -- current search match, replace-mode cursor
  cursor = "#50ffa0",
}

local hl = vim.api.nvim_set_hl

---@param spec table
---@param groups string[]
local function paint(spec, groups)
  for _, group in ipairs(groups) do
    hl(0, group, spec)
  end
end


-- Frame
paint({ fg = c.fg, bg = c.bg }, { "Normal", "NormalNC" })
paint({ fg = c.border, bg = c.bg }, { "VertSplit", "WinSeparator" })
paint({ fg = c.gray, bg = c.bar }, { "StatusLine", "WinBar" })
paint({ fg = c.gray, bg = c.bar_nc }, { "StatusLineNC", "WinBarNC" })
paint({ bg = c.sel }, { "Visual", "VisualNOS" })
paint({ bg = c.sel_hi }, { "MatchParen" })
paint({ bg = c.line }, { "CursorLine" })
paint({ fg = c.fg }, { "Directory" })


-- Cursor. 'guicursor' is global and every scheme in colors/ owns it; the
-- `hi clear` above wipes the Cursor* groups the previous scheme's guicursor
-- names, so min has to define its own or the cursor falls back to
-- Neovim's default thin insert-mode bar. Visual mode has no cursor color of its
-- own -- the selection block already says where you are.
paint({ bg = c.cursor }, { "Cursor", "lCursor" })
hl(0, "CursorNormal", { fg = c.bg, bg = c.cursor })
hl(0, "CursorInsert", { fg = c.bg, bg = c.blue })
hl(0, "CursorReplace", { fg = c.bg, bg = c.rose })
vim.opt.guicursor = {
  "n-v-c-o:block-CursorNormal",
  "i-ci-ve:block-CursorInsert",
  "r-cr:block-CursorReplace",
}


-- Syntax
paint({ fg = c.yellow }, {
  "PreProc", "Include", "Define", "PreCondit",
  "Keyword", "Statement", "Conditional", "Repeat", "Label", "Exception", "StorageClass",
})
paint({ fg = c.fg }, {
  "Type", "Structure", "Typedef",
  "Constant", "Boolean", "Character", "Function", "Identifier", "Macro",
  "Number", "Float", "Operator",
  "Comment", "SpecialComment",
})
paint({ fg = c.green }, { "String" })

hl(0, "DiagnosticWarn", { fg = c.blue })
hl(0, "WarningMsg", { fg = c.blue })
hl(0, "ErrorMsg", { fg = c.rose })


-- Search and completion
hl(0, "Search", { bg = c.sel })
paint({ fg = c.bg, bg = c.rose }, { "IncSearch", "CurSearch" })
hl(0, "Pmenu", { fg = c.fg, bg = c.sel })
hl(0, "PmenuSel", { fg = c.fg, bg = c.sel_hi })
hl(0, "PmenuSbar", { bg = c.sel })
hl(0, "PmenuThumb", { bg = c.sel_hi })


-- Everything else is a link. YgKeyword/YgType are the groups lua/hh/macros.lua
-- paints project macros and their base types with; a macro call reads as plain
-- text like any other call, so only the type half of that indexer shows.
local links = {
  YgKeyword = "Macro",
  YgType = "Type",

  ["@comment"] = "Comment",
  ["@comment.documentation"] = "Comment",

  ["@string"] = "String",
  ["@string.documentation"] = "Comment",
  ["@string.regexp"] = "String",
  ["@string.escape"] = "SpecialChar",
  ["@string.special"] = "Special",

  ["@character"] = "Character",
  ["@character.special"] = "Special",

  ["@number"] = "Number",
  ["@number.float"] = "Float",

  ["@boolean"] = "Boolean",

  ["@constant"] = "Constant",
  ["@constant.builtin"] = "Constant",
  ["@constant.macro"] = "Macro",

  ["@function"] = "Function",
  ["@function.builtin"] = "Function",
  ["@function.call"] = "Function",
  ["@function.method"] = "Function",
  ["@function.method.call"] = "Function",

  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Keyword",
  ["@variable.parameter"] = "Identifier",
  ["@variable.member"] = "Identifier",

  ["@property"] = "Identifier",
  ["@field"] = "Identifier",

  ["@type"] = "Type",
  ["@type.builtin"] = "Type",
  ["@type.definition"] = "Type",

  ["@keyword"] = "Keyword",
  ["@keyword.function"] = "Keyword",
  ["@keyword.operator"] = "Keyword",
  ["@keyword.import"] = "PreProc",
  ["@keyword.return"] = "Keyword",
  ["@keyword.repeat"] = "Repeat",
  ["@keyword.conditional"] = "Conditional",
  ["@keyword.exception"] = "Exception",
  ["@keyword.modifier"] = "StorageClass",
  ["@keyword.type"] = "Keyword",
  ["@keyword.directive"] = "PreProc",

  ["@operator"] = "Operator",

  ["@punctuation.delimiter"] = "Delimiter",
  ["@punctuation.bracket"] = "Delimiter",
  ["@punctuation.special"] = "Special",

  ["@tag"] = "Keyword",
  ["@tag.attribute"] = "Identifier",
  ["@tag.delimiter"] = "Delimiter",
}

for group, target in pairs(links) do
  hl(0, group, { link = target })
end


-- Back-cycle for nested scopes: each level lifts warmer off the background,
-- toward the burlywood text. Four levels at ~9 per step, so a level is legible
-- against the one outside it and the cycle repeats before the lift gets loud.
-- These do NOT track the background down -- level 1 sits above #0a0a0a on
-- purpose, so even the outermost scope reads as a lift. hh/scope.lua indexes
-- these mod cycle_len.
local scope_bgs = {
  "#131313",
  "#1c1a17",
  "#25211b",
  "#2e2a20",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()
