-- Telescope configuration
--
-- Lazy-loaded: requiring the telescope plugin (and the fzf-native extension)
-- is the single biggest cost in startup, but none of it is needed until the
-- first picker is opened. So M.setup() only registers keymaps; the plugin is
-- required and configured exactly once, on first use, via ensure(). External
-- callers that drive telescope directly (notes, divider_comments) call
-- M.ensure() first so they get this same custom config.

local M = {}

local function get_visual_selection()
    -- getregion handles reversed selections and single/multi-line slicing.
    return table.concat(
        vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = "v" }), "\n")
end

local find_project_root = require("utils.project_root").find

-- Trees every picker skips, and the reason they have to be listed explicitly.
--
-- `--no-ignore-vcs` (kept on purpose, so gitignored build output stays
-- searchable) means .gitignore does not filter anything, and vendored code is
-- checked IN, so nothing filtered it at all. Measured in ~/projects/notes:
-- `live_grep "render"` ran rg over the whole 1.7G tree on EVERY keystroke —
-- 1060ms and 32679 results, of which the top four sources were all
-- appgui/third_party/slang (a 9.9MB validusage.json alone contributed 3761
-- matches, plus vulkan_structs.hpp, Metal.hpp and vk.xml). With these globs
-- it is 67ms and 12229 results, and renderer's own hits are untouched
-- (4847 -> 4842; the five lost are under renderer/build).
--
-- --max-filesize caps the pathological generated headers this codebase has a
-- lot of (a 63MB slang-core-module-generated.h, 2.2MB fonts_embedded.h) —
-- nothing hand-written here comes close to 1MB.
local EXCLUDE_GLOBS = {
    "--glob=!.git/",
    "--glob=!node_modules/",
    "--glob=!**/third_party/**",
    "--glob=!**/thirdparty/**",
    "--glob=!**/vendor/**",
    "--glob=!**/external/**",
    "--glob=!**/build/**",
    "--glob=!**/out/**",
    "--glob=!**/*.dSYM/**",
    "--max-filesize=1M",
}

---rg argv with the exclusions appended, plus an optional tail that must come
---after them (`--` and the pattern, which have to be last).
---@param args string[]
---@param tail string[]|nil
---@return string[]
local function with_excludes(args, tail)
    local out = vim.list_extend(vim.deepcopy(args), EXCLUDE_GLOBS)
    return tail and vim.list_extend(out, tail) or out
end

-- Configure telescope exactly once, on first use.
local configured = false
function M.ensure()
    if configured then return end
    configured = true

    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
        defaults = {
            path_display = { "smart" },
            prompt_prefix = "> ",
            selection_caret = "> ",
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            vimgrep_arguments = with_excludes({
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--no-ignore-vcs",
                "--no-require-git",
            }),
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
                ".next/",
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
                find_command = with_excludes({
                    "rg",
                    "--files",
                    "--hidden",
                    "--no-ignore-vcs",
                    "--no-require-git",
                }),
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
end

-- Lazy accessor: telescope.builtin behind a one-time ensure().
local function builtin()
    M.ensure()
    return require("telescope.builtin")
end

function M.setup()
    -- Keymaps only — setup() above is deferred to the first picker.

    vim.keymap.set("n", "<leader>pws", function()
        local root = find_project_root()
        builtin().grep_string({
            search = vim.fn.expand("<cword>"),
            cwd = root,
            search_dirs = { root },
            word_match = "-w",
            prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
        })
    end, { desc = "Grep word under cursor (exact)" })

    vim.keymap.set("n", "<leader>pWs", function()
        local root = find_project_root()
        builtin().grep_string({
            search = vim.fn.expand("<cWORD>"),
            cwd = root,
            search_dirs = { root },
            prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
        })
    end, { desc = "Grep WORD under cursor" })

    vim.keymap.set("v", "<leader>ps", function()
        local root = find_project_root()
        local text = get_visual_selection()
        builtin().grep_string({
            search = text,
            cwd = root,
            search_dirs = { root },
            prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t")
        })
    end, { desc = "Grep selected text" })

    vim.keymap.set("n", "<leader>ff", function()
        local root = find_project_root()
        builtin().find_files({
            cwd = root,
            prompt_title = "Files in " .. vim.fn.fnamemodify(root, ":t")
        })
    end, { desc = "Find files" })

    vim.keymap.set("n", "<leader>/", function()
        local root = find_project_root()
        builtin().live_grep({
            cwd = root,
            prompt_title = "Grep in " .. vim.fn.fnamemodify(root, ":t") .. " (use **file to filter)",
            on_input_filter_cb = function(prompt)
                local search, glob = prompt:match("^(.-)%s+%*%*(.+)$")
                if search and glob ~= "" then
                    return { prompt = search, updated_finder = require("telescope.finders").new_job(function(new_prompt)
                        -- This finder builds its own argv, so it bypasses
                        -- defaults.vimgrep_arguments and needs the exclusions
                        -- applied explicitly — without them the **file filter
                        -- was the one grep path still scanning third_party.
                        return vim.iter(with_excludes({
                            "rg", "--color=never", "--no-heading", "--with-filename",
                            "--line-number", "--column", "--smart-case",
                            "--glob", "**" .. glob,
                        }, { "--", new_prompt })):flatten():totable()
                    end, require("telescope.make_entry").gen_from_vimgrep({ cwd = root }), nil, root) }
                end
                return { prompt = prompt }
            end,
        })
    end, { desc = "Live grep (project root, use **file to filter)" })

    vim.keymap.set("n", "<leader>.", function()
        local cwd = vim.fn.getcwd()
        builtin().live_grep({
            cwd = cwd,
            search_dirs = { cwd },
            prompt_title = "Grep in " .. vim.fn.fnamemodify(cwd, ":t")
        })
    end, { desc = "Live grep (current dir)" })

    vim.keymap.set("n", "<leader>pg", function()
        local root = find_project_root()
        builtin().live_grep({
            cwd = root,
            prompt_title = "Grep (strict, .gitignore) in " .. vim.fn.fnamemodify(root, ":t"),
            -- No --no-ignore-vcs here: this picker's whole purpose is the
            -- .gitignore-honoring search. It still gets the vendored-tree
            -- globs, because third_party is checked in and .gitignore never
            -- excluded it.
            vimgrep_arguments = with_excludes({
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
            }),
        })
    end, { desc = "Live grep (strict, honors .gitignore)" })

    vim.keymap.set("n", "<leader>gf", function() builtin().git_files() end, { desc = "Git files" })

    vim.keymap.set("n", "<leader>ds", function()
        if next(vim.lsp.get_clients({ bufnr = 0 })) then
            builtin().lsp_document_symbols()
        else
            builtin().current_buffer_tags()
        end
    end, { desc = "Document symbols (LSP, fallback ctags)" })

    vim.keymap.set("n", "<leader>ws", function()
        if next(vim.lsp.get_clients({ bufnr = 0 })) then
            builtin().lsp_workspace_symbols()
        else
            builtin().tags({ ctags_file = vim.fn.tagfiles()[1] })
        end
    end, { desc = "Workspace symbols (LSP, fallback ctags)" })

    vim.keymap.set("n", "<leader>gc", function() builtin().git_commits() end, { desc = "Git commits" })
    vim.keymap.set("n", "<leader>gb", function() builtin().git_branches() end, { desc = "Git branches" })
    vim.keymap.set("n", "<leader>gs", function() builtin().git_status() end, { desc = "Git status" })

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

                builtin().live_grep({
                    cwd = jai_modules_path,
                    prompt_title = "Jai " .. choice,
                    default_text = search_pattern,
                })
            end
        )
    end, { desc = "Search Jai module symbols" })

    vim.keymap.set("n", "<leader>jg", function()
        builtin().live_grep({
            cwd = jai_modules_path,
            prompt_title = "Grep Jai Modules",
        })
    end, { desc = "Grep search in Jai modules" })

    vim.keymap.set("n", "<leader>fg", function()
        local root = find_project_root()
        vim.ui.input({ prompt = "Search --- *.ext: " }, function(input)
            if not input or input == "" then return end

            local search, glob = input:match("^(.-)%s+%-%-%-%s+(%*.-)$")
            if not search or search == "" then
                search = input
                glob = nil
            end

            builtin().live_grep({
                cwd = root,
                default_text = search,
                glob_pattern = glob,
                prompt_title = glob and ("Grep (" .. glob .. ")") or "Grep",
            })
        end)
    end, { desc = "Grep with file type filter (search --- *.ext)" })
end

return M
