-- Jai filetype detection + options (native, no plugin)
vim.filetype.add({ extension = { jai = "jai" } })

-- Simple brace-aware indentexpr for Jai.
-- cindent misreads `x: Type` as a C goto-label, so we roll our own.
function _G._jai_indentexpr()
  local lnum = vim.v.lnum
  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev == 0 then return 0 end

  local prev_line = vim.fn.getline(prev)
  local indent = vim.fn.indent(prev)
  local sw = vim.bo.shiftwidth

  -- Increase indent after lines ending with { or (
  if prev_line:match('[{(]%s*$') or prev_line:match('[{(]%s*//.*$') then
    indent = indent + sw
  end

  -- Decrease indent for lines starting with } or )
  local cur_line = vim.fn.getline(lnum)
  if cur_line:match('^%s*[})]') then
    indent = indent - sw
  end

  return math.max(0, indent)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "jai",
  callback = function()
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
    vim.bo.smartindent = false
    vim.bo.cindent = false
    vim.bo.indentexpr = 'v:lua._jai_indentexpr()'
    vim.bo.errorformat = "%f:%l\\,%c:%m"
    vim.bo.define = "^\\s*\\w\\+\\s*:.*:.*\\s*[({]"
  end,
})
