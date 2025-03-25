function ColorMyPencils()
    vim.cmd('colorscheme naysayer')
    -- vim.g.termguicolors = false

    --vim.api.nvim_set_hl(0, "Normal", { bg = "black" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "black" })


end


return {
    {
        'alljokecake/naysayer-theme.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd('colorscheme naysayer')
            -- Any additional highlight customizations
        end,
    }
}
