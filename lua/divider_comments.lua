-- Divider Comments: Render horizontal lines above //- style comments
local M = {}

local ns_id = vim.api.nvim_create_namespace("divider_comments")
local pending_timer = nil

function M.render_dividers()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Clear existing extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local width = vim.api.nvim_win_get_width(0)

  for i, line in ipairs(lines) do
    -- Match //- style comments (C/C++), #- (shell/python), --- (lua)
    if line:match("^%s*//%-") or line:match("^%s*#%-") or line:match("^%s*%-%-%-") then
      local divider_line = string.rep("─", width)
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
        virt_lines_above = true,
        virt_lines = { { { divider_line, "Comment" } } },
      })
    end
  end
end

local function render_debounced()
  if pending_timer then
    vim.uv.timer_stop(pending_timer)
  end
  pending_timer = vim.defer_fn(function()
    pending_timer = nil
    M.render_dividers()
  end, 50)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("DividerComments", { clear = true })

  -- Immediate render for these events (no conflict with treesitter)
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "WinResized" }, {
    group = group,
    callback = function()
      M.render_dividers()
    end,
  })

  -- Debounced render for text changes (avoids race with treesitter)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function()
      render_debounced()
    end,
  })
end

return M
