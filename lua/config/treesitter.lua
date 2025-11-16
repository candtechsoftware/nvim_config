local M = {}

function M.setup()
    local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
    if not ok then
        return
    end

    ts_configs.setup({
        ensure_installed = {
            "c", "cpp", "lua", "rust", "go",
            "javascript", "typescript", "tsx",
            "json", "yaml", "toml", "bash", "vim", "vimdoc", "query"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = function(lang, buf)
                if lang == "zig" then
                    return true
                end

                -- More aggressive file size limits for performance
                local max_filesize = 50 * 1024  -- Reduced from 100KB to 50KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end

                -- Also disable for very long lines (performance killer)
                local max_line_length = 1000
                local lines = vim.api.nvim_buf_get_lines(buf, 0, 100, false)  -- Check first 100 lines
                for _, line in ipairs(lines) do
                    if #line > max_line_length then
                        return true
                    end
                end
            end,
            use_languagetree = true,  -- Better for complex files
        },
        indent = {
            enable = true,
            disable = { "python", "c", "cpp", "lua", "rust", "go", "jai" },
        },
        -- Performance: reduce incremental selection overhead
        incremental_selection = {
            enable = false,  -- Disable if not used
        },
        -- Performance: reduce textobjects overhead
        textobjects = {
            enable = false,  -- Disable if not used
        },
    })

    -- Async treesitter setup for better performance
    vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function(args)
            local buf = args.buf
            local file_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))

            -- For large files, delay treesitter parsing
            if file_size > 25 * 1024 then  -- 25KB threshold
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        -- Only start treesitter if parser exists for this filetype
                        local ok = pcall(vim.treesitter.get_parser, buf)
                        if ok then
                            vim.treesitter.start(buf)
                        end
                    end
                end, 100)
            end
        end,
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.jai",
        callback = function()
            vim.bo.filetype = "jai"
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
end

-- Debug commands (preserving your custom functionality)
function M.setup_debug_commands()
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

    -- Inspect highlight groups
    vim.keymap.set("n", "<leader>hi", "<cmd>Inspect<CR>", { desc = "Show treesitter highlight groups under cursor" })
end

function M.setup_commands()
end

return M
