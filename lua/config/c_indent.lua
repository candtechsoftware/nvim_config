-- Shared indentexpr for the C-family ftplugins: cindent plus the one layout
-- it gets wrong for this codebase's switch style.
--
-- A `{` on its own line after a case label sits at the label's indent:
--
--   case A:
--   {
--     ...
--   } break;
--
-- cindent indents that `{` like a statement after the label, and when an
-- earlier label carries its statement on the same line (`default: {}break;`)
-- it lines up with that statement's column instead. Block contents and the
-- closing `}` follow whatever indent the `{` line has, so fixing the `{` (and
-- the plain statement-after-label case) is enough; everything else is cindent.
--
-- indentexpr is evaluated under textlock: the buffer cannot be rewritten from
-- here (setline() silently fails, nvim_buf_set_lines throws E565), so any fix
-- has to be a computed indent, never a rewrite-then-cindent.
local M = {}

local function is_label(line)
  line = line:gsub('%s*//.*$', '')
  return line:match('^%s*case%s.*:%s*$') ~= nil or line:match('^%s*default%s*:%s*$') ~= nil
end

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
