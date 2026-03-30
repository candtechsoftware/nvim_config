-- Harpoon configuration

local M = {}

function M.setup()
    local harpoon = require("harpoon")
    harpoon:setup({})

    -- Add file to harpoon
    vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():add()
    end, { desc = "Harpoon add file" })

    -- Quick access to harpooned files
    vim.keymap.set("n", "<C-h>", function()
        harpoon:list():select(1)
    end)
    vim.keymap.set("n", "<C-t>", function()
        harpoon:list():select(2)
    end)
    vim.keymap.set("n", "<C-n>", function()
        harpoon:list():select(3)
    end)
    vim.keymap.set("n", "<C-s>", function()
        harpoon:list():select(4)
    end)

    -- Navigate between harpooned files
    vim.keymap.set("n", "<leader>hp", function()
        harpoon:list():prev()
    end, { desc = "Harpoon prev file" })
    vim.keymap.set("n", "<leader>hn", function()
        harpoon:list():next()
    end, { desc = "Harpoon next file" })

    -- Toggle harpoon menu using telescope (simplified since we don't have fzf-lua)
    vim.keymap.set("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Open harpoon menu" })
end

return M