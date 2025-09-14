local M = {}

-- Use a global variable to persist across module reloads
if not _G.launch_cached_root then
  _G.launch_cached_root = nil
  _G.launch_initial_cwd = vim.fn.getcwd()
end

local function find_project_root()
  -- Don't use cached root if we're in a different project
  if _G.launch_cached_root then
    local current_file = vim.fn.expand('%:p')
    if current_file ~= "" then
      -- Check if current file is under the cached root
      local relative = vim.fn.fnamemodify(current_file, ':~:.')
      if not vim.startswith(current_file, _G.launch_cached_root) then
        -- We're in a different project, reset cache
        _G.launch_cached_root = nil
      end
    end
  end
  
  if _G.launch_cached_root then
    return _G.launch_cached_root
  end
  
  local current_file = vim.fn.expand('%:p')
  local search_dir = current_file ~= "" and vim.fn.fnamemodify(current_file, ':h') or vim.fn.getcwd()
  
  -- First try to find launch.json file from current file's directory up the tree
  local launch_file = vim.fn.findfile("launch.json", search_dir .. ";")
  if launch_file ~= "" then
    _G.launch_cached_root = vim.fn.fnamemodify(launch_file, ":p:h")
    return _G.launch_cached_root
  end
  
  -- Try to find build.jai (for Jai projects)
  local build_jai = vim.fn.findfile("build.jai", search_dir .. ";")
  if build_jai ~= "" then
    _G.launch_cached_root = vim.fn.fnamemodify(build_jai, ":p:h")
    return _G.launch_cached_root
  end
  
  -- Fallback to .git directory
  local git_dir = vim.fn.finddir(".git", search_dir .. ";")
  if git_dir ~= "" then
    _G.launch_cached_root = vim.fn.fnamemodify(git_dir, ":p:h")
  else
    _G.launch_cached_root = search_dir
  end
  return _G.launch_cached_root
end

local function load_launch_json(root)
  local path = root .. "/launch.json"
  if vim.fn.filereadable(path) == 1 then
    local contents = vim.fn.readfile(path)
    local joined = table.concat(contents, "\n")
    return vim.fn.json_decode(joined)
  end
  return nil
end

function M.reset_cache()
  _G.launch_cached_root = nil
  vim.notify("Launch root cache cleared", vim.log.levels.INFO)
end

function M.show_root()
  local root = find_project_root()
  vim.notify("Current launch root: " .. root, vim.log.levels.INFO)
end

function M.setup()
  local root = find_project_root()
  local config = load_launch_json(root)

  if not config or not config.key_map then
    vim.notify("No valid launch.json found", vim.log.levels.WARN)
    return
  end

  vim.notify("Launch plugin loaded with root: " .. root)

  for key, cmd in pairs(config.key_map) do
    vim.keymap.set("n", key, function()
      -- Re-find the root in case we've switched projects
      local current_root = find_project_root()
      vim.notify("Running command: " .. cmd)

      -- Collect output
      local output = {}

      -- Use jobstart for true background execution
      local job_id = vim.fn.jobstart(cmd, {
        cwd = current_root,
        on_stdout = function(_, data)
          if data then
            for _, line in ipairs(data) do
              if line ~= "" then
                table.insert(output, line)
              end
            end
          end
        end,
        on_stderr = function(_, data)
          if data then
            for _, line in ipairs(data) do
              if line ~= "" then
                table.insert(output, line)
              end
            end
          end
        end,
        on_exit = function(_, exit_code, _)
          vim.schedule(function()
            if exit_code == 0 then
              -- Success - just show a notification
              vim.notify("Build succeeded!", vim.log.levels.INFO)
            else
              -- Failure - create buffer with output and show in split
              vim.notify("Build failed with exit code: " .. exit_code, vim.log.levels.ERROR)

              -- Create a new buffer for the output
              local bufnr = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
              vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
              vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
              vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)

              -- Open split and show buffer
              vim.cmd("split")
              vim.api.nvim_win_set_buf(0, bufnr)

              -- Scroll to bottom to show error
              vim.cmd("normal! G")
            end
          end)
        end
      })

      if job_id <= 0 then
        vim.notify("Failed to start job: " .. cmd, vim.log.levels.ERROR)
      end

    end, { noremap = true, silent = true, desc = "launch.json command" })
  end
  
  -- Add helper commands
  vim.api.nvim_create_user_command('LaunchReset', M.reset_cache, { desc = 'Reset launch root cache' })
  vim.api.nvim_create_user_command('LaunchInfo', M.show_root, { desc = 'Show current launch root' })
  vim.api.nvim_create_user_command('LaunchReload', function()
    M.reset_cache()
    M.setup()
  end, { desc = 'Reload launch configuration' })
end

return M
