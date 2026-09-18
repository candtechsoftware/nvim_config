-- `.fs` would otherwise be Forth/F#.
vim.filetype.add({
  extension = {
    glsl = 'glsl', vert = 'glsl', frag = 'glsl', geom = 'glsl', tesc = 'glsl', tese = 'glsl', comp = 'glsl',
    vs = 'glsl', fs = 'glsl', gs = 'glsl', vsh = 'glsl', fsh = 'glsl', gsh = 'glsl',
    vshader = 'glsl', fshader = 'glsl', gshader = 'glsl',
    hlsl = 'hlsl', hlsli = 'hlsl', fx = 'hlsl', fxh = 'hlsl', psh = 'hlsl', cginc = 'hlsl', compute = 'hlsl', shader = 'hlsl',
    m = 'objc', mm = 'objcpp',
    jai = 'jai',
  },
})

vim.treesitter.language.register('objc', 'objcpp')
