-- The shared tail of every external formatter in this config (odinfmt,
-- prettier): turn the tool's stdout into buffer lines and swap them in without
-- disturbing the view or dirtying a buffer that was already formatted. Kept in
-- one place so the two formatters cannot drift on the cursor/undo details.

local M = {}

---Split formatter stdout into buffer lines.
---@param out string
---@return string[]
function M.split_output(out)
  -- Buffer lines never hold the '\r' of a CRLF file ('fileformat' puts it back
  -- on write), so strip it whatever line ending the tool was configured for.
  local lines = vim.split((out:gsub('\r\n', '\n')), '\n', { plain = true })
  -- The output ends with a newline (odinfmt's println, Prettier's own), which
  -- splits into a trailing empty line. Neovim writes the final newline itself.
  while #lines > 0 and lines[#lines] == '' do
    table.remove(lines)
  end
  return lines
end

---Replace the whole buffer with `formatted`, keeping the window's view.
---@param bufnr integer
---@param lines string[] the buffer's lines as they were handed to the formatter
---@param formatted string[] the formatter's output, from `split_output`
---@return boolean changed false if the buffer was already formatted
function M.replace(bufnr, lines, formatted)
  -- Already formatted: don't touch the buffer, so 'modified' and the undo tree
  -- stay as they were.
  if vim.deep_equal(lines, formatted) then return false end

  local win = vim.api.nvim_get_current_win()
  local restore = vim.api.nvim_win_get_buf(win) == bufnr and vim.fn.winsaveview() or nil

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)

  if restore then
    -- The formatted text can be shorter than what the cursor sat on.
    restore.lnum = math.min(restore.lnum, math.max(#formatted, 1))
    vim.fn.winrestview(restore)
  end
  return true
end

return M
