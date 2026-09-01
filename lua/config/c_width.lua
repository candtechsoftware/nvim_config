-- Indent width for the C-family ftplugins. Three sources, highest first:
--
--   1. The project's own .editorconfig. Nothing here reads it: Neovim applies
--      .editorconfig AFTER ftplugins run (see :h editorconfig and
--      $VIMRUNTIME/plugin/editorconfig.lua), so an indent_size lands on top of
--      whatever this returns. ~/projects/the_std already works this way.
--   2. WIDTHS below, nearest enclosing directory winning.
--   3. DEFAULT.
--
-- This replaced a scan that voted on the first 2/4/8-space line of up to 40
-- files under the project root, and it was wrong in both directions: the
-- 40-file cap called ~/projects/gap 4-space when the full tree is 421 files of
-- 2 against 121 of 4, and 8-space block-comment prose put six spurious 8 votes
-- into ~/projects/test_game. A width the reader can look up beats a width the
-- editor guesses.
local DEFAULT = 2

-- Only the trees that are not DEFAULT, so this list is the 4-space ones. A
-- nested entry overrides its parent: draw is 4-space apart from src/font.
local WIDTHS = {
  ['~/projects/Library'] = 4,
  ['~/projects/RenderApi'] = 4,
  ['~/projects/TheCountsDown'] = 4,
  ['~/projects/TheGame'] = 4,
  ['~/projects/TheLibrary'] = 4,
  ['~/projects/TheModules'] = 4,
  ['~/projects/TheStd'] = 4,
  ['~/projects/asset_pack'] = 4,
  ['~/projects/bifrost'] = 4,
  ['~/projects/cap'] = 4,
  ['~/projects/codebase'] = 4,
  ['~/projects/core'] = 4,
  ['~/projects/draw'] = 4,
  ['~/projects/draw/src/font'] = 2,
  ['~/projects/engine'] = 4,
  ['~/projects/enjam'] = 4,
  ['~/projects/game-engine'] = 4,
  ['~/projects/game_jam'] = 4,
  ['~/projects/gamejam-engine'] = 4,
  ['~/projects/games'] = 4,
  ['~/projects/gbc'] = 4,
  ['~/projects/graphics_learnin'] = 4,
  ['~/projects/jamgen'] = 4,
  ['~/projects/jeng'] = 4,
  ['~/projects/jeng2'] = 4,
  ['~/projects/jengine'] = 4,
  ['~/projects/no_libc'] = 4,
  ['~/projects/notes'] = 4,
  ['~/projects/old_std'] = 4,
  ['~/projects/sekaiju'] = 4,
  ['~/projects/std'] = 4,
  ['~/projects/tasked'] = 4,
  ['~/projects/test_asset_pack'] = 4,
  ['~/projects/test_game'] = 4,
  ['~/projects/the_platform'] = 4,
}

local BY_DIR = {}
for path, width in pairs(WIDTHS) do
  BY_DIR[vim.fs.normalize(path)] = width
end

local M = {}

---@return integer
function M.get()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= '' then
    for dir in vim.fs.parents(vim.fs.normalize(name)) do
      if BY_DIR[dir] then return BY_DIR[dir] end
    end
  end
  return DEFAULT
end

return M
