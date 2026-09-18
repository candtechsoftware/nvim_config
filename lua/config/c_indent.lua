-- Indentation for the C-family ftplugins.
local M = {}

-- Trees that indent with 4 spaces; everything else is 2. The nearest listed
-- directory wins. A project's .editorconfig still wins over both, since it is
-- applied after ftplugins.
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

function M.width()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= '' then
    for dir in vim.fs.parents(vim.fs.normalize(name)) do
      if BY_DIR[dir] then return BY_DIR[dir] end
    end
  end
  return 2
end

local function is_label(line)
  line = line:gsub('%s*//.*$', '')
  return line:match('^%s*case%s.*:%s*$') ~= nil or line:match('^%s*default%s*:%s*$') ~= nil
end

-- cindent, except the line after a `case`/`default` label: a `{` sits at the
-- label's indent, anything else one shiftwidth in.
function M.indent()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev > 0 and is_label(vim.fn.getline(prev)) and not is_label(line) and not line:match('^%s*[}#]') then
    local base = vim.fn.indent(prev)
    return line:match('^%s*{') and base or base + vim.fn.shiftwidth()
  end
  return vim.fn.cindent(lnum)
end

return M
