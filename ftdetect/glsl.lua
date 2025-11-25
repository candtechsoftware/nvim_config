-- GLSL (OpenGL Shading Language) file type detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.glsl", "*.vert", "*.frag", "*.geom", "*.tesc", "*.tese", "*.comp", "*.vs", "*.fs", "*.gs", "*.vsh", "*.fsh", "*.gsh", "*.vshader", "*.fshader", "*.gshader" },
  callback = function()
    vim.bo.filetype = "glsl"
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
})