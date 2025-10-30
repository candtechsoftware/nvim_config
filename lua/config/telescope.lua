-- Telescope configuration (migrated from lazy/telescope.lua)

local project_root = require("utils.project_root")

local M = {}

function M.setup()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")

    telescope.setup({
        defaults = {
            path_display = { "smart" },
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
            file_ignore_patterns = {
                "node_modules",
                ".git/",
                "dist/",
                "build/",
                ".next/",
                "coverage/",
            },
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "top",
                    preview_width = 0.55,
                },
                width = 0.9,
                height = 0.85,
            },
            sorting_strategy = "ascending",
        },
        pickers = {
            find_files = {
                hidden = true,
            },
            live_grep = {},
            grep_string = {},
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = false, -- Don't override, use ripgrep
                override_file_sorter = false,    -- Don't override, use ripgrep
                case_mode = "smart_case",
            },
        },
    })

    -- Don't load fzf extension - we want to use ripgrep
    -- if vim.fn.has("win32") ~= 1 then
    --     pcall(telescope.load_extension, "fzf")
    -- end
end

function M.setup_keymaps()
    local builtin = require("telescope.builtin")

    -- Helper function to get visual selection (preserving from original config)
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

    local function get_project_root()
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir = vim.fn.getcwd()
        
        local git_root = vim.fn.systemlist({ 'git', '-C', current_dir, 'rev-parse', '--show-toplevel' })
        if vim.v.shell_error == 0 and git_root[1] and git_root[1] ~= '' then
            return git_root[1]
        end
        
        return project_root.find({
            startpath = current_file,
            fallback_to_initial_cwd = true,
        })
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
            prompt_title = "Files in " .. vim.fn.fnamemodify(root, ":t")
        })
    end, { desc = "Find files" })

    vim.keymap.set("n", "<leader>/", function()
        local root = get_project_root()
        builtin.live_grep({
            cwd = root,
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

    vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git files" })

    -- Symbol search (use LSP for symbols)
    vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document symbols" })
    vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })

    -- Additional useful git commands
    vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
    vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
    vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

    -- Jai module search keymaps (preserving your custom functionality)
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
end

function M.setup_commands()
    -- Helper commands for workspace debugging
    vim.api.nvim_create_user_command('WorkspaceInfo', function()
        local function get_project_root()
            local start_dir
            local current_file = vim.fn.expand('%:p')

            if current_file ~= '' then
                start_dir = vim.fn.fnamemodify(current_file, ':h')
            else
                start_dir = vim.fn.getcwd()
            end

            local markers = { '.git', 'build.jai', 'first.jai', 'package.json', 'Cargo.toml', 'go.mod', 'CMakeLists.txt', 'Makefile', '.project', '.root' }
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
                if parent == current then break end
                current = parent
            end

            return start_dir
        end

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
        require('telescope').setup()
        vim.notify("Telescope configuration reloaded", vim.log.levels.INFO)
    end, { desc = 'Reload Telescope configuration' })
end

return M
