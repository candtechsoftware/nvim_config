-- Place cursor over the word "string" and run this command:
-- :lua print(vim.inspect(vim.treesitter.get_captures_at_cursor()))
-- Or use this function:
local function show_highlight_under_cursor()
  local result = vim.treesitter.get_captures_at_cursor(0)
  print(vim.inspect(result))
end

vim.api.nvim_create_user_command('ShowHighlight', show_highlight_under_cursor, {})