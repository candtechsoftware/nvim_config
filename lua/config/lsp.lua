-- Modern Neovim 0.11+ LSP configuration
-- Uses vim.lsp.config + vim.lsp.enable() API with lsp/*.lua config files

local M = {}

-- LSP servers to enable (configs are in lsp/*.lua)
local servers = {
  'lua_ls',
  'gopls',
  'ts_ls',
  'rust_analyzer',
  'zls',
  'ols',
  'jails',
}

---Get LSP capabilities (no snippets, full completion support)
---@return table
local function get_capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()

  -- Completion capabilities (no snippets)
  caps.textDocument.completion = {
    completionItem = {
      snippetSupport = false,
      documentationFormat = { 'plaintext', 'markdown' },
      resolveSupport = {
        properties = {
          'detail',
          'documentation',
          'additionalTextEdits',
        },
      },
      deprecatedSupport = true,
      labelDetailsSupport = true,
      insertReplaceSupport = true,
      preselectSupport = true,
      tagSupport = {
        valueSet = { 1 },  -- Deprecated tag
      },
    },
    contextSupport = true,
    dynamicRegistration = false,
  }

  -- Signature help capabilities
  caps.textDocument.signatureHelp = {
    signatureInformation = {
      documentationFormat = { 'plaintext', 'markdown' },
      parameterInformation = {
        labelOffsetSupport = true,
      },
      activeParameterSupport = true,
    },
    dynamicRegistration = false,
  }

  -- Hover capabilities
  caps.textDocument.hover = {
    contentFormat = { 'plaintext', 'markdown' },
    dynamicRegistration = false,
  }

  return caps
end

---Set LSP keymaps for a buffer
---@param bufnr integer
local function set_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Navigation
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gv', function()
    vim.cmd('vsplit')
    vim.lsp.buf.definition()
  end, opts)

  -- Workspace
  vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)

  -- Diagnostics
  vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

  -- Actions
  vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>vi', vim.lsp.buf.incoming_calls, opts)

  -- Signature help in insert mode (manual trigger)
  vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)

  -- Formatting (manual)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = false })
  end, opts)

  -- Diagnostics to quickfix/loclist
  vim.keymap.set('n', '<leader>qf', function()
    vim.diagnostic.setqflist({ open = true })
  end, opts)
  vim.keymap.set('n', '<leader>qq', function()
    vim.diagnostic.setloclist({ open = true })
  end, opts)
end

---Configure diagnostics display
local function setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = {
      prefix = '',
      source = true,
      severity = { min = vim.diagnostic.severity.WARN },
      spacing = 4,
      format = function(diagnostic)
        local severity = vim.diagnostic.severity[diagnostic.severity]
        return string.format('[%s] %s', severity:sub(1, 1), diagnostic.message)
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = 'E',
        [vim.diagnostic.severity.WARN] = 'W',
        [vim.diagnostic.severity.INFO] = 'I',
        [vim.diagnostic.severity.HINT] = 'H',
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = 'rounded',
      header = '',
      prefix = '',
      focusable = false,
      max_width = 80,
      max_height = 20,
      source = true,
    },
  })
end

---Configure LSP handlers (hover, signature help)
local function setup_handlers()
  -- Hover handler - configure appearance
  vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, config)
    config = config or {}
    config.focusable = false
    config.border = 'rounded'
    config.max_width = 80
    config.max_height = 20
    return vim.lsp.handlers.hover(err, result, ctx, config)
  end

  -- Signature help handler - prevent focus stealing + fix activeParameter
  vim.lsp.handlers['textDocument/signatureHelp'] = function(err, result, ctx, config)
    config = config or {}
    config.focusable = false
    config.focus = false
    config.border = 'rounded'
    config.max_width = 80
    config.max_height = 15
    config.close_events = { 'CursorMovedI', 'BufHidden', 'InsertLeave' }

    -- Fix activeParameter - count commas before cursor to determine position
    if result and result.signatures and #result.signatures > 0 then
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before_cursor = line:sub(1, col)

      -- Find the opening paren and count commas after it
      local paren_pos = before_cursor:match('.*()%(')
      if paren_pos then
        local inside_parens = before_cursor:sub(paren_pos + 1)
        -- Count commas (simple - doesn't handle nested parens/strings)
        local comma_count = 0
        for _ in inside_parens:gmatch(',') do
          comma_count = comma_count + 1
        end
        -- Override activeParameter with our calculated value
        result.activeParameter = comma_count
        if result.signatures[1] then
          result.signatures[1].activeParameter = comma_count
        end
      end
    end

    return vim.lsp.handlers.signature_help(err, result, ctx, config)
  end
end

---Main setup function
function M.setup()
  setup_diagnostics()
  setup_handlers()

  -- Configure defaults for ALL LSP servers
  vim.lsp.config('*', {
    capabilities = get_capabilities(),
    root_markers = { '.git' },
  })

  -- Enable all servers (vim.lsp.enable handles missing executables gracefully)
  vim.lsp.enable(servers)

  -- LspAttach: Set up keymaps and completion when LSP attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_attach_config', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      local bufnr = args.buf

      -- Set keymaps
      set_keymaps(bufnr)

      -- Enable native completion with auto-trigger on '.' etc
      if client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, bufnr, {
          autotrigger = true,
        })

        -- Debounced completion trigger for smoother typing
        local completion_timer = vim.uv.new_timer()
        vim.api.nvim_create_autocmd('TextChangedI', {
          buffer = bufnr,
          callback = function()
            completion_timer:stop()
            completion_timer:start(50, 0, vim.schedule_wrap(function()
              if vim.fn.pumvisible() == 1 or vim.api.nvim_get_mode().mode ~= 'i' then
                return
              end

              local col = vim.api.nvim_win_get_cursor(0)[2]
              if col < 2 then return end

              local line = vim.api.nvim_get_current_line()
              local char = line:sub(col, col)
              local prev = line:sub(col - 1, col - 1)

              -- Trigger signature help on ( or , or while inside parens
              if char == '(' or char == ',' then
                vim.lsp.buf.signature_help()
              -- Re-trigger signature help if we're likely inside function args
              elseif line:sub(1, col):match('%([^)]*$') then
                -- Inside unclosed parens - keep signature help updated
                vim.lsp.buf.signature_help()
              -- Trigger completion on word characters
              elseif prev:match('%w') and char:match('%w') then
                local keys = vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true)
                vim.api.nvim_feedkeys(keys, 'n', false)
              end
            end))
          end,
        })
      end

      -- Set omnifunc as fallback for <C-x><C-o>
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Set tagfunc for CTRL-] navigation
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end,
  })
end

---Stop LSP for a buffer
---@param bufnr integer|nil
function M.stop_lsp(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    vim.lsp.buf_detach_client(bufnr, client.id)
  end
end

vim.api.nvim_create_user_command('LspStop', function()
  M.stop_lsp()
end, { desc = 'Stop LSP for current buffer' })

return M
