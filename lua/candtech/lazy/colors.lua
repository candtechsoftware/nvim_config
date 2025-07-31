return
{
        'luisiacc/handmade-hero-theme',
        lazy = false,
        config = function()
            vim.opt.termguicolors = false

            vim.cmd("colorscheme handmade-hero-theme")
        vim.cmd [[
             highlight Normal ctermbg=None
             highlight NormalNC ctermbg=None
             highlight EndOfBuffer ctermbg=None
             highlight VertSplit ctermbg=None
             highlight StatusLine ctermbg=None
             highlight SignColumn ctermbg=None
             highlight LineNr ctermbg=None
             highlight CursorLine ctermbg=None
             highlight CursorLineNr ctermbg=None
             highlight FoldColumn ctermbg=None
        ]]
    end,
}
