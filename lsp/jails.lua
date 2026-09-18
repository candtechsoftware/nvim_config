local function jails_bin()
  for _, path in ipairs({ '~/bins/jails', '~/.local/bin/jails', '/usr/local/bin/jails' }) do
    path = vim.fn.expand(path)
    if vim.fn.executable(path) == 1 then return path end
  end
  local uname = vim.uv.os_uname()
  local arch = uname.machine:lower() == 'x86_64' and 'amd64' or uname.machine:lower()
  local platform = vim.fn.exepath(('jails-%s-%s'):format(uname.sysname:lower(), arch))
  return platform ~= '' and platform or 'jails'
end

-- jails wants the jai install root (the dir holding modules/), not the compiler,
-- and ~/bins/jai is a symlink to the compiler.
local function jai_install()
  for _, candidate in ipairs({ vim.fn.expand('~/bins/jai'), vim.fn.exepath('jai') }) do
    local real = candidate ~= '' and vim.uv.fs_realpath(candidate)
    if real then
      if vim.fn.isdirectory(real .. '/modules') == 1 then return real, nil end
      local root = vim.fs.dirname(vim.fs.dirname(real))
      if vim.fn.isdirectory(root .. '/modules') == 1 then return root, vim.fs.basename(real) end
    end
  end
end

local cmd = { jails_bin() }
local root, exe = jai_install()
if root then vim.list_extend(cmd, { '-jai_path', root }) end
if exe then vim.list_extend(cmd, { '-jai_exe_name', exe }) end

return {
  cmd = cmd,
  filetypes = { 'jai' },
  root_markers = { 'jails.json', 'build.jai', 'first.jai', '.git' },
  workspace_required = true,
}
