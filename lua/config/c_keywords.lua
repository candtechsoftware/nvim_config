-- C/C++ keyword highlighting via matchadd
-- Workaround: treesitter anonymous node highlights don't render on some Neovim builds.
-- Uses 2 combined patterns (fast) instead of individual matchadd per keyword.
--
-- NOTE: matchadd is WINDOW-local and buffer-agnostic — a match added while a C
-- buffer is displayed keeps highlighting whatever else that window later shows.
-- So the matches have to be torn down when the window switches to a non-C
-- buffer, or `if`/`else`/`for`/`static`/... light up as keywords (at priority
-- 101, i.e. above treesitter) in Lua, Markdown, quickfix — everything.

local M = {}

local C_FT = { c = true, cpp = true, objc = true, objcpp = true }

local match_ids = {} -- [winid] = { match id, ... }

local function clear_matches(winid)
  local ids = match_ids[winid]
  if not ids then return end
  for _, id in ipairs(ids) do
    -- Window may already be gone; matchdelete errors on an unknown id.
    pcall(vim.fn.matchdelete, id, winid)
  end
  match_ids[winid] = nil
end

local function add_matches(winid)
  if match_ids[winid] then return end -- already set up for this window
  local ids = {}

  -- matchadd() only ever acts on the *current* window, so hop into the target.
  vim.api.nvim_win_call(winid, function()
    local function add(group, pattern)
      table.insert(ids, vim.fn.matchadd(group, pattern, 101)) -- 101: above treesitter (100)
    end
    -- All C keywords in one pattern (hash-like via \| alternation)
    add("Keyword",
      "\\<\\(typedef\\|struct\\|enum\\|union\\|return\\|if\\|else\\|for\\|while\\|do\\|switch\\|case\\|break\\|continue\\|goto\\|default\\)\\>")
    -- Storage class / qualifiers in one pattern
    add("StorageClass", "\\<\\(static\\|extern\\|const\\|volatile\\|inline\\|register\\)\\>")
  end)

  match_ids[winid] = ids
end

---Add or remove the matches so they track the buffer currently in `winid`.
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

function M.setup()
  local group = vim.api.nvim_create_augroup("CKeywordHighlight", { clear = true })

  -- BufWinEnter is the one that matters for teardown: it fires when a buffer is
  -- displayed in a window, including `:e other.lua` in a window that was
  -- showing C. FileType covers the initial load, WinEnter covers splits.
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "WinEnter" }, {
    group = group,
    callback = function()
      refresh(vim.api.nvim_get_current_win())
    end,
  })

  -- Clean up closed windows (the window is gone, so just drop the entry).
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      local wid = tonumber(ev.match)
      if wid then match_ids[wid] = nil end
    end,
  })
end

return M
