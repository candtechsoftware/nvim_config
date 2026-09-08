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
    root_markers = { 'jails.json', 'build.jai', 'first.jai', '.git' },
  }
end

-- jails wants the jai *installation root* (it looks for <root>/modules), not the
-- compiler binary. `~/bins/jai` is a symlink to the binary, so the old
-- `isdirectory('~/bins/jai')` test was always false and -jai_path was never
-- passed at all. jails' own whereis fallback happens to land on the right
-- place today, but only while `jai` stays on PATH. Resolve the link instead and
-- strip `bin/<exe>`, which also gives us the real binary name for free.
local function get_jai_install()
  for _, candidate in ipairs({ vim.fn.expand('~/bins/jai'), vim.fn.exepath('jai') }) do
    if candidate ~= '' then
      local real = vim.uv.fs_realpath(candidate)
      if real then
        if vim.fn.isdirectory(real) == 1 and vim.fn.isdirectory(real .. '/modules') == 1 then
          return real, nil
        end
        local root = vim.fs.dirname(vim.fs.dirname(real))
        if root and vim.fn.isdirectory(root .. '/modules') == 1 then
          return root, vim.fs.basename(real)
        end
      end
    end
  end
  return nil, nil
end

local jai_path, jai_exe = get_jai_install()
if jai_path then
  table.insert(cmd, '-jai_path')
  table.insert(cmd, jai_path)
  if jai_exe then
    table.insert(cmd, '-jai_exe_name')
    table.insert(cmd, jai_exe)
  end
end

return {
  cmd = cmd,
  filetypes = { 'jai' },
  -- jails.json is the strongest signal: it is the file jails itself reads for
  -- roots, build_root and local_modules, so a project that has one but no
  -- build.jai and no .git still gets a correct root.
  root_markers = { 'jails.json', 'build.jai', 'first.jai', '.git' },
  -- Jai LSP needs a project root. This was `single_file_support = false` — an
  -- nvim-lspconfig key nothing in native vim.lsp reads, so the intent was
  -- silently unenforced. workspace_required is the native equivalent (same
  -- key lsp/clangd.lua uses).
  workspace_required = true,
}
