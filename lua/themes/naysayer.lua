-- naysayer.lua
-- A Neovim theme inspired by the naysayer Emacs theme

local naysayer = {}

-- Define the color palette
naysayer.colors = {
  background = "#062329",
  gutters = "#062329",
  gutter_fg = "#062329",
  builtin = "#ffffff",
  selection = "#0000ff",
  text = "#d1b897",
  comments = "#44b340",
  punctuation = "#8cde94",
  keywords = "#ffffff",
  variables = "#c1d1e3",
  functions = "#ffffff",
  methods = "#c1d1e3",
  strings = "#2ec09c",
  constants = "#7ad0c6",
  macros = "#8cde94",
  numbers = "#7ad0c6",
  white = "#ffffff",
  error = "#ff0000",
  warning = "#ffaa00",
  highlight_line = "#0b3335",
  line_fg = "#126367",
  violet = "#AE81FF",
  blue = "#66D9EF",
  green = "#A6E22E",
  yellow = "#E6DB74",
  orange = "#FD971F",
  red = "#F92672",
  cyan = "#A1EFE4",
}

-- Apply the theme
naysayer.apply = function()
  local colors = naysayer.colors

  -- Set terminal colors
  vim.g.terminal_color_0 = colors.background
  vim.g.terminal_color_1 = colors.red
  vim.g.terminal_color_2 = colors.green
  vim.g.terminal_color_3 = colors.yellow
  vim.g.terminal_color_4 = colors.blue
  vim.g.terminal_color_5 = colors.violet
  vim.g.terminal_color_6 = colors.cyan
  vim.g.terminal_color_7 = colors.text
  vim.g.terminal_color_8 = colors.gutters
  vim.g.terminal_color_9 = colors.red
  vim.g.terminal_color_10 = colors.green
  vim.g.terminal_color_11 = colors.yellow
  vim.g.terminal_color_12 = colors.blue
  vim.g.terminal_color_13 = colors.violet
  vim.g.terminal_color_14 = colors.cyan
  vim.g.terminal_color_15 = colors.white

  -- Set highlight groups
  local highlight = function(group, fg, bg, opts)
    opts = opts or {}
    vim.api.nvim_set_hl(0, group, {
      fg = fg,
      bg = bg,
      bold = opts.bold,
      italic = opts.italic,
      underline = opts.underline,
    })
  end

  -- Editor
  highlight("Normal", colors.text, colors.background)
  highlight("Cursor", colors.white, colors.text)
  highlight("Visual", nil, colors.selection)
  highlight("LineNr", colors.line_fg, colors.background)
  highlight("CursorLineNr", colors.white, colors.background)
  highlight("CursorLine", nil, colors.highlight_line)
  highlight("Comment", colors.comments, nil, { italic = true })
  highlight("Error", colors.error, nil, { bold = true })
  highlight("WarningMsg", colors.warning, nil, { bold = true })

  -- Syntax
  highlight("Keyword", colors.keywords, nil, { bold = true })
  highlight("Type", colors.punctuation, nil)
  highlight("Constant", colors.constants, nil)
  highlight("Variable", colors.variables, nil)
  highlight("Function", colors.functions, nil)
  highlight("String", colors.strings, nil)
  highlight("Number", colors.numbers, nil)
  highlight("Macro", colors.macros, nil)

  -- Diagnostics
  highlight("DiagnosticError", colors.error, nil)
  highlight("DiagnosticWarn", colors.warning, nil)
  highlight("DiagnosticInfo", colors.blue, nil)
  highlight("DiagnosticHint", colors.cyan, nil)

  -- Plugins
  highlight("GitSignsAdd", colors.green, nil)
  highlight("GitSignsChange", colors.yellow, nil)
  highlight("GitSignsDelete", colors.red, nil)

  -- Rainbow parentheses (if using nvim-ts-rainbow)
  highlight("RainbowDelimiter1", colors.violet, nil)
  highlight("RainbowDelimiter2", colors.blue, nil)
  highlight("RainbowDelimiter3", colors.green, nil)
  highlight("RainbowDelimiter4", colors.yellow, nil)
  highlight("RainbowDelimiter5", colors.orange, nil)
  highlight("RainbowDelimiter6", colors.red, nil)
  highlight("RainbowDelimiter7", colors.cyan, nil)
end

return naysayer

