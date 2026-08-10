-- The one list of vendored/build directory names that project-tree scanners skip.
--
-- Four tools in this config walk a project tree, and every one of them needs
-- this list in a different argv format: clangd unity-TU discovery
-- (config/clangd_setup.lua), the ctags index (config/ctags.lua), telescope's
-- rg pickers (config/telescope.lua), and the #define indexer (hh/macros.lua).
--
-- It lives here because the list was previously re-typed in each of those four
-- files, and they drifted — with consequences far past "the scan is slow".
-- Measured in ~/projects/tick, which vendors SDL as `3rd_party/`, a spelling
-- none of the four copies had:
--
--   clangd_setup  The unity-TU scan walked SDL, emitted 155 PathMatch fragments
--                 instead of a handful, and merged an SDL test TU into the
--                 project's own — .clangd carried a fragment headed "Unity
--                 preamble from 3rd_party/SDL/test/testevdev.c + src/main.cpp".
--                 src/game.cpp was then parsed under the wrong preamble, so
--                 `game_controller_input` and `loaded_texture_data` both
--                 resolved to `int` and struct member completion returned zero
--                 items. Regenerating with the name present: 7891 lines -> 104.
--
--   hh.macros     The #define scan found 20994 names, 19845 of them SDL's and
--                 101 the project's own. Chunked 50 to a matchadd() alternation
--                 that is 435 patterns totalling 592293 characters of regex,
--                 re-run by Vim's regex engine on every displayed line of every
--                 redraw: 131ms per redraw, roughly 7fps while scrolling.
--                 With the name present, 3 patterns and 2.48ms.
--
--   telescope     Every picker enumerated 2320 files for a 30-file project, and
--                 `live_grep "render"` returned 15070 results per keystroke.
--                 With the name present, 31 files and 228 results.
--
--   ctags         `:Ctags` indexed the whole SDL tree.
--
-- One list, one place to add the next spelling. Note that the hh.macros case is
-- invisible to `nvim --headless` — redraw is a no-op with no UI attached, so it
-- measures as zero. See the header of lua/config/perf.lua.
local M = {}

M.NAMES = {
  'build', 'bin', 'out', 'dist',
  'third_party', 'thirdparty', '3rd_party', '3rdparty',
  'vendor', 'node_modules',
}

---One flag per name, for tools that take `--flag=value` as a single argv entry.
---@param fmt string  format applied to each name, e.g. '--exclude=%s'
---@return string[]
function M.flags(fmt)
  local out = {}
  for _, d in ipairs(M.NAMES) do
    out[#out + 1] = fmt:format(d)
  end
  return out
end

---rg exclusion globs as SEPARATE argv entries (`-g`, `!**/build/**`, ...), which
---is what rg requires when the flag and its value are not joined with `=`.
---@return string[]
function M.rg_glob_args()
  local out = {}
  for _, d in ipairs(M.NAMES) do
    out[#out + 1] = '-g'
    out[#out + 1] = '!**/' .. d .. '/**'
  end
  return out
end

return M
