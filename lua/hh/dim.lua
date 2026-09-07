-- Recess the editor behind a picker.
--
-- The picker windows in colors/ll.lua paint no background of their own, so the
-- code around them competes with the results for the eye. While a picker is
-- open every ordinary window is switched to a highlight namespace in which
-- every group is one flat, recessed tone: the text behind is still there as
-- shape, but none of it reads as code.
--
-- A colorscheme opts in by calling, after it has defined its groups:
--
--     require("hh.dim").setup({ fg = c.dim })
--
-- This is a module rather than part of colors/ll.lua for the reason spelled
-- out at the top of hh/scope.lua: a colors/*.lua chunk is re-sourced on every
-- :colorscheme, so its file-local state resets underneath autocmds that are
-- still live.

local M = {}

local dim_ns = vim.api.nvim_create_namespace("hh_dim")

local enabled_for = nil

---Paint every group the colorscheme just defined as one flat tone in dim_ns.
---
---The groups are read back out of the global namespace rather than listed
---here: any list would be the colorscheme's own group list duplicated, and a
---group missing from it is a group that stays lit behind the picker.
---@param fg string
local function build(fg)
  for group in pairs(vim.api.nvim_get_hl(0, {})) do
    vim.api.nvim_set_hl(dim_ns, group, { fg = fg })
  end
end

---@param ns integer
local function apply(ns)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- The floats are the picker itself.
    if vim.api.nvim_win_get_config(win).relative == "" then
      vim.api.nvim_win_set_hl_ns(win, ns)
    end
  end
end

---Called by a colorscheme, after it has defined its groups.
---@param opts { fg: string }
function M.setup(opts)
  enabled_for = vim.g.colors_name
  build(opts.fg)

  local group = vim.api.nvim_create_augroup("HHDim", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "TelescopePrompt",
    callback = function(ev)
      apply(dim_ns)
      -- The prompt window going away is the picker closing, on every exit path
      -- there is: <esc>, opening a file, sending the results to the quickfix
      -- list. Telescope has created its floats by the time the prompt buffer
      -- gets its filetype, so apply() above already sees them as floats.
      vim.api.nvim_create_autocmd("BufWinLeave", {
        group = group,
        buffer = ev.buf,
        once = true,
        callback = function() apply(0) end,
      })
    end,
  })

  -- Tear down when the user switches to a colorscheme that does not opt in,
  -- rather than dimming its windows with this one's tone.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      vim.schedule(function()
        if enabled_for ~= vim.g.colors_name then
          apply(0)
          pcall(vim.api.nvim_del_augroup_by_name, "HHDim")
        end
      end)
    end,
  })
end

return M
