vim.g.mapleader = " "

-- Take you to the builtin directory browser (:h dir) at the current file's dir
vim.keymap.set("n", "<leader>pv", function()
    local dir = vim.fn.expand("%:p:h")
    vim.cmd.edit(dir ~= "" and dir or ".")
end, { desc = "Open directory browser" })

-- The builtin browser is navigation-only (`<CR>` open, `-` up, `R` reload);
-- it cannot touch the filesystem. Add netrw's create keys on top.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "directory",
    callback = function(ev)
        local function dirpath()
            return vim.api.nvim_buf_get_name(ev.buf)
        end
        vim.keymap.set("n", "%", function()
            local name = vim.fn.input("New file: ")
            if name ~= "" then
                vim.cmd.edit(vim.fs.joinpath(dirpath(), name))
            end
        end, { buffer = ev.buf, desc = "New file in this directory (:w to create)" })
        vim.keymap.set("n", "d", function()
            local name = vim.fn.input("New directory: ")
            if name ~= "" then
                vim.fn.mkdir(vim.fs.joinpath(dirpath(), name), "p")
                vim.cmd.edit() -- re-edit triggers the listing's reload
            end
        end, { buffer = ev.buf, desc = "New directory here" })
        vim.keymap.set("n", "D", function()
            local line = vim.api.nvim_get_current_line()
            if line == "" then return end
            local isdir = line:sub(-1) == "/"
            local name = isdir and line:sub(1, -2) or line
            local what = isdir and ("directory " .. name .. " and its contents") or name
            if vim.fn.confirm("Delete " .. what .. "?", "&Yes\n&No", 2) ~= 1 then
                return
            end
            local path = vim.fs.joinpath(dirpath(), name)
            if vim.fn.delete(path, isdir and "rf" or "") ~= 0 then
                vim.notify("Failed to delete " .. path, vim.log.levels.ERROR)
            end
            vim.cmd.edit()
        end, { buffer = ev.buf, desc = "Delete entry under cursor" })
        vim.keymap.set("n", "r", function()
            local line = vim.api.nvim_get_current_line()
            if line == "" then return end
            local isdir = line:sub(-1) == "/"
            local name = isdir and line:sub(1, -2) or line
            local newname = vim.fn.input({ prompt = "Rename to: ", default = name })
            if newname == "" or newname == name then return end
            local from = vim.fs.joinpath(dirpath(), name)
            local to = vim.fs.joinpath(dirpath(), newname)
            if vim.fn.rename(from, to) ~= 0 then
                vim.notify("Failed to rename " .. from, vim.log.levels.ERROR)
            end
            vim.cmd.edit()
        end, { buffer = ev.buf, desc = "Rename entry under cursor" })
    end,
})

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
vim.keymap.set("n", "<leader>qf", function()
    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
    vim.cmd("copen")
end, { desc = "Send diagnostic errors to quickfix" }) -- e.g. clang/clangd errors
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

-- Undotree: the builtin nvim.undotree pack (0.13, replaces mbbill/undotree).
-- open() toggles; inside the window, moving the cursor changes the undo state.
vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
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
-- Tab is the ONLY way to OPEN the popup; nothing auto-triggers it. (While it
-- is open, lua/config/lsp.lua re-queries the server on each keystroke when
-- the last reply was truncated — see the InsertCharPre autocmd there.)
-- With an LSP: vim.lsp.completion.get() (native, textEdit ranges honored;
--   `<C-x><C-o>` via an LSP omnifunc concatenates the prefix with some servers).
-- Without an LSP (unity-build C/C++): route by context —
--   * after a member operator (`.`/`->`/`::`) -> `<C-x><C-o>` omni completion,
--     which is the built-in `ccomplete` (omnifunc set by runtime ftplugin/c.vim);
--     it does real struct/union member completion via the tags file.
--   * otherwise -> `<C-n>` keyword completion: per 'complete' it merges buffer
--     words, other buffers and tags, so it also catches local variables and
--     parameters, which are NOT in the tags file.

---True if the text before the cursor ends with a member-access operator
---(`.`, `->`, `::`) + an optional partial identifier — including when the
---operator follows `)` or `]` (`get_x().`, `arr[i].`). After ANY member
---operator we want omni completion: if the type resolves it returns the
---type's members, and if it can't it returns nothing. Keyword completion
---here would instead dump the whole tag file ("wild"), which is never what
---you want after a `.`. A float literal like `3.` also routes to omni and
---harmlessly yields an empty result.
---@return boolean
local function at_member_access()
  local col = vim.fn.col(".")
  local before = vim.fn.getline("."):sub(1, col - 1)
  return before:match("%.%s*[%w_]*$") ~= nil
    or before:match("%->%s*[%w_]*$") ~= nil
    or before:match("::%s*[%w_]*$") ~= nil
end

vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  if next(vim.lsp.get_clients({ bufnr = 0 })) then
    vim.schedule(function() vim.lsp.completion.get() end)
    return ""
  end
  -- No LSP attached (e.g. unity-build C/C++): route by context.
  if at_member_access() then return "<C-x><C-o>" end
  -- Plain identifier: the smart treesitter+tags completefunc when one is set
  -- (C/C++ — see lua/config/c_complete.lua), else plain keyword completion.
  if vim.bo.completefunc ~= "" then return "<C-x><C-u>" end
  return "<C-n>"
end, { expr = true, desc = "Tab: LSP completion, else omni/smart/keyword completion" })
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
