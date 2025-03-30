return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "j-hui/fidget.nvim",
    },
    config = function()

      local lspconfig = require("lspconfig")
      require("fidget").setup({})

      -- Configure diagnostic display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = 'rounded',
          header = '',
          prefix = '',
        },
      })

      -- Automatically send diagnostics to quickfix list
      local function add_buffer_diagnostics_to_quickfix()
        local diagnostics = vim.diagnostic.get()
        local qf_items = {}
        for bufnr, diagnostic_items in pairs(diagnostics) do
          -- Check if the buffer exists and is valid
          if vim.api.nvim_buf_is_valid(bufnr) then
            local filename = vim.api.nvim_buf_get_name(bufnr)
            for _, d in ipairs(diagnostic_items) do
              table.insert(qf_items, {
                filename = filename,
                lnum = d.lnum + 1,
                col = d.col + 1,
                text = d.message,
                type = d.severity == 1 and 'E' or (d.severity == 2 and 'W' or 'I')
              })
            end
          end
        end
        vim.fn.setqflist(qf_items)
      end

      -- Update quickfix list whenever diagnostics change
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        callback = add_buffer_diagnostics_to_quickfix,
        group = vim.api.nvim_create_augroup("DiagnosticQuickfix", { clear = true })
      })

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("n", "<leader>vi", function() vim.lsp.buf.incoming_calls() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        
        -- Add quickfix specific keymaps
        vim.keymap.set("n", "<leader>qf", function() vim.diagnostic.setqflist() end, opts)
        vim.keymap.set("n", "<leader>qq", function() vim.diagnostic.setloclist() end, opts)
      end

      local cmp = require('cmp')
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
      )

      -- Setup completion
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- Configure lua language server for neovim
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {'vim'},
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- Setup other language servers
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      lspconfig.zls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end
  }
}

