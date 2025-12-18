-- Modern Neovim configuration without Lazy.nvim
-- Using native LSP, treesitter, and minimal plugin dependencies

-- YouCompleteMe settings (must be set BEFORE plugin loads)
vim.g.ycm_use_clangd = 1  -- Use clangd backend
vim.g.ycm_clangd_binary_path = vim.fn.exepath('clangd')
vim.g.ycm_clangd_args = {
    '--background-index',
    '--header-insertion=never',
    '--completion-style=detailed',  -- Shows [kind] in completions
    '--function-arg-placeholders=0',
    '--fallback-style=llvm',
    '--pch-storage=memory',
    '-j=4',
}
vim.g.ycm_filetype_whitelist = {
    c = 1,
    cpp = 1,
    objc = 1,
    objcpp = 1,
    cuda = 1,
}
vim.g.ycm_auto_hover = ''  -- Disable auto hover, use K manually
vim.g.ycm_auto_trigger = 1
vim.g.ycm_disable_signature_help = 0  -- Enable signature help
vim.g.ycm_signature_help_disable_syntax = 0  -- Keep syntax highlighting in signature popup
vim.g.ycm_key_list_select_completion = {'<Tab>', '<Down>'}
vim.g.ycm_key_list_previous_completion = {'<S-Tab>', '<Up>'}
vim.g.ycm_key_list_stop_completion = {}  -- Don't capture Esc (causes double-Esc issue)
vim.g.ycm_show_diagnostics_ui = 0  -- Disable diagnostics (for unity builds)
vim.g.ycm_enable_diagnostic_signs = 0
vim.g.ycm_enable_diagnostic_highlighting = 0
vim.g.ycm_semantic_triggers = {
    c = { '->', '.' },
    cpp = { '->', '.', '::' },
}
vim.g.ycm_confirm_extra_conf = 0  -- Auto-load .ycm_extra_conf.py
vim.g.ycm_clangd_uses_ycmd_caching = 0  -- Let clangd handle caching
vim.g.ycm_add_preview_to_completeopt = 0  -- No preview window
vim.g.ycm_complete_in_comments = 1
vim.g.ycm_collect_identifiers_from_comments_and_strings = 1

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

-- Load and setup YouCompleteMe for C/C++
require("config.ycm").setup()

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

-- Load color scheme
vim.cmd.colorscheme("hh")


-- Build telescope-fzf-native if needed (silently)
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        local fzf_path = vim.fn.stdpath("config") .. "/pack/plugins/start/telescope-fzf-native.nvim"
        local so_file = fzf_path .. "/build/fzf.so"

        if vim.fn.isdirectory(fzf_path) == 1 and vim.fn.filereadable(so_file) == 0 then
            vim.fn.system("cd " .. vim.fn.shellescape(fzf_path) .. " && make >/dev/null 2>&1")
        end
    end,
})
