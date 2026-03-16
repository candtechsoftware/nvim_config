vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Take you to netrw (file explorer)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z") -- Join lines without spaces
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Move down half a page and center the cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Move up half a page and center the cursor
vim.keymap.set("n", "n", "nzzzv") -- Keep the cursor centered when searching
vim.keymap.set("n", "N", "Nzzzv") -- Keep the cursor centered when searching

vim.keymap.set("x", "<leader>p", [["_dP]]) -- Paste without yanking
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]]) -- Copy to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]]) -- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d") -- Delete without yanking
vim.keymap.set('n', '<leader>pc', '"+p', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>pc', '"+p', { noremap = true, silent = true })

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz") -- Move to the next quickfix item
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz") -- Move to the previous quickfix item
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz") -- Move to the next location list item
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz") -- Move to the previous location list item

-- Tabs
vim.keymap.set("n", "<leader>t", "<cmd>tabnew<CR>zz")
vim.keymap.set("n", "<leader><Tab>", "<cmd>tabnext<CR>zz")
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>zz")


-- Search and replace
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Search and replace the word under the cursor

-- Source file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end) -- Source the file


-- Notes keybindings
vim.keymap.set("n", "<leader>ns", function()
    require("notes").search_notes()
end, { desc = "Search notes content" })

vim.keymap.set("n", "<leader>nf", function()
    require("notes").find_notes()
end, { desc = "Find notes by filename" })

vim.keymap.set("n", "<leader>nn", function()
    require("notes").new_note()
end, { desc = "Create new note" })

vim.keymap.set("n", "<leader>n", function()
    require("notes").open_notes_dir()
end, { desc = "Open notes directory" })

vim.keymap.set("n", "<leader>ng", function()
    require("notes").git_status()
end, { desc = "Notes git status" })

-- Comment navigation
vim.keymap.set("n", "]c", function()
    vim.fn.search("\\v^\\s*(//|#|--|\"|'|/\\*|\\*)", "W")
end, { desc = "Next comment" })

vim.keymap.set("n", "[c", function()
    vim.fn.search("\\v^\\s*(//|#|--|\"|'|/\\*|\\*)", "bW")
end, { desc = "Previous comment" })
