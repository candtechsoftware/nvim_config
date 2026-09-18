-- Servers are configured in lsp/*.lua. Status, restart and logs are the builtin
-- :checkhealth vim.lsp, :lsp restart|stop|enable and :log lsp.
local M = {}

-- clangd only attaches where :ClangdSetup opted the project in (lsp/clangd.lua).
local SERVERS = { 'clangd', 'lua_ls', 'gopls', 'ts_ls', 'eslint', 'rust_analyzer', 'zls', 'ols', 'jails' }

local function capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local td = caps.textDocument
  td.completion.completionItem.snippetSupport = false
  td.completion.completionItem.documentationFormat = { 'plaintext', 'markdown' }
  td.signatureHelp.signatureInformation.documentationFormat = { 'plaintext', 'markdown' }
  td.hover.contentFormat = { 'plaintext', 'markdown' }
  return caps
end

-- Some servers start textEdit.range at the cursor instead of the start of the
-- word, so accepting `window` after `game.win` gave `game.winwindow`. Snap such
-- starts back to the word boundary. Patches a private function.
local function patch_completion_ranges()
  local convert = vim.lsp.completion._convert_results
  vim.lsp.completion._convert_results = function(line, lnum, cursor_col, client_id, client_start, server_start, result, encoding)
    local enc = encoding or 'utf-16'
    local boundary = vim.str_utfindex(line, enc, client_start, false)
    for _, item in ipairs(result.items or result) do
      for _, key in ipairs({ 'range', 'insert', 'replace' }) do
        local range = item.textEdit and item.textEdit[key]
        if range and range.start.line == lnum
          and vim.str_byteindex(line, enc, range.start.character, false) > client_start then
          range.start.character = boundary
        end
      end
    end
    return convert(line, lnum, cursor_col, client_id, client_start, server_start, result, encoding)
  end
end

local function jump(win, item)
  vim.api.nvim_win_call(win, function() vim.cmd("normal! m'") end)
  local buf = vim.fn.bufadd(item.filename)
  vim.bo[buf].buflisted = true
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_cursor(win, { item.lnum, math.max(item.col - 1, 0) })
end

-- One result jumps without touching quickfix (it holds the build errors), several go to quickfix.
local function show(win, items, title)
  if #items == 1 then
    jump(win, items[1])
  else
    vim.fn.setqflist({}, ' ', { title = title, items = items })
    vim.cmd('botright copen')
  end
end

local function index_definition(buf, win, word)
  vim.lsp.buf_request(buf, 'workspace/symbol', { query = word }, function(_, result)
    local items = {}
    for _, sym in ipairs(result or {}) do
      local loc = sym.location
      if sym.name == word and loc.range then
        items[#items + 1] = {
          filename = vim.uri_to_fname(loc.uri),
          lnum = loc.range.start.line + 1,
          col = loc.range.start.character + 1,
          text = sym.containerName and (sym.containerName .. '::' .. sym.name) or sym.name,
        }
      end
    end
    if #items == 0 then
      vim.notify('no definition of ' .. word, vim.log.levels.WARN)
    else
      show(win, items, 'Definition: ' .. word)
    end
  end)
end

-- A function defined only in another unity member is an implicit declaration
-- in this file's standalone parse, so clangd answers with the call site itself.
-- The background index knows the real definition, so ask it by name instead.
function M.goto_definition(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local word_col = col + 2 - #line:sub(1, col + 1):match('[%w_]*$')
  local is_call = line:sub(col + 2):match('^[%w_]*%s*%(') ~= nil
  local word = vim.fn.expand('<cword>')
  vim.lsp.buf.definition({
    on_list = function(list)
      local item = list.items[1]
      if #list.items == 1 and is_call and item.filename == name and item.lnum == row and item.col == word_col then
        index_definition(buf, win, word)
      else
        show(win, list.items, list.title)
      end
    end,
  })
end

-- Definition in the other split, creating one if needed, keeping focus here.
local function definition_in_other_window()
  local cur = vim.api.nvim_get_current_win()
  local target
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= cur then
      target = win
      break
    end
  end
  if not target then
    vim.cmd('vsplit')
    target = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur)
  end
  M.goto_definition(target)
end

-- Folding is window-local, and LspAttach carries no window.
local function set_folding(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].foldmethod = 'expr'
    vim.wo[win].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    vim.wo[win].foldlevel = 99
  end
end

local INCOMPLETE = { triggerKind = vim.lsp.protocol.CompletionTriggerKind.TriggerForIncompleteCompletions }

function M.setup()
  patch_completion_ranges()

  -- Diagnostics are received (float and qf/loclist maps work) but never drawn.
  vim.diagnostic.config({
    severity_sort = true,
    float = { header = '', prefix = '', focusable = false, max_width = 80, max_height = 20, source = true },
  })
  vim.diagnostic.enable(false)

  vim.lsp.config('*', { capabilities = capabilities() })
  vim.lsp.enable(SERVERS)

  local buf_group = vim.api.nvim_create_augroup('lsp_buf', {})
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp_attach', {}),
    callback = function(ev)
      local buf = ev.buf
      set_folding(buf)
      vim.lsp.completion.enable(true, ev.data.client_id, buf, { autotrigger = false })

      -- Two clients can attach to one buffer; replace rather than stack.
      vim.api.nvim_clear_autocmds({ group = buf_group, buf = buf })
      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = buf_group,
        buf = buf,
        callback = function() set_folding(buf) end,
      })
      -- Signature help on ( and ,. Without autotrigger nothing re-queries a
      -- truncated list (clangd caps at 100 items), so do that while its popup is open.
      vim.api.nvim_create_autocmd('InsertCharPre', {
        group = buf_group,
        buf = buf,
        callback = function()
          if vim.v.char == '(' or vim.v.char == ',' then
            vim.schedule(function() vim.lsp.buf.signature_help({ silent = true }) end)
          end
          if vim.fn.complete_info({ 'mode' }).mode == 'eval' then
            vim.schedule(function() vim.lsp.completion.get({ ctx = INCOMPLETE }) end)
          end
        end,
      })

      local opts = { buf = buf, silent = true }
      vim.keymap.set('n', 'gd', M.goto_definition, opts)
      vim.keymap.set('n', 'gv', definition_in_other_window, opts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', '<leader>vi', vim.lsp.buf.incoming_calls, opts)
    end,
  })
end

return M
