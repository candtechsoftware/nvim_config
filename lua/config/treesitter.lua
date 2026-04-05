local M = {}

function M.setup()
    -- Parser management (native, no nvim-treesitter plugin)
    require("config.ts_parsers").setup()

    -- Neovim 0.12 built-in treesitter highlighting
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            local ft = vim.bo[args.buf].filetype
            -- Skip filetypes that shouldn't use treesitter
            if ft == "zig" or ft == "" then return end
            -- Start treesitter highlighting if a parser exists
            pcall(vim.treesitter.start, args.buf)
        end,
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.zig",
        callback = function()
            vim.bo.filetype = "zig"
            vim.cmd("setlocal syntax=on")
            pcall(vim.treesitter.stop)
        end,
    })

    -- Debug keymaps
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

    vim.keymap.set("n", "<leader>hi", "<cmd>Inspect<CR>", { desc = "Show treesitter highlight groups under cursor" })
end

return M
