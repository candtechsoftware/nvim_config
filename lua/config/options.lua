-- Neovim options
--
-- Only settings that actually DIVERGE from the Neovim defaults live here.
-- `number`, `relativenumber`, `laststatus`, `hlsearch`, `incsearch`,
-- `inccommand`, `signcolumn` and `colorcolumn` were all being set to exactly
-- their default values and have been dropped — they were noise that had to be
-- read and mentally diffed against the manual to learn they did nothing.
--
-- 'guicursor' is not set here either: every colorscheme in colors/ owns it (it
-- names per-mode Cursor* highlight groups), and the colorscheme loads last, so
-- an "a:block-blinkon0" here was silently overwritten at startup every time.

-- Remove tildes (~) on empty lines
vim.opt.fillchars:append({ eob = " " })

vim.o.statusline = ' %f %l:%c %{%v:lua.vim.diagnostic.status()%} %{%v:lua.vim.ui.progress_status()%}'

-- Indentation
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> key press in insert mode inserts
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.smartindent = true -- Automatically insert indents in the correct place

-- Line wrapping
vim.opt.wrap = false -- Don't wrap lines

-- File handling
vim.opt.swapfile = false -- Don't create swap files
vim.opt.backup = false -- Don't create backup files
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- Save undo history
vim.opt.undofile = true -- Save undo history

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.scrolloff = 2 -- Keep 2 lines above and below the cursor
vim.opt.smoothscroll = true
vim.opt.updatetime = 250 -- Update interval for CursorHold and CursorHoldI
vim.opt.shortmess:append('c') -- Suppress completion messages (prevents command line focus steal)

-- Performance optimizations
vim.opt.synmaxcol = 300 -- Syntax highlight up to 300 columns
vim.opt.redrawtime = 1500 -- Time in ms for redrawing screen
vim.opt.timeoutlen = 400 -- Faster key sequence completion
vim.opt.ttimeoutlen = 10 -- Near-instant escape key response

vim.g.tex_conceal = "mgs"

-- Globally disable italics, bold, and underline-family decorations.
-- Measured at ~0.25ms per pass over ~450 groups. Note the pass runs once per
-- sourced file via SourcePost below (~36 times at startup), so budget ~9ms
-- total, not 0.25ms.
local DECORATIONS = {
    'italic', 'bold', 'underline', 'undercurl',
    'underdouble', 'underdotted', 'underdashed',
}

---Strip decorations from one group's definition, in place.
---Also clears the `cterm` variants: they live in a nested table, so nil'ing the
---top-level keys alone left every group with `cterm = { bold = true }` intact.
---`termguicolors` is on, so that was invisible rather than harmful — but the
---function did not do what it claimed.
---@param hl table  a single group's definition, as returned by nvim_get_hl
---@return boolean stripped
local function strip(hl)
    local found = false
    local cterm = hl.cterm
    for _, attr in ipairs(DECORATIONS) do
        if hl[attr] then hl[attr] = nil; found = true end
        if cterm and cterm[attr] then cterm[attr] = nil; found = true end
    end
    return found
end

local function strip_decorations()
    for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if strip(hl) then
            -- A group whose only color is `sp` renders NOTHING once the
            -- underline is gone: `sp` colors the decoration, not the text.
            -- Every colorscheme here defines the diagnostic underlines as
            -- `{ sp = <color>, undercurl = true }`, so blanket-stripping left
            -- DiagnosticUnderline{Error,Warn,Info,Hint} inert and LSP
            -- diagnostics had no in-text indication at all. Promote `sp` to
            -- `fg` so the diagnostic still reads, without a decoration.
            if not hl.fg and not hl.bg and hl.sp then
                hl.fg, hl.sp = hl.sp, nil
            end
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

-- Coalesce bursts of requests into a single pass.
--
-- SourcePost fires once per sourced file, and each handler did its own
-- `vim.schedule(strip_decorations)` — so startup queued ~36 identical full
-- sweeps of every highlight group, back to back on the same event-loop tick.
-- They all see the same state, so only the last one can matter. Setting a flag
-- and scheduling once collapses them into one.
local strip_pending = false
local function strip_decorations_soon()
    if strip_pending then return end
    strip_pending = true
    vim.schedule(function()
        strip_pending = false
        strip_decorations()
    end)
end

local strip_group = vim.api.nvim_create_augroup("StripDecorations", { clear = true })

strip_decorations()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = strip_group,
    callback = strip_decorations_soon,
})

-- This only ever visits groups that exist AT THAT MOMENT. Telescope and
-- render-markdown define their groups lazily, on first use, so their italics
-- and underlines were never stripped. Re-run once after startup and after any
-- plugin is sourced.
vim.api.nvim_create_autocmd({ "VimEnter", "SourcePost" }, {
    group = strip_group,
    callback = strip_decorations_soon,
})

vim.o.winborder = 'rounded'
vim.o.completeopt = 'menu,menuone,noselect,fuzzy'

vim.opt.splitright = true

-- Use system clipboard for all yank/paste operations
vim.opt.clipboard = "unnamedplus"

if vim.g.neovide then
    vim.g.neovide_position_animation_length = 0.01
    vim.g.neovide_scroll_animation_length = 0.01
end


