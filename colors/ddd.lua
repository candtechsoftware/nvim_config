vim.cmd("hi clear")

if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "ddd"

local hl = vim.api.nvim_set_hl

local c = {
  background = "#0a0a0a",
  foreground = "burlywood3",

  border = "#030303",

  cursor = "#50ffa0",
  -- Replace-mode cursor only; the palette has no red of its own.
  cursor_replace = "#d05050",
  region = "#343c37",

  prompt = "#759fbf",

  -- Both stay below the darkened background so the mode line still reads as a
  -- separate strip; the inactive one tracks the background down, staying one
  -- step under the current #0a0a0a.
  mode_line = "#000000",
  mode_line_inactive = "#050505",

  paren = "#536058",

  -- Blue in place of ddd's original orange. handmade's identifier #bfc9db read
  -- as off-white here, so this is ddd's own blue instead.
  warning = "#759fbf",
  preprocessor = "#759fbf",
  keyword = "#759fbf",
  builtin = "#759fbf",

  -- fleury_color_index_macro from the 4coder fleury layer (0xFF2895c7):
  -- identifiers the indexer resolved as macros. lua/hh/macros.lua paints every
  -- project #define with the Macro group at priority 200.
  macro = "#2895c7",

  -- handmade's defcolor_keyword gold (0xFFcd950c). It sits in the same warm
  -- family as burlywood3, so it reads as one palette, but it's saturated enough
  -- that types stop being indistinguishable from every other identifier.
  type = "#cd950c",

  constant = "burlywood3",
  function_name = "burlywood3",
  variable = "burlywood3",

  string = "#98c379",
  number = "#759fbf",

  comment = "gray50",
  documentation = "gray70",

  multicursor = "#5d6b63",

  -- Search highlights come from handmade: a flat backdrop for all matches and
  -- the rose block for the one under the cursor. The match1-4 ramp below stays
  -- ddd's own, and still drives the popup menu and the Ivy groups.
  search = "#383638",
  search_active = "#b55f75",
  search_active_fg = "#161616",

  match1 = "#343c37",
  match2 = "#3e4842",
  match3 = "#48544d",
  match4 = "#536058",
}


-- Frame
hl(0, "Normal", {
  fg = c.foreground,
  bg = c.background,
})

hl(0, "NormalNC", {
  fg = c.foreground,
  bg = c.background,
})

hl(0, "VertSplit", {
  fg = c.border,
  bg = c.background,
})

hl(0, "WinSeparator", {
  fg = c.border,
  bg = c.background,
})

hl(0, "Cursor", {
  bg = c.cursor,
})

hl(0, "lCursor", {
  bg = c.cursor,
})

-- 'guicursor' is global and every scheme in colors/ owns it; `hi clear` at the
-- top wipes the Cursor* groups it names, so ddd has to redefine them or the
-- previous scheme's guicursor is left pointing at nothing. Without this block
-- ddd fell back to Neovim's default, which is a thin bar in insert mode.
hl(0, "CursorNormal", { fg = c.background, bg = c.cursor })
hl(0, "CursorInsert", { fg = c.background, bg = c.number })
hl(0, "CursorVisual", { fg = c.background, bg = c.string })
hl(0, "CursorReplace", { fg = c.background, bg = c.cursor_replace })
hl(0, "CursorCommand", { fg = c.background, bg = c.keyword })
vim.opt.guicursor = {
  "n-c:block-CursorNormal",     -- normal / command -> mint block
  "i-ci-ve:block-CursorInsert", -- insert -> blue block
  "v-V:block-CursorVisual",     -- visual -> green block
  "r-cr:block-CursorReplace",   -- replace -> red block
  "o:block-CursorNormal",       -- operator-pending -> mint block
}

hl(0, "Visual", {
  bg = c.region,
})

hl(0, "VisualNOS", {
  bg = c.region,
})

hl(0, "MinibufferPrompt", {
  fg = c.prompt,
})


-- Mode line
hl(0, "StatusLine", {
  fg = "#a0a0a0",
  bg = c.mode_line,
})

hl(0, "StatusLineNC", {
  fg = "#a0a0a0",
  bg = c.mode_line_inactive,
})

hl(0, "WinBar", {
  fg = "#a0a0a0",
  bg = c.mode_line,
})

hl(0, "WinBarNC", {
  fg = "#a0a0a0",
  bg = c.mode_line_inactive,
})


-- Parentheses
hl(0, "MatchParen", {
  bg = c.paren,
})


-- Code
hl(0, "DiagnosticWarn", {
  fg = c.warning,
  bold = true,
})

hl(0, "WarningMsg", {
  fg = c.warning,
})

hl(0, "ErrorMsg", {
  fg = c.warning,
})

hl(0, "PreProc", {
  fg = c.preprocessor,
  bold = true,
})

hl(0, "Include", {
  fg = c.preprocessor,
  bold = true,
})

hl(0, "Define", {
  fg = c.macro,
  bold = true,
})

hl(0, "Macro", {
  fg = c.macro,
  bold = true,
})

-- lua/hh/macros.lua marks the yg_/arc_ storage-class macros with YgKeyword and
-- their return types with YgType; without these ddd leaves both undefined.
hl(0, "YgKeyword", {
  link = "Macro",
})

hl(0, "YgType", {
  link = "Type",
})

hl(0, "PreCondit", {
  fg = c.preprocessor,
  bold = true,
})

hl(0, "Keyword", {
  fg = c.keyword,
})

hl(0, "Statement", {
  fg = c.keyword,
})

hl(0, "Conditional", {
  fg = c.keyword,
})

hl(0, "Repeat", {
  fg = c.keyword,
})

hl(0, "Label", {
  fg = c.keyword,
})

hl(0, "Exception", {
  fg = c.keyword,
})

hl(0, "Operator", {
  fg = c.keyword,
})

hl(0, "Builtin", {
  fg = c.builtin,
})

hl(0, "Type", {
  fg = c.type,
})

hl(0, "StorageClass", {
  fg = c.type,
})

hl(0, "Structure", {
  fg = c.type,
})

hl(0, "Typedef", {
  fg = c.type,
})

hl(0, "Constant", {
  fg = c.constant,
})

hl(0, "Boolean", {
  fg = c.constant,
})

hl(0, "Character", {
  fg = c.constant,
})

hl(0, "Number", {
  fg = c.number,
})

hl(0, "Float", {
  fg = c.number,
})

hl(0, "Function", {
  fg = c.function_name,
})

hl(0, "Identifier", {
  fg = c.variable,
})

hl(0, "String", {
  fg = c.string,
})

hl(0, "Comment", {
  fg = c.comment,
})

hl(0, "SpecialComment", {
  fg = c.documentation,
})

hl(0, "DocComment", {
  fg = c.documentation,
})


-- Multiple cursors
hl(0, "MultiCursorCursor", {
  bg = c.multicursor,
})


-- Search / completion
hl(0, "Search", {
  bg = c.search,
})

hl(0, "IncSearch", {
  fg = c.search_active_fg,
  bg = c.search_active,
})

hl(0, "CurSearch", {
  fg = c.search_active_fg,
  bg = c.search_active,
})

hl(0, "Pmenu", {
  fg = c.foreground,
  bg = c.match1,
})

hl(0, "PmenuSel", {
  fg = c.foreground,
  bg = c.match4,
})

hl(0, "PmenuSbar", {
  bg = c.match2,
})

hl(0, "PmenuThumb", {
  bg = c.match4,
})


-- Ivy / Swiper equivalents
hl(0, "IvyMatch1", {
  bg = c.match1,
})

hl(0, "IvyMatch2", {
  bg = c.match2,
})

hl(0, "IvyMatch3", {
  bg = c.match3,
})

hl(0, "IvyMatch4", {
  bg = c.match4,
})

hl(0, "SwiperMatch1", {
  bg = c.match1,
})

hl(0, "SwiperMatch2", {
  bg = c.match2,
})

hl(0, "SwiperMatch3", {
  bg = c.match3,
})

hl(0, "SwiperMatch4", {
  bg = c.match4,
})

hl(0, "SwiperBackgroundMatch1", {
  bg = c.match1,
})

hl(0, "SwiperBackgroundMatch2", {
  bg = c.match2,
})

hl(0, "SwiperBackgroundMatch3", {
  bg = c.match3,
})

hl(0, "SwiperBackgroundMatch4", {
  bg = c.match4,
})


-- Tree-sitter
local links = {
  ["@comment"] = "Comment",
  ["@comment.documentation"] = "DocComment",

  ["@string"] = "String",
  ["@string.documentation"] = "DocComment",
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
  ["@constant.macro"] = "Constant",

  ["@function"] = "Function",
  ["@function.builtin"] = "Builtin",
  ["@function.call"] = "Function",
  ["@function.method"] = "Function",
  ["@function.method.call"] = "Function",

  ["@variable"] = "Identifier",
  ["@variable.builtin"] = "Builtin",
  ["@variable.parameter"] = "Identifier",
  ["@variable.member"] = "Identifier",

  ["@property"] = "Identifier",
  ["@field"] = "Identifier",

  ["@type"] = "Type",
  ["@type.builtin"] = "Type",
  ["@type.definition"] = "Type",

  ["@keyword"] = "Keyword",
  ["@keyword.function"] = "Keyword",
  ["@keyword.operator"] = "Operator",
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
  hl(0, group, {
    link = target,
  })
end


-- Back-cycle for nested scopes, same idea as handmade: each nesting level lifts
-- slightly warmer off the background, toward the burlywood text. These do NOT
-- track the background down -- level 0 sits above the #0a0a0a background on
-- purpose, so even the outermost scope reads as a lift. hh/scope.lua indexes
-- these mod cycle_len, so six entries is the full cycle.
local scope_bgs = {
  "#141414",
  "#181716",
  "#1c1a18",
  "#201d1a",
  "#24201c",
  "#28231e",
}
for i, bg in ipairs(scope_bgs) do
  hl(0, "HHScope" .. i, { bg = bg })
end

require("hh.scope").setup({ cycle_len = #scope_bgs })
