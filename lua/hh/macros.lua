-- 4coder-style project-wide #define indexer + yg_*/type keyword highlighting.
--
-- Scans a project's C-family sources once for `#define` names so that every
-- project macro (push_struct, ArrayCount, KB, ...) gets the macro color whether
-- or not an LSP has indexed it, and adds the yg_*/arc_* storage-class and type
-- patterns on top of treesitter.
--
-- A colorscheme opts in with:
--
--     require("hh.macros").setup()
--
-- Two things this fixes versus the old in-colors/hh.lua version:
--
--  * The scan was `vim.fn.systemlist` — a synchronous, full-tree rg/grep on the
--    UI thread, run on the first C buffer you opened. It is now vim.system +
--    callback, so the editor never blocks.
--  * Its caches were file-local to a colors/*.lua chunk, which Neovim re-sources
--    on EVERY :colorscheme. So the cache reset to {} each time and the whole
--    blocking scan ran again — while the matches already added to each window
--    were still live but no longer tracked, so they could not be deleted and a
--    second full set was added on top. As a require'd module this state is
--    cached once, for real.

local M = {}

local C_FT = { c = true, cpp = true, objc = true, objcpp = true }

-- [root] = { "MACRO_NAME", ... }
local macro_cache = {}
-- [root] = true while a scan is in flight (so N windows do not spawn N scans)
local scanning = {}
-- [winid] = { match id, ... }
local match_ids = {}

local SOURCE_GLOBS = { "*.h", "*.c", "*.hpp", "*.cpp", "*.cc", "*.hh", "*.m", "*.mm" }

---@param buf integer
---@return string?
local function project_root(buf)
  -- vim.fs.root replaces the hand-rolled parent-directory walk this used to do.
  return vim.fs.root(buf, { ".git", "compile_commands.json", ".clangd" })
end

---@param out string
---@return string[]
local function parse_defines(out)
  local names, seen = {}, {}
  for line in out:gmatch("[^\r\n]+") do
    local name = line:match("#%s*define%s+([A-Za-z_][A-Za-z0-9_]*)")
    if name and not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  return names
end

---@param root string
---@return string[]
local function scan_cmd(root)
  if vim.fn.executable("rg") == 1 then
    local cmd = { "rg", "--no-heading", "--no-line-number", "-N", "-I",
      "-e", "^\\s*#\\s*define\\s+[A-Za-z_][A-Za-z0-9_]*" }
    for _, g in ipairs(SOURCE_GLOBS) do
      cmd[#cmd + 1] = "-g"
      cmd[#cmd + 1] = g
    end
    cmd[#cmd + 1] = root
    return cmd
  end
  local cmd = { "grep", "-rhE",
    "^[[:space:]]*#[[:space:]]*define[[:space:]]+[A-Za-z_][A-Za-z0-9_]*" }
  for _, g in ipairs(SOURCE_GLOBS) do
    cmd[#cmd + 1] = "--include=" .. g
  end
  cmd[#cmd + 1] = root
  return cmd
end

---Scan `root` for #define names, then invoke `done(names)` on the main loop.
---Cached, and de-duplicated while in flight.
---@param root string
---@param done fun(names: string[])
local function scan_macros(root, done)
  local cached = macro_cache[root]
  if cached then
    done(cached)
    return
  end
  if scanning[root] then return end -- a scan is already running; its callback repaints
  scanning[root] = true

  vim.system(scan_cmd(root), { text = true }, vim.schedule_wrap(function(res)
    scanning[root] = nil
    -- rg exits 1 when it finds nothing; that is a legitimate empty result.
    local names = parse_defines(res.stdout or "")
    macro_cache[root] = names
    done(names)
  end))
end

---@param winid integer
local function clear_matches(winid)
  local ids = match_ids[winid]
  if not ids then return end
  for _, id in ipairs(ids) do
    pcall(vim.fn.matchdelete, id, winid)
  end
  match_ids[winid] = nil
end

---Add the static (non-macro) patterns to `winid`, then fill in the project's
---#define names asynchronously when the scan lands.
---@param winid integer
local function add_matches(winid)
  if match_ids[winid] then return end
  local ids = {}
  match_ids[winid] = ids

  local function add(group, pattern, priority)
    vim.api.nvim_win_call(winid, function()
      ids[#ids + 1] = vim.fn.matchadd(group, pattern, priority or 100)
    end)
  end

  -- All yg/arc macros in one pattern (teal)
  add("YgKeyword", "\\<\\(yg\\|arc\\)_\\(internal\\|inline\\|global\\|local_persist\\)\\>")

  -- All yg base types in one pattern (gold)
  add("YgType",
    "\\<\\([usb]\\(8\\|16\\|32\\|64\\)\\|f\\(32\\|64\\)\\|void\\|Vec[234]\\(F32\\|F64\\|S16\\|S32\\|S64\\)\\?\\|Mat[34]\\(F32\\)\\?\\|Quaternion\\(F32\\)\\?\\|Rng[12]\\(F32\\|U32\\|U64\\|S16\\|S32\\)\\?\\|Arena\\|Scratch\\|String8\\|R_Handle\\|Entity\\(Handle\\|Store\\|Pool\\|Kind\\|Flags\\)\\?\\|Direction8\\)\\>")

  -- Return type after yg/arc prefix macros (gold)
  add("YgType", "\\<\\(yg\\|arc\\)_\\(internal\\|inline\\)\\s\\+\\zs\\w\\+\\ze")

  -- Function declarations after yg/arc macros: PREFIX TYPE FUNCNAME( or PREFIX TYPE *FUNCNAME(
  add("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(")
  add("Function", "\\<\\(arc\\|yg\\)_\\w\\+\\s\\+\\w\\+\\s*\\*\\s*\\zs\\w\\+\\ze\\s*(")

  -- Function names after bare storage-class macros: MACRO TYPE name( or MACRO TYPE *name(
  add("Function",
    "\\<\\(internal\\|function\\|global\\|local_persist\\|thread_local\\|inline\\|static\\|force_inline\\|no_inline\\|read_only\\|write_only\\|shared\\|exported\\)\\s\\+\\w\\+\\s\\+\\zs\\w\\+\\ze\\s*(")
  add("Function",
    "\\<\\(internal\\|function\\|global\\|local_persist\\|thread_local\\|inline\\|static\\|force_inline\\|no_inline\\|read_only\\|write_only\\|shared\\|exported\\)\\s\\+\\w\\+\\s*\\*\\+\\s*\\zs\\w\\+\\ze\\s*(")

  -- Return/declaration type (PascalCase) after bare storage-class macros.
  -- Uppercase-first to skip C keywords like `const`, `int`. Lowercase types
  -- (u32/f32/etc.) are already covered by the YgType pattern above.
  add("Type",
    "\\<\\(internal\\|function\\|global\\|local_persist\\|thread_local\\|inline\\|static\\|force_inline\\|no_inline\\|read_only\\|write_only\\|shared\\|exported\\)\\s\\+\\zs[A-Z]\\w*\\ze\\s*\\*\\?\\s*\\w")

  -- thread_local + other storage-class macros as keywords
  add("YgKeyword",
    "\\<\\(thread_local\\|force_inline\\|no_inline\\|read_only\\|write_only\\|shared\\|exported\\)\\>")

  -- Every #define in the project gets the macro color. Priority 200 so it beats
  -- the Function patterns above (100) — otherwise a macro like push_struct would
  -- match both and the function pattern would win by registration order.
  -- Chunked alternation keeps each pattern under Vim's regex limits.
  local buf = vim.api.nvim_win_get_buf(winid)
  local root = project_root(buf)
  if not root then return end

  scan_macros(root, function(macros)
    -- The window may have closed, or switched to a non-C buffer, while the scan
    -- was in flight; and the id list may have been replaced by a teardown.
    if not vim.api.nvim_win_is_valid(winid) then return end
    if match_ids[winid] ~= ids then return end

    local CHUNK = 50
    for i = 1, #macros, CHUNK do
      local parts = {}
      for j = i, math.min(i + CHUNK - 1, #macros) do
        parts[#parts + 1] = macros[j]
      end
      if #parts > 0 then
        add("YgKeyword", "\\<\\(" .. table.concat(parts, "\\|") .. "\\)\\>", 200)
      end
    end
  end)
end

---Add or remove this window's matches so they track the buffer it is showing.
---
---matchadd is WINDOW-local and buffer-agnostic, so without the teardown branch
---every project #define plus \<void\>, \<u32\>, \<static\>... kept highlighting
---after you :e'd a Lua or Markdown file into the same window.
---@param winid integer?
local function refresh(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(winid) then return end
  local buf = vim.api.nvim_win_get_buf(winid)
  if C_FT[vim.bo[buf].filetype] then
    add_matches(winid)
  else
    clear_matches(winid)
  end
end

---Drop every window's matches and re-add them where appropriate.
local function refresh_all()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    clear_matches(win)
    refresh(win)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("HHMacroKeywords", { clear = true })

  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "WinEnter" }, {
    group = group,
    callback = function() refresh(vim.api.nvim_get_current_win()) end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      local wid = tonumber(ev.match)
      if wid then match_ids[wid] = nil end
    end,
  })

  vim.api.nvim_create_user_command("HHMacroDump", function()
    local root = project_root(0)
    if not root then
      vim.notify("HH: no project root (need .git, compile_commands.json, or .clangd)",
        vim.log.levels.WARN)
      return
    end
    scan_macros(root, function(macros)
      vim.notify(("HH: root = %s\nHH: %d #define names\nHH: first 20 = %s")
        :format(root, #macros, table.concat({ unpack(macros, 1, math.min(20, #macros)) }, ", ")),
        vim.log.levels.INFO)
    end)
  end, { desc = "Show the #define names the macro indexer found" })

  -- Force a fresh scan + reapply in EVERY window. The old version only cleared
  -- the current window, so other windows kept their stale macro patterns.
  vim.api.nvim_create_user_command("HHMacroRescan", function()
    macro_cache = {}
    refresh_all()
    vim.notify("HH: rescanning project macros", vim.log.levels.INFO)
  end, { desc = "Re-scan the project for #define names" })

  refresh_all()
end

return M
