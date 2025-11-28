-- Neovim options (migrated from set.lua)

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = {
        prefix = '●', -- Custom prefix
        source = "if_many", -- Show source when multiple
        severity = { min = vim.diagnostic.severity.WARN },
    }
})

-- Cursor configuration with mode colors
vim.opt.guicursor = {
    "n-c:block-Cursor",           -- Normal, Command: green cursor
    "v:block-CursorVisual",       -- Visual: orange cursor
    "i-ci:block-CursorInsert",    -- Insert: gold cursor
    "r-cr:block-CursorReplace",   -- Replace: red cursor
}

-- Line numbers
vim.o.number = false
vim.o.relativenumber = false

-- Remove tildes (~) on empty lines
vim.opt.fillchars:append({ eob = " " })

-- Set statusline with mode indicator
vim.o.laststatus = 2  -- Always show status line

-- Mode-aware statusline
local function get_mode_statusline()
    local mode_map = {
        ['n']  = { name = 'NORMAL',  hl = 'StatusLineNormal' },
        ['no'] = { name = 'NORMAL',  hl = 'StatusLineNormal' },
        ['v']  = { name = 'VISUAL',  hl = 'StatusLineVisual' },
        ['V']  = { name = 'V-LINE',  hl = 'StatusLineVisual' },
        [''] = { name = 'V-BLOCK', hl = 'StatusLineVisual' },
        ['s']  = { name = 'SELECT',  hl = 'StatusLineVisual' },
        ['S']  = { name = 'S-LINE',  hl = 'StatusLineVisual' },
        ['i']  = { name = 'INSERT',  hl = 'StatusLineInsert' },
        ['ic'] = { name = 'INSERT',  hl = 'StatusLineInsert' },
        ['R']  = { name = 'REPLACE', hl = 'StatusLineReplace' },
        ['Rv'] = { name = 'V-REPLACE', hl = 'StatusLineReplace' },
        ['c']  = { name = 'COMMAND', hl = 'StatusLineCommand' },
        ['cv'] = { name = 'VIM EX',  hl = 'StatusLineCommand' },
        ['ce'] = { name = 'EX',      hl = 'StatusLineCommand' },
        ['r']  = { name = 'PROMPT',  hl = 'StatusLineNormal' },
        ['rm'] = { name = 'MORE',    hl = 'StatusLineNormal' },
        ['r?'] = { name = 'CONFIRM', hl = 'StatusLineNormal' },
        ['!']  = { name = 'SHELL',   hl = 'StatusLineNormal' },
        ['t']  = { name = 'TERMINAL', hl = 'StatusLineInsert' },
    }
    local mode = vim.fn.mode()
    local info = mode_map[mode] or { name = mode, hl = 'StatusLine' }
    return info.name, info.hl
end

function StatusLine()
    local mode, hl = get_mode_statusline()
    return string.format('%%#%s# %s %%#StatusLine# %%f %%l:%%c', hl, mode)
end

vim.o.statusline = '%!v:lua.StatusLine()'

-- Indentation
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> key press in insert mode inserts
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.smartindent = true -- Automatically insert indents in the correct place

-- Line wrapping
vim.opt.wrap = false -- Don't wrap lines

-- File handling
vim.opt.swapfile = false -- Don't create swap files
vim.opt.backup = false -- Don't create backup files
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- Save undo history
vim.opt.undofile = true -- Save undo history

-- Search
vim.opt.hlsearch = false -- Don't highlight search results
vim.opt.incsearch = true -- Incremental search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.opt.signcolumn = "yes" -- Always show the sign column
vim.opt.colorcolumn = "" -- Disable the color column
vim.opt.updatetime = 250 -- Update interval for CursorHold and CursorHoldI

-- Performance optimizations
vim.opt.lazyredraw = false -- Keep false for smooth scrolling/cursor
vim.opt.synmaxcol = 300 -- Syntax highlight up to 300 columns
vim.opt.redrawtime = 1500 -- Time in ms for redrawing screen
vim.opt.timeoutlen = 400 -- Faster key sequence completion
vim.opt.ttimeoutlen = 10 -- Near-instant escape key response

-- Font and display
vim.o.guifont = "Liberation Mono:h18"
vim.g.tex_conceal = "mgs"

-- Disable italics for various highlight groups
vim.api.nvim_set_hl(0, "Comment", { italic = false })
vim.api.nvim_set_hl(0, "Keyword", { italic = false })
vim.api.nvim_set_hl(0, "Type", { italic = false })
vim.api.nvim_set_hl(0, "Function", { italic = false })
vim.api.nvim_set_hl(0, "Identifier", { italic = false })

vim.opt.splitright = true

if vim.g.neovide then
    vim.g.neovide_position_animation_length = 0.01
    vim.g.neovide_scroll_animation_length = 0.01
end

-- Optimized completion settings for performance and usability
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" } -- Show menu, don't auto-select/insert
vim.opt.pumheight = 15 -- Slightly larger popup for better visibility
vim.opt.pumwidth = 25 -- Consistent popup width
vim.opt.shortmess:append("c") -- Don't show completion messages
vim.opt.complete = ".,w,b,u" -- Faster completion sources (current buffer, windows, buffers, unloaded buffers)
