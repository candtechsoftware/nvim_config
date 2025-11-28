-- YouCompleteMe keybindings for C/C++
-- NOTE: Global YCM settings are in init.lua (must load before plugin)
local M = {}

function M.setup()
    -- Set up keybindings for C/C++ files (clangd backend)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        callback = function(args)
            local opts = { buffer = args.buf, silent = true }

            -- Navigation
            vim.keymap.set("n", "gd", "<cmd>YcmCompleter GoTo<CR>", opts)
            vim.keymap.set("n", "gD", "<cmd>YcmCompleter GoToDeclaration<CR>", opts)
            vim.keymap.set("n", "gi", "<cmd>YcmCompleter GoToInclude<CR>", opts)
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
