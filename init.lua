-- Modern Neovim configuration without Lazy.nvim
-- Using native LSP, treesitter, and minimal plugin dependencies

-- Set up netrw before anything else
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0  -- Use regular listing style
vim.g.netrw_browse_split = 0  -- Open files in the current window
vim.g.netrw_altv = 0  -- Disable vertical splitting
vim.g.netrw_winsize = 25
vim.g.netrw_keepdir = 0
vim.g.netrw_special_syntax = 1
vim.g.netrw_list_hide = [[^\.$]]  -- Hide dot files by default
vim.g.netrw_hide = 1  -- Hide dot files by default
vim.g.netrw_use_errorwindow = 0  -- Don't use error window
vim.g.netrw_retmap = 1  -- Allow using <CR> to navigate into directories
vim.g.netrw_sort_by = "name"  -- Sort by name
vim.g.netrw_sort_direction = "normal"  -- Normal sort direction
vim.g.netrw_sort_options = "i"  -- Case-insensitive sorting

-- Load core configuration
require("config.options")
require("config.keymaps")

-- Load and setup native LSP
require("config.lsp").setup()
require("config.ctags").setup()

-- Load and setup blink.cmp (completion framework)
require("config.blink").setup()

-- Load and setup native treesitter
local treesitter = require("config.treesitter")
treesitter.setup()
treesitter.setup_debug_commands()
treesitter.setup_commands()

-- Load and setup telescope
require("config.telescope").setup()
require("config.telescope").setup_keymaps()
require("config.telescope").setup_commands()

-- Load and setup harpoon
require("config.harpoon").setup()

-- Load custom utilities
require("utils.make_detect").setup()
require("launch").setup()

-- Load and setup notes plugin
require("notes").setup()

-- Load and setup clipboard manager
require("config.clipboard").setup()

-- Load and setup divider comments (renders lines above //- comments)
require("divider_comments").setup()

-- Load and setup render-markdown
require("render-markdown").setup()

-- Load color scheme
vim.cmd.colorscheme("hh")

-- Comment tag highlights: NOTE(alex), TODO(alex), PERF(alex), etc.
-- Applied after colorscheme so they work with all themes
local function setup_comment_tags()
    local set = vim.api.nvim_set_hl
    set(0, "CommentTagNote",  { fg = "#2ab34f" })
    set(0, "CommentTagTodo",  { fg = "#ffa900" })
    set(0, "CommentTagPerf",  { fg = "#2895c7" })
    set(0, "CommentTagFixme", { fg = "#ff0000" })
    set(0, "CommentTagHack",  { fg = "#FF44DD" })
end

setup_comment_tags()

-- Re-apply after colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = setup_comment_tags,
})

-- Match patterns for NOTE(name)/TODO(name)/PERF(name) style comments
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.fn.matchadd("CommentTagNote",  [[\v<NOTE(\([^)]*\))?:?]])
        vim.fn.matchadd("CommentTagTodo",  [[\v<TODO(\([^)]*\))?:?]])
        vim.fn.matchadd("CommentTagPerf",  [[\v<PERF(\([^)]*\))?:?]])
        vim.fn.matchadd("CommentTagFixme", [[\v<FIXME(\([^)]*\))?:?]])
        vim.fn.matchadd("CommentTagHack",  [[\v<HACK(\([^)]*\))?:?]])
        vim.fn.matchadd("CommentTagHack",  [[\v<XXX(\([^)]*\))?:?]])
    end,
})


-- Build telescope-fzf-native if needed (silently)
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local fzf_path = vim.fn.stdpath("config") .. "/pack/plugins/start/telescope-fzf-native.nvim"
        local so_file = fzf_path .. "/build/fzf.so"

        if vim.fn.isdirectory(fzf_path) == 1 and vim.fn.filereadable(so_file) == 0 then
            vim.fn.system("cd " .. vim.fn.shellescape(fzf_path) .. " && make >/dev/null 2>&1")
        end

        -- Build blink.cmp Rust fuzzy matcher if needed
        local blink_path = vim.fn.stdpath("config") .. "/pack/plugins/start/blink.cmp"
        local blink_lib = blink_path .. "/target/release"
        if vim.fn.isdirectory(blink_path) == 1 and vim.fn.isdirectory(blink_lib) == 0 then
            vim.fn.system("cd " .. vim.fn.shellescape(blink_path) .. " && cargo build --release >/dev/null 2>&1")
        end
    end,
})
