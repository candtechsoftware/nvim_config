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
--
-- No "strip the `%3d: ` history-display prefix" pass here any more. It was
-- meant to stop a yank *from* the ClipboardHistory buffer re-entering history
-- with its line number attached — but the <CR> handler below reads
-- `history[row]` directly, never the rendered line, so nothing could reach
-- push() in that form. What the strip did do was silently eat the leading
-- `42: ` from any legitimate yank that happened to start with digits and a
-- colon: `grep -n` output, compiler errors, log lines. Routine content in a
-- quickfix-driven config, corrupted on the way into the history.
function ClipboardWatcher:push(text)
  if not text or text == '' then return end
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
    self:push(current)
  end
end

-- Sync clipboard on FocusGained and explicit yank only.
-- Timer polling was tried but caused cursor flicker.
local function start_watcher()
  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("ClipboardSync", { clear = true }),
    callback = function()
      vim.schedule(function()
        ClipboardWatcher:sync()
      end)
    end,
  })
end

-- Track yanks inside Neovim via TextYankPost.
--
-- Every yank is recorded, including the unnamed one. `clipboard=unnamedplus`
-- (see config/options.lua) means a plain `yy` reports regname == '' — NOT '+'
-- — so the old guard that skipped '' skipped literally every ordinary yank,
-- and nothing reached the history until the next FocusGained. `last_clip` is
-- updated in step so that FocusGained sync does not then re-push the same text.
local function setup_yank_tracking()
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("ClipboardYankTrack", { clear = true }),
    callback = function()
      local event = vim.v.event
      if event.operator ~= 'y' then return end
      local text = table.concat(event.regcontents, '\n')
      ClipboardWatcher:push(text)
      -- Keep the mirror register in step with the yank. Without this, setreg
      -- only ever ran from sync() (FocusGained) and the history picker, so
      -- after any in-Neovim yank `<leader>ca` pasted whatever the clipboard
      -- held at the last focus change — stale, and silently so.
      vim.fn.setreg(ClipboardWatcher.target_reg, text)
      -- With unnamedplus this yank also went to the system clipboard; record
      -- it so the FocusGained sync sees no change and does not double-push.
      if event.regname == '' or event.regname == '+' or event.regname == '*' then
        ClipboardWatcher.last_clip = text
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
  start_watcher()
  setup_yank_tracking()
  setup_commands()
  setup_keymaps()

  -- Seed last_clip with the current clipboard so pre-existing content is not
  -- pushed into history as if it were just yanked. Deferred: on macOS every
  -- getreg('+') spawns `pbpaste` (~12ms), and this used to run twice on the
  -- startup critical path — once here and once in start_watcher's initial
  -- sync, which was redundant anyway since it had just been set to the same
  -- value. Now it costs one spawn, off the critical path.
  vim.schedule(function()
    ClipboardWatcher.last_clip = vim.fn.getreg('+')
  end)
end

-- Clear clipboard history
function ClipboardWatcher:clear()
  self.history = {}
  self.last_clip = nil
end

-- Expose for customization
M.watcher = ClipboardWatcher

return M
