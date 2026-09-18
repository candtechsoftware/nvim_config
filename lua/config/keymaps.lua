local map = vim.keymap.set

map('n', '<leader>pv', function()
  local dir = vim.fn.expand('%:p:h')
  vim.cmd.edit(dir ~= '' and dir or '.')
end, { desc = 'Open directory browser' })

map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")
map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<Esc>', '<cmd>nohlsearch<CR><Esc>', { silent = true })
map('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })
map({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete without yanking' })
map('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Substitute word under cursor' })

-- A fresh list starts ON entry 1, so step onto the current entry first unless
-- the cursor is already there. <M-n> is 4coder's Alt-N.
local function qf_step(cmd)
  local idx = vim.fn.getqflist({ idx = 0 }).idx
  local cur = idx > 0 and vim.fn.getqflist({ idx = idx, items = 0 }).items[1] or nil
  local on_it = cur ~= nil and cur.bufnr == vim.api.nvim_get_current_buf() and cur.lnum == vim.fn.line('.')
  return '<cmd>' .. (on_it and cmd or 'cc') .. '<CR>zz'
end
map('n', { '<C-k>', '<M-n>' }, function() return qf_step('cnext') end, { expr = true, desc = 'Next quickfix item' })
map('n', { '<C-j>', '<M-N>' }, function() return qf_step('cprev') end, { expr = true, desc = 'Previous quickfix item' })
map('n', '<leader>qo', '<cmd>copen<CR>', { desc = 'Open quickfix list' })
map('n', '<leader>qc', '<cmd>cclose<CR>', { desc = 'Close quickfix list' })
map('n', '<leader>k', '<cmd>lnext<CR>zz', { desc = 'Next location list item' })
map('n', '<leader>j', '<cmd>lprev<CR>zz', { desc = 'Previous location list item' })
map('n', '<leader>qf', function() vim.diagnostic.setqflist({ open = true }) end, { desc = 'Diagnostics to quickfix' })
map('n', '<leader>qq', function() vim.diagnostic.setloclist({ open = true }) end, { desc = 'Diagnostics to location list' })
map('n', '<leader>vd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })

map('n', '<C-,>', '<C-w>w', { desc = 'Cycle splits' })
map('n', '<C-.>', '<C-^>', { desc = 'Alternate buffer' })
map('n', '<leader>t', '<cmd>tabnew<CR>', { desc = 'New tab' })
map('n', '<leader><Tab>', '<cmd>tabnext<CR>', { desc = 'Next tab' })
map('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close tab' })

-- [count]Q places cursors without follow-mode, and only follow-mode replays
-- motions and Visual sequences per cursor. "1q=" forces it on.
map('n', '<leader>Q', '1Q1q=', { desc = 'Cursor on every search match, follow-mode on' })

map('n', '<leader>u', function()
  vim.cmd.packadd('nvim.undotree')
  require('undotree').open()
end, { desc = 'Toggle undotree' })

map('n', '<leader><leader>', '<cmd>source<CR>', { desc = 'Source current file' })
map('n', '<leader>ih', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = 'Toggle inlay hints' })
map('n', '<leader>f', function() require('config.format').buffer(0) end, { desc = 'Format buffer' })

local COMMENT_LINE = [[\v^\s*(//|#|--|"|'|/\*|\*)]]
map('n', ']c', function() vim.fn.search(COMMENT_LINE, 'W') end, { desc = 'Next comment' })
map('n', '[c', function() vim.fn.search(COMMENT_LINE, 'bW') end, { desc = 'Previous comment' })

-- Completion only ever opens from <Tab>. With an LSP: native LSP completion.
-- Without one: omni after `.`/`->`/`::`, the buffer's completefunc when it has
-- one (C, see config/c_complete.lua), else keyword completion.
local function at_member_access()
  local before = vim.fn.getline('.'):sub(1, vim.fn.col('.') - 1)
  return before:match('%.%s*[%w_]*$') or before:match('%->%s*[%w_]*$') or before:match('::%s*[%w_]*$')
end

map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then return '<C-n>' end
  if next(vim.lsp.get_clients({ bufnr = 0 })) then
    vim.schedule(vim.lsp.completion.get)
    return ''
  end
  if at_member_access() then return '<C-x><C-o>' end
  if vim.bo.completefunc ~= '' then return '<C-x><C-u>' end
  return '<C-n>'
end, { expr = true, desc = 'Complete' })
map('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true, desc = 'Previous completion' })
map('i', '<CR>', function()
  if vim.fn.pumvisible() == 0 then return '<CR>' end
  return vim.fn.complete_info({ 'selected' }).selected ~= -1 and '<C-y>' or '<C-e><CR>'
end, { expr = true, desc = 'Accept completion or newline' })
map('i', '<C-]>', '<C-x><C-]>', { desc = 'Tag completion' })
