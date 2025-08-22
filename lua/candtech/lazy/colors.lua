return
{
        'sainnhe/gruvbox-material',
        dependencies = {
            'rktjmp/lush.nvim'
        },
        lazy = false,
        config = function()

            vim.cmd("colorscheme gruvbox-material")
        end,
}
