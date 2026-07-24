-- GLSL (OpenGL Shading Language) file type detection.
--
-- vim.filetype.add, not a BufRead/BufNewFile autocmd: extension lookup is a
-- hash hit instead of glob patterns evaluated against every opened file, and
-- user-added entries take priority over the runtime's (needed for `.fs`,
-- which the runtime would otherwise detect as Forth/F#).
--
-- `.vsh` is claimed here, not in ftdetect/hlsl.lua: both files used to
-- register it, so whichever autocmd was defined last won, nondeterministically.
-- It belongs with its GLSL siblings `.fsh`/`.gsh`; HLSL keeps `.psh`.
-- No ftplugin needed: the runtime's ftplugin/glsl.lua sets commentstring.
vim.filetype.add({
  extension = {
    glsl = "glsl",
    vert = "glsl",
    frag = "glsl",
    geom = "glsl",
    tesc = "glsl",
    tese = "glsl",
    comp = "glsl",
    vs = "glsl",
    fs = "glsl",
    gs = "glsl",
    vsh = "glsl",
    fsh = "glsl",
    gsh = "glsl",
    vshader = "glsl",
    fshader = "glsl",
    gshader = "glsl",
  },
})
