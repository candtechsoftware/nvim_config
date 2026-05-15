-- Neovim 0.12+ LSP configuration
-- Uses vim.lsp.config + vim.lsp.enable() with lsp/*.lua config files
-- Default mappings (grn, grr, gra, gO, K, C-s) are set automatically

local M = {}

-- LSP servers to enable (configs are in lsp/*.lua)
-- tsgo (TypeScript-Go 7.0.0-dev) is intentionally NOT in this list — it has
-- gaps with Expo/React Native projects (e.g. ~/work/app/IrisBetaApp). Use
-- ts_ls (typescript-language-server) instead. To experiment with tsgo on a
-- single buffer, run :lsp enable tsgo manually.
local servers = {
  'clangd',
  'lua_ls',
  'gopls',
  'ts_ls',
  'eslint',
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
    local cur_win = vim.api.nvim_get_current_win()

    -- Find or create the target split window
    local target_win
    local wins = vim.api.nvim_tabpage_list_wins(0)
    if #wins < 2 then
      vim.cmd('vsplit')
      target_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(cur_win)
    else
      for _, w in ipairs(wins) do
        if w ~= cur_win then
          target_win = w
          break
        end
      end
    end

    vim.lsp.buf.definition({
      on_list = function(options)
        if not options.items or #options.items == 0 then return end
        local item = options.items[1]
        vim.api.nvim_set_current_win(target_win)
        vim.cmd('edit ' .. vim.fn.fnameescape(item.filename))
        vim.api.nvim_win_set_cursor(target_win, { item.lnum, item.col - 1 })
        vim.api.nvim_set_current_win(cur_win)
      end
    })
  end, opts)

  vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)

  -- Diagnostics
  vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)

  -- Actions (grn/grr/gra are 0.12 defaults for rename/references/code_action)
  vim.keymap.set('n', '<leader>vi', vim.lsp.buf.incoming_calls, opts)

  -- Formatting (manual): TS/JS via eslint LSP only.
  -- Everything else (incl. unity-build C/C++, Lua, Rust, Jai) is a no-op.
  vim.keymap.set('n', '<leader>f', function()
    local js = {
      typescript = true, typescriptreact = true,
      javascript = true, javascriptreact = true,
    }
    if not js[vim.bo.filetype] then return end
    local clients = vim.lsp.get_clients({ bufnr = 0, name = 'eslint' })
    if #clients == 0 then return end
    vim.lsp.buf.code_action({
      context = { only = { 'source.fixAll.eslint' }, diagnostics = {} },
      apply = true,
    })
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

-- Some servers return textEdit.range starting AT the cursor (insert-only,
-- no prefix replacement). Native LSP completion then anchors the popup at
-- the cursor, so accepting `window` on `game.win<Tab>` appends and yields
-- `game.winwindow` instead of `game.window`. Snap any range start that sits
-- past the keyword boundary back onto it — `plenary.async`-style spans that
-- start BEFORE the keyword boundary are left untouched.
local function patch_completion_concat_bug()
  local comp = vim.lsp.completion
  if not (comp and comp._convert_results) then return end
  local orig = comp._convert_results
  comp._convert_results = function(
    line, lnum, cursor_col, client_id,
    client_start_boundary, server_start_boundary, result, encoding
  )
    local enc = encoding or 'utf-16'
    local boundary_char = vim.str_utfindex(line, enc, client_start_boundary, false)
    local items = result.items or result
    for _, item in ipairs(items) do
      local te = item.textEdit
      if te then
        local function fix(rng)
          if rng and rng.start and rng.start.line == lnum then
            local sb = vim.str_byteindex(line, enc, rng.start.character, false)
            if sb > client_start_boundary then
              rng.start.character = boundary_char
            end
          end
        end
        fix(te.range)
        fix(te.insert)
        fix(te.replace)
      end
    end
    return orig(line, lnum, cursor_col, client_id,
      client_start_boundary, server_start_boundary, result, encoding)
  end
end

---Main setup function
function M.setup()
  patch_completion_concat_bug()
  setup_diagnostics()

  -- Configure defaults for ALL LSP servers
  vim.lsp.config('*', {
    capabilities = get_capabilities(),
    root_markers = { '.git' },
  })

  -- Enable all servers (vim.lsp.enable handles missing executables gracefully)
  vim.lsp.enable(servers)

  -- Unity builds confuse clangd — it flags some function decls as variables.
  -- Clear @lsp.type.variable.{c,cpp} so treesitter @function wins for misparses.
  local function clear_clangd_variable_hl()
    vim.api.nvim_set_hl(0, '@lsp.type.variable.c', {})
    vim.api.nvim_set_hl(0, '@lsp.type.variable.cpp', {})
  end
  clear_clangd_variable_hl()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('lsp_clangd_hl_fix', { clear = true }),
    callback = clear_clangd_variable_hl,
  })

  -- LspAttach: Set up keymaps and completion when LSP attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_attach_config', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      local bufnr = args.buf

      -- Disable diagnostics for clangd (unity builds produce false positives)
      -- Semantic tokens stay enabled so types/functions/macros get colored like in 4coder
      if client.name == 'clangd' then
        vim.diagnostic.enable(false, { bufnr = bufnr })
      end

      -- LSP folding
      vim.wo[args.data.winid or 0].foldmethod = 'expr'
      vim.wo[args.data.winid or 0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      vim.wo[args.data.winid or 0].foldlevel = 99

      -- Native LSP completion. clangd: autotrigger on so `.`, `->`, `::`
      -- fire member completion with triggerKind=TriggerCharacter (more
      -- reliable than the Invoked path that <Tab> uses). Every other
      -- server stays Tab-only via lua/config/keymaps.lua.
      local autotrigger = client.name == 'clangd'
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = autotrigger })

      -- Signature help on '(' and ',' — one-line cmdline echo only, no popup.
      vim.api.nvim_create_autocmd('InsertCharPre', {
        buffer = bufnr,
        group = vim.api.nvim_create_augroup('lsp_insert_trigger_' .. bufnr, { clear = true }),
        callback = function()
          local char = vim.v.char
          if char == '(' or char == ',' then
            vim.schedule(function()
              vim.lsp.buf.signature_help({ silent = true })
            end)
          end
        end,
      })

      -- Set keymaps (omnifunc/tagfunc are auto-set by 0.12)
      set_keymaps(bufnr)

      -- Unity builds index every .c as its own TU, so the same symbol
      -- often resolves to several candidates. Auto-pick the one that
      -- looks like a real definition: prefer source files over headers,
      -- and prefer paths outside build/ output dirs.
      if client.name == 'clangd' then
        vim.keymap.set('n', 'gd', function()
          vim.lsp.buf.definition({
            on_list = function(opts)
              local items = opts.items or {}
              if #items == 0 then return end
              local function score(item)
                local f = item.filename or ''
                local s = 0
                if f:match('%.c$') or f:match('%.cpp$') or f:match('%.cc$') or f:match('%.m$') or f:match('%.mm$') then
                  s = s + 2
                elseif f:match('%.h$') or f:match('%.hpp$') then
                  s = s - 1
                end
                if f:match('/build/') or f:match('/dist/') then
                  s = s - 3
                end
                return s
              end
              table.sort(items, function(a, b) return score(a) > score(b) end)
              local best = items[1]
              vim.cmd('edit ' .. vim.fn.fnameescape(best.filename))
              vim.api.nvim_win_set_cursor(0, { best.lnum, math.max(0, (best.col or 1) - 1) })
            end,
          })
        end, { buffer = bufnr, silent = true, desc = 'Clangd: go to best definition' })
      end
    end,
  })

  -- :LspInfo — short summary of LSP state for the current buffer.
  -- nvim 0.12+ ships `:lsp enable|disable|restart|stop` and `:checkhealth
  -- vim.lsp` but no one-shot status command. This fills the gap.
  vim.api.nvim_create_user_command('LspInfo', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local lines = {
      ('Buffer %d  filetype=%s'):format(bufnr, vim.bo[bufnr].filetype),
      ('%d attached client(s):'):format(#clients),
    }
    local attached = {}
    for _, c in ipairs(clients) do
      attached[c.name] = true
      local stp = c.server_capabilities.semanticTokensProvider and 'yes' or 'no'
      local root = c.config.root_dir or c.root_dir or '?'
      table.insert(lines, ('  - %s (id=%d) root=%s  semantic_tokens=%s')
        :format(c.name, c.id, root, stp))
      table.insert(lines, ('    cmd=%s'):format(table.concat(c.config.cmd or {}, ' ')))
    end
    local not_attached = {}
    for _, cfg in ipairs(vim.lsp.get_configs()) do
      if not attached[cfg.name] and vim.lsp.is_enabled(cfg.name) then
        table.insert(not_attached, cfg.name)
      end
    end
    if #not_attached > 0 then
      table.insert(lines, ('Enabled but not attached: %s'):format(table.concat(not_attached, ', ')))
    end
    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
  end, { desc = 'Show LSP clients attached to current buffer' })

  -- :LspLog — open the LSP log file in a new tab.
  vim.api.nvim_create_user_command('LspLog', function()
    vim.cmd('tabnew ' .. vim.fn.fnameescape(vim.lsp.get_log_path()))
  end, { desc = 'Open the LSP log file' })
end

return M
