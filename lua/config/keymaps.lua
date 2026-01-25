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

-- Format the file - use jai-format for .jai files, LSP for others
vim.keymap.set("n", "<leader>f", function()
    if vim.bo.filetype == "jai" then
        -- Save cursor position and view
        local view = vim.fn.winsaveview()
        
        -- Write buffer to temp file in /tmp (away from any .jai-format configs)
        local tmpfile = "/tmp/jai-format-buffer.jai"
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        vim.fn.writefile(lines, tmpfile)
        
        -- Run jai-format from /tmp to use default config
        local result = vim.fn.system("cd /tmp && jai-format -to_stdout " .. tmpfile .. " 2>/dev/null")
        local exit_code = vim.v.shell_error
        
        -- Clean up temp file
        vim.fn.delete(tmpfile)
        
        if exit_code == 0 and result ~= "" then
            -- Split result into lines and set buffer content
            local new_lines = vim.split(result, "\n", { plain = true })
            -- Remove trailing empty line if present (jai-format adds one)
            if new_lines[#new_lines] == "" then
                table.remove(new_lines)
            end
            vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
            -- Restore view
            vim.fn.winrestview(view)
        else
            vim.notify("jai-format failed: " .. result, vim.log.levels.ERROR)
        end
    else
        vim.lsp.buf.format()
    end
end)

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
