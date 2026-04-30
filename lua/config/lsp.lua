-- Neovim 0.12+ LSP configuration
-- Uses vim.lsp.config + vim.lsp.enable() with lsp/*.lua config files
-- Default mappings (grn, grr, gra, gO, K, C-s) are set automatically

local M = {}

-- LSP servers to enable (configs are in lsp/*.lua)
local servers = {
  'clangd',
  'lua_ls',
  'gopls',
  'tsgo',
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

  local c_filetypes = { c = true, cpp = true, objc = true, objcpp = true, hlsl = true }

  -- Navigation
  vim.keymap.set('n', 'gd', function()
    -- Try ctags first for C/C++ (covers unity builds and project-local symbols)
    if c_filetypes[vim.bo.filetype] then
      local word = vim.fn.expand('<cword>')
      local saved_tagfunc = vim.bo.tagfunc
      vim.bo.tagfunc = ''
      local tags = vim.fn.taglist('^' .. word .. '$')
      vim.bo.tagfunc = saved_tagfunc
      -- Only use ctags if at least one match is from the project
      local root = require('config.ctags').get_project_root()
      if root then
        for _, tag in ipairs(tags) do
          local abs = vim.fn.fnamemodify(tag.filename, ':p')
          if abs:sub(1, #root) == root then
            require('config.ctags').jump()
            return
          end
        end
      end
    end
    -- No ctags match — try LSP
    vim.lsp.buf.definition()
  end, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<leader>gi', require('config.ctags').jump_vsplit, opts)
  vim.keymap.set('n', 'gv', function()
    local cur_win = vim.api.nvim_get_current_win()
    local word = vim.fn.expand('<cword>')

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

    -- Try ctags first for C/C++ (synchronous, project tags only)
    if c_filetypes[vim.bo.filetype] then
      local saved_tagfunc = vim.bo.tagfunc
      vim.bo.tagfunc = ''
      local tags = vim.fn.taglist('^' .. word .. '$')
      vim.bo.tagfunc = saved_tagfunc

      -- Filter to project tags (same logic as gd)
      local root = require('config.ctags').get_project_root()
      if root then
        local project_tags = {}
        for _, tag in ipairs(tags) do
          local abs = vim.fn.fnamemodify(tag.filename, ':p')
          if abs:sub(1, #root) == root then
            table.insert(project_tags, tag)
          end
        end
        if #project_tags > 0 then tags = project_tags end
      end

      if #tags > 0 then
        local tag = tags[1]
        local filename = vim.fn.fnamemodify(tag.filename, ':p')
        vim.api.nvim_set_current_win(target_win)
        vim.cmd('edit ' .. vim.fn.fnameescape(filename))
        if tag.line then
          pcall(vim.api.nvim_win_set_cursor, target_win, { tonumber(tag.line), 0 })
        elseif tag.cmd then
          local pattern = tag.cmd:match('^/(.+)/$') or tag.cmd:match('^%?(.+)%?$')
          if pattern then pcall(vim.fn.search, pattern, 'w') end
        end
        vim.api.nvim_set_current_win(cur_win)
        return
      end
    end
    do
      -- LSP (async) — use on_list to control where the result opens
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
    end
  end, opts)

  -- Workspace
  vim.keymap.set('n', '<leader>vws', function()
    local ok, results = pcall(function()
      local params = { query = '' }
      return vim.lsp.buf_request_sync(0, 'textDocument/symbol', params, 1000)
        or vim.lsp.buf_request_sync(0, 'workspace/symbol', params, 1000)
    end)
    if ok and results then
      for _, res in pairs(results) do
        if res.result and type(res.result) == 'table' and not vim.tbl_isempty(res.result) then
          vim.lsp.buf.workspace_symbol()
          return
        end
      end
    end
    -- LSP returned nothing useful — fall back to ctags
    require('config.ctags').workspace_symbols()
  end, opts)

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

---Main setup function
function M.setup()
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

      local c_ft = { c = true, cpp = true, objc = true, objcpp = true, hlsl = true }
      local is_c = c_ft[vim.bo[bufnr].filetype]

      -- For C/C++ files: strip '.' and '>' from clangd triggers so ctags handles
      -- struct member completion (node->, node.) without LSP racing
      if client.name == 'clangd' and is_c then
        local caps = client.server_capabilities
        if caps.completionProvider and caps.completionProvider.triggerCharacters then
          local triggers = caps.completionProvider.triggerCharacters
          for i = #triggers, 1, -1 do
            if triggers[i] == '.' or triggers[i] == '>' then
              table.remove(triggers, i)
            end
          end
        end
      end

      -- Enable native LSP completion — disable autotrigger for C/C++ since ctags handles it
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = not is_c })

      -- Insert-mode triggers: keyword completion + signature help
      vim.api.nvim_create_autocmd('InsertCharPre', {
        buffer = bufnr,
        group = vim.api.nvim_create_augroup('lsp_insert_trigger_' .. bufnr, { clear = true }),
        callback = function()
          local char = vim.v.char

          -- Signature help on ( and ,
          if char == '(' or char == ',' then
            vim.schedule(function()
              -- C/C++ files: use ctags signature help (clangd lacks compile database)
              if is_c then
                require('config.ctags').show_signature_help()
              else
                vim.lsp.buf.signature_help({ silent = true })
              end
            end)
            return
          end

          -- Keyword completion on word characters
          if char:match('[%w_]') and vim.fn.pumvisible() == 0 then
            vim.schedule(function()
              -- C/C++ files: use ctags prefix matching (clangd lacks compile database)
              if is_c then
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local line = vim.api.nvim_get_current_line()
                local prefix = line:sub(1, col + 1):match('([%w_]+)$')
                if prefix and #prefix >= 2 then
                  local ctags = require('config.ctags')
                  local items = ctags.get_prefix_matches(prefix:lower(), 20)
                  if #items > 0 then
                    local matches = {}
                    for _, t in ipairs(items) do
                      matches[#matches + 1] = { word = t.name, kind = t.kind or '' }
                    end
                    vim.fn.complete(col + 1 - #prefix, matches)
                    return
                  end
                end
              end
              -- Non-C files or ctags had no matches: use LSP
              vim.lsp.completion.get()
            end)
          end
        end,
      })

      -- Set keymaps (omnifunc/tagfunc are auto-set by 0.12)
      set_keymaps(bufnr)

    end,
  })
end

return M
