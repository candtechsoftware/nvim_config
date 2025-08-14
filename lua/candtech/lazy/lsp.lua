return {
  {
    "neovim/nvim-lspconfig",
    tag = "v1.0.0",
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

      -- Universal function to find workspace root for any LSP
      local function get_workspace_root(fname, patterns)
        -- First try to find by patterns
        local root = lspconfig.util.root_pattern(unpack(patterns))(fname)
        if root then
          return root
        end
        
        -- Then try git root
        local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.fnamemodify(fname, ":h")) .. " rev-parse --show-toplevel")[1]
        if vim.v.shell_error == 0 and git_root and git_root ~= "" then
          return git_root
        end
        
        -- Use the initial working directory as fallback (not current directory)
        return vim.fn.getcwd()
      end

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
        
        -- Update quickfix specific keymaps to not auto-update
        vim.keymap.set("n", "<leader>qf", function() 
          vim.diagnostic.setqflist({open = true}) 
        end, opts)
        vim.keymap.set("n", "<leader>qq", function() 
          vim.diagnostic.setloclist({open = true}) 
        end, opts)
      end

      local cmp = require('cmp')
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
      )
      capabilities.textDocument.completion.completionItem.snippetSupport = false

      -- Setup completion
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Remove function parameters from display
            if vim_item.kind == "Function" or vim_item.kind == "Method" then
              vim_item.word = vim_item.word:gsub("%(.*%)", "()")
            end
            return vim_item
          end,
        },
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

      -- Setup other language servers with consistent workspace detection
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return get_workspace_root(fname, {'go.mod', 'go.sum', '.git'})
        end,
      })

      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return get_workspace_root(fname, {'package.json', 'tsconfig.json', '.git'})
        end,
      })

      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return get_workspace_root(fname, {'Cargo.toml', '.git'})
        end,
      })

      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm"
        },
        root_dir = function(fname)
          return get_workspace_root(fname, {'compile_commands.json', '.clangd', 'CMakeLists.txt', 'Makefile', '.git'})
        end,
      })

      lspconfig.zls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return get_workspace_root(fname, {'build.zig', '.git'})
        end,
      })

      lspconfig.ols.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return get_workspace_root(fname, {'ols.json', '.git'})
        end,
      })

      -- Jai Language Server
      local configs = require('lspconfig.configs')
      
      -- Determine the correct binary path
      local function get_jails_path()
        -- Check common locations
        local paths = {
          vim.fn.expand("~/bins/jails"),
          vim.fn.expand("~/.local/bin/jails"),
          "/usr/local/bin/jails",
          vim.fn.exepath("jails") -- Check if it's in PATH
        }
        
        for _, p in ipairs(paths) do
          if p and p ~= "" and vim.fn.executable(p) == 1 then
            return p
          end
        end
        
        -- Platform-specific binary name
        local platform = vim.loop.os_uname().sysname:lower()
        local arch = vim.loop.os_uname().machine:lower()
        if arch == "x86_64" then arch = "amd64" end
        
        local binary_name = string.format("jails-%s-%s", platform, arch)
        if platform == "windows" then
          binary_name = binary_name .. ".exe"
        end
        
        -- Check with platform-specific name
        local platform_specific = vim.fn.exepath(binary_name)
        if platform_specific and platform_specific ~= "" then
          return platform_specific
        end
        
        return nil
      end
      
      local jails_path = get_jails_path()
      
      if jails_path then
        if not configs.jails then
          configs.jails = {
            default_config = {
              cmd = { jails_path },
              filetypes = { 'jai' },
              root_dir = function(fname)
                -- More robust root directory detection for Jai
                return get_workspace_root(fname, {'build.jai', 'first.jai', '.git'})
              end,
              settings = {},
              -- Keep the workspace root once found
              single_file_support = false,
            },
          }
        end
        
        lspconfig.jails.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          autostart = true,
          -- Ensure the root directory is maintained
          root_dir = function(fname)
            return get_workspace_root(fname, {'build.jai', 'first.jai', '.git'})
          end,
        })
      else
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "jai",
          once = true,
          callback = function()
            vim.notify(
              "Jai Language Server not found. Please install jails from https://github.com/SogoCZE/Jails",
              vim.log.levels.WARN
            )
          end,
        })
      end

      -- Helper commands for Jai LSP
      vim.api.nvim_create_user_command('JailsStart', function()
        if jails_path then
          vim.cmd('LspStart jails')
        else
          vim.notify("Jails not found in PATH", vim.log.levels.ERROR)
        end
      end, { desc = 'Start Jai Language Server' })
      
      vim.api.nvim_create_user_command('JailsStop', function()
        vim.cmd('LspStop jails')
      end, { desc = 'Stop Jai Language Server' })
      
      vim.api.nvim_create_user_command('JailsRestart', function()
        vim.cmd('LspStop jails')
        vim.defer_fn(function()
          vim.cmd('LspStart jails')
        end, 500)
      end, { desc = 'Restart Jai Language Server' })
      
      vim.api.nvim_create_user_command('JailsInfo', function()
        if jails_path then
          vim.notify(string.format("Jails path: %s", jails_path), vim.log.levels.INFO)
        else
          vim.notify("Jails not found. Install from https://github.com/SogoCZE/Jails", vim.log.levels.WARN)
        end
      end, { desc = 'Show Jai Language Server info' })
    end
  }
}

