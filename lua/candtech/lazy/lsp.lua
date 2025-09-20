return {
  {
    "neovim/nvim-lspconfig",
    tag = "v1.0.0",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
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
            -- Safeguard against any errors in formatting
            local ok, result = pcall(function()
              -- Special handling for Jai files
              if vim.bo.filetype == 'jai' then
                -- Get the completion item
                local completion_item = entry:get_completion_item()
                
                -- Create a minimal safe vim_item for Jai
                local safe_item = {
                  word = "",
                  abbr = "",
                  menu = "[LSP]",
                  kind = vim_item.kind or "Text"
                }
                
                -- Try to extract text safely
                if completion_item then
                  if completion_item.label and type(completion_item.label) == "string" then
                    safe_item.abbr = completion_item.label
                    safe_item.word = completion_item.label
                  elseif completion_item.insertText and type(completion_item.insertText) == "string" then
                    safe_item.abbr = completion_item.insertText
                    safe_item.word = completion_item.insertText
                  end
                end
                
                -- Fallback to entry's insert text
                if safe_item.word == "" then
                  local insert_text = entry:get_insert_text()
                  if insert_text and type(insert_text) == "string" then
                    safe_item.word = insert_text
                    safe_item.abbr = insert_text
                  end
                end
                
                return safe_item
              end
              
              -- For non-Jai files, just ensure word is a string
              if vim_item.word and type(vim_item.word) == "string" and
                 (vim_item.kind == "Function" or vim_item.kind == "Method") then
                vim_item.word = vim_item.word:gsub("%(.*%)", "()")
              end
              
              return vim_item
            end)
            
            if not ok then
              -- Return a minimal safe item on any error
              return {
                word = entry:get_insert_text() or "",
                abbr = entry:get_insert_text() or "",
                menu = "",
                kind = ""
              }
            end
            
            return result
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
          "--header-insertion=never",
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
          "/home/candtech/gits/Jails/bin",
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
              cmd = { jails_path, "-jai_path", "/home/candtech/gits/jai" },
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
          on_attach = function(client, bufnr)
            -- Intercept completion responses for Jai to clean blob data
            local original_handler = vim.lsp.handlers["textDocument/completion"]
            vim.lsp.handlers["textDocument/completion"] = function(err, result, ctx, config)
              if result and vim.bo.filetype == 'jai' then
                -- Deep clean function to remove all non-serializable data
                local function clean_value(v)
                  local vtype = type(v)
                  if vtype == "string" or vtype == "number" or vtype == "boolean" or vtype == "nil" then
                    return v
                  elseif vtype == "userdata" then
                    -- This is likely a blob - convert to empty string
                    return ""
                  elseif vtype == "function" then
                    return nil
                  elseif vtype == "table" then
                    local clean = {}
                    for k, val in pairs(v) do
                      local cleaned = clean_value(val)
                      if cleaned ~= nil or val == nil then
                        clean[k] = cleaned
                      end
                    end
                    return clean
                  else
                    -- Unknown type - convert to string
                    local ok, str = pcall(tostring, v)
                    return ok and str or ""
                  end
                end
                
                -- Clean the entire result
                result = clean_value(result)
                
                -- Extra safety for import completions
                if result and result.items then
                  local line = vim.api.nvim_get_current_line()
                  if line:match('#import%s*"') then
                    for i, item in ipairs(result.items) do
                      -- Ensure critical fields are present and are strings
                      if not item.label or type(item.label) ~= "string" then
                        item.label = item.insertText or item.filterText or "module"
                      end
                      if item.label then
                        item.label = tostring(item.label):gsub("%z", "")
                      end
                    end
                  end
                end
              end
              return original_handler(err, result, ctx, config)
            end
            
            -- Call the original on_attach
            on_attach(client, bufnr)
          end,
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

