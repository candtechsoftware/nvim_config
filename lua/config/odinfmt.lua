-- Format Odin buffers with `odinfmt`, the formatter that ships with ols
-- (~/gits/ols; build it with ./odinfmt.sh, which drops the binary next to
-- `ols`). ols can also format over LSP, but driving the binary keeps <leader>f
-- working when the server is not attached — no ols.json in the project, ols
-- still indexing, or a crashed server.
--
-- Style comes from `odinfmt.json` (character_width, tabs/spaces, brace_style,
-- align_struct_fields, ...); the ols README documents the full set.

local M = {}

local TIMEOUT_MS = 5000

---Run the whole buffer through odinfmt and write the result back.
---@param bufnr integer|nil buffer to format (0/nil = current)
---@return boolean ok false if odinfmt is missing or rejected the buffer
function M.format(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr

  if vim.fn.executable('odinfmt') == 0 then
    vim.notify('odinfmt not on PATH — build it with ~/gits/ols/odinfmt.sh', vim.log.levels.WARN)
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- odinfmt finds `odinfmt.json` by walking UP from its `-path` argument, and
  -- with `-stdin` alone that path is the process cwd — whatever nvim was
  -- started in, not the project this buffer belongs to. Pointing it at the
  -- buffer's own directory is what makes per-project style actually apply.
  local name = vim.api.nvim_buf_get_name(bufnr)
  local dir = name ~= '' and vim.fs.dirname(name) or vim.uv.cwd()

  local res = vim.system(
    { 'odinfmt', '-path:' .. dir, '-stdin' },
    { stdin = table.concat(lines, '\n') .. '\n', text = true }
  ):wait(TIMEOUT_MS)

  -- A buffer that does not parse is not formatted: odinfmt reports the
  -- position on stderr, prints nothing, and exits 1. Leave the text alone.
  if res.code ~= 0 or not res.stdout or res.stdout == '' then
    local msg = vim.trim(res.stderr or '')
    vim.notify(msg ~= '' and ('odinfmt: ' .. msg) or 'odinfmt failed', vim.log.levels.WARN)
    return false
  end

  -- CRLF/trailing-newline handling and the view-preserving swap are shared
  -- with the Prettier path (lua/config/prettier.lua).
  local format_buf = require('config.format_buf')
  format_buf.replace(bufnr, lines, format_buf.split_output(res.stdout))
  return true
end

return M
