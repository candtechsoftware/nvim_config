vim.opt.guicursor = "n-v-c:block-Cursor"

vim.opt.nu = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers

vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> key press in insert mode inserts
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.smartindent = true -- Automatically insert indents in the correct place

vim.opt.wrap = false -- Don't wrap lines

vim.opt.swapfile = false -- Don't create swap files (super annoyin trust me on this)
vim.opt.backup = false -- Don't create backup files (same as above)
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Save undo history
vim.opt.undofile = true -- Save undo history
  
vim.opt.hlsearch = false -- Don't highlight search results (I don't like this but you might)
vim.opt.incsearch = true -- Incremental search

vim.opt.termguicolors = false -- Enable 24-bit RGB colors, I don't care for them 

vim.opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.opt.signcolumn = "yes" -- Always show the sign column

vim.opt.updatetime = 50 -- Update interval for CursorHold and CursorHoldI
 
vim.opt.colorcolumn = "100" -- Highlight the 100th column try to keep lines under 100 characters 
