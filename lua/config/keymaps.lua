-- Keymaps configuration (migrated from remap.lua + custom queries)

-- Set leader key
vim.g.mapleader = " "

-- File explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Take you to netrw (file explorer)

-- Move lines up and down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Text manipulation
vim.keymap.set("n", "J", "mzJ`z") -- Join lines without spaces
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Move down half a page and center the cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Move up half a page and center the cursor
vim.keymap.set("n", "n", "nzzzv") -- Keep the cursor centered when searching
vim.keymap.set("n", "N", "Nzzzv") -- Keep the cursor centered when searching

-- Clipboard operations
vim.keymap.set("x", "<leader>p", [["_dP]]) -- Paste without yanking
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]]) -- Copy to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]]) -- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d") -- Delete without yanking
vim.keymap.set('n', '<leader>pc', '"+p', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>pc', '"+p', { noremap = true, silent = true })

-- LSP formatting
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format) -- Format the file

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz") -- Move to the next quickfix item
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz") -- Move to the previous quickfix item
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz") -- Move to the next location list item
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz") -- Move to the previous location list item

-- Search and replace
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Search and replace the word under the cursor

-- Source file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end) -- Source the file

-- Treesitter debug keymaps (preserving your custom functionality)
vim.keymap.set("n", "<leader>hi", "<cmd>Inspect<CR>") -- Show treesitter highlight groups under cursor

-- Debug treesitter
vim.keymap.set("n", "<leader>ts", function()
    print("Filetype: " .. vim.bo.filetype)
    local buf = vim.api.nvim_get_current_buf()
    local has_parser = pcall(vim.treesitter.get_parser, buf)
    print("Treesitter enabled: " .. tostring(has_parser))
    if has_parser then
        local parser = vim.treesitter.get_parser(buf)
        print("Parser lang: " .. parser:lang())
    end
end, { desc = "Debug treesitter" })

-- Show all highlight groups under cursor
vim.keymap.set("n", "<leader>hh", function()
    local captures = vim.treesitter.get_captures_at_cursor(0)
    if #captures == 0 then
        print("No captures found")
    else
        for _, capture in ipairs(captures) do
            print("Capture: @" .. capture)
        end
    end
end, { desc = "Show treesitter captures" })

-- Completion keymaps for native LSP completion
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP completion" })

vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    else
        return "<Tab>"
    end
end, { expr = true, desc = "Navigate completion menu" })

vim.keymap.set("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-p>"
    else
        return "<S-Tab>"
    end
end, { expr = true, desc = "Navigate completion menu backwards" })

vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-y>"
    else
        return "<CR>"
    end
end, { expr = true, desc = "Accept completion or new line" })