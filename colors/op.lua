vim.cmd("hi clear")

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "op"

-- op: four neutral steps on one warm hue, with two accents hung off them. What
-- separates this from the other schemes in colors/ is that the loudest thing on
-- screen is a name being introduced: declarations, parameters and fields are
-- bold cream, ordinary text and calls sit a step below, and the operators and
-- punctuation holding them together sit a step below that, so the shape of a
-- declaration reads before any of its detail does. Types take a slate blue and
-- literals a sand tan. Comments are the bottom step of the same ladder.
local c = {
  bg = "#17160f",
  fg = "#b9b4a6", -- calls and plain text

  bright = "#eae3d1", -- fg one step up, bold: names being introduced
  punct = "#8b877b",  -- fg one step down: operators and delimiters
  comment = "#66625a", -- two steps down: comments recede

  blue = "#7f96a9", -- types
  tan = "#c8b88b",  -- strings, numbers, booleans, constants, macros
  red = "#b06a63",  -- warnings, errors, current search match
  gray = "gray50",  -- status text

  -- Chrome. Warm darks a few steps either side of the background, so the frame
  -- stays on the same hue as the text rather than cutting neutral grey into it.
  border = "#0d0c08",
  bar = "#0b0a07",
  bar_nc = "#121109",
  sel = "#33312a",    -- visual, search, popup
  sel_hi = "#4b4840", -- matching paren, popup selection
  line = "#201e16",   -- cursor line, on in the directory listing only
  dim = "#454239", -- the one tone every window behind a picker is painted in
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
-- names, so op has to define its own or the cursor falls back to Neovim's
-- default thin insert-mode bar. The three modes take the top of the ladder and
-- the two accents, so no fourth hue enters for the cursor alone. Visual mode
-- has no cursor color of its own -- the selection block already says where you
-- are.
paint({ bg = c.bright }, { "Cursor", "lCursor" })
hl(0, "CursorNormal", { fg = c.bg, bg = c.bright })
hl(0, "CursorInsert", { fg = c.bg, bg = c.blue })
hl(0, "CursorReplace", { fg = c.bg, bg = c.red })
vim.opt.guicursor = {
  "n-v-c-o:block-CursorNormal",
  "i-ci-ve:block-CursorInsert",
  "r-cr:block-CursorReplace",
}


-- Syntax
paint({ fg = c.bright, bold = true }, {
  "Identifier",
  "Keyword", "Statement", "Conditional", "Repeat", "Label", "Exception", "StorageClass",
  "PreProc", "Include", "Define", "PreCondit",
})
paint({ fg = c.fg }, { "Function" })
paint({ fg = c.punct }, { "Operator", "Delimiter", "Special", "SpecialChar" })
paint({ fg = c.blue }, { "Type", "Structure", "Typedef" })
paint({ fg = c.tan }, { "String", "Character", "Number", "Float", "Boolean", "Constant", "Macro" })
paint({ fg = c.comment }, { "Comment", "SpecialComment" })

hl(0, "DiagnosticWarn", { fg = c.red })
hl(0, "WarningMsg", { fg = c.red })
hl(0, "ErrorMsg", { fg = c.red })


-- Search and completion
hl(0, "Search", { bg = c.sel })
paint({ fg = c.bg, bg = c.red }, { "IncSearch", "CurSearch" })
hl(0, "Pmenu", { fg = c.fg })
hl(0, "PmenuSel", { fg = c.bright, bg = c.sel_hi })
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
hl(0, "TelescopeSelection", { fg = c.bright, bg = c.sel })
hl(0, "TelescopeSelectionCaret", { fg = c.blue, bg = c.sel })
hl(0, "TelescopeMultiSelection", { fg = c.blue })
hl(0, "TelescopeMatching", { fg = c.red })


-- Everything else is a link. YgKeyword/YgType are the groups lua/hh/macros.lua
-- paints project macros and their base types with; the macro is tan with the
-- constants it stands in for and the base type blue with the other types, so
-- both halves of the indexer read at a glance.
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

  -- A call is plain text; the name being declared is not. @function is the
  -- definition site, so it goes up to the bold step with the other declarations
  -- while every call form stays on Function.
  ["@function"] = "Identifier",
  ["@function.builtin"] = "Function",
  ["@function.call"] = "Function",
  ["@function.method"] = "Identifier",
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
-- along the same hue as the text. Level 1 paints nothing -- Normal is
-- transparent, so the outermost scope has to be the terminal or it reads as a
-- dark slab over it -- and the three above it lift at ~5 per step, so the
-- nesting is there to follow when you look for it and stays out of the way when
-- you are reading the code instead. hh/scope.lua indexes these mod cycle_len.
local scope_bgs = {
  "none",
  "#1c1b14",
  "#211f17",
  "#26241a",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()
require("hh.dim").setup({ fg = c.dim })
