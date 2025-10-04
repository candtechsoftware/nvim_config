-- Tilt-view plugin configuration
--return {
--    {
--        dir = "~/gits/tilt-view.nvim", -- Local plugin path
--        name = "tilt-view",
--        config = function()
--            require("tilt-view").setup({
--                host = "localhost",
--                port = 10350,
--                auto_connect = true,
--            })
--
--            -- Create the Tilt command
--            vim.api.nvim_create_user_command("Tilt", function(opts)
--                require("tilt-view").command(opts.args)
--            end, {
--                nargs = "*",
--                complete = function(ArgLead, CmdLine, CursorPos)
--                    return require("tilt-view").complete(ArgLead, CmdLine, CursorPos)
--                end,
--            })
--
--            -- Optional keybindings
--            vim.keymap.set("n", "<leader>tt", ":Tilt show<CR>", { desc = "Show Tilt resources" })
--            vim.keymap.set("n", "<leader>tr", ":Tilt restart ", { desc = "Restart Tilt resource" })
--            vim.keymap.set("n", "<leader>tl", ":Tilt logs ", { desc = "Show Tilt logs" })
--        end,
--    },
--}
--
return {
  'candtechsoftware/tilt-view.nvim',
  config = function()
    require("tilt-view").setup()
  end
}

