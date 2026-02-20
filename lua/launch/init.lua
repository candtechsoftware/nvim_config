local M = {}

-- Use a global variable to persist across module reloads
if not _G.launch_cached_root then
  _G.launch_cached_root = nil
  _G.launch_initial_cwd = vim.fn.getcwd()
end

local function get_os()
  local uname = vim.uv.os_uname().sysname:lower()
  if uname == "darwin" then
    return "mac"
  elseif uname == "linux" then
    return "linux"
  else
    return "windows"
  end
end

-- Parse error lines into quickfix entries
local function parse_errors(lines, root)
  local qf_entries = {}

  for _, line in ipairs(lines) do
    -- Jai format: /path/file.jai:192,30: Error: message
    -- Use pattern that captures path with slashes, allowing leading whitespace
    local file, lnum, col, msg = line:match("%s*(/[^:]+):(%d+),(%d+):%s*Error:%s*(.+)")
    if file and lnum then
      table.insert(qf_entries, {
        filename = vim.fn.fnamemodify(file, ":p"),
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = msg,
        type = "E",
      })
    else
      -- C/Clang format: file:line:col: error: message (absolute path)
      file, lnum, col, msg = line:match("%s*(/[^:]+):(%d+):(%d+):%s*error:%s*(.+)")
      if file and lnum then
        table.insert(qf_entries, {
          filename = vim.fn.fnamemodify(file, ":p"),
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = msg,
          type = "E",
        })
      else
        -- C/Clang format with relative path: ../src/file.c:103:35: error: message
        file, lnum, col, msg = line:match("%s*([%.%w_/-]+%.[%w]+):(%d+):(%d+):%s*error:%s*(.+)")
        if file and lnum then
          -- Resolve relative path from root directory
          local abs_path = vim.fn.resolve(root .. "/" .. file)
          table.insert(qf_entries, {
            filename = abs_path,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = msg,
            type = "E",
          })
        end
      end
    end
  end

  return qf_entries
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
    -- Silently return if no launch.json found
    return
  end

  -- Determine which key_map to use (OS-specific or flat)
  local os_name = get_os()
  local key_map = config.key_map

  -- Check if key_map has OS-specific structure
  if config.key_map.linux or config.key_map.mac or config.key_map.windows then
    key_map = config.key_map[os_name]
    if not key_map then
      -- No config for this OS, silently return
      return
    end
  end

  for key, cmd in pairs(key_map) do
    vim.keymap.set("n", key, function()
      -- Re-find the root in case we've switched projects
      local current_root = find_project_root()
      local output_lines = {}

      vim.notify("Running: " .. cmd, vim.log.levels.INFO)

      vim.fn.jobstart(cmd, {
        cwd = current_root,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
          if data then
            vim.list_extend(output_lines, data)
          end
        end,
        on_stderr = function(_, data)
          if data then
            vim.list_extend(output_lines, data)
          end
        end,
        on_exit = function(_, exit_code)
          vim.schedule(function()
            local qf_entries = parse_errors(output_lines, current_root)
            if #qf_entries > 0 then
              vim.fn.setqflist(qf_entries, "r")
              vim.fn.setqflist({}, "a", { title = "Build Errors: " .. cmd })
              vim.cmd("copen")
              vim.notify("Build FAILED - " .. #qf_entries .. " error(s)", vim.log.levels.ERROR)
            elseif exit_code ~= 0 then
              -- Non-zero exit but no parseable errors, show raw output
              vim.fn.setqflist({}, "r")
              for _, line in ipairs(output_lines) do
                if line ~= "" then
                  vim.fn.setqflist({ { text = line } }, "a")
                end
              end
              vim.fn.setqflist({}, "a", { title = "Build Output: " .. cmd })
              vim.cmd("copen")
              vim.notify("Build FAILED (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
            else
              -- No errors and exit 0: success
              vim.fn.setqflist({}, "r")
              vim.fn.setqflist({}, "a", { title = "Build: SUCCESS" })
              vim.cmd("cclose")
              vim.notify("Build SUCCESS", vim.log.levels.INFO)
            end
          end)
        end,
      })
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
