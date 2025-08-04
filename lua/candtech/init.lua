-- Load basic configurations first
require("candtech.set")
require("candtech.remap")

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0  -- Use regular listing style
vim.g.netrw_browse_split = 0  -- Open files in the current window
vim.g.netrw_altv = 0  -- Disable vertical splitting
vim.g.netrw_winsize = 25
vim.g.netrw_keepdir = 0
vim.g.netrw_special_syntax = 1
vim.g.netrw_list_hide = [[^\.$]]  -- Hide dot files by default
vim.g.netrw_hide = 1  -- Hide dot files by default
vim.g.netrw_use_errorwindow = 0  -- Don't use error window
vim.g.netrw_retmap = 1  -- Allow using <CR> to navigate into directories
vim.g.netrw_sort_by = "name"  -- Sort by name
vim.g.netrw_sort_direction = "normal"  -- Normal sort direction
vim.g.netrw_sort_options = "i"  -- Case-insensitive sorting

-- Load lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Initialize lazy with all plugins
require("lazy").setup({
    -- Import all plugin specs from the lazy directory
    { import = "candtech.lazy" },
}, {
        change_detection = {
            enabled = true,
            notify = false,  -- Don't show notifications about config changes
        },
        checker = {
            enabled = true,  -- Enable checking for plugin updates
            notify = false,  -- Don't show notifications about updates
        },
        performance = {
            rtp = {
                disabled_plugins = {
                    "gzip",
                    "matchit",
                    "matchparen",
                    "tarPlugin",
                    "tohtml",
                    "tutor",
                    "zipPlugin",
                },
            },
        },
    })
