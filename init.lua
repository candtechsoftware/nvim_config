-- Started from a deleted directory: vim.fs lookups (and :h dir) assert without a cwd.
if not vim.uv.cwd() then
  vim.uv.chdir(vim.uv.os_homedir())
  vim.schedule(function()
    vim.notify('Working directory no longer exists; changed to ~', vim.log.levels.WARN)
  end)
end

vim.g.mapleader = ' '
-- Directories open in the builtin browser (:h dir).
vim.g.loaded_netrwPlugin = 1

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local kind = ev.data.kind
    if ev.data.spec.name == 'fff' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd('fff') end
      require('fff.download').download_or_build_binary()
    end
  end,
})

-- fff's nightly tag only moves once that commit's prebuilt binaries exist.
vim.pack.add({ { src = 'https://github.com/dmtrKovalenko/fff', version = 'nightly' } })

-- A no-op load keeps render-markdown off the runtimepath until the first markdown buffer.
vim.pack.add({ 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }, { load = function() end })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  once = true,
  callback = function() vim.cmd.packadd('render-markdown.nvim') end,
})

require('config.options')
require('config.keymaps')
require('config.lsp').setup()
require('config.ctags').setup()
require('config.clangd_setup').setup()
require('config.treesitter').setup()
require('config.pickers').setup()
require('config.notes').setup()
require('config.dividers').setup()
require('config.comment_tags').setup()
require('config.perf').setup()
require('launch').setup()

vim.cmd.colorscheme('ll')

-- The new cmdline and message UI. Still only exposed as a private module.
require('vim._core.ui2').enable({})
