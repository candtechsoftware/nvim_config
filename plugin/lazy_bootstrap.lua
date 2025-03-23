-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Manually collect all plugin specs
local plugins = {}

-- Add plugins from init.lua
local ok, base_plugins = pcall(require, "candtech.plugins")
if ok and type(base_plugins) == "table" then
  for _, plugin in ipairs(base_plugins) do
    table.insert(plugins, plugin)
  end
end

-- Add plugins from individual modules
local modules = {
  "cmp", "colors", "copilot", "fugitive", "lsp", "peek", 
  "spell", "telescope", "treesitter", "trouble", "undotree"
}

for _, module_name in ipairs(modules) do
  local ok, module = pcall(require, "candtech.plugins." .. module_name)
  if ok and type(module) == "table" then
    if module[1] and type(module[1]) == "table" then
      -- It's an array of plugin specs
      for _, plugin in ipairs(module) do
        table.insert(plugins, plugin)
      end
    else
      -- It's a single plugin spec
      table.insert(plugins, module)
    end
  end
end

-- Initialize lazy with all plugins
require("lazy").setup(plugins, {
  change_detection = {
    enabled = true,
    notify = false,  -- Don't show notifications about config changes
  },
  checker = {
    enabled = true,  -- Enable checking for plugin updates
    notify = false,  -- Don't show notifications about updates
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}) 