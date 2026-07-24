-- HLSL (High-Level Shading Language) file type detection.
-- See ftdetect/glsl.lua for why vim.filetype.add and who owns `.vsh` (glsl).
-- Buffer-local settings (commentstring) live in after/ftplugin/hlsl.lua.
vim.filetype.add({
  extension = {
    hlsl = "hlsl",
    hlsli = "hlsl",
    fx = "hlsl",
    fxh = "hlsl",
    psh = "hlsl",
    cginc = "hlsl",
    compute = "hlsl",
    shader = "hlsl",
  },
})
