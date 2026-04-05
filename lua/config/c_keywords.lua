-- C/C++ keyword highlighting via matchadd
-- Workaround: treesitter anonymous node highlights don't render on some Neovim builds.
-- Uses 2 combined patterns (fast) instead of individual matchadd per keyword.

local M = {}

local match_ids = {} -- track per window

local function setup_matches()
  local winid = vim.api.nvim_get_current_win()

  -- Already set up for this window
  if match_ids[winid] then return end

  match_ids[winid] = {}

  local function add(group, pattern)
    local id = vim.fn.matchadd(group, pattern, 101) -- priority 101: above treesitter (100)
    table.insert(match_ids[winid], id)
  end

  -- All C keywords in one pattern (hash-like via \| alternation)
  add("Keyword", "\\<\\(typedef\\|struct\\|enum\\|union\\|return\\|if\\|else\\|for\\|while\\|do\\|switch\\|case\\|break\\|continue\\|goto\\|default\\)\\>")

  -- Storage class / qualifiers in one pattern
  add("StorageClass", "\\<\\(static\\|extern\\|const\\|volatile\\|inline\\|register\\)\\>")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CKeywordHighlight", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "c", "cpp", "objc", "objcpp" },
    callback = setup_matches,
  })

  -- Re-apply when entering a window (matches are per-window)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function()
      local ft = vim.bo.filetype
      if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
        setup_matches()
      end
    end,
  })

  -- Clean up closed windows
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      local wid = tonumber(ev.match)
      if wid then match_ids[wid] = nil end
    end,
  })
end

return M
