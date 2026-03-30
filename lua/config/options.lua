-- Neovim options

-- Cursor configuration - disable all blinking
vim.opt.guicursor = "a:block-blinkon0"

-- Line numbers
vim.o.number = false
vim.o.relativenumber = false

-- Remove tildes (~) on empty lines
vim.opt.fillchars:append({ eob = " " })

-- Set statusline with mode indicator
vim.o.laststatus = 2  -- Always show status line

vim.o.statusline = ' %f %l:%c'

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
vim.opt.smoothscroll = true
vim.opt.signcolumn = "auto" -- Only show sign column when needed
vim.opt.colorcolumn = "" -- Disable the color column
vim.opt.updatetime = 250 -- Update interval for CursorHold and CursorHoldI

-- Performance optimizations
vim.opt.synmaxcol = 300 -- Syntax highlight up to 300 columns
vim.opt.redrawtime = 1500 -- Time in ms for redrawing screen
vim.opt.timeoutlen = 400 -- Faster key sequence completion
vim.opt.ttimeoutlen = 10 -- Near-instant escape key response

vim.g.tex_conceal = "mgs"

-- Disable italics for various highlight groups
vim.api.nvim_set_hl(0, "Comment", { italic = false })
vim.api.nvim_set_hl(0, "Keyword", { italic = false })
vim.api.nvim_set_hl(0, "Type", { italic = false })
vim.api.nvim_set_hl(0, "Function", { italic = false })
vim.api.nvim_set_hl(0, "Identifier", { italic = false })

vim.opt.splitright = true

-- Use system clipboard for all yank/paste operations
vim.opt.clipboard = "unnamedplus"

if vim.g.neovide then
    vim.g.neovide_position_animation_length = 0.01
    vim.g.neovide_scroll_animation_length = 0.01
end


