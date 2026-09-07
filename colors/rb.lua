vim.cmd("hi clear")

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "rb"

-- rb: ll with min's burlywood text and the accents cut to two. The tan runs as
-- a three-step ladder on one hue -- comments below the text, keywords and
-- preprocessor directives above it -- so control flow lifts off the page
-- without spending a color on it. Operators, delimiters and local identifiers
-- stay the plain middle tone. The two accents split the line by what the
-- compiler does with a name: blue is resolved elsewhere -- calls and types --
-- and red is fixed text standing in the line itself: strings, characters,
-- numbers, booleans, constants and the macros that expand into them. Red
-- carries the same weight past the syntax, on the matches and the failures.
-- There is no third hue.
local c = {
  bg = "#1c1c1c",
  fg = "#b09573", -- min's burlywood tan, stepped down and desaturated

  bright = "#ded3c4", -- fg one step up: keywords lift, hue unchanged
  comment = "#7c6950", -- fg one step down: comments recede, hue unchanged

  blue = "#8a9eaf",  -- calls and types: names resolved elsewhere
  red = "#b56b6b",   -- literals, constants, macros, matches, warnings, errors
  gray = "gray50",   -- status text

  -- Chrome. Neutral greys a few steps either side of the background.
  border = "#121212",
  bar = "#111111",
  bar_nc = "#171717",
  sel = "#3a3a3a",    -- visual, search, popup
  sel_hi = "#525252", -- matching paren, popup selection
  line = "#272727",   -- cursor line, on in the directory listing only
  dim = "#4a443a", -- the one tone every window behind a picker is painted in
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
--
-- Nothing here paints the editor background. Normal is transparent, so the
-- terminal's own background is what you see, and every group that names no bg
-- of its own -- floats, the sign column, the pickers below -- is transparent
-- with it. c.bg stays as the tone the rest of the palette is chosen against,
-- and as the text color on the cursor and the current search match.
paint({ fg = c.fg, bg = "none" }, { "Normal", "NormalNC", "NormalFloat" })
paint({ fg = c.border }, { "VertSplit", "WinSeparator" })
paint({ fg = c.gray, bg = c.bar }, { "StatusLine", "WinBar" })
paint({ fg = c.gray, bg = c.bar_nc }, { "StatusLineNC", "WinBarNC" })
paint({ fg = c.comment }, { "FloatBorder", "LineNr", "SignColumn" })
paint({ bg = c.sel }, { "Visual", "VisualNOS" })
paint({ bg = c.sel_hi }, { "MatchParen" })
paint({ bg = c.line }, { "CursorLine" })
paint({ fg = c.fg }, { "Directory" })


-- Cursor. 'guicursor' is global and every scheme in colors/ owns it; the
-- `hi clear` above wipes the Cursor* groups the previous scheme's guicursor
-- names, so rb has to define its own or the cursor falls back to Neovim's
-- default thin insert-mode bar. With no third accent the normal-mode cursor is
-- a plain block of the text tone. Visual mode has no cursor color of its own --
-- the selection block already says where you are.
paint({ bg = c.fg }, { "Cursor", "lCursor" })
hl(0, "CursorNormal", { fg = c.bg, bg = c.fg })
hl(0, "CursorInsert", { fg = c.bg, bg = c.blue })
hl(0, "CursorReplace", { fg = c.bg, bg = c.red })
vim.opt.guicursor = {
  "n-v-c-o:block-CursorNormal",
  "i-ci-ve:block-CursorInsert",
  "r-cr:block-CursorReplace",
}


-- Syntax
paint({ fg = c.bright }, {
  "PreProc", "Include", "Define", "PreCondit",
  "Keyword", "Statement", "Conditional", "Repeat", "Label", "Exception", "StorageClass",
})
paint({ fg = c.fg }, {
  "Identifier", "Operator", "Delimiter", "Special", "SpecialChar",
})
paint({ fg = c.blue }, {
  "Type", "Structure", "Typedef", "Function",
})
paint({ fg = c.red }, {
  "String", "Character", "Constant", "Boolean", "Number", "Float", "Macro",
})
paint({ fg = c.comment }, { "Comment", "SpecialComment" })

hl(0, "DiagnosticWarn", { fg = c.red })
hl(0, "WarningMsg", { fg = c.red })
hl(0, "ErrorMsg", { fg = c.red })


-- Search and completion
hl(0, "Search", { bg = c.sel })
paint({ fg = c.bg, bg = c.red }, { "IncSearch", "CurSearch" })
hl(0, "Pmenu", { fg = c.fg })
hl(0, "PmenuSel", { fg = c.fg, bg = c.sel_hi })
hl(0, "PmenuSbar", { bg = c.sel })
hl(0, "PmenuThumb", { bg = c.sel_hi })


-- Telescope. The picker is text laid over the editor, not a panel: no window
-- in it paints a background and the border is its only edge. What separates it
-- from the file underneath is the other half -- hh/dim.lua recesses every
-- window behind it while it is open.
paint({ fg = c.fg }, {
  "TelescopeNormal", "TelescopePromptNormal", "TelescopeResultsNormal", "TelescopePreviewNormal",
})
paint({ fg = c.comment }, {
  "TelescopeBorder", "TelescopePromptBorder", "TelescopeResultsBorder", "TelescopePreviewBorder",
})
paint({ fg = c.gray }, {
  "TelescopeTitle", "TelescopePromptTitle", "TelescopeResultsTitle", "TelescopePreviewTitle",
})
hl(0, "TelescopePromptPrefix", { fg = c.blue })
hl(0, "TelescopeSelection", { fg = c.fg, bg = c.sel })
hl(0, "TelescopeSelectionCaret", { fg = c.blue, bg = c.sel })
hl(0, "TelescopeMultiSelection", { fg = c.blue })
hl(0, "TelescopeMatching", { fg = c.red })


-- Everything else is a link. YgKeyword/YgType are the groups lua/hh/macros.lua
-- paints project macros and their base types with; the two accents fall either
-- side of that split on their own -- the macro is red with the constants it
-- stands in for, the base type blue with the other types -- so both halves of
-- the indexer read at a glance.
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
-- toward the burlywood text. Level 1 paints nothing -- Normal is transparent, so
-- the outermost scope has to be the terminal or it reads as a dark slab over it
-- -- and the three above it lift at ~5 per step, half ll's, so the nesting is
-- there to follow when you look for it and stays out of the way when you are
-- reading the code instead. hh/scope.lua indexes these mod cycle_len.
local scope_bgs = {
  "none",
  "#212120",
  "#262523",
  "#2b2a26",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()
require("hh.dim").setup({ fg = c.dim })
