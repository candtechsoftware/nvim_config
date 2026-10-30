-- While an fff picker is open, every ordinary window is drawn in one flat,
-- recessed tone so the results are all that reads. A colorscheme opts in
-- after defining its groups with:
--
--   require('hh.dim').setup({ fg = c.dim })
--
-- A module rather than part of the colorscheme, because colors/*.lua is
-- re-sourced on every :colorscheme while its autocmds stay live.
local M = {}

local ns = vim.api.nvim_create_namespace('hh_dim')
local generation = 0
local current_group

local function apply(hl_ns)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- Floats are the picker itself.
    if vim.api.nvim_win_get_config(win).relative == '' then
      vim.api.nvim_win_set_hl_ns(win, hl_ns)
    end
  end
end

function M.setup(opts)
  local scheme = vim.g.colors_name
  if current_group then pcall(vim.api.nvim_del_augroup_by_id, current_group) end
  for group in pairs(vim.api.nvim_get_hl(0, {})) do
    vim.api.nvim_set_hl(ns, group, { fg = opts.fg })
  end

  -- ColorScheme cleanup is scheduled, so each generation needs its own group.
  -- Reusing one id lets an old callback delete the new scheme's autocmds.
  generation = generation + 1
  local group = vim.api.nvim_create_augroup('HHDim' .. generation, {})
  current_group = group
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'fff_input',
    callback = function(ev)
      apply(ns)
      -- fff wipes the input buffer on every way the picker closes.
      vim.api.nvim_create_autocmd('BufWinLeave', {
        group = group,
        buf = ev.buf,
        once = true,
        callback = function() apply(0) end,
      })
    end,
  })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = vim.schedule_wrap(function()
      if vim.g.colors_name ~= scheme then
        apply(0)
        pcall(vim.api.nvim_del_augroup_by_id, group)
        if current_group == group then current_group = nil end
      end
    end),
  })
end

return M
