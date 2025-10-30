return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        formatting = {
          format = function(_, vim_item)
            local menu = vim_item.menu
            if menu == nil or menu == vim.NIL then
              vim_item.menu = ""
            elseif type(menu) ~= "string" then
              vim_item.menu = tostring(menu)
            end

            local word = vim_item.word
            if word == nil or word == vim.NIL then
              word = ""
            elseif type(word) ~= "string" then
              word = tostring(word)
            end

            if type(word) == "string" and (vim_item.kind == "Function" or vim_item.kind == "Method") then
              word = word:gsub("%(.*%)", "()")
            end
            vim_item.word = word

            if vim_item.abbr == nil or vim_item.abbr == vim.NIL then
              vim_item.abbr = ""
            end

            if vim_item.kind == nil or vim_item.kind == vim.NIL then
              vim_item.kind = ""
            end

            return vim_item
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  }
}
