-- witness.lua
local M = {}

-- Color palette
local colors = {
    bg = "#072626",
    fg = "#d3b58d",
    accent = "#d3b58d",
    light_blue = "lightblue",
    light_green = "lightgreen",
    white = "white",
    comment_green = "#3fdf1f",
    cyan = "#79ffcf",
    string_cyan = "#0fdfaf",
    selection_blue = "blue",
    error_bg = "#504038",
    error_fg = "darkseagreen",
    visual_highlight = "#0f3f3f",  -- A slightly lighter shade of the background
}

function M.setup()
    -- Reset highlighting
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    -- Set colorscheme name
    vim.g.colors_name = "witness"

    -- Define highlight groups
    local groups = {
        -- Editor highlights
        Normal = { fg = colors.fg, bg = colors.bg },
        CursorLine = { bg = colors.bg },
        Visual = { bg = colors.visual_highlight},
        Search = { bg = colors.light_green, fg = colors.white },
        LineNr = { fg = colors.fg },
        CursorLineNr = { fg = colors.accent },
        VertSplit = { fg = colors.fg },
        StatusLine = { fg = colors.fg, bg = colors.bg },
        StatusLineNC = { fg = colors.fg, bg = colors.bg },

        -- Syntax highlighting
        Comment = { fg = colors.comment_green },
        Constant = { fg = colors.cyan },
        String = { fg = colors.string_cyan },
        Identifier = { fg = colors.light_blue },
        Function = { fg = colors.light_green},
        Statement = { fg = colors.white },
        Keyword = { fg = colors.light_blue},
        Type = { fg = colors.light_green },
        Special = { fg = colors.accent },
        Error = { fg = colors.error_fg, bg = colors.error_bg },

        -- Netrw
        netrwDir = { fg = colors.light_blue },
        netrwClassify = { fg = colors.accent },
        netrwPlain = { fg = colors.fg },
        netrwExe = { fg = colors.light_green },

        -- Telescope
        TelescopeBorder = { fg = colors.accent },
        TelescopePromptBorder = { fg = colors.accent },
        TelescopeResultsBorder = { fg = colors.accent },
        TelescopePreviewBorder = { fg = colors.accent },
        TelescopeSelectionCaret = { fg = colors.accent },
        TelescopeSelection = { bg = colors.visual_highlight },
        TelescopeMatching = { fg = colors.cyan },
        TelescopePromptPrefix = { fg = colors.accent },

        -- Additional common highlights
        Pmenu = { fg = colors.fg, bg = colors.bg },
        PmenuSel = { fg = colors.white, bg = colors.visual_highlight },
        SignColumn = { bg = colors.bg },
        ColorColumn = { bg = colors.bg },
        Folded = { fg = colors.accent, bg = colors.bg },
        MatchParen = { fg = colors.accent, underline = true },
    }

    -- Apply highlights
    for group, settings in pairs(groups) do
        vim.api.nvim_set_hl(0, group, settings)
    end
end

return M


