local M = {}

-- Use a global variable to persist across module reloads
if not _G.launch_cached_root then
  _G.launch_cached_root = nil
  _G.launch_initial_cwd = vim.fn.getcwd()
end

local function find_project_root()
  if _G.launch_cached_root then
    return _G.launch_cached_root
  end
  
  local current_cwd = vim.fn.getcwd()
  
  -- First try to find launch.json file from current working directory up the tree
  local launch_file = vim.fn.findfile("launch.json", current_cwd .. ";")
  if launch_file ~= "" then
    _G.launch_cached_root = vim.fn.fnamemodify(launch_file, ":h")
    return _G.launch_cached_root
  end
  
  -- If not found, try from initial directory
  launch_file = vim.fn.findfile("launch.json", _G.launch_initial_cwd .. ";")  
  if launch_file ~= "" then
    _G.launch_cached_root = vim.fn.fnamemodify(launch_file, ":h")
    return _G.launch_cached_root
  end
  
  -- Fallback to .git directory
  local root = vim.fn.finddir(".git", _G.launch_initial_cwd .. ";")
  if root ~= "" then
    _G.launch_cached_root = vim.fn.fnamemodify(root, ":h")
  else
    _G.launch_cached_root = _G.launch_initial_cwd
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
      vim.notify("Running command: " .. cmd .. " in directory: " .. root)
      vim.cmd("split")
      vim.cmd("terminal")
      -- Change to the correct directory in the terminal
      local term_cmd = "cd /d " .. vim.fn.shellescape(root) .. " && " .. cmd
      vim.fn.chansend(vim.b.terminal_job_id, term_cmd .. "\r")
    end, { noremap = true, silent = true, desc = "launch.json command" })
  end
end

return M
