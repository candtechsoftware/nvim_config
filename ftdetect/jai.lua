vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.jai",
  callback = function()
    vim.bo.filetype = "jai"
    -- Set some reasonable defaults for Jai
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
})