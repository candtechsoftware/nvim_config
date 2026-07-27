-- naysayer_black: naysayer's foreground palette on a neutral dark-grey
-- background. The two schemes differed by 10 palette entries across 359
-- duplicated lines, so the whole thing now lives in naysayer.lua behind this
-- flag. This file exists so `:colorscheme naysayer_black` keeps working.
vim.g.naysayer_black = true
local ok, err = pcall(dofile, vim.fn.stdpath("config") .. "/colors/naysayer.lua")
vim.g.naysayer_black = nil
if not ok then error(err) end
