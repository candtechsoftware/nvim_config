-- Telescope configuration

local M = {}

local function get_visual_selection()
    local _, ls, cs = unpack(vim.fn.getpos("v"))
    local _, le, ce = unpack(vim.fn.getpos("."))

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
    return require("utils.project_root").find()
end

function M.setup()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
        defaults = {
            path_display = { "smart" },
            prompt_prefix = "> ",
            selection_caret = "> ",
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob=!.git/",
            },
            preview = {
                treesitter = false,
            },
            cache_picker = {
                num_pickers = 10,
                limit_entries = 1000,
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
            file_ignore_patterns = {
                "node_modules",
                ".git/",
                "dist/",
                "build/",
                ".next/",
                "coverage/",
            },
            layout_strategy = "vertical",
            layout_config = {
                vertical = {
                    prompt_position = "bottom",
                    mirror = false,
                    preview_height = 0.4,
                },
                width = 0.8,
                height = 0.8,
            },
            sorting_strategy = "descending",
        },
        pickers = {
            find_files = {
                hidden = true,
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

    if vim.fn.has("win32") ~= 1 then
        pcall(telescope.load_extension, "fzf")
    end

    -- Keymaps
    local builtin = require("telescope.builtin")

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

    vim.keymap.set("v", "<leader>ps", function()
        local root = get_project_root()
        local text = get_visual_selection()
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
            prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t") .. " (use **file to filter)",
            on_input_filter_cb = function(prompt)
                local search, glob = prompt:match("^(.-)%s+%*%*(.+)$")
                if search and glob ~= "" then
                    return { prompt = search, updated_finder = require("telescope.finders").new_job(function(new_prompt)
                        return vim.tbl_flatten({ "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", "--glob", "**" .. glob, "--", new_prompt }
                        )
                    end, require("telescope.make_entry").gen_from_vimgrep({ cwd = root }), nil, root) }
                end
                return { prompt = prompt }
            end,
        })
    end, { desc = "Live grep (project root, use **file to filter)" })

    vim.keymap.set("n", "<leader>.", function()
        local cwd = vim.fn.getcwd()
        builtin.live_grep({
            cwd = cwd,
            search_dirs = { cwd },
            prompt_title = "Grep in " .. vim.fn.fnamemodify(cwd, ":t")
        })
    end, { desc = "Live grep (current dir)" })

    vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git files" })

    vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document symbols" })
    vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })

    vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
    vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
    vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

    -- Jai module search
    local jai_modules_path = "/Users/alexmatthewcandelario/gits/jai/modules"

    vim.keymap.set("n", "<leader>js", function()
        vim.ui.select(
            { "All Symbols", "Functions (::)", "Structs", "Enums", "Constants" },
            { prompt = "Select symbol type to search:" },
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
                end

                builtin.live_grep({
                    cwd = jai_modules_path,
                    prompt_title = "Jai " .. choice,
                    default_text = search_pattern,
                })
            end
        )
    end, { desc = "Search Jai module symbols" })

    vim.keymap.set("n", "<leader>jg", function()
        builtin.live_grep({
            cwd = jai_modules_path,
            prompt_title = "Grep Jai Modules",
        })
    end, { desc = "Grep search in Jai modules" })

    vim.keymap.set("n", "<leader>fg", function()
        local root = get_project_root()
        vim.ui.input({ prompt = "Search --- *.ext: " }, function(input)
            if not input or input == "" then return end

            local search, glob = input:match("^(.-)%s+%-%-%-%s+(%*.-)$")
            if not search or search == "" then
                search = input
                glob = nil
            end

            builtin.live_grep({
                cwd = root,
                default_text = search,
                glob_pattern = glob,
                prompt_title = glob and ("Grep (" .. glob .. ")") or "Grep",
            })
        end)
    end, { desc = "Grep with file type filter (search --- *.ext)" })
end

return M
