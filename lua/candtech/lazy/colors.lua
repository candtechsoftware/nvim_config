return
{
    "morhetz/gruvbox",
    dependencies = {
        'rktjmp/lush.nvim'
    },
    lazy = false,
    config = function()
        vim.cmd("colorscheme cand")

        -- Make the sign column background match the main background
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
            for _, group in ipairs(vim.fn.getcompletion('', 'highlight')) do
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, {name = group, link = false})
                if ok and hl.bold then
                    hl.bold = false
                    vim.api.nvim_set_hl(0, group, hl)
                end
            end

    end,
}
