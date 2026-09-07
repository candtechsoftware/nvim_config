vim.cmd("hi clear")

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "ll"

-- ll: min lifted off black onto neutral grey, with the accent moved from the
-- keywords to the names. Keywords, operators and local identifiers are all one
-- plain tone; calls, types, constants and literals take a slate blue and
-- strings a sage green, so a line reads as text with its references picked
-- out of it. Comments sit a step below the text. Every color is desaturated a
-- notch from the source screenshot so nothing on screen is bright.
local c = {
  bg = "#1c1c1c",
  fg = "#bcbcb2",

  blue = "#8a9eaf",   -- calls, types, constants, numbers
  green = "#9db08e",  -- strings
  gray = "gray50",    -- status text
  comment = "#767670", -- fg one step down: comments recede

  -- Chrome. Neutral greys a few steps either side of the background.
  border = "#121212",
  bar = "#111111",
  bar_nc = "#171717",
  sel = "#3a3a3a",    -- visual, search, popup
  sel_hi = "#525252", -- matching paren, popup selection
  line = "#272727",   -- cursor line, on in the directory listing only
  yellow = "#b09a6a", -- warnings
  rose = "#ad6b7d",   -- current search match, replace-mode cursor, errors
  cursor = "#7fcf9f",
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
-- names, so ll has to define its own or the cursor falls back to Neovim's
-- default thin insert-mode bar. Visual mode has no cursor color of its own --
-- the selection block already says where you are.
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
paint({ fg = c.fg }, {
  "PreProc", "Include", "Define", "PreCondit",
  "Keyword", "Statement", "Conditional", "Repeat", "Label", "Exception", "StorageClass",
  "Identifier", "Operator", "Delimiter", "Special", "SpecialChar",
})
paint({ fg = c.blue }, {
  "Type", "Structure", "Typedef",
  "Constant", "Boolean", "Number", "Float", "Function", "Macro",
})
paint({ fg = c.comment }, { "Comment", "SpecialComment" })
paint({ fg = c.green }, { "String", "Character" })

hl(0, "DiagnosticWarn", { fg = c.yellow })
hl(0, "WarningMsg", { fg = c.yellow })
hl(0, "ErrorMsg", { fg = c.rose })


-- Search and completion
hl(0, "Search", { bg = c.sel })
paint({ fg = c.bg, bg = c.rose }, { "IncSearch", "CurSearch" })
hl(0, "Pmenu", { fg = c.fg, bg = c.sel })
hl(0, "PmenuSel", { fg = c.fg, bg = c.sel_hi })
hl(0, "PmenuSbar", { bg = c.sel })
hl(0, "PmenuThumb", { bg = c.sel_hi })


-- Everything else is a link. YgKeyword/YgType are the groups lua/hh/macros.lua
-- paints project macros and their base types with; here a call is blue, so a
-- macro call is blue like any other call and both halves of that indexer show.
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


-- Back-cycle for nested scopes: each level lifts off the background, warming
-- slightly so the lift reads against the neutral chrome. Four levels at ~9 per
-- step, so a level is legible against the one outside it and the cycle repeats
-- before the lift gets loud. Level 1 sits above #1c1c1c on purpose, so even
-- the outermost scope reads as a lift. hh/scope.lua indexes these mod
-- cycle_len.
local scope_bgs = {
  "#252525",
  "#2e2d2a",
  "#37352f",
  "#403d34",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

require("hh.scope").setup({ cycle_len = #scope_bgs })
require("hh.macros").setup()
