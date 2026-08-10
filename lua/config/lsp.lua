-- Neovim 0.12+ LSP configuration
-- Uses vim.lsp.config + vim.lsp.enable() with lsp/*.lua config files
-- Default mappings (grn, grr, gra, gO, K, C-s) are set automatically

local M = {}

-- LSP servers to enable (configs are in lsp/*.lua)
-- tsgo (TypeScript-Go 7.0.0-dev) is intentionally NOT in this list — it has
-- gaps with Expo/React Native projects (e.g. ~/work/app/IrisBetaApp). Use
-- ts_ls (typescript-language-server) instead. To experiment with tsgo on a
-- single buffer, run :lsp enable tsgo manually.
-- clangd is marker-gated (see lsp/clangd.lua); :ClangdSetup opts a project in.
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

local function lsp_command_names()
  local names, seen = {}, {}
  for _, name in ipairs(servers) do
    names[#names + 1] = name
    seen[name] = true
  end
  for _, client in ipairs(vim.lsp.get_clients()) do
    if not seen[client.name] then
      names[#names + 1] = client.name
      seen[client.name] = true
    end
  end
  table.sort(names)
  return names
end

local function complete_lsp_name(arg_lead)
  local out = {}
  for _, name in ipairs(lsp_command_names()) do
    if name:find('^' .. vim.pesc(arg_lead)) then
      out[#out + 1] = name
    end
  end
  return out
end

local function command_targets(name)
  if name ~= '' then return { name } end
  return servers
end

local function attached_clients(bufnr, name)
  local opts = { bufnr = bufnr }
  if name ~= '' then opts.name = name end
  return vim.lsp.get_clients(opts)
end

local function stop_clients(bufnr, name)
  local clients = attached_clients(bufnr, name)
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  return clients
end

---Get LSP capabilities: the deltas from Neovim's defaults, and nothing else.
---
---This used to assign `caps.textDocument.completion = { ... }` wholesale, ~46
---lines restating what `make_client_capabilities()` already returns
---(contextSupport, deprecatedSupport, labelDetailsSupport, insertReplaceSupport,
---preselectSupport, tagSupport, parameterInformation...). Those were no-ops:
---`Client:_init` deep-merges our table over the defaults, so anything identical
---to the default, and anything omitted, ends up the same either way.
---
---What was NOT a no-op: `tbl_deep_extend` REPLACES lists rather than merging
---them, so restating `resolveSupport.properties` without `'command'` (which the
---default includes) actually dropped it, weakening lazy resolution of
---completion-item commands — ts_ls auto-imports in particular. Mutating the
---defaults in place keeps every list intact and leaves only the three real
---intentions: no snippets, and plaintext preferred over markdown.
---@return table
local function get_capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local td = caps.textDocument

  td.completion.completionItem.snippetSupport = false
  td.completion.completionItem.documentationFormat = { 'plaintext', 'markdown' }
  td.signatureHelp.signatureInformation.documentationFormat = { 'plaintext', 'markdown' }
  td.hover.contentFormat = { 'plaintext', 'markdown' }

  -- Kept only to preserve the previous behavior exactly: the old wholesale
  -- assignment set this, and the default is `true`. Unlike completion's and
  -- signatureHelp's (which are false by default anyway), this one is a real
  -- deviation. Nothing here records why it was wanted, so it stays rather than
  -- get flipped as a side effect of a cleanup. Safe to drop if hover should
  -- follow the default.
  td.hover.dynamicRegistration = false

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

---Configure diagnostics display.
---
---Diagnostics are OFF. This config wants exactly three things from the LSP —
---completion, member/struct completion, and signature help — and diagnostics
---are the part that costs the most for the least: every display mode here
---(virtual_text, signs, underline) is drawn per redrawn line, so on a unity
---build like ~/projects/tick, where clangd reports a steady stream of
---unity-build false positives, they were repainted on every scroll step and
---every keystroke.
---
---`vim.diagnostic.enable(false)` at the end is the ONLY switch: it stops every
---extmark and sign being placed, whatever the display modes below say. Those
---modes are therefore left fully configured rather than set to `false` — a
---second, redundant off switch would have made `:lua vim.diagnostic.enable(true)`
---turn diagnostics back on and still render nothing, which is a worse place to
---land than either state. Diagnostics are still received and stored, so
---`<leader>vd` (open_float) and the qf/loclist commands below work untouched.
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
      -- no `border` here: floats inherit 'winborder' (rounded, options.lua)
      header = '',
      prefix = '',
      focusable = false,
      max_width = 80,
      max_height = 20,
      source = true,
    },
  })
  -- The single off switch. Everything configured above is what you get back
  -- from `:lua vim.diagnostic.enable(true)`.
  vim.diagnostic.enable(false)
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

  -- Configure defaults for ALL LSP servers.
  -- No `root_markers` here: config resolution deep-extends '*' with the
  -- server's own table, and lists REPLACE rather than merge — so every
  -- lsp/*.lua's root_markers won outright and a '.git' default here was never
  -- read by anything. It also read as if it were *adding* to each server's
  -- markers, which it was not. All nine servers set their own.
  vim.lsp.config('*', {
    capabilities = get_capabilities(),
  })

  -- Enable all servers (vim.lsp.enable handles missing executables gracefully)
  vim.lsp.enable(servers)

  -- One augroup for every buffer-local LSP autocmd. This used to be
  -- `nvim_create_augroup('lsp_insert_trigger_' .. bufnr)` per attach, which
  -- leaked one augroup per buffer that ever had a client — buffer numbers only
  -- go up, so a long session accumulated them forever. Scoping the *clear* to
  -- the buffer (below) keeps the anti-stacking property when two clients attach
  -- to one buffer (ts_ls + eslint) without the leak.
  local buf_group = vim.api.nvim_create_augroup('lsp_buf_local', { clear = true })

  ---Turn on LSP folding for every window currently displaying `bufnr`.
  ---
  ---`LspAttach` is fired with `data = { client_id }` only — there is no
  ---`winid`. `vim.wo[args.data.winid or 0]` therefore always took the `or 0`
  ---branch and configured the *current* window, whichever that happened to be
  ---when the async `initialize` response landed. Splitting to another file
  ---while clangd started up gave that window clangd's foldexpr. Folding is
  ---window-local, so it also has to be re-applied when a new window shows the
  ---buffer, hence the BufWinEnter hook.
  ---@param bufnr integer
  local function set_folding(bufnr)
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
      vim.wo[win].foldmethod = 'expr'
      vim.wo[win].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      vim.wo[win].foldlevel = 99
    end
  end

  -- LspAttach: Set up keymaps and completion when LSP attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_attach_config', { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      local bufnr = args.buf

      -- LSP folding
      set_folding(bufnr)

      -- Native LSP completion — Tab-only, no auto-triggers
      -- (see lua/config/keymaps.lua).
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })

      -- Replace only THIS buffer's autocmds, leaving other buffers' intact.
      vim.api.nvim_clear_autocmds({ group = buf_group, buffer = bufnr })

      -- A window opened on this buffer later needs folding too.
      vim.api.nvim_create_autocmd('BufWinEnter', {
        buffer = bufnr,
        group = buf_group,
        callback = function() set_folding(bufnr) end,
      })

      -- Signature help on '(' and ',' — one-line cmdline echo only, no popup.
      vim.api.nvim_create_autocmd('InsertCharPre', {
        buffer = bufnr,
        group = buf_group,
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

  -- Compatibility commands for the old common spellings. Neovim 0.12 has
  -- lower-case `:lsp ...`, but these are easier to type from memory.
  vim.api.nvim_create_user_command('LspStop', function(cmd)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = stop_clients(bufnr, cmd.args)
    local label = cmd.args ~= '' and cmd.args or 'attached LSP clients'
    vim.notify(('Stopped %d %s for buffer %d'):format(#clients, label, bufnr), vim.log.levels.INFO)
  end, {
    nargs = '?',
    complete = complete_lsp_name,
    desc = 'Stop LSP clients attached to current buffer',
  })

  vim.api.nvim_create_user_command('LspStart', function(cmd)
    local targets = command_targets(cmd.args)
    vim.lsp.enable(targets)
    vim.notify(('Started/enabled LSP: %s'):format(table.concat(targets, ', ')), vim.log.levels.INFO)
  end, {
    nargs = '?',
    complete = complete_lsp_name,
    desc = 'Start or enable LSP clients',
  })

  vim.api.nvim_create_user_command('LspRestart', function(cmd)
    local bufnr = vim.api.nvim_get_current_buf()
    local targets = command_targets(cmd.args)
    local stopped = stop_clients(bufnr, cmd.args)
    vim.defer_fn(function()
      vim.lsp.enable(targets)
      vim.notify(('Restarted LSP: %s (%d stopped)'):format(table.concat(targets, ', '), #stopped),
        vim.log.levels.INFO)
    end, 200)
  end, {
    nargs = '?',
    complete = complete_lsp_name,
    desc = 'Restart LSP clients for current buffer',
  })

  -- :LspLog — open the LSP log file in a new tab.
  vim.api.nvim_create_user_command('LspLog', function()
    vim.cmd('tabnew ' .. vim.fn.fnameescape(vim.lsp.log.get_filename()))
  end, { desc = 'Open the LSP log file' })
end

return M
