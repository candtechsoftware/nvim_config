-- Indentation for the C-family ftplugins.
local M = {}

local function is_label(line)
  line = line:gsub('%s*//.*$', '')
  return line:match('^%s*case%s.*:%s*$') ~= nil or line:match('^%s*default%s*:%s*$') ~= nil
end

-- cindent, except the line after a `case`/`default` label: a `{` sits at the
-- label's indent, anything else one shiftwidth in.
function M.indent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev > 0 and is_label(vim.fn.getline(prev)) and not is_label(line) and not line:match('^%s*[}#]') then
    local base = vim.fn.indent(prev)
    return line:match('^%s*{') and base or base + vim.fn.shiftwidth()
  end
  return vim.fn.cindent(lnum)
end

return M
