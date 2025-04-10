return {
    "ibhagwan/fzf-lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    config = function()
        local fzf = require("fzf-lua")

        fzf.setup({
            winopts = {
                height = 0.85,
                width = 0.9,
                preview = {
                    layout = "flex", -- automatically adjust between horizontal and vertical
                    horizontal = "right:60%", -- preview on the right taking 60% width
                    vertical = "down:75%",
                    flip_columns = 120,
                },
                prompt = " > ",
                prompt_pos = "top",
            },

            keymap = {
                builtin = {
                    -- these match telescope's <C-j>, <C-k>, <C-q>, and <esc>
                    ["<C-j>"] = "down",
                    ["<C-k>"] = "up",
                    ["<C-q>"] = "toggle-all+accept",
                    ["<esc>"] = "abort",
                },
            },

            files = {
                prompt = "Find Files❯ ",
                cmd = "fd --type f --hidden",
                git_icons = true,
                file_icons = true,
                color_icons = true,
                fd_opts = "--type f --hidden",
                actions = {
                    ["default"] = fzf.actions.file_edit,
                    ["ctrl-q"] = fzf.actions.file_sel_to_qf,
                },
            },

            grep = {
                prompt = "Live Grep❯ ",
                input_prompt = "Grep For❯ ",
                rg_opts =
                "--color=never --no-heading --with-filename --line-number --column --smart-case --hidden --glob=!.git/*",
                actions = {
                    ["default"] = fzf.actions.file_edit,
                    ["ctrl-q"] = fzf.actions.file_sel_to_qf,
                },
            },

            git = {
                files = {
                    prompt = "Git Files❯ ",
                    cmd = "git ls-files --others --cached --exclude-standard",
                },
            },

            quickfix = {
                file_icons = true,
                git_icons = true,
            },

            fzf_opts = {
                ["--ansi"] = true,
                ["--layout"] = "reverse",
                ["--info"] = "inline",
                ["--prompt"] = " > ",
                ["--pointer"] = "▶",
                ["--marker"] = "✓",
            },
        })

        -- Keymaps (equivalent to Telescope ones)
        vim.keymap.set("n", "<leader>pws", function()
            fzf.grep_cword()
        end, { desc = "Grep word under cursor" })

        vim.keymap.set("n", "<leader>pWs", function()
            fzf.grep_cWORD()
        end, { desc = "Grep WORD under cursor" })

        vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>/", fzf.grep_project, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>gf", fzf.git_files, { desc = "Git files" })
    end,
}
