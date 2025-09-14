
vim.diagnostic.config({
    virtual_text = {
        prefix = '●', -- Custom prefix
        source = "if_many", -- Show source when multiple
        severity = { min = vim.diagnostic.severity.WARN },
    }
    --
})

vim.opt.guicursor = {
  "n-v-c:block",       -- Normal, Visual, Command: block cursor
  "i-ci:block",         -- Insert, Insert Command: horizontal line (underline)
}
vim.o.number = false
vim.o.relativenumber = false

-- Remove tildes (~) on empty lines
vim.opt.fillchars:append({ eob = " " })

-- Set statusline to: filename line:col
vim.o.laststatus = 2  -- Always show status line
vim.o.statusline = "%f %l:%c"

vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> key press in insert mode inserts
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.smartindent = true -- Automatically insert indents in the correct place

vim.opt.wrap = false -- Don't wrap lines

vim.opt.swapfile = false -- Don't create swap files (super annoyin trust me on this)
vim.opt.backup = false -- Don't create backup files (same as above)
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- Save undo history
vim.opt.undofile = true -- Save undo history
vim.opt.hlsearch = false -- Don't highlight search results (I don't like this but you might)
vim.opt.incsearch = true -- Incremental search

vim.opt.scrolloff = 8 -- Keep 8 lines above and below the cursor
vim.opt.signcolumn = "yes" -- Always show the sign column

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 50 -- Update interval for CursorHold and CursorHoldI

vim.g.tex_conceal = "mgs"
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
