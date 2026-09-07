-- Telescope configuration
--
-- File finding and live grep moved to fff.nvim (config/fff.lua). What is left
-- here is everything fff has no equivalent for: buffer/oldfile jumping, git
-- pickers, LSP/ctags symbols, the <leader>pg escape hatch that greps
-- gitignored files (fff never indexes those, so it cannot search them), and
-- the custom pickers in notes/ and divider_comments.lua.
--
-- Lazy-loaded: requiring the telescope plugin (and the fzf-native extension)
-- is the single biggest cost in startup, but none of it is needed until the
-- first picker is opened. So M.setup() only registers keymaps; the plugin is
-- required and configured exactly once, on first use, via ensure(). External
-- callers that drive telescope directly (notes, divider_comments) call
-- M.ensure() first so they get this same custom config.

local M = {}

local search_root = require("utils.project_root").search_root

-- Trees every telescope picker skips, and the reason they have to be listed
-- explicitly. fff gets the same exclusions a different way -- it has no glob
-- config at all, so :FFFIgnore writes them as a .ignore file (config/fff.lua).
--
-- Vendored code is checked IN, so .gitignore does not filter it: these globs
-- are what keeps it out. Measured in ~/projects/notes: `live_grep "render"`
-- ran rg over the whole 1.7G tree on EVERY keystroke — 1060ms and 32679
-- results, of which the top four sources were all appgui/third_party/slang (a
-- 9.9MB validusage.json alone contributed 3761 matches, plus
-- vulkan_structs.hpp, Metal.hpp and vk.xml). With these globs it is 67ms and
-- 12229 results, and renderer's own hits are untouched (4847 -> 4842; the five
-- lost are under renderer/build).
--
-- .gitignore is honoured (no `--no-ignore-vcs`): a glob list cannot keep up
-- with what a JS/TS tree generates, and every project here already gitignores
-- its build output. Measured, files per keystroke and `live_grep` wall time:
--
--   ~/work/app             40232 -> 4849,  919ms -> 77ms   (ios/Pods: 18719
--                          .h + 7974 .hpp + 1998 .m, same 2913 real hits)
--   ~/work/percipio-repo   78173 -> 46592, 1970ms -> 994ms (compiled lib/,
--                          generated/, types/, and .claude/worktrees copies
--                          that returned every hit a second time)
--   ~/projects C trees     lose 1-2 files each (a stray .json, a .clangd);
--                          raddebugger-mac loses none
--
-- --max-filesize caps the pathological generated headers this codebase has a
-- lot of (a 63MB slang-core-module-generated.h, 2.2MB fonts_embedded.h) —
-- nothing hand-written here comes close to 1MB.
--
-- The vendored/build directory names come from lua/utils/skip_dirs.lua, shared
-- with clangd_setup, ctags and hh.macros — one miss there silently disables
-- this whole optimization (it did: 2320 files and 15070 grep hits per keystroke
-- for a 30-file project). The entries below are the ones telescope needs on top
-- of that shared list:
--
--   .git/, *.dSYM/   never interesting to grep, not vendored code
--   external/        deliberately NOT in the shared list — clangd_setup and
--                    ctags both look INSIDE external/ for real include dirs
--   .cache/          `--hidden` makes rg descend into it, and clangd puts its
--                    background index there (binary .idx blobs in the tree)
local EXCLUDE_GLOBS = vim.list_extend({
    "--glob=!.git/",
    "--glob=!**/external/**",
    "--glob=!**/.cache/**",
    "--glob=!**/*.dSYM/**",
    "--max-filesize=1M",
}, require("utils.skip_dirs").flags("--glob=!**/%s/**"))

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

    -- Buffer/recent-file jumping. These replace harpoon: it was the only
    -- "hop between the N files I'm working in" mechanism, and neither picker
    -- was bound anywhere before it was removed.
    vim.keymap.set("n", "<leader>fb", function()
        builtin().buffers({ sort_mru = true, ignore_current_buffer = true })
    end, { desc = "Find buffers" })

    vim.keymap.set("n", "<leader>fo", function()
        builtin().oldfiles({ cwd_only = true })
    end, { desc = "Find recent files (this project)" })

    vim.keymap.set("n", "<leader>pg", function()
        local root = search_root()
        builtin().live_grep({
            cwd = root,
            prompt_title = "Grep (+ignored) in " .. vim.fn.fnamemodify(root, ":t"),
            -- The escape hatch, now that every other picker honours
            -- .gitignore: `--no-ignore-vcs` puts build output, generated code
            -- and vendored SDKs back in. Slow by construction — in ~/work/app
            -- it is the difference between 4849 files and 40232.
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
            }),
        })
    end, { desc = "Live grep (includes gitignored files)" })

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

end

return M
