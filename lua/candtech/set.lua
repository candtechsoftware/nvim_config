vim.opt.guicursor = "n-v-c:block-Cursor"

vim.opt.nu = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = false -- Enable 24-bit RGB colors, I don't care for them

vim.opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.opt.signcolumn = "yes" -- Always show the sign column

vim.opt.updatetime = 50 -- Update interval for CursorHold and CursorHoldI
 
vim.opt.colorcolumn = "100" 
