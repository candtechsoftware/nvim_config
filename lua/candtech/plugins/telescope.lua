return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make", -- Ensure the fzf-native extension is built
        },
    },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")

        -- Telescope setup
        telescope.setup({
            defaults = {
                -- Ignore unnecessary files for better performance
                file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/", "%.lock", "%.log" },

                -- UI and layout improvements
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.6, -- Larger preview for better visibility
                        results_width = 0.4,
                    },
                    width = 0.9,
                    height = 0.85,
                    preview_cutoff = 100, -- Disable preview for small windows
                },

                -- Enable sorting and preview optimizations
                sorting_strategy = "ascending", -- Show results in ascending order
                path_display = { "truncate" }, -- Truncate long paths for better readability

                -- Mappings for better navigation
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next, -- Move to next item
                        ["<C-k>"] = actions.move_selection_previous, -- Move to previous item
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- Send to quickfix
                        ["<esc>"] = actions.close, -- Close Telescope
                    },
                },

                -- Performance optimizations
                dynamic_preview_title = true, -- Dynamically update preview title
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden", -- Include hidden files
                    "--glob=!.git/*", -- Exclude .git directory
                },
            },
            pickers = {
                find_files = {
                    hidden = true, -- Show hidden files
                    find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" }, -- Use fd for better performance
                },
                live_grep = {
                    additional_args = function()
                        return { "--hidden", "--ignore-case" }
                    end,
                },
                git_files = {
                    show_untracked = true, -- Show untracked files in Git
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true, -- Enable fuzzy searching
                    override_generic_sorter = true, -- Override the generic sorter
                    override_file_sorter = true, -- Override the file sorter
                    case_mode = "smart_case", -- Use smart case
                },
            },
        })

        -- Load the fzf extension
        telescope.load_extension("fzf")
        vim.keymap.set("n", "<leader>fs", builtin.lsp_dynamic_workspace_symbols, opts) -- Find symbols in the workspace

        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)

        -- Keymaps
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<leader>pf", builtin.find_files, opts) -- Find files
        vim.keymap.set("n", "<leader>/", builtin.live_grep, opts) -- Search in files
        vim.keymap.set("n", "<leader>fb", builtin.buffers, opts) -- List open buffers
        vim.keymap.set("n", "<leader>vh", builtin.help_tags, opts) -- Search help tags
        vim.keymap.set("n", "<leader>ff", builtin.git_files, opts) -- Find Git files
    end,
}

