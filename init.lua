-- Neovim 0.12 configuration
-- Using vim.pack, native LSP, treesitter

-- If nvim was started from a directory that no longer exists (rm -rf'd while
-- the shell was still sitting in it), vim.uv.cwd() returns nil and every
-- vim.fs.abspath/vim.fs.root call — ours, and nvim's own :h dir startup hook
-- on VimEnter — asserts. Move to a real directory before anything looks.
if not vim.uv.cwd() then
    local fallback = vim.uv.os_homedir() or '/'
    vim.uv.chdir(fallback)
    vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        callback = function()
            vim.notify(
                'Working directory no longer exists; changed to ' .. fallback,
                vim.log.levels.WARN
            )
        end,
    })
end

-- Directory browsing uses the 0.13 builtin browser (:h dir), so netrw is not
-- loaded at all. Delete this line to get :Ex/netrw back (its old g:netrw_*
-- settings are in git history).
vim.g.loaded_netrwPlugin = 1

-- Post-install/update build hooks (must register before vim.pack.add)
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
        local name = ev.data.spec.name
        local path = ev.data.path
        if name == 'telescope-fzf-native.nvim' then
            -- Async + exit-code checked: a :wait() here froze the UI for the
            -- whole build, and a silent failure left telescope on the slow Lua
            -- sorter with no indication (telescope.lua pcall's load_extension).
            vim.system({ 'make' }, { cwd = path }, vim.schedule_wrap(function(res)
                if res.code ~= 0 then
                    vim.notify('telescope-fzf-native build failed:\n' .. (res.stderr or ''),
                        vim.log.levels.ERROR)
                end
            end))
        end
    end,
})

-- Plugins (built-in package manager, Neovim 0.12+)
vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
})

-- render-markdown is markdown-only but cost ~4ms of a ~40ms startup: its
-- plugin/render-markdown.lua pulls in ~20 modules, and it self-initializes
-- with no setup() call (which is why nothing here configures it).
--
-- `load = false` is NOT enough to defer it. That is already the default while
-- init.lua is sourcing — it means `:packadd!`, which still puts the plugin on
-- 'runtimepath', and the normal post-init rtp scan then sources plugin/ anyway.
-- A no-op `load` keeps it off the rtp entirely until the packadd below.
vim.pack.add({ 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
    { load = function() end })

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    once = true,
    desc = 'Load render-markdown.nvim on first markdown buffer',
    callback = function()
        vim.cmd.packadd('render-markdown.nvim')
    end,
})

-- Core
require("config.options")
require("config.keymaps")

-- LSP + completion
require("config.lsp").setup()
require("config.ctags").setup()
require("config.clangd_setup").setup()

-- Treesitter
require("config.treesitter").setup()
-- config.c_keywords (matchadd keyword highlighting) is gone: it worked around
-- anonymous-node treesitter highlights not rendering on old builds. Verified
-- on this build that @keyword.* captures render fine, including inside
-- ERROR-recovered unity-macro functions, and colors/handmade.lua links them
-- to the same groups the matchadd patterns forced.

-- Telescope
require("config.telescope").setup()

-- Utilities
require("utils.make_detect").setup()
require("launch").setup()
require("notes").setup()
require("config.clipboard").setup()
require("divider_comments").setup()
require("config.comment_tags").setup()
require("config.perf").setup()

-- render-markdown.nvim self-initializes via its plugin/render-markdown.lua
-- (sourced by vim.pack), so no explicit setup() call is needed here.

-- UI2: new commandline + message UI (Neovim 0.12+).
-- `vim._core.ui2` is private/@nodoc and there is still no public equivalent in
-- 0.13 (:h ui2 documents this exact call). pcall'd so a rename upstream can't
-- abort init.lua before the colorscheme below ever loads.
pcall(function()
    require('vim._core.ui2').enable({})
end)

-- Colorscheme
vim.cmd.colorscheme("ddd")
