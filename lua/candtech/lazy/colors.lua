return {
    "aktersnurra/no-clown-fiesta.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd("colorscheme no-clown-fiesta")
        vim.opt.background = 'dark'
        vim.api.nvim_command('au VimEnter * hi Normal ctermbg=0 guibg=#000000')

        -- Any additional highlight customizations
    end,
}

