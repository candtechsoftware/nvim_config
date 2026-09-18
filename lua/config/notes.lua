-- Notes in ~/notes: <leader>nn new, <leader>nf find, <leader>ns search,
-- <leader>n open the directory, <leader>ng git status. Saves auto-commit when
-- ~/notes is a git repo.
local M = {}

local DIR = vim.fs.normalize('~/notes')
local AUTO_PUSH = false

local function notes_dir()
  if vim.fn.isdirectory(DIR) == 1 then return DIR end
  vim.notify(DIR .. ' does not exist', vim.log.levels.WARN)
end

local function new_note(name)
  local dir = notes_dir()
  if not dir then return end
  if not name or name == '' then name = vim.fn.input('Note name: ') end
  if name == '' then return end
  name = name:gsub('[^%w%s%-_]', ''):gsub('%s+', '-')
  if not name:match('%.%w+$') then name = name .. '.md' end
  local path = dir .. '/' .. name
  if vim.fn.filereadable(path) == 0 then
    local title = name:gsub('%.md$', ''):gsub('%-', ' ')
    vim.fn.writefile({ '# ' .. title, '', 'Created: ' .. os.date('%Y-%m-%d %H:%M'), '', '' }, path)
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.cmd('normal! G')
end

local function open_dir()
  local dir = notes_dir()
  if not dir then return end
  vim.cmd('vsplit')
  vim.cmd.cd(vim.fn.fnameescape(dir))
  vim.cmd.edit('.')
end

local function find_notes()
  local dir = notes_dir()
  if dir then require('fff').find_files({ cwd = dir, title = 'Notes' }) end
end

local function search_notes()
  local dir = notes_dir()
  if dir then require('fff').live_grep({ cwd = dir, title = 'Search notes' }) end
end

local function git_status()
  local dir = notes_dir()
  if dir then vim.cmd('split | terminal git -C ' .. vim.fn.shellescape(dir) .. ' status') end
end

local function git(args, on_ok)
  vim.system(vim.list_extend({ 'git', '-C', DIR }, args), {}, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      vim.notify('notes: git ' .. args[1] .. ' failed', vim.log.levels.WARN)
    elseif on_ok then
      on_ok()
    end
  end))
end

local function auto_commit(file)
  local msg = ('Auto-save: %s - %s'):format(vim.fs.basename(file), os.date('%Y-%m-%d %H:%M'))
  git({ 'add', file }, function()
    git({ 'commit', '-m', msg }, AUTO_PUSH and function() git({ 'push' }) end or nil)
  end)
end

function M.setup()
  if vim.fn.isdirectory(DIR .. '/.git') == 1 then
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = vim.api.nvim_create_augroup('NotesAutoCommit', {}),
      pattern = DIR .. '/*',
      callback = function(ev) auto_commit(ev.file) end,
    })
  end

  local cmd = vim.api.nvim_create_user_command
  cmd('NotesNew', function(o) new_note(o.args) end, { nargs = '?', desc = 'New note' })
  cmd('NotesFind', find_notes, { desc = 'Find notes by name' })
  cmd('NotesSearch', search_notes, { desc = 'Search note contents' })
  cmd('NotesDir', open_dir, { desc = 'Open notes directory' })
  cmd('NotesGit', git_status, { desc = 'Notes git status' })

  vim.keymap.set('n', '<leader>nn', function() new_note() end, { desc = 'New note' })
  vim.keymap.set('n', '<leader>nf', find_notes, { desc = 'Find notes by name' })
  vim.keymap.set('n', '<leader>ns', search_notes, { desc = 'Search note contents' })
  vim.keymap.set('n', '<leader>n', open_dir, { desc = 'Open notes directory' })
  vim.keymap.set('n', '<leader>ng', git_status, { desc = 'Notes git status' })
end

return M
