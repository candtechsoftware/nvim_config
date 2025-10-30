-- Neovim options (migrated from set.lua)

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = {
        prefix = '●', -- Custom prefix
        source = "if_many", -- Show source when multiple
        severity = { min = vim.diagnostic.severity.WARN },
    }
})

-- Cursor configuration
vim.opt.guicursor = {
    "n-v-c:block",       -- Normal, Visual, Command: block cursor
    "i-ci:block",        -- Insert, Insert Command: block cursor
}

-- Line numbers
vim.o.number = false
vim.o.relativenumber = false

-- Remove tildes (~) on empty lines
vim.opt.fillchars:append({ eob = " " })

-- Set statusline to: filename line:col
vim.o.laststatus = 2  -- Always show status line
vim.o.statusline = "%f %l:%c"

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

-- UI
vim.opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.opt.signcolumn = "yes" -- Always show the sign column
vim.opt.colorcolumn = "" -- Disable the color column
vim.opt.updatetime = 50 -- Update interval for CursorHold and CursorHoldI

-- Performance optimizations
vim.opt.lazyredraw = false -- Keep false for smooth experience
vim.opt.synmaxcol = 240 -- Only syntax highlight first 240 columns
vim.opt.redrawtime = 1500 -- Time in ms for redrawing screen

-- Font and display
vim.o.guifont = "Liberation Mono:h18"
vim.g.tex_conceal = "mgs"

-- Disable italics for various highlight groups
vim.api.nvim_set_hl(0, "Comment", { italic = false })
vim.api.nvim_set_hl(0, "Keyword", { italic = false })
vim.api.nvim_set_hl(0, "Type", { italic = false })
vim.api.nvim_set_hl(0, "Function", { italic = false })
vim.api.nvim_set_hl(0, "Identifier", { italic = false })

-- Window splitting
vim.opt.splitright = true

-- Neovide specific settings
if vim.g.neovide then
    vim.g.neovide_position_animation_length = 0.01
    vim.g.neovide_scroll_animation_length = 0.01
end

-- Completion settings
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" } -- Don't auto-select or auto-insert
vim.opt.pumheight = 10 -- Limit popup menu height
vim.opt.shortmess:append("c") -- Don't show completion messages