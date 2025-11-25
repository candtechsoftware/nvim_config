-- HLSL (High-Level Shading Language) file type detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.hlsl", "*.hlsli", "*.fx", "*.fxh", "*.vsh", "*.psh", "*.cginc", "*.compute", "*.shader" },
  callback = function()
    vim.bo.filetype = "hlsl"
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
})