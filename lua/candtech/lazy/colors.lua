return 
{
    "drewxs/ash.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd("colorscheme ash")
        vim.opt.background = 'dark'
        vim.api.nvim_command('au VimEnter * hi Normal ctermbg=0 guibg=#000000')

        -- Any additional highlight customizations
    end,
}
