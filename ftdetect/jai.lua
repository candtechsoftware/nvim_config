-- Jai filetype detection + options (native, no plugin)
vim.filetype.add({ extension = { jai = "jai" } })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "jai",
  callback = function()
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
    vim.bo.cindent = true
    vim.bo.cinoptions = "N-s"
    vim.bo.errorformat = "%f:%l\\,%c:%m"
    vim.bo.define = "^\\s*\\w\\+\\s*:.*:.*\\s*[({]"
  end,
})
