return
{
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000, 
        config = function()
            vim.cmd("colorscheme candark")
            -- Make the sign column background match the main background
            vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
        end,
    }
