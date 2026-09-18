-- The builtin browser (:h dir) only navigates. Add a cursorline and the
-- filesystem keys: % new file, d new directory, D delete, r rename.
local buf = vim.api.nvim_get_current_buf()
local reload = require('nvim.dir')._reload

-- cursorline is window-local, so it would follow the window into the file opened from here.
vim.wo.cursorline = true
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufLeave' }, {
  buf = buf,
  callback = function(ev) vim.wo.cursorline = ev.event == 'BufEnter' end,
})

local function path(name)
  return vim.fs.joinpath(vim.api.nvim_buf_get_name(buf), name)
end

-- The listing shows a newline in a name as NUL.
local function entry()
  local line = vim.api.nvim_get_current_line()
  local isdir = line:sub(-1) == '/'
  return ((isdir and line:sub(1, -2) or line):gsub('%z', '\n')), isdir
end

local function map(lhs, fn, desc)
  vim.keymap.set('n', lhs, fn, { buf = buf, desc = desc })
end

map('%', function()
  local name = vim.fn.input('New file: ')
  if name ~= '' then vim.cmd.edit(path(name)) end
end, 'New file here (:w to create)')

map('d', function()
  local name = vim.fn.input('New directory: ')
  if name ~= '' then
    vim.fn.mkdir(path(name), 'p')
    reload(buf)
  end
end, 'New directory here')

map('D', function()
  local name, isdir = entry()
  local prompt = 'Delete ' .. name .. (isdir and ' and its contents?' or '?')
  if name ~= '' and vim.fn.confirm(prompt, '&Yes\n&No', 2) == 1 then
    if vim.fn.delete(path(name), isdir and 'rf' or '') ~= 0 then
      vim.notify('Failed to delete ' .. path(name), vim.log.levels.ERROR)
    end
    reload(buf)
  end
end, 'Delete entry')

map('r', function()
  local name = entry()
  local new = name ~= '' and vim.fn.input({ prompt = 'Rename to: ', default = name }) or ''
  if new ~= '' and new ~= name then
    if vim.fn.rename(path(name), path(new)) ~= 0 then
      vim.notify('Failed to rename ' .. path(name), vim.log.levels.ERROR)
    end
    reload(buf)
  end
end, 'Rename entry')

-- The listing is a snapshot. Watch the directory so outside changes show up.
local ok, unwatch = pcall(vim._watch.watch, vim.api.nvim_buf_get_name(buf), { debounce = 100 }, function()
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then reload(buf) end
  end)
end)
if ok then
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    buf = buf,
    once = true,
    callback = function() unwatch() end,
  })
end
