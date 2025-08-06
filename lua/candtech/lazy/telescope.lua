return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
                return vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1
            end,
        },
    },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                path_display = { "truncate" },
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<esc>"] = actions.close,
                    },
                    n = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["q"] = actions.close,
                    },
                },
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--follow",
                    "--glob",
                    "!.git/*",
                    "--glob",
                    "!node_modules/*",
                    "--glob",
                    "!.next/*",
                    "--glob",
                    "!dist/*",
                    "--glob",
                    "!build/*",
                    "--glob",
                    "!coverage/*",
                    "--glob",
                    "!*.lock",
                    "--glob",
                    "!*.log",
                },
                file_ignore_patterns = {
                    "node_modules",
                    ".git/",
                    "dist/",
                    "build/",
                    ".next/",
                    "coverage/",
                    "%.lock",
                    "%.log",
                },
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.6,
                    },
                    width = 0.9,
                    height = 0.85,
                },
                sorting_strategy = "ascending",
            },
            pickers = {
                find_files = {
                    hidden = true,
                    find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
                },
                live_grep = {
                    additional_args = function()
                        return { "--hidden" }
                    end,
                },
                grep_string = {
                    additional_args = function()
                        return { "--hidden" }
                    end,
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
        })

        -- Load fzf extension if available (not on Windows)
        if vim.fn.has("win32") ~= 1 then
            pcall(telescope.load_extension, "fzf")
        end

        -- Keymaps
        vim.keymap.set("n", "<leader>pws", function()
            builtin.grep_string({ search = vim.fn.expand("<cword>") })
        end, { desc = "Grep word under cursor" })

        vim.keymap.set("n", "<leader>pWs", function()
            builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
        end, { desc = "Grep WORD under cursor" })

        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Live grep (all files)" })
        -- Remove <leader>g/ as it's not easily implemented in telescope
        -- Use <leader>/ for general grep and <leader>gf to browse git files instead
        vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git files" })
        
        -- Symbol search
        vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document symbols" })
        vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, { desc = "Dynamic workspace symbols" })
        vim.keymap.set("n", "<leader>Ws", function()
            builtin.lsp_workspace_symbols({ query = "" })
        end, { desc = "Workspace symbols (all)" })
        
        -- Additional useful git commands
        vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
        vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
        vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
    end,
}
