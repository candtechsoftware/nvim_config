-- Tags for C-family buffers: &tags points at a per-project file in the cache
-- dir, built on demand with :Ctags. `gd` jumps through it (after/ftplugin/c.lua).
local M = {}

local project = require('config.project')

-- The clangd markers make a C subproject its own root inside a larger repo.
local TAG_MARKERS = vim.list_extend({ '.clangd', 'compile_commands.json', 'compile_flags.txt' }, project.MARKERS)
local TAGS_DIR = vim.fs.joinpath(vim.fn.stdpath('cache'), 'tags')

local function tags_path(root)
  local name = vim.fs.basename(root):gsub('[^%w._-]', '_')
  return vim.fs.joinpath(TAGS_DIR, name .. '-' .. vim.fn.sha256(root):sub(1, 12))
end

-- &path gets the project's include dirs so `gf` and :find resolve #includes.
local function set_c_path(buf, root)
  local file = vim.api.nvim_buf_get_name(buf)
  local paths = { '.', file ~= '' and vim.fs.dirname(file) or vim.uv.cwd() }
  for _, dir in ipairs({ 'inc', 'include', 'src', 'lib' }) do
    local p = vim.fs.joinpath(root, dir)
    if vim.uv.fs_stat(p) then paths[#paths + 1] = p end
  end
  local ext = vim.fs.joinpath(root, 'external')
  if vim.uv.fs_stat(ext) then
    for name, type in vim.fs.dir(ext) do
      if type == 'directory' then
        for _, sub in ipairs({ 'include', 'src' }) do
          local p = vim.fs.joinpath(ext, name, sub)
          if vim.uv.fs_stat(p) then paths[#paths + 1] = p end
        end
      end
    end
  end
  vim.bo[buf].path = table.concat(paths, ',')
  vim.bo[buf].suffixesadd = '.h,.hpp,.hh,.hxx,.inl'
end

-- A :Ctags issued while that root is still generating runs again when it ends.
local running, queued = {}, {}

local function generate(root, notify)
  if running[root] then
    queued[root] = true
    return
  end
  if vim.fn.executable('ctags') == 0 then
    vim.notify('ctags: executable not found in PATH, so tag `gd` and member completion are unavailable',
      vim.log.levels.WARN)
    return
  end

  -- Absolute paths, since the tags file lives outside the project. +St adds the
  -- typeref and signature fields member completion reads.
  local tags = tags_path(root)
  local cmd = { 'ctags', '-R', '--tag-relative=no', '--exclude=.git' }
  for _, dir in ipairs(project.SKIP_DIRS) do
    cmd[#cmd + 1] = '--exclude=' .. dir
  end
  vim.list_extend(cmd, { '--fields=+St', '-f', tags, root })

  running[root] = true
  vim.system(cmd, { text = true }, vim.schedule_wrap(function(obj)
    running[root] = nil
    if obj.code ~= 0 then
      local msg = (obj.stderr ~= '' and obj.stderr) or ('exit ' .. tostring(obj.code))
      vim.notify('ctags failed: ' .. msg, vim.log.levels.ERROR)
    elseif notify then
      vim.notify('ctags: regenerated ' .. tags, vim.log.levels.INFO)
    end
    if queued[root] then
      queued[root] = nil
      generate(root, false)
    end
  end))
end

function M.setup()
  vim.fn.mkdir(TAGS_DIR, 'p')

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('ctags_tagpath', { clear = true }),
    pattern = { 'c', 'cpp', 'objc', 'objcpp' },
    callback = function(args)
      local root = project.root(args.buf, TAG_MARKERS)
      vim.bo[args.buf].tags = tags_path(root) .. ',' .. vim.go.tags
      set_c_path(args.buf, root)
    end,
  })

  vim.api.nvim_create_user_command('Ctags', function()
    generate(project.root(0, TAG_MARKERS), true)
  end, { desc = 'Regenerate the project tags file' })
end

return M
