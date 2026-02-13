-- Ctags fallback for C/C++ go-to-definition
-- Generates tags under /tmp/nvim-ctags/ so the repo stays clean

local M = {}

local function get_git_root()
  local result = vim.fn.systemlist('git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 or #result == 0 then
    return nil
  end
  return result[1]
end

local function tags_path(root)
  local escaped = root:gsub('/', '%%')
  return '/tmp/nvim-ctags/' .. escaped .. '/tags'
end

local function generate_tags(root, outpath)
  local dir = vim.fn.fnamemodify(outpath, ':h')
  vim.fn.mkdir(dir, 'p')
  vim.fn.jobstart({
    'ctags', '-R',
    '--languages=C,C++',
    '--fields=+nKz',
    '--extras=+q',
    '-f', outpath,
    root,
  }, { detach = true })
end

--- Jump to tag using raw ctags, bypassing LSP tagfunc.
--- Single match: jumps directly. Multiple: vim.ui.select (Enter picks first).
function M.jump()
  local word = vim.fn.expand('<cword>')
  local saved = vim.bo.tagfunc
  vim.bo.tagfunc = ''
  local tags = vim.fn.taglist('^' .. word .. '$')
  vim.bo.tagfunc = saved

  if #tags == 0 then
    vim.notify('No tags found for: ' .. word, vim.log.levels.WARN)
    return
  end

  -- Single match: jump directly
  if #tags == 1 then
    vim.bo.tagfunc = ''
    pcall(vim.cmd, 'tag ' .. vim.fn.fnameescape(word))
    vim.bo.tagfunc = saved
    return
  end

  -- Multiple matches: vim.ui.select (Enter picks highlighted/first item)
  local items = {}
  for _, tag in ipairs(tags) do
    local file = vim.fn.fnamemodify(tag.filename, ':~:.')
    local kind = tag.kind or '?'
    table.insert(items, string.format('[%s] %s', kind, file))
  end

  vim.ui.select(items, {
    prompt = 'Tag: ' .. word,
  }, function(_, idx)
    if not idx then return end
    vim.bo.tagfunc = ''
    pcall(vim.cmd, idx .. 'tag ' .. vim.fn.fnameescape(word))
    vim.bo.tagfunc = saved
  end)
end

local function setup_completion_trigger(bufnr)
  if vim.b[bufnr]._comp_trigger then return end
  vim.b[bufnr]._comp_trigger = true

  local comp_timer = vim.uv.new_timer()
  vim.api.nvim_create_autocmd('TextChangedI', {
    buffer = bufnr,
    callback = function()
      comp_timer:stop()
      comp_timer:start(100, 0, vim.schedule_wrap(function()
        if vim.api.nvim_get_current_buf() ~= bufnr then return end
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        if vim.fn.pumvisible() == 1 or vim.api.nvim_get_mode().mode ~= 'i' then
          return
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        if col < 1 then return end

        local line = vim.api.nvim_get_current_line()
        local before = line:sub(1, col)

        -- Member access: . or -> triggers LSP omnifunc (if available)
        if before:match('%.$') or before:match('->$') then
          if vim.bo[bufnr].omnifunc ~= '' then
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)
          end
          return
        end

        -- Typing member name after . or -> : buffer keyword fallback
        if before:match('%.[%w_]$') or before:match('%->[%w_]$') then
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
          return
        end

        -- 2+ identifier chars: buffer keyword completion
        if col >= 2 and before:match('[%w_][%w_]$') then
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
        end
      end))
    end,
  })
end

function M.setup()
  local group = vim.api.nvim_create_augroup('ctags_fallback', { clear = true })

  -- On BufEnter: add tags path, generate if missing, set up completion
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx' },
    callback = function(args)
      local root = get_git_root()
      if not root then return end

      local tp = tags_path(root)

      -- Add to tags option if not already present
      local current = vim.opt.tags:get()
      for _, t in ipairs(current) do
        if t == tp then
          goto skip_add
        end
      end
      vim.opt.tags:append(tp)
      ::skip_add::

      -- Generate tags if file doesn't exist
      if vim.fn.filereadable(tp) == 0 then
        generate_tags(root, tp)
      end

      -- Auto-trigger buffer keyword completion (works without LSP)
      setup_completion_trigger(args.buf)
    end,
  })

  -- On BufWritePost: regenerate tags async
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.cxx' },
    callback = function()
      local root = get_git_root()
      if not root then return end
      generate_tags(root, tags_path(root))
    end,
  })

  -- Manual command
  vim.api.nvim_create_user_command('TagGen', function()
    local root = get_git_root()
    if not root then
      vim.notify('Not in a git repository', vim.log.levels.WARN)
      return
    end
    local tp = tags_path(root)
    generate_tags(root, tp)
    vim.notify('Generating tags: ' .. tp)
  end, { desc = 'Regenerate ctags for current project' })
end

M.setup_completion = setup_completion_trigger

return M
