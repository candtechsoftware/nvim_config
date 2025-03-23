-- Prettier error from lsp and can move erros to quickfix list
return {
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({
                icons = true,
                signs = {
                    -- Icons / text used for diagnostics
                    error = "E",
                    warning = "W",
                    hint = "H",
                    information = "I",
                    other = "O"
                },
                use_diagnostic_signs = false,
                auto_jump = false
            })

            -- Toggle trouble
            vim.keymap.set("n", "<leader>tt", function()
                require("trouble").toggle()
            end)
            
            -- Document diagnostics
            vim.keymap.set("n", "<leader>td", function()
                require("trouble").toggle("document_diagnostics")
            end)
            
            -- Workspace diagnostics (all errors across files)
            vim.keymap.set("n", "<leader>tw", function()
                require("trouble").toggle("workspace_diagnostics")
            end)
            
            -- LSP references
            vim.keymap.set("n", "<leader>tr", function()
                require("trouble").toggle("lsp_references")
            end)
            
            -- Quickfix list
            vim.keymap.set("n", "<leader>tq", function()
                require("trouble").toggle("quickfix")
            end)

            -- Direct way to send all diagnostics to quickfix list
            vim.keymap.set("n", "<leader>tx", function()
                vim.diagnostic.setqflist()
            end, { desc = "Send diagnostics to quickfix" })
            
            -- Add explicit keybinding to send Trouble items to quickfix
            vim.keymap.set("n", "<leader>tQ", function()
                local trouble = require("trouble")
                trouble.open()
                vim.cmd("TroubleClose")
                vim.cmd("copen")
            end, { desc = "Send Trouble to quickfix and open" })

            vim.keymap.set("n", "[t", function()
                require("trouble").next({skip_groups = true, jump = true});
            end)

            vim.keymap.set("n", "]t", function()
                require("trouble").previous({skip_groups = true, jump = true});
            end)

            -- Add quickfix navigation keybindings
            vim.keymap.set("n", "<leader>cn", ":cnext<CR>", { desc = "Next quickfix item" })
            vim.keymap.set("n", "<leader>cp", ":cprev<CR>", { desc = "Previous quickfix item" })
            vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "Open quickfix window" })
            vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "Close quickfix window" })
        end
    },
}
