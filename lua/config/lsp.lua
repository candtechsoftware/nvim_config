-- Modern Neovim 0.11+ LSP configuration
-- Uses vim.lsp.config + vim.lsp.enable() API with lsp/*.lua config files

local M = {}

-- LSP servers to enable (configs are in lsp/*.lua)
local servers = {
  'clangd',
  'lua_ls',
  'gopls',
  'tsgo',
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

  local c_filetypes = { c = true, cpp = true, objc = true, objcpp = true }

  -- Navigation
  vim.keymap.set('n', 'gd', function()
    -- Try ctags first for C/C++ (covers unity builds and project-local symbols)
    if c_filetypes[vim.bo.filetype] then
      local word = vim.fn.expand('<cword>')
      local saved_tagfunc = vim.bo.tagfunc
      vim.bo.tagfunc = ''
      local tags = vim.fn.taglist('^' .. word .. '$')
      vim.bo.tagfunc = saved_tagfunc
      if #tags > 0 then
        require('config.ctags').jump()
        return
      end
    end
    -- No ctags match — try LSP
    vim.lsp.buf.definition()
  end, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<leader>gi', require('config.ctags').jump, opts)
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

    -- Try ctags first for C/C++ (synchronous)
    if c_filetypes[vim.bo.filetype] then
      local saved_tagfunc = vim.bo.tagfunc
      vim.bo.tagfunc = ''
      local tags = vim.fn.taglist('^' .. word .. '$')
      vim.bo.tagfunc = saved_tagfunc

      if #tags > 0 then
        vim.api.nvim_set_current_win(target_win)
        vim.bo.tagfunc = ''
        pcall(vim.cmd, 'tag ' .. vim.fn.fnameescape(word))
        vim.bo.tagfunc = saved_tagfunc
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
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

  -- Actions
  vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>vi', vim.lsp.buf.incoming_calls, opts)

  -- Signature help in insert mode (manual trigger)
  vim.keymap.set('i', '<C-h>', function()
    vim.lsp.buf.signature_help({ focusable = false, focus = false })
  end, opts)

  -- Formatting (manual) - use jai-format for Jai, LSP for others
  vim.keymap.set('n', '<leader>f', function()
    if vim.bo.filetype == "jai" or vim.fn.expand("%:e") == "jai" then
      local view = vim.fn.winsaveview()
      local tmpfile = "/tmp/jai-format-buffer.jai"
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      vim.fn.writefile(lines, tmpfile)
      local result = vim.fn.system("cd /tmp && jai-format -to_stdout -silent " .. tmpfile .. " 2>/dev/null")
      local exit_code = vim.v.shell_error
      vim.fn.delete(tmpfile)
      if exit_code == 0 and result ~= "" then
        local new_lines = vim.split(result, "\n", { plain = true })
        if new_lines[#new_lines] == "" then
          table.remove(new_lines)
        end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
      else
        vim.notify("jai-format failed: " .. result, vim.log.levels.ERROR)
      end
      vim.fn.winrestview(view)
    else
      vim.lsp.buf.format({ async = false })
    end
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
    if not result or not result.signatures or #result.signatures == 0 then
      -- Close any existing signature help window
      local wins = vim.api.nvim_list_wins()
      for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft == 'markdown' and vim.api.nvim_win_get_config(win).relative ~= '' then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end
      return
    end

    -- Fix activeParameter - count commas at current nesting level
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before_cursor = line:sub(1, col)

    -- Find the matching opening paren for our current context
    local paren_depth = 0
    local bracket_depth = 0
    local brace_depth = 0
    local in_string = false
    local string_char = nil
    local paren_pos = nil

    -- Scan backwards to find the opening paren at depth 0
    for i = #before_cursor, 1, -1 do
      local c = before_cursor:sub(i, i)
      local prev = i > 1 and before_cursor:sub(i - 1, i - 1) or ''

      -- Handle string detection (simple - doesn't handle all escape sequences)
      if (c == '"' or c == "'") and prev ~= '\\' then
        if in_string and c == string_char then
          in_string = false
          string_char = nil
        elseif not in_string then
          in_string = true
          string_char = c
        end
      elseif not in_string then
        if c == ')' then paren_depth = paren_depth + 1
        elseif c == '(' then
          if paren_depth == 0 then
            paren_pos = i
            break
          end
          paren_depth = paren_depth - 1
        elseif c == ']' then bracket_depth = bracket_depth + 1
        elseif c == '[' then bracket_depth = bracket_depth - 1
        elseif c == '}' then brace_depth = brace_depth + 1
        elseif c == '{' then brace_depth = brace_depth - 1
        end
      end
    end

    if paren_pos then
      -- Count commas at depth 0 after the opening paren
      local inside = before_cursor:sub(paren_pos + 1)
      local comma_count = 0
      paren_depth = 0
      bracket_depth = 0
      brace_depth = 0
      in_string = false
      string_char = nil

      for i = 1, #inside do
        local c = inside:sub(i, i)
        local prev = i > 1 and inside:sub(i - 1, i - 1) or ''

        if (c == '"' or c == "'") and prev ~= '\\' then
          if in_string and c == string_char then
            in_string = false
            string_char = nil
          elseif not in_string then
            in_string = true
            string_char = c
          end
        elseif not in_string then
          if c == '(' then paren_depth = paren_depth + 1
          elseif c == ')' then paren_depth = paren_depth - 1
          elseif c == '[' then bracket_depth = bracket_depth + 1
          elseif c == ']' then bracket_depth = bracket_depth - 1
          elseif c == '{' then brace_depth = brace_depth + 1
          elseif c == '}' then brace_depth = brace_depth - 1
          elseif c == ',' and paren_depth == 0 and bracket_depth == 0 and brace_depth == 0 then
            comma_count = comma_count + 1
          end
        end
      end

      result.activeParameter = comma_count
      if result.signatures[1] then
        result.signatures[1].activeParameter = comma_count
      end
    end

    -- Create floating window manually to ensure no focus stealing
    local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result, vim.bo[ctx.bufnr].filetype, {})
    if not lines or #lines == 0 then
      return
    end

    -- Store current window before creating float
    local current_win = vim.api.nvim_get_current_win()

    local fbuf, fwin = vim.lsp.util.open_floating_preview(lines, 'markdown', {
      border = 'rounded',
      max_width = 80,
      max_height = 15,
      focus_id = 'signature_help',
      focusable = false,
      focus = false,
    })

    -- Force window to never be focusable and restore focus
    if fwin and vim.api.nvim_win_is_valid(fwin) then
      vim.api.nvim_win_set_config(fwin, { focusable = false })
      -- Force focus back to original window
      vim.api.nvim_set_current_win(current_win)
    end

    return fbuf, fwin
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

      -- Disable diagnostics for clangd (unity builds produce false positives)
      if client.name == 'clangd' then
        vim.diagnostic.enable(false, { bufnr = bufnr })
      end

      -- Set keymaps
      set_keymaps(bufnr)

      -- Set omnifunc for <C-x><C-o>
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Set tagfunc for CTRL-] navigation
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'

      -- Auto-trigger completion (C/C++ uses ctags-based, others use native LSP completion)
      local ft = vim.bo[bufnr].filetype
      if client:supports_method('textDocument/completion') then
        if ft == 'c' or ft == 'cpp' or ft == 'objc' or ft == 'objcpp' then
          require('config.ctags').setup_completion(bufnr)
        else
          require('config.ctags').setup_lsp_completion(bufnr)
        end
      end

      -- Debounced signature help trigger (independent of completion)
      if client:supports_method('textDocument/signatureHelp') then
        local sig_help_timer = vim.uv.new_timer()
        vim.api.nvim_create_autocmd('TextChangedI', {
          buffer = bufnr,
          callback = function()
            sig_help_timer:stop()
            sig_help_timer:start(150, 0, vim.schedule_wrap(function()
              if vim.api.nvim_get_current_buf() ~= bufnr then return end
              if not vim.api.nvim_buf_is_valid(bufnr) then return end
              if vim.fn.pumvisible() == 1 or vim.api.nvim_get_mode().mode ~= 'i' then
                return
              end

              local col = vim.api.nvim_win_get_cursor(0)[2]
              if col < 1 then return end

              local line = vim.api.nvim_get_current_line()
              local char = line:sub(col, col)

              -- Trigger signature help on ( or ,
              if char == '(' or char == ',' then
                vim.lsp.buf.signature_help({ focusable = false, focus = false })
              -- Re-trigger signature help if we're inside unclosed parens
              elseif line:sub(1, col):match('%([^)]*$') then
                vim.lsp.buf.signature_help({ focusable = false, focus = false })
              end
            end))
          end,
        })
      end
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
