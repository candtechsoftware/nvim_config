return
{
        'srcery-colors/srcery-vim',
        lazy = false,
        config = function()
            vim.opt.termguicolors = true

            vim.cmd("colorscheme fleury")
        end,
}
