vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Take you to netrw (file explorer)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z") -- Join lines without spaces
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Move down half a page and center the cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Move up half a page and center the cursor
vim.keymap.set("n", "n", "nzzzv") -- Keep the cursor centered when searching
vim.keymap.set("n", "N", "Nzzzv") -- Keep the cursor centered when searching
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true }) -- Clear search highlight

vim.keymap.set("x", "<leader>p", [["_dP]]) -- Paste without yanking
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d") -- Delete without yanking

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz") -- Move to the next quickfix item
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz") -- Move to the previous quickfix item
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz") -- Move to the next location list item
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz") -- Move to the previous location list item

-- Splits and buffers
vim.keymap.set("n", "<C-,>", "<C-w>w", { desc = "Cycle splits" })
vim.keymap.set("n", "<C-.>", "<C-^>", { desc = "Swap to alternate buffer" })

-- Tabs
vim.keymap.set("n", "<leader>t", "<cmd>tabnew<CR>zz")
vim.keymap.set("n", "<leader><Tab>", "<cmd>tabnext<CR>zz")
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>zz")


-- Search and replace
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Search and replace the word under the cursor

-- Undotree
vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    vim.cmd.Undotree()
end, { desc = "Toggle undotree" })

-- Source file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end) -- Source the file

-- Inlay hints
vim.keymap.set("n", "<leader>ih", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Completion: Tab cycles next, Shift-Tab cycles prev, Enter accepts.
local c_completion_ft = { c = true, cpp = true, objc = true, objcpp = true, hlsl = true }
vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  -- C/C++ buffers: drive the popup via ctags (clangd has no compile_commands
  -- in unity-build projects). Schedule because <expr> mappings can't directly
  -- call vim.fn.complete().
  if c_completion_ft[vim.bo.filetype] then
    vim.schedule(function() require("config.ctags").complete_prefix() end)
    return ""
  end
  return "<C-x><C-o>"
end, { expr = true, desc = "Tab: open / cycle next in popup" })
vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-p>" end
  return "<S-Tab>"
end, { expr = true, desc = "Shift-Tab: cycle prev in popup" })
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info({ "selected" }).selected ~= -1 then
      return "<C-y>"
    end
    return "<C-e><CR>"
  end
  return "<CR>"
end, { expr = true, desc = "Enter: accept selection or insert newline" })
vim.keymap.set("i", "<C-]>", "<C-x><C-]>", { desc = "Trigger tag completion" })

-- Comment navigation
vim.keymap.set("n", "]c", function()
    vim.fn.search("\\v^\\s*(//|#|--|\"|'|/\\*|\\*)", "W")
end, { desc = "Next comment" })

vim.keymap.set("n", "[c", function()
    vim.fn.search("\\v^\\s*(//|#|--|\"|'|/\\*|\\*)", "bW")
end, { desc = "Previous comment" })
