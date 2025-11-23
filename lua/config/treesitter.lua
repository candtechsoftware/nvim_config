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
            disable = { "zig" },
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
