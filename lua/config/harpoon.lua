-- Harpoon configuration
--
-- Lazy-loaded: the harpoon plugin is required and configured the first time
-- one of its keymaps is pressed, not at startup. M.setup() only registers the
-- (cheap) keymaps.

local M = {}

-- Require + configure harpoon exactly once, returning the singleton.
local harpoon
local function H()
    if not harpoon then
        harpoon = require("harpoon")
        harpoon:setup({})
    end
    return harpoon
end

function M.setup()
    -- Add file to harpoon
    vim.keymap.set("n", "<leader>ha", function()
        H():list():add()
    end, { desc = "Harpoon add file" })

    -- Quick access to harpooned files
    vim.keymap.set("n", "<C-h>", function()
        H():list():select(1)
    end)
    vim.keymap.set("n", "<C-t>", function()
        H():list():select(2)
    end)
    vim.keymap.set("n", "<C-n>", function()
        H():list():select(3)
    end)
    vim.keymap.set("n", "<C-s>", function()
        H():list():select(4)
    end)

    -- Navigate between harpooned files
    vim.keymap.set("n", "<leader>hp", function()
        H():list():prev()
    end, { desc = "Harpoon prev file" })
    vim.keymap.set("n", "<leader>hn", function()
        H():list():next()
    end, { desc = "Harpoon next file" })

    -- Toggle harpoon menu using telescope (simplified since we don't have fzf-lua)
    vim.keymap.set("n", "<C-e>", function()
        local h = H()
        h.ui:toggle_quick_menu(h:list())
    end, { desc = "Open harpoon menu" })
end

return M
