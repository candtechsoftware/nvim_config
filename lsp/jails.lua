-- Jai Language Server (jails) configuration

-- Find jails binary in common locations
local function get_jails_cmd()
  local paths = {
    vim.fn.expand('~/bins/jails'),
    vim.fn.expand('~/.local/bin/jails'),
    '/usr/local/bin/jails',
  }

  for _, p in ipairs(paths) do
    if vim.fn.executable(p) == 1 then
      return { p }
    end
  end

  -- Try platform-specific binary name
  local uname = vim.uv.os_uname()
  local platform = uname.sysname:lower()
  local arch = uname.machine:lower()
  if arch == 'x86_64' then
    arch = 'amd64'
  end

  local binary_name = string.format('jails-%s-%s', platform, arch)
  if platform == 'windows' then
    binary_name = binary_name .. '.exe'
  end

  local platform_path = vim.fn.exepath(binary_name)
  if platform_path and platform_path ~= '' then
    return { platform_path }
  end

  -- Fallback to PATH lookup
  local default = vim.fn.exepath('jails')
  if default and default ~= '' then
    return { default }
  end

  return nil
end

local cmd = get_jails_cmd()
if not cmd then
  -- Return empty config if jails not found - server won't start
  return {
    cmd = { 'jails' },  -- Will fail gracefully
    filetypes = { 'jai' },
    root_markers = { 'build.jai', 'first.jai', '.git' },
  }
end

-- Add jai_path if jai compiler isn't directly findable via whereis
local jai_path = vim.fn.expand('~/gits/jai')
if vim.fn.isdirectory(jai_path) == 1 then
  table.insert(cmd, '-jai_path')
  table.insert(cmd, jai_path)
  -- macOS uses jai-macos, not jai
  table.insert(cmd, '-jai_exe_name')
  table.insert(cmd, 'jai-macos')
end

return {
  cmd = cmd,
  filetypes = { 'jai' },
  root_markers = { 'build.jai', 'first.jai', '.git' },
  single_file_support = false,  -- Jai LSP needs a project root
}
