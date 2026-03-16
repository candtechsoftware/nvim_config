-- blink.cmp configuration
-- Replaces custom completion UI/triggering with blink.cmp while preserving
-- ctags infrastructure for C/C++ and LSP for all other languages

local M = {}

function M.setup()
  require('blink.cmp').setup({
    -- Keybindings matching current behavior
    keymap = {
      preset = 'none',
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<C-e>'] = { 'cancel', 'fallback' },
      ['<C-h>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },

    completion = {
      -- Match current completeopt: noselect, noinsert
      list = {
        selection = { preselect = false, auto_insert = false },
      },

      -- Menu appearance
      menu = {
        max_height = 12,
        draw = {
          columns = {
            { 'label' },
            { 'kind' },
            { 'source_name' },
          },
        },
      },

      documentation = {
        auto_show = false,
      },
    },

    signature = {
      enabled = true,
      window = {
        border = 'rounded',
        max_height = 15,
        max_width = 80,
        show_documentation = false,
      },
    },

    -- Sources: LSP + ctags + buffer + path for all filetypes
    -- ctags source self-disables for non-C/C++ files
    sources = {
      default = { 'lsp', 'ctags', 'buffer', 'path' },
      providers = {
        ctags = {
          name = 'Ctags',
          module = 'config.blink_ctags_source',
          score_offset = 3,
          max_items = 200,
        },
      },
    },
  })
end

return M
