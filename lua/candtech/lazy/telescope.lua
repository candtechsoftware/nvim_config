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
                path_display = { "smart" },
                preview = {
                    hide_on_startup = false,
                },
                prompt_prefix = "> ",
                selection_caret = "> ",
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
                    "--trim",
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
                    "--glob",
                    "!*.min.js",
                    "--glob",
                    "!*.min.css",
                },
                file_ignore_patterns = {
                    "^node_modules/",
                    "^.git/",
                    "^dist/",
                    "^build/",
                    "^.next/",
                    "^coverage/",
                    "%.lock$",
                    "%.log$",
                    "%.min%.js$",
                    "%.min%.css$",
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
                    follow = true,
                    find_command = { 
                        "rg", 
                        "--files", 
                        "--hidden", 
                        "--follow",
                        "--glob", "!.git/*",
                        "--glob", "!node_modules/*",
                        "--glob", "!*.lock",
                        "--glob", "!*.log"
                    },
                },
                live_grep = {
                    additional_args = function()
                        return { "--hidden", "--follow", "--trim" }
                    end,
                    disable_coordinates = false,
                    only_sort_text = false,
                },
                grep_string = {
                    additional_args = function()
                        return { "--hidden", "--follow", "--trim" }
                    end,
                    disable_coordinates = false,
                    only_sort_text = false,
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
        
        -- Helper function to get visual selection
        vim.getVisualSelection = function()
            local _, ls, cs = unpack(vim.fn.getpos("v"))
            local _, le, ce = unpack(vim.fn.getpos("."))
            
            -- Swap if selection is backwards
            if ls > le or (ls == le and cs > ce) then
                ls, le = le, ls
                cs, ce = ce, cs
            end
            
            local lines = vim.fn.getline(ls, le)
            if #lines == 0 then return "" end
            
            if #lines == 1 then
                lines[1] = string.sub(lines[1], cs, ce)
            else
                lines[1] = string.sub(lines[1], cs)
                lines[#lines] = string.sub(lines[#lines], 1, ce)
            end
            
            return table.concat(lines, "\n")
        end

        -- Function to find project root (similar to LSP workspace detection)
        local function get_project_root()
            -- Start from current buffer's directory or cwd
            local start_dir
            local current_file = vim.fn.expand('%:p')
            
            if current_file ~= '' then
                start_dir = vim.fn.fnamemodify(current_file, ':h')
            else
                start_dir = vim.fn.getcwd()
            end
            
            -- Try to find project markers in order of preference
            local markers = {
                -- Git is most common
                '.git',
                -- Jai specific
                'build.jai',
                'first.jai',
                -- Common project files
                'package.json',
                'Cargo.toml',
                'go.mod',
                'CMakeLists.txt',
                'Makefile',
                '.project',
                '.root'
            }
            
            -- Search upward from start directory, but stop at home directory
            local home = vim.fn.expand('~')
            local current = start_dir
            
            while current ~= home and current ~= '/' do
                for _, marker in ipairs(markers) do
                    local marker_path = current .. '/' .. marker
                    if vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1 then
                        return current
                    end
                end
                
                local parent = vim.fn.fnamemodify(current, ':h')
                if parent == current then
                    break
                end
                current = parent
            end
            
            -- If no marker found, try git root from current working directory
            local git_root = vim.fn.system("cd " .. vim.fn.shellescape(start_dir) .. " && git rev-parse --show-toplevel 2>/dev/null")
            if vim.v.shell_error == 0 and git_root ~= "" then
                return vim.fn.trim(git_root)
            end
            
            -- Use start directory as fallback (not home or root)
            return start_dir
        end

        -- Keymaps with improved search
        vim.keymap.set("n", "<leader>pws", function()
            local root = get_project_root()
            builtin.grep_string({ 
                search = vim.fn.expand("<cword>"),
                cwd = root,
                search_dirs = { root },
                word_match = "-w",
                prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
            })
        end, { desc = "Grep word under cursor (exact)" })

        vim.keymap.set("n", "<leader>pWs", function()
            local root = get_project_root()
            builtin.grep_string({ 
                search = vim.fn.expand("<cWORD>"),
                cwd = root,
                search_dirs = { root },
                prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
            })
        end, { desc = "Grep WORD under cursor" })
        
        -- Add visual mode grep
        vim.keymap.set("v", "<leader>ps", function()
            local root = get_project_root()
            local text = vim.getVisualSelection()
            builtin.grep_string({ 
                search = text,
                cwd = root,
                search_dirs = { root },
                prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
            })
        end, { desc = "Grep selected text" })

        vim.keymap.set("n", "<leader>ff", function()
            local root = get_project_root()
            builtin.find_files({ 
                cwd = root,
                search_dirs = { root },
                prompt_title = "Files in " .. vim.fn.fnamemodify(root, ":t")
            })
        end, { desc = "Find files" })
        
        vim.keymap.set("n", "<leader>/", function()
            local root = get_project_root()
            builtin.live_grep({ 
                cwd = root,
                search_dirs = { root },
                prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
            })
        end, { desc = "Live grep (project root)" })
        
        -- Add a keybinding for current directory search
        vim.keymap.set("n", "<leader>.", function()
            local cwd = vim.fn.getcwd()
            builtin.live_grep({ 
                cwd = cwd,
                search_dirs = { cwd },
                prompt_title = "Grep in " .. vim.fn.fnamemodify(cwd, ":t")
            })
        end, { desc = "Live grep (current dir)" })
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
            local cwd = vim.fn.getcwd()
            local buf_path = vim.fn.expand('%:p:h')
            vim.notify(string.format("Project root: %s\nCurrent dir: %s\nBuffer dir: %s", root, cwd, buf_path), vim.log.levels.INFO)
        end, { desc = 'Show current workspace root' })
        
        vim.api.nvim_create_user_command('WorkspaceReset', function()
            vim.g.initial_cwd = nil
            vim.notify("Workspace root cache cleared", vim.log.levels.INFO)
        end, { desc = 'Reset workspace root cache' })
        
        -- Command to reload Telescope configuration
        vim.api.nvim_create_user_command('TelescopeReload', function()
            require('plenary.reload').reload_module('telescope')
            require('telescope').setup(telescope.setup())
            vim.notify("Telescope configuration reloaded", vim.log.levels.INFO)
        end, { desc = 'Reload Telescope configuration' })

        -- Jai module search keymaps
        local jai_modules_path = "/Users/alexmatthewcandelario/gits/jai/modules"
        
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
