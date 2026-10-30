-- Only settings that differ from the Neovim defaults. The colorscheme owns 'guicursor'.
vim.o.fillchars = 'eob: '
vim.o.statusline = ' %f %l:%c %{%v:lua.vim.ui.progress_status()%}'

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.wrap = false

vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath('data') .. '/undodir'

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 2
-- Keep 'scrolloff' below the last line too (0.13).
vim.o.scrolloffpad = 1
vim.o.smoothscroll = true
vim.o.splitright = true
vim.o.clipboard = 'unnamedplus'
vim.o.winborder = 'rounded'
vim.o.pumborder = 'rounded'
vim.o.completeopt = 'menu,menuone,noselect,fuzzy'
vim.opt.shortmess:append('cu')

vim.o.updatetime = 250
vim.o.timeoutlen = 400
vim.o.ttimeoutlen = 10
vim.o.synmaxcol = 300
vim.o.redrawtime = 1500

vim.g.tex_conceal = 'mgs'

-- Cmdline autocompletion (:h cmdline-autocompletion). This is what makes :b,
-- :e, :tag and the commands in config/pickers.lua work as fuzzy pickers.
vim.o.wildmode = 'noselect:lastused,full'
vim.o.wildoptions = 'pum,tagfile,fuzzy'
vim.api.nvim_create_autocmd('CmdlineChanged', {
  pattern = ':',
  callback = function() vim.fn.wildtrigger() end,
})
vim.keymap.set('c', '<Up>', function()
  return vim.fn.wildmenumode() == 1 and '<C-e><Up>' or '<Up>'
end, { expr = true })
vim.keymap.set('c', '<Down>', function()
  return vim.fn.wildmenumode() == 1 and '<C-e><Down>' or '<Down>'
end, { expr = true })

-- 0.13 can identify the exact region changed by either operation.
vim.api.nvim_create_autocmd({ 'TextYankPost', 'TextPutPost' }, {
  group = vim.api.nvim_create_augroup('HighlightTextOperation', {}),
  callback = function() vim.hl.hl_op({ higroup = 'Visual', timeout = 150 }) end,
  desc = 'Briefly highlight yanked or put text',
})

if vim.g.neovide then
  vim.g.neovide_position_animation_length = 0.01
  vim.g.neovide_scroll_animation_length = 0.01
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
end

-- Kitty's multiple-cursor protocol needs concrete colors, but many schemes
-- define Cursor with only a background (or not at all). Resolve a complete,
-- contrasting pair after every colorscheme and keep Visual cursors themed.
local function contrast(color)
  local r = bit.rshift(bit.band(color, 0xff0000), 16)
  local g = bit.rshift(bit.band(color, 0x00ff00), 8)
  local b = bit.band(color, 0x0000ff)
  return r * 299 + g * 587 + b * 114 > 127500 and 0x000000 or 0xffffff
end

local function set_multicursor_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local cursor = vim.api.nvim_get_hl(0, { name = 'Cursor', link = false })
  local bg = cursor.bg
  if bg == nil or bg == normal.bg then bg = normal.fg end
  bg = bg or (vim.o.background == 'dark' and 0xffffff or 0x000000)
  local fg = cursor.fg or normal.bg or contrast(bg)
  if fg == bg then fg = contrast(bg) end
  vim.api.nvim_set_hl(0, 'MCursor', { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, 'MCursorVisual', { link = 'Visual' })
end

local multicursor_group = vim.api.nvim_create_augroup('MulticursorHighlight', {})
vim.api.nvim_create_autocmd('ColorScheme', {
  group = multicursor_group,
  callback = set_multicursor_highlights,
  desc = 'Keep native multicursors visible in every colorscheme',
})
set_multicursor_highlights()

-- No italics, bold or underlines anywhere. Plugins define their groups
-- lazily, so this reruns after anything outside this config is sourced.
local DECORATIONS = { 'italic', 'bold', 'underline', 'undercurl', 'underdouble', 'underdotted', 'underdashed' }

local function strip_decorations()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    local found = false
    for _, attr in ipairs(DECORATIONS) do
      if hl[attr] or (hl.cterm and hl.cterm[attr]) then
        found = true
        hl[attr] = nil
        if hl.cterm then hl.cterm[attr] = nil end
      end
    end
    if found then
      -- sp only colors the decoration, so an sp-only group would draw nothing.
      if not hl.fg and not hl.bg and hl.sp then hl.fg, hl.sp = hl.sp, nil end
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

local strip_pending = false
local function strip_soon()
  if strip_pending then return end
  strip_pending = true
  vim.schedule(function()
    strip_pending = false
    strip_decorations()
  end)
end

local config_dir = vim.fn.stdpath('config')
local group = vim.api.nvim_create_augroup('StripDecorations', {})
vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, { group = group, callback = strip_soon })
vim.api.nvim_create_autocmd('SourcePost', {
  group = group,
  callback = function(ev)
    if not vim.startswith(vim.fs.normalize(ev.match), config_dir) then strip_soon() end
  end,
})
