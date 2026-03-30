-- Clipboard manager with system clipboard sync and history
-- Polls system clipboard, maintains history, and provides keybindings

local M = {}

local ClipboardWatcher = {
  last_clip = nil,
  history = {},
  max_items = 100,
  target_reg = 'a', -- which Vim register to mirror into
}

-- Push a new value into history (dedupe consecutive and skip empty)
function ClipboardWatcher:push(text)
  if not text or text == '' then return end
  -- Strip all clipboard history prefix patterns (e.g., "  1: " or "1:   1: ")
  while text:match('^%s*%d+:%s*') do
    text = text:gsub('^%s*%d+:%s*', '')
  end
  if text == '' then return end
  if self.history[1] == text then return end
  table.insert(self.history, 1, text)
  if #self.history > self.max_items then
    table.remove(self.history)
  end
end

-- Sync from system clipboard to register + history
function ClipboardWatcher:sync()
  local current = vim.fn.getreg('+')
  if current ~= self.last_clip then
    self.last_clip = current
    vim.fn.setreg(self.target_reg, current)
    -- Skip if this looks like a clipboard history display line
    if not current:match('^%s*%d+:%s') then
      self:push(current)
    end
  end
end

-- Start the clipboard watcher timer
-- NOTE: Disabled timer polling - can cause cursor flickering
-- Now only syncs on FocusGained and explicit yank
local clipboard_timer = nil
local function start_watcher()
  -- Use FocusGained instead of polling to avoid cursor flicker
  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("ClipboardSync", { clear = true }),
    callback = function()
      vim.schedule(function()
        ClipboardWatcher:sync()
      end)
    end,
  })
  -- Initial sync
  ClipboardWatcher:sync()
end

-- Track yanks inside Neovim via TextYankPost
-- Only track yanks to registers other than the system clipboard,
-- since the watcher handles system clipboard changes
local function setup_yank_tracking()
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("ClipboardYankTrack", { clear = true }),
    callback = function()
      local event = vim.v.event
      -- Skip if yanking to system clipboard - watcher will handle it
      if event.regname == '+' or event.regname == '*' or event.regname == '' then
        return
      end
      if event.operator == 'y' then
        local text = table.concat(event.regcontents, '\n')
        ClipboardWatcher:push(text)
      end
    end,
  })
end

-- Create the ClipboardHistory command
local function setup_commands()
  vim.api.nvim_create_user_command('ClipboardHistory', function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'clipboard_history'

    local lines = {}
    for i, entry in ipairs(ClipboardWatcher.history) do
      local first_line = entry:match('([^\n\r]*)') or ''
      if #first_line > 120 then
        first_line = first_line:sub(1, 117) .. '...'
      end
      table.insert(lines, string.format('%3d: %s', i, first_line))
    end

    if #lines == 0 then
      lines = { '<< clipboard history empty >>' }
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, buf)

    -- Press <CR> to copy entry back to registers
    vim.keymap.set('n', '<CR>', function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local entry = ClipboardWatcher.history[row]
      if entry then
        vim.fn.setreg('+', entry)
        vim.fn.setreg(ClipboardWatcher.target_reg, entry)
        vim.fn.setreg('"', entry)
        vim.notify('Copied clipboard history #' .. row .. ' to +, ' .. ClipboardWatcher.target_reg)
      end
    end, { buffer = buf, nowait = true, noremap = true, silent = true })

    -- Press q to close
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, nowait = true, noremap = true, silent = true })
  end, {})

  vim.api.nvim_create_user_command('ClipboardClear', function()
    ClipboardWatcher:clear()
  end, {})
end

-- Setup keybindings
local function setup_keymaps()
  -- Yank to system clipboard
  vim.keymap.set({"n", "v"}, "<leader>cy", [["+y]], { desc = "Yank to system clipboard" })
  vim.keymap.set("n", "<leader>cY", [["+Y]], { desc = "Yank line to system clipboard" })

  -- Paste from system clipboard
  vim.keymap.set("n", "<leader>cp", [["+p]], { desc = "Paste from system clipboard (after)" })
  vim.keymap.set("n", "<leader>cP", [["+P]], { desc = "Paste from system clipboard (before)" })
  vim.keymap.set("v", "<leader>cp", [["+p]], { desc = "Paste from system clipboard" })

  -- Paste from vim register "a (mirrored system clipboard)
  vim.keymap.set("n", "<leader>ca", [["ap]], { desc = "Paste from register 'a' (after)" })
  vim.keymap.set("n", "<leader>cA", [["aP]], { desc = "Paste from register 'a' (before)" })
  vim.keymap.set("v", "<leader>ca", [["ap]], { desc = "Paste from register 'a'" })

  -- Open clipboard history
  vim.keymap.set("n", "<leader>ch", "<cmd>ClipboardHistory<CR>", { desc = "Open clipboard history" })

  -- Clear clipboard history
  vim.keymap.set("n", "<leader>cc", "<cmd>ClipboardClear<CR>", { desc = "Clear clipboard history" })
end

function M.setup()
  -- Initialize last_clip with current clipboard to avoid adding stale content to history
  ClipboardWatcher.last_clip = vim.fn.getreg('+')
  start_watcher()
  setup_yank_tracking()
  setup_commands()
  setup_keymaps()
end

-- Clear clipboard history
function ClipboardWatcher:clear()
  self.history = {}
  self.last_clip = nil
end

-- Expose for customization
M.watcher = ClipboardWatcher

return M
