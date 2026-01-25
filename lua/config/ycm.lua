-- YouCompleteMe keybindings for C/C++
-- NOTE: Global YCM settings are in init.lua (must load before plugin)
-- YCM is in pack/plugins/opt/ and only loads for C/C++ files
local M = {}

local ycm_loaded = false

function M.setup()
    -- Load YCM only for C/C++ files
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        callback = function(args)
            -- Load YCM plugin once
            if not ycm_loaded then
                vim.cmd("packadd YouCompleteMe")
                ycm_loaded = true
            end

            local opts = { buffer = args.buf, silent = true }

            -- Navigation
            vim.keymap.set("n", "gd", "<cmd>YcmCompleter GoTo<CR>", opts)
            vim.keymap.set("n", "gD", "<cmd>YcmCompleter GoToDeclaration<CR>", opts)
            vim.keymap.set("n", "gi", "<cmd>YcmCompleter GoToInclude<CR>", opts)
            vim.keymap.set("n", "<leader>gi", "<cmd>YcmCompleter GoToDefinition<CR>", opts)
            -- K uses YCMHover which shows popup that auto-closes on cursor move
            vim.keymap.set("n", "K", "<Plug>(YCMHover)", opts)
            vim.keymap.set("n", "<C-k>", "<cmd>YcmCompleter GetType<CR>", opts)
            -- Toggle signature help visibility in insert mode
            vim.keymap.set("i", "<C-s>", "<Plug>(YCMToggleSignatureHelp)", opts)

            -- Actions
            vim.keymap.set("n", "<leader>vrr", "<cmd>YcmCompleter GoToReferences<CR>", opts)
            vim.keymap.set("n", "<leader>vrn", function()
                local new_name = vim.fn.input("New name: ")
                if new_name and new_name ~= "" then
                    vim.cmd("YcmCompleter RefactorRename " .. new_name)
                end
            end, opts)
            vim.keymap.set("n", "<leader>vca", "<cmd>YcmCompleter FixIt<CR>", opts)
            vim.keymap.set("n", "<leader>vi", "<cmd>YcmCompleter GoToCallers<CR>", opts)

            -- Formatting
            vim.keymap.set("n", "<leader>f", "<cmd>YcmCompleter Format<CR>", opts)
        end,
    })
end

return M
