local M = {}

if not _G.launch_initial_cwd then
  _G.launch_initial_cwd = vim.fn.getcwd()
end

local function get_os()
  local uname = vim.uv.os_uname().sysname:lower()
  if uname == "darwin" then return "mac"
  elseif uname == "linux" then return "linux"
  else return "windows"
  end
end

local function parse_errors(lines, root)
  local qf_entries = {}

  for _, line in ipairs(lines) do
    -- Jai format: /path/file.jai:192,30: Error: message
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
        -- C/Clang format with relative path
        file, lnum, col, msg = line:match("%s*([%.%w_/-]+%.[%w]+):(%d+):(%d+):%s*error:%s*(.+)")
        if file and lnum then
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
  return require("utils.project_root").find({ fallback_to_initial_cwd = true })
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
  _G.launch_initial_cwd = vim.fn.getcwd()
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
    return
  end

  local os_name = get_os()
  local key_map = config.key_map

  if config.key_map.linux or config.key_map.mac or config.key_map.windows then
    key_map = config.key_map[os_name]
    if not key_map then return end
  end

  for key, cmd in pairs(key_map) do
    vim.keymap.set("n", key, function()
      local current_root = find_project_root()
      local output_lines = {}

      vim.notify("Running: " .. cmd, vim.log.levels.INFO)

      vim.fn.jobstart(cmd, {
        cwd = current_root,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
          if data then vim.list_extend(output_lines, data) end
        end,
        on_stderr = function(_, data)
          if data then vim.list_extend(output_lines, data) end
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

  vim.api.nvim_create_user_command('LaunchReset', M.reset_cache, { desc = 'Reset launch root cache' })
  vim.api.nvim_create_user_command('LaunchInfo', M.show_root, { desc = 'Show current launch root' })
  vim.api.nvim_create_user_command('LaunchReload', function()
    M.reset_cache()
    M.setup()
  end, { desc = 'Reload launch configuration' })
end

return M
