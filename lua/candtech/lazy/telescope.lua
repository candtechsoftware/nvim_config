return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "rluba/jai.vim",
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
                preview = {
                    hide_on_startup = false,
                },
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
                        preview_width = 0.55,
                        preview_cutoff = 40,
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

        -- Function to find project root (similar to LSP workspace detection)
        local function get_project_root()
            local current_file = vim.fn.expand('%:p')
            local current_dir = vim.fn.fnamemodify(current_file, ':h')
            
            -- Try to find project markers in order of preference
            local markers = {
                -- Jai specific
                'build.jai',
                'first.jai',
                -- Common project files
                '.git',
                'package.json',
                'Cargo.toml',
                'go.mod',
                'CMakeLists.txt',
                'Makefile',
                '.project',
                '.root'
            }
            
            -- Search upward from current file's directory
            for _, marker in ipairs(markers) do
                local found = vim.fn.findfile(marker, current_dir .. ';')
                if found ~= '' then
                    return vim.fn.fnamemodify(found, ':h')
                end
                local found_dir = vim.fn.finddir(marker, current_dir .. ';')
                if found_dir ~= '' then
                    return vim.fn.fnamemodify(found_dir, ':h')
                end
            end
            
            -- Try git root as fallback
            local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
            if vim.v.shell_error == 0 and git_root and git_root ~= "" then
                return git_root
            end
            
            -- Use the initial working directory as final fallback
            -- Store it once to avoid it changing when using netrw
            if not vim.g.initial_cwd then
                vim.g.initial_cwd = vim.fn.getcwd()
            end
            return vim.g.initial_cwd
        end

        -- Keymaps
        vim.keymap.set("n", "<leader>pws", function()
            builtin.grep_string({ 
                search = vim.fn.expand("<cword>"),
                cwd = get_project_root()
            })
        end, { desc = "Grep word under cursor" })

        vim.keymap.set("n", "<leader>pWs", function()
            builtin.grep_string({ 
                search = vim.fn.expand("<cWORD>"),
                cwd = get_project_root()
            })
        end, { desc = "Grep WORD under cursor" })

        vim.keymap.set("n", "<leader>ff", function()
            builtin.find_files({ cwd = get_project_root() })
        end, { desc = "Find files" })
        
        vim.keymap.set("n", "<leader>/", function()
            builtin.live_grep({ cwd = get_project_root() })
        end, { desc = "Live grep (all files)" })
        -- Remove <leader>g/ as it's not easily implemented in telescope
        -- Use <leader>/ for general grep and <leader>gf to browse git files instead
        vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git files" })

        -- Symbol search
        vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document symbols" })
        vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })

        -- Additional useful git commands
        vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
        vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
        vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

        -- Helper commands for workspace debugging
        vim.api.nvim_create_user_command('WorkspaceInfo', function()
            local root = get_project_root()
            vim.notify(string.format("Current workspace root: %s", root), vim.log.levels.INFO)
        end, { desc = 'Show current workspace root' })
        
        vim.api.nvim_create_user_command('WorkspaceReset', function()
            vim.g.initial_cwd = nil
            vim.notify("Workspace root cache cleared", vim.log.levels.INFO)
        end, { desc = 'Reset workspace root cache' })

        -- Jai module search keymaps
        local jai_modules_path = "~/gits/jai/modules"
        
        -- Search for symbols (functions/structs) in Jai modules
        vim.keymap.set("n", "<leader>js", function()
            -- Create a simple menu for symbol type selection
            vim.ui.select(
                { "All Symbols", "Functions (::)", "Structs", "Enums", "Constants" },
                {
                    prompt = "Select symbol type to search:",
                },
                function(choice)
                    if not choice then return end
                    
                    local search_pattern = ""
                    if choice == "Functions (::)" then
                        search_pattern = "\\w+\\s*::"
                    elseif choice == "Structs" then
                        search_pattern = "struct\\s+\\w+"
                    elseif choice == "Enums" then
                        search_pattern = "enum\\s+\\w+"
                    elseif choice == "Constants" then
                        search_pattern = "^\\s*\\w+\\s*::\\s*:"
                    else
                        -- For "All Symbols", start with empty search and let user type
                        search_pattern = ""
                    end
                    
                    builtin.live_grep({
                        cwd = jai_modules_path,
                        prompt_title = "Jai " .. choice,
                        default_text = search_pattern,
                    })
                end
            )
        end, { desc = "Search Jai module symbols" })

        -- Grep search in Jai modules
        vim.keymap.set("n", "<leader>jg", function()
            builtin.live_grep({
                cwd = jai_modules_path,
                prompt_title = "Grep Jai Modules",
            })
        end, { desc = "Grep search in Jai modules" })
    end,
}
