-- Only settings that differ from the Neovim defaults. 'guicursor' belongs to colors/ll.lua.
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
vim.o.smoothscroll = true
vim.o.splitright = true
vim.o.clipboard = 'unnamedplus'
vim.o.winborder = 'rounded'
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

if vim.g.neovide then
  vim.g.neovide_position_animation_length = 0.01
  vim.g.neovide_scroll_animation_length = 0.01
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
end

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
