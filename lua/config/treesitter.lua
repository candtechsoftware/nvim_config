local M = {}

-- Byte size past which a buffer gets no treesitter. Generated C headers are
-- the reason: renderer/src/font/fonts_embedded.h is 2.2MB of byte-array
-- initializer and appgui/build has a 63MB one. Parsing those blocks the UI on
-- open, and because treesitter re-parses on every edit, the buffer stays
-- laggy for the whole session. 512KB clears every hand-written source in
-- these projects (the largest is ~780KB of generated code) while catching the
-- embedded-asset headers that actually hurt.
local MAX_TS_BYTES = 512 * 1024

---Should this buffer get treesitter highlighting?
---@param buf integer
---@return boolean
local function ts_viable(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    -- Prefer the on-disk size: it is one stat, whereas nvim_buf_get_offset
    -- on an unloaded-then-loaded buffer costs a full line walk. Fall back to
    -- the byte offset of the last line for buffers with no file behind them.
    local st = name ~= "" and vim.uv.fs_stat(name) or nil
    local bytes = st and st.size
        or vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
    return bytes <= MAX_TS_BYTES
end

function M.setup()
    -- Parser management (native, no nvim-treesitter plugin)
    require("config.ts_parsers").setup()

    -- Neovim 0.12 built-in treesitter highlighting
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            local ft = vim.bo[args.buf].filetype
            -- Skip filetypes that shouldn't use treesitter
            if ft == "zig" or ft == "" then return end
            -- Huge (usually generated) files get no treesitter, and no regex
            -- syntax either — leaving `syntax on` would just trade one slow
            -- highlighter for another on the same buffer.
            --
            -- Scheduled, not set inline: $VIMRUNTIME/syntax/synload.vim also
            -- hooks FileType, and when it runs after this callback it sets
            -- 'syntax' back to the filetype (measured: syntax="cpp" on a 2.2MB
            -- header this had just disabled). Deferring puts the `off` after
            -- the whole FileType chain, whichever order the autocmds fire in.
            if not ts_viable(args.buf) then
                local buf = args.buf
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.bo[buf].syntax = "off"
                    end
                end)
                return
            end
            -- Start treesitter highlighting if a parser exists.
            -- objcpp uses the objc parser via the language.register call
            -- in ftdetect/objc.lua.
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
