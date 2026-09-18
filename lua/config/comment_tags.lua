-- NOTE(alex), TODO, PERF, FIXME, HACK and XXX in their own colors.
local M = {}

local TAGS = {
  { 'CommentTagNote', 'NOTE', '#2ab34f' },
  { 'CommentTagTodo', 'TODO', '#ffa900' },
  { 'CommentTagPerf', 'PERF', '#2895c7' },
  { 'CommentTagFixme', 'FIXME', '#ff0000' },
  { 'CommentTagHack', 'HACK', '#ff44dd' },
  { 'CommentTagHack', 'XXX', '#ff44dd' },
}

-- matchadd is window-local; remember which windows already have the matches.
local has_matches = {}

local function set_highlights()
  for _, tag in ipairs(TAGS) do
    vim.api.nvim_set_hl(0, tag[1], { fg = tag[3] })
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('CommentTags', {})
  -- Plain colors, not links, so every :colorscheme's `hi clear` wipes them.
  set_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd({ 'FileType', 'WinEnter' }, {
    group = group,
    callback = function()
      local win = vim.api.nvim_get_current_win()
      if has_matches[win] then return end
      has_matches[win] = true
      for _, tag in ipairs(TAGS) do
        vim.fn.matchadd(tag[1], [[\v<]] .. tag[2] .. [[(\([^)]*\))?:?]])
      end
    end,
  })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(ev) has_matches[tonumber(ev.match)] = nil end,
  })
end

return M
