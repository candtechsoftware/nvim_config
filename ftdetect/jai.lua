vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.jai",
  callback = function()
    vim.bo.filetype = "jai"
    -- Set some reasonable defaults for Jai
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
    
    -- Enhanced settings based on Emacs mode
    vim.bo.cindent = true
    vim.bo.cinoptions = "N-s"  -- Better handling of namespaces/nested code
    
    -- Set up compilation error format for Jai
    vim.bo.errorformat = "%f:%l\\,%c:%m"
    
    -- Function text objects and navigation
    vim.bo.define = "^\\s*\\w\\+\\s*:.*:.*\\s*[({]"
  end,
})