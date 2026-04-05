-- Neovim 0.12 configuration
-- Using vim.pack, native LSP, treesitter

-- Set up netrw before anything else
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_altv = 0
vim.g.netrw_winsize = 25
vim.g.netrw_keepdir = 0
vim.g.netrw_special_syntax = 1
vim.g.netrw_list_hide = [[^\.$]]
vim.g.netrw_hide = 1
vim.g.netrw_use_errorwindow = 0
vim.g.netrw_retmap = 1
vim.g.netrw_sort_by = "name"
vim.g.netrw_sort_direction = "normal"
vim.g.netrw_sort_options = "i"

-- Post-install/update build hooks (must register before vim.pack.add)
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
        local name = ev.data.spec.name
        local path = ev.data.path
        if name == 'telescope-fzf-native.nvim' then
            vim.system({ 'make' }, { cwd = path }):wait()
        end
    end,
})

-- Plugins (built-in package manager, Neovim 0.12+)
vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
    { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
})

-- Core
require("config.options")
require("config.keymaps")

-- LSP + completion
require("config.lsp").setup()
require("config.ctags").setup()

-- Treesitter
require("config.treesitter").setup()
require("config.c_keywords").setup()

-- Telescope + Harpoon
require("config.telescope").setup()
require("config.harpoon").setup()

-- Utilities
require("utils.make_detect").setup()
require("launch").setup()
require("notes").setup()
require("config.clipboard").setup()
require("divider_comments").setup()
require("config.comment_tags").setup()

-- Plugins
require("render-markdown").setup()

-- Colorscheme
vim.cmd.colorscheme("hh")
