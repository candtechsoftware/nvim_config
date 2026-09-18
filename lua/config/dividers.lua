-- Section comments (//- in C, #- in shell, ---- in Lua) get a rule drawn above
-- them, ]s/[s to step between them and <leader>ss to list them.
local M = {}

local ns = vim.api.nvim_create_namespace('dividers')

-- Lua needs four dashes: `---` is every LuaLS annotation.
local MARKERS = { '^%s*//%-+%s*', '^%s*#%-+%s*', '^%s*%-%-%-%-+%s*' }
local MAX_LINES = 20000

local function section_text(line)
  for _, marker in ipairs(MARKERS) do
    local s, e = line:find(marker)
    if s then return line:sub(e + 1) end
  end
end

local function step(dir)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local row = vim.fn.line('.')
  local i = row + dir
  while i >= 1 and i <= #lines do
    if section_text(lines[i]) then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.cmd('normal! zz')
      return
    end
    i = i + dir
  end
  vim.notify(dir > 0 and 'No more sections below' or 'No more sections above')
end

local function list_sections()
  local items = {}
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local text = section_text(line)
    if text then
      items[#items + 1] = { bufnr = vim.api.nvim_get_current_buf(), lnum = i, text = text ~= '' and text or '(section)' }
    end
  end
  if #items == 0 then return vim.notify('No section comments in this buffer') end
  vim.fn.setloclist(0, {}, ' ', { title = 'Sections', items = items })
  vim.cmd('lopen')
end

-- Rendered only when the text or window width changed since the last render.
local rendered = {}

local function render(buf)
  local tick, width = vim.api.nvim_buf_get_changedtick(buf), vim.api.nvim_win_get_width(0)
  local last = rendered[buf]
  if last and last.tick == tick and last.width == width then return end
  rendered[buf] = { tick = tick, width = width }

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if vim.bo[buf].buftype ~= '' or vim.api.nvim_buf_line_count(buf) > MAX_LINES then return end
  local rule = { { { string.rep('─', width), 'Comment' } } }
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if section_text(line) then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { virt_lines_above = true, virt_lines = rule })
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('Dividers', {})
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'WinResized' }, {
    group = group,
    callback = function(ev) render(ev.buf) end,
  })
  local timer = assert(vim.uv.new_timer())
  vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
    group = group,
    callback = function(ev)
      timer:start(50, 0, vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then render(ev.buf) end
      end))
    end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev) rendered[ev.buf] = nil end,
  })

  vim.keymap.set('n', ']s', function() step(1) end, { desc = 'Next section comment' })
  vim.keymap.set('n', '[s', function() step(-1) end, { desc = 'Previous section comment' })
  vim.keymap.set('n', '<leader>ss', list_sections, { desc = 'List section comments' })
end

return M
