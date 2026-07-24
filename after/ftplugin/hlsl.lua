-- Load-bearing, unlike glsl (whose runtime ftplugin sets this): the runtime
-- ships no ftplugin/hlsl. Indent options from the old ftdetect were dropped
-- as no-ops (identical to the globals in lua/config/options.lua).
vim.bo.commentstring = "// %s"
