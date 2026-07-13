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
            -- Async + exit-code checked: a :wait() here froze the UI for the
            -- whole build, and a silent failure left telescope on the slow Lua
            -- sorter with no indication (telescope.lua pcall's load_extension).
            vim.system({ 'make' }, { cwd = path }, vim.schedule_wrap(function(res)
                if res.code ~= 0 then
                    vim.notify('telescope-fzf-native build failed:\n' .. (res.stderr or ''),
                        vim.log.levels.ERROR)
                end
            end))
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
require("config.clangd_setup").setup()

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

-- render-markdown.nvim self-initializes via its plugin/render-markdown.lua
-- (sourced by vim.pack), so no explicit setup() call is needed here.

-- UI2: new commandline + message UI (Neovim 0.12+).
-- `vim._core.ui2` is private/@nodoc and there is still no public equivalent in
-- 0.13 (:h ui2 documents this exact call). pcall'd so a rename upstream can't
-- abort init.lua before the colorscheme below ever loads.
pcall(function()
    require('vim._core.ui2').enable({})
end)

-- Colorscheme
vim.cmd.colorscheme("handmade")
