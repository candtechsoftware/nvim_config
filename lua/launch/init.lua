local M = {}

local function get_os()
  local uname = vim.uv.os_uname().sysname:lower()
  if uname == "darwin" then return "mac"
  elseif uname == "linux" then return "linux"
  else return "windows"
  end
end

local build_diag_ns = vim.api.nvim_create_namespace('launch_build')
local active_keymaps = {}
local current_launch_root = nil

local function find_project_root()
  return require("utils.project_root").find()
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

local function clear_keymaps()
  for _, key in ipairs(active_keymaps) do
    pcall(vim.keymap.del, "n", key)
  end
  active_keymaps = {}
end

local function apply_launch(root)
  if root == current_launch_root then return end

  clear_keymaps()
  current_launch_root = root

  local config = load_launch_json(root)
  if not config or not config.key_map then return end

  local os_name = get_os()
  local key_map = config.key_map

  if config.key_map.linux or config.key_map.mac or config.key_map.windows then
    key_map = config.key_map[os_name]
    if not key_map then return end
  end

  for key, cmd in pairs(key_map) do
    table.insert(active_keymaps, key)
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
            -- Clear previous build diagnostics
            vim.diagnostic.reset(build_diag_ns)

            -- Ensure errorformat is current for this project
            require('utils.make_detect').apply()

            if exit_code ~= 0 then
              -- Use Neovim's errorformat to parse all output lines
              vim.fn.setqflist({}, "r", {
                lines = output_lines,
                efm = vim.o.errorformat,
                title = "Build Errors: " .. cmd,
              })

              local qf = vim.fn.getqflist()
              local error_count = 0
              for _, item in ipairs(qf) do
                if item.valid == 1 then error_count = error_count + 1 end
              end

              if error_count > 0 then
                -- Convert quickfix to inline diagnostics with multiline merging
                local diags = vim.diagnostic.fromqflist(qf, { merge_lines = true })
                local by_buf = {}
                for _, d in ipairs(diags) do
                  if d.bufnr and d.bufnr > 0 then
                    if not by_buf[d.bufnr] then by_buf[d.bufnr] = {} end
                    table.insert(by_buf[d.bufnr], d)
                  end
                end
                for bufnr, buf_diags in pairs(by_buf) do
                  vim.diagnostic.set(build_diag_ns, bufnr, buf_diags)
                end

                vim.cmd("copen")
                vim.notify("Build FAILED - " .. error_count .. " error(s)", vim.log.levels.ERROR)
              else
                -- Non-zero exit but no parsed errors: dump raw output
                vim.fn.setqflist({}, "r", { title = "Build Output: " .. cmd })
                for _, line in ipairs(output_lines) do
                  if line ~= "" then
                    vim.fn.setqflist({ { text = line } }, "a")
                  end
                end
                vim.cmd("copen")
                vim.notify("Build FAILED (exit code " .. exit_code .. ")", vim.log.levels.ERROR)
              end
            else
              vim.fn.setqflist({}, "r")
              vim.fn.setqflist({}, "a", { title = "Build: SUCCESS" })
              vim.cmd("cclose")
              vim.notify("Build SUCCESS", vim.log.levels.INFO)
            end
          end)
        end,
      })
    end, { noremap = true, silent = true, desc = "launch.json: " .. cmd })
  end
end

function M.reset_cache()
  current_launch_root = nil
  vim.notify("Launch root cache cleared", vim.log.levels.INFO)
end

function M.show_root()
  local root = find_project_root()
  vim.notify("Current launch root: " .. root, vim.log.levels.INFO)
end

function M.setup()
  apply_launch(find_project_root())

  -- Re-evaluate keymaps when project context changes
  vim.api.nvim_create_autocmd({ 'BufEnter', 'DirChanged' }, {
    group = vim.api.nvim_create_augroup('launch_auto', { clear = true }),
    callback = function()
      apply_launch(find_project_root())
    end,
  })

  vim.api.nvim_create_user_command('LaunchReset', M.reset_cache, { desc = 'Reset launch root cache' })
  vim.api.nvim_create_user_command('LaunchInfo', M.show_root, { desc = 'Show current launch root' })
  vim.api.nvim_create_user_command('LaunchReload', function()
    M.reset_cache()
    apply_launch(find_project_root())
  end, { desc = 'Reload launch configuration' })
end

return M
