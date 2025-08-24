return
{
    'RostislavArts/naysayer.nvim',
    dependencies = {
        'rktjmp/lush.nvim'
    },
    lazy = false,
    config = function()
        vim.cmd("colorscheme cand")
    end,
}
