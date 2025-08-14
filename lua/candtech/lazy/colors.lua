return
{
        'metalelf0/jellybeans-nvim',
        dependencies = {
            'rktjmp/lush.nvim'
        },
        lazy = false,
        config = function()
            vim.opt.termguicolors = true

            vim.cmd("colorscheme jellybeans-nvim")
        end,
}
