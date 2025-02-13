-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/alexmatthewcandelario/.cache/nvim/packer_hererocks/2.1.1736781742/share/lua/5.1/?.lua;/Users/alexmatthewcandelario/.cache/nvim/packer_hererocks/2.1.1736781742/share/lua/5.1/?/init.lua;/Users/alexmatthewcandelario/.cache/nvim/packer_hererocks/2.1.1736781742/lib/luarocks/rocks-5.1/?.lua;/Users/alexmatthewcandelario/.cache/nvim/packer_hererocks/2.1.1736781742/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/alexmatthewcandelario/.cache/nvim/packer_hererocks/2.1.1736781742/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua",
    url = "https://github.com/hrsh7th/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["copilot.vim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/copilot.vim",
    url = "https://github.com/github/copilot.vim"
  },
  delimitMate = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/delimitMate",
    url = "https://github.com/Raimondi/delimitMate"
  },
  ["friendly-snippets"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/friendly-snippets",
    url = "https://github.com/rafamadriz/friendly-snippets"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["lazygit.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/lazygit.nvim",
    url = "https://github.com/kdheepak/lazygit.nvim"
  },
  ["lsp-zero.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/lsp-zero.nvim",
    url = "https://github.com/VonHeikemen/lsp-zero.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "https://github.com/williamboman/mason-lspconfig.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "https://github.com/williamboman/mason.nvim"
  },
  ["nightcity.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/nightcity.nvim",
    url = "https://github.com/cryptomilk/nightcity.nvim"
  },
  ["none-ls.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/none-ls.nvim",
    url = "https://github.com/nvimtools/none-ls.nvim"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["odin.vim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/odin.vim",
    url = "https://github.com/Tetralux/odin.vim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["refactoring.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/refactoring.nvim",
    url = "https://github.com/theprimeagen/refactoring.nvim"
  },
  ["snacks.nvim"] = {
    config = { "\27LJ\2\ni\0\4\n\0\4\0\19\14\0\3\0X\4\1Ä4\3\0\0009\4\0\3\v\4\1\0X\4\2Ä+\4\1\0X\5\1Ä+\4\2\0=\4\0\0036\4\1\0009\4\2\0049\4\3\4\18\6\0\0\18\a\1\0\18\b\2\0\18\t\3\0B\4\5\1K\0\1\0\bset\vkeymap\bvim\vsilent*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nsmart\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fbuffers\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tgrep\vpicker4\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\20command_history\vpicker2\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\18notifications\vpicker\"\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\0¿\rexplorer,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fbuffers\vpickerh\0\0\6\1\b\0\f-\0\0\0009\0\0\0009\0\1\0005\2\6\0006\3\2\0009\3\3\0039\3\4\3'\5\5\0B\3\2\2=\3\a\2B\0\2\1K\0\1\0\0¿\bcwd\1\0\1\bcwd\0\vconfig\fstdpath\afn\bvim\nfiles\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nfiles\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14git_files\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rprojects\vpicker+\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\vrecent\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17git_branches\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fgit_log\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17git_log_line\vpicker/\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\15git_status\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14git_stash\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rgit_diff\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17git_log_file\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nlines\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17grep_buffers\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tgrep\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14grep_word\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14registers\vpicker3\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\19search_history\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rautocmds\vpicker4\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\20command_history\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rcommands\vpicker0\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\16diagnostics\vpicker7\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\23diagnostics_buffer\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\thelp\vpicker/\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\15highlights\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nicons\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\njumps\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fkeymaps\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\floclist\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nmarks\vpicker(\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\bman\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tlazy\vpicker+\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\vqflist\vpicker+\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\vresume\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tundo\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17colorschemes\vpicker4\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\20lsp_definitions\vpicker5\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\21lsp_declarations\vpicker3\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\19lsp_references\vpicker8\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\24lsp_implementations\vpicker9\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\25lsp_type_definitions\vpicker0\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\16lsp_symbols\vpicker:\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\26lsp_workspace_symbols\vpickerò\23\1\0\b\0†\1\0π\0026\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\4\0005\4\3\0=\4\5\0034\4\0\0=\4\6\3B\1\2\0013\1\a\0\18\2\1\0'\4\b\0'\5\t\0003\6\n\0005\a\v\0B\2\5\1\18\2\1\0'\4\b\0'\5\f\0003\6\r\0005\a\14\0B\2\5\1\18\2\1\0'\4\b\0'\5\15\0003\6\16\0005\a\17\0B\2\5\1\18\2\1\0'\4\b\0'\5\18\0003\6\19\0005\a\20\0B\2\5\1\18\2\1\0'\4\b\0'\5\21\0003\6\22\0005\a\23\0B\2\5\1\18\2\1\0'\4\b\0'\5\24\0003\6\25\0005\a\26\0B\2\5\1\18\2\1\0'\4\b\0'\5\27\0003\6\28\0005\a\29\0B\2\5\1\18\2\1\0'\4\b\0'\5\30\0003\6\31\0005\a \0B\2\5\1\18\2\1\0'\4\b\0'\5!\0003\6\"\0005\a#\0B\2\5\1\18\2\1\0'\4\b\0'\5$\0003\6%\0005\a&\0B\2\5\1\18\2\1\0'\4\b\0'\5'\0003\6(\0005\a)\0B\2\5\1\18\2\1\0'\4\b\0'\5*\0003\6+\0005\a,\0B\2\5\1\18\2\1\0'\4\b\0'\5-\0003\6.\0005\a/\0B\2\5\1\18\2\1\0'\4\b\0'\0050\0003\0061\0005\a2\0B\2\5\1\18\2\1\0'\4\b\0'\0053\0003\0064\0005\a5\0B\2\5\1\18\2\1\0'\4\b\0'\0056\0003\0067\0005\a8\0B\2\5\1\18\2\1\0'\4\b\0'\0059\0003\6:\0005\a;\0B\2\5\1\18\2\1\0'\4\b\0'\5<\0003\6=\0005\a>\0B\2\5\1\18\2\1\0'\4\b\0'\5?\0003\6@\0005\aA\0B\2\5\1\18\2\1\0'\4\b\0'\5B\0003\6C\0005\aD\0B\2\5\1\18\2\1\0'\4\b\0'\5E\0003\6F\0005\aG\0B\2\5\1\18\2\1\0'\4\b\0'\5H\0003\6I\0005\aJ\0B\2\5\1\18\2\1\0005\4K\0'\5L\0003\6M\0005\aN\0B\2\5\1\18\2\1\0'\4\b\0'\5O\0003\6P\0005\aQ\0B\2\5\1\18\2\1\0'\4\b\0'\5R\0003\6S\0005\aT\0B\2\5\1\18\2\1\0'\4\b\0'\5U\0003\6V\0005\aW\0B\2\5\1\18\2\1\0'\4\b\0'\5X\0003\6Y\0005\aZ\0B\2\5\1\18\2\1\0'\4\b\0'\5[\0003\6\\\0005\a]\0B\2\5\1\18\2\1\0'\4\b\0'\5^\0003\6_\0005\a`\0B\2\5\1\18\2\1\0'\4\b\0'\5a\0003\6b\0005\ac\0B\2\5\1\18\2\1\0'\4\b\0'\5d\0003\6e\0005\af\0B\2\5\1\18\2\1\0'\4\b\0'\5g\0003\6h\0005\ai\0B\2\5\1\18\2\1\0'\4\b\0'\5j\0003\6k\0005\al\0B\2\5\1\18\2\1\0'\4\b\0'\5m\0003\6n\0005\ao\0B\2\5\1\18\2\1\0'\4\b\0'\5p\0003\6q\0005\ar\0B\2\5\1\18\2\1\0'\4\b\0'\5s\0003\6t\0005\au\0B\2\5\1\18\2\1\0'\4\b\0'\5v\0003\6w\0005\ax\0B\2\5\1\18\2\1\0'\4\b\0'\5y\0003\6z\0005\a{\0B\2\5\1\18\2\1\0'\4\b\0'\5|\0003\6}\0005\a~\0B\2\5\1\18\2\1\0'\4\b\0'\5\127\0003\6Ä\0005\aÅ\0B\2\5\1\18\2\1\0'\4\b\0'\5Ç\0003\6É\0005\aÑ\0B\2\5\1\18\2\1\0'\4\b\0'\5Ö\0003\6Ü\0005\aá\0B\2\5\1\18\2\1\0'\4\b\0'\5à\0003\6â\0005\aä\0B\2\5\1\18\2\1\0'\4\b\0'\5ã\0003\6å\0005\aç\0B\2\5\1\18\2\1\0'\4\b\0'\5é\0003\6è\0005\aê\0B\2\5\1\18\2\1\0'\4\b\0'\5ë\0003\6í\0005\aì\0B\2\5\1\18\2\1\0'\4\b\0'\5î\0003\6ï\0005\añ\0B\2\5\1\18\2\1\0'\4\b\0'\5ó\0003\6ò\0005\aô\0B\2\5\1\18\2\1\0'\4\b\0'\5ö\0003\6õ\0005\aú\0B\2\5\1\18\2\1\0'\4\b\0'\5ù\0003\6û\0005\aü\0B\2\5\0012\0\0ÄK\0\1\0\1\0\1\tdesc\26LSP Workspace Symbols\0\15<leader>sS\1\0\1\tdesc\16LSP Symbols\0\15<leader>ss\1\0\1\tdesc\27Goto T[y]pe Definition\0\agy\1\0\1\tdesc\24Goto Implementation\0\agI\1\0\2\tdesc\15References\vnowait\2\0\agr\1\0\1\tdesc\21Goto Declaration\0\agD\1\0\1\tdesc\20Goto Definition\0\agd\1\0\1\tdesc\17Colorschemes\0\15<leader>uC\1\0\1\tdesc\17Undo History\0\15<leader>su\1\0\1\tdesc\vResume\0\15<leader>sR\1\0\1\tdesc\18Quickfix List\0\15<leader>sq\1\0\1\tdesc\27Search for Plugin Spec\0\15<leader>sp\1\0\1\tdesc\14Man Pages\0\15<leader>sM\1\0\1\tdesc\nMarks\0\15<leader>sm\1\0\1\tdesc\18Location List\0\15<leader>sl\1\0\1\tdesc\fKeymaps\0\15<leader>sk\1\0\1\tdesc\nJumps\0\15<leader>sj\1\0\1\tdesc\nIcons\0\15<leader>si\1\0\1\tdesc\15Highlights\0\15<leader>sH\1\0\1\tdesc\15Help Pages\0\15<leader>sh\1\0\1\tdesc\23Buffer Diagnostics\0\15<leader>sD\1\0\1\tdesc\16Diagnostics\0\15<leader>sd\1\0\1\tdesc\rCommands\0\15<leader>sC\1\0\1\tdesc\20Command History\0\15<leader>sc\1\0\1\tdesc\rAutocmds\0\15<leader>sa\1\0\1\tdesc\19Search History\0\15<leader>s/\1\0\1\tdesc\14Registers\0\15<leader>s\"\1\0\1\tdesc\29Visual selection or word\0\15<leader>sw\1\3\0\0\6n\6x\1\0\1\tdesc\tGrep\0\15<leader>sg\1\0\1\tdesc\22Grep Open Buffers\0\15<leader>sB\1\0\1\tdesc\17Buffer Lines\0\15<leader>sb\1\0\1\tdesc\17Git Log File\0\15<leader>gf\1\0\1\tdesc\21Git Diff (Hunks)\0\15<leader>gd\1\0\1\tdesc\14Git Stash\0\15<leader>gS\1\0\1\tdesc\15Git Status\0\15<leader>gs\1\0\1\tdesc\17Git Log Line\0\15<leader>gL\1\0\1\tdesc\fGit Log\0\15<leader>gl\1\0\1\tdesc\17Git Branches\0\15<leader>gb\1\0\1\tdesc\vRecent\0\15<leader>fr\1\0\1\tdesc\rProjects\0\15<leader>fp\1\0\1\tdesc\19Find Git Files\0\15<leader>fg\1\0\1\tdesc\15Find Files\0\15<leader>ff\1\0\1\tdesc\21Find Config File\0\15<leader>fc\1\0\1\tdesc\fBuffers\0\15<leader>fb\1\0\1\tdesc\18File Explorer\0\14<leader>e\1\0\1\tdesc\25Notification History\0\14<leader>n\1\0\1\tdesc\20Command History\0\14<leader>:\1\0\1\tdesc\tGrep\0\14<leader>/\1\0\1\tdesc\fBuffers\0\14<leader>,\1\0\1\tdesc\21Smart Find Files\0\20<leader><space>\6n\0\rexplorer\vpicker\1\0\2\vpicker\0\rexplorer\0\1\0\2\15auto_close\2\venbale\2\nsetup\vsnacks\frequire\0" },
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/snacks.nvim",
    url = "https://github.com/folke/snacks.nvim"
  },
  sonokai = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/sonokai",
    url = "https://github.com/sainnhe/sonokai"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["tree-sitter-odin"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/tree-sitter-odin",
    url = "https://github.com/ap29600/tree-sitter-odin"
  },
  ["trouble.nvim"] = {
    config = { "\27LJ\2\nù\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\tkeys\1\0\1\tkeys\0\1\3\1\0\15<leader>xx(<cmd>Trouble diagnostics toggle<cr>\tdesc\26Diagnostics (Trouble)\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  undotree = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-gitgutter"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/vim-gitgutter",
    url = "https://github.com/airblade/vim-gitgutter"
  },
  ["zig.vim"] = {
    loaded = true,
    path = "/Users/alexmatthewcandelario/.local/share/nvim/site/pack/packer/start/zig.vim",
    url = "https://github.com/ziglang/zig.vim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: markdown-preview.nvim
time([[Setup for markdown-preview.nvim]], true)
try_loadstring("\27LJ\2\n=\0\0\2\0\4\0\0056\0\0\0009\0\1\0005\1\3\0=\1\2\0K\0\1\0\1\2\0\0\rmarkdown\19mkdp_filetypes\6g\bvim\0", "setup", "markdown-preview.nvim")
time([[Setup for markdown-preview.nvim]], false)
-- Config for: snacks.nvim
time([[Config for snacks.nvim]], true)
try_loadstring("\27LJ\2\ni\0\4\n\0\4\0\19\14\0\3\0X\4\1Ä4\3\0\0009\4\0\3\v\4\1\0X\4\2Ä+\4\1\0X\5\1Ä+\4\2\0=\4\0\0036\4\1\0009\4\2\0049\4\3\4\18\6\0\0\18\a\1\0\18\b\2\0\18\t\3\0B\4\5\1K\0\1\0\bset\vkeymap\bvim\vsilent*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nsmart\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fbuffers\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tgrep\vpicker4\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\20command_history\vpicker2\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\18notifications\vpicker\"\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\0¿\rexplorer,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fbuffers\vpickerh\0\0\6\1\b\0\f-\0\0\0009\0\0\0009\0\1\0005\2\6\0006\3\2\0009\3\3\0039\3\4\3'\5\5\0B\3\2\2=\3\a\2B\0\2\1K\0\1\0\0¿\bcwd\1\0\1\bcwd\0\vconfig\fstdpath\afn\bvim\nfiles\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nfiles\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14git_files\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rprojects\vpicker+\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\vrecent\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17git_branches\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fgit_log\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17git_log_line\vpicker/\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\15git_status\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14git_stash\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rgit_diff\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17git_log_file\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nlines\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17grep_buffers\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tgrep\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14grep_word\vpicker.\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\14registers\vpicker3\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\19search_history\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rautocmds\vpicker4\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\20command_history\vpicker-\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\rcommands\vpicker0\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\16diagnostics\vpicker7\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\23diagnostics_buffer\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\thelp\vpicker/\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\15highlights\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nicons\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\njumps\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\fkeymaps\vpicker,\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\floclist\vpicker*\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\nmarks\vpicker(\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\bman\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tlazy\vpicker+\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\vqflist\vpicker+\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\vresume\vpicker)\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\tundo\vpicker1\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\17colorschemes\vpicker4\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\20lsp_definitions\vpicker5\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\21lsp_declarations\vpicker3\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\19lsp_references\vpicker8\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\24lsp_implementations\vpicker9\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\25lsp_type_definitions\vpicker0\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\16lsp_symbols\vpicker:\0\0\2\1\2\0\5-\0\0\0009\0\0\0009\0\1\0B\0\1\1K\0\1\0\0¿\26lsp_workspace_symbols\vpickerò\23\1\0\b\0†\1\0π\0026\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\4\0005\4\3\0=\4\5\0034\4\0\0=\4\6\3B\1\2\0013\1\a\0\18\2\1\0'\4\b\0'\5\t\0003\6\n\0005\a\v\0B\2\5\1\18\2\1\0'\4\b\0'\5\f\0003\6\r\0005\a\14\0B\2\5\1\18\2\1\0'\4\b\0'\5\15\0003\6\16\0005\a\17\0B\2\5\1\18\2\1\0'\4\b\0'\5\18\0003\6\19\0005\a\20\0B\2\5\1\18\2\1\0'\4\b\0'\5\21\0003\6\22\0005\a\23\0B\2\5\1\18\2\1\0'\4\b\0'\5\24\0003\6\25\0005\a\26\0B\2\5\1\18\2\1\0'\4\b\0'\5\27\0003\6\28\0005\a\29\0B\2\5\1\18\2\1\0'\4\b\0'\5\30\0003\6\31\0005\a \0B\2\5\1\18\2\1\0'\4\b\0'\5!\0003\6\"\0005\a#\0B\2\5\1\18\2\1\0'\4\b\0'\5$\0003\6%\0005\a&\0B\2\5\1\18\2\1\0'\4\b\0'\5'\0003\6(\0005\a)\0B\2\5\1\18\2\1\0'\4\b\0'\5*\0003\6+\0005\a,\0B\2\5\1\18\2\1\0'\4\b\0'\5-\0003\6.\0005\a/\0B\2\5\1\18\2\1\0'\4\b\0'\0050\0003\0061\0005\a2\0B\2\5\1\18\2\1\0'\4\b\0'\0053\0003\0064\0005\a5\0B\2\5\1\18\2\1\0'\4\b\0'\0056\0003\0067\0005\a8\0B\2\5\1\18\2\1\0'\4\b\0'\0059\0003\6:\0005\a;\0B\2\5\1\18\2\1\0'\4\b\0'\5<\0003\6=\0005\a>\0B\2\5\1\18\2\1\0'\4\b\0'\5?\0003\6@\0005\aA\0B\2\5\1\18\2\1\0'\4\b\0'\5B\0003\6C\0005\aD\0B\2\5\1\18\2\1\0'\4\b\0'\5E\0003\6F\0005\aG\0B\2\5\1\18\2\1\0'\4\b\0'\5H\0003\6I\0005\aJ\0B\2\5\1\18\2\1\0005\4K\0'\5L\0003\6M\0005\aN\0B\2\5\1\18\2\1\0'\4\b\0'\5O\0003\6P\0005\aQ\0B\2\5\1\18\2\1\0'\4\b\0'\5R\0003\6S\0005\aT\0B\2\5\1\18\2\1\0'\4\b\0'\5U\0003\6V\0005\aW\0B\2\5\1\18\2\1\0'\4\b\0'\5X\0003\6Y\0005\aZ\0B\2\5\1\18\2\1\0'\4\b\0'\5[\0003\6\\\0005\a]\0B\2\5\1\18\2\1\0'\4\b\0'\5^\0003\6_\0005\a`\0B\2\5\1\18\2\1\0'\4\b\0'\5a\0003\6b\0005\ac\0B\2\5\1\18\2\1\0'\4\b\0'\5d\0003\6e\0005\af\0B\2\5\1\18\2\1\0'\4\b\0'\5g\0003\6h\0005\ai\0B\2\5\1\18\2\1\0'\4\b\0'\5j\0003\6k\0005\al\0B\2\5\1\18\2\1\0'\4\b\0'\5m\0003\6n\0005\ao\0B\2\5\1\18\2\1\0'\4\b\0'\5p\0003\6q\0005\ar\0B\2\5\1\18\2\1\0'\4\b\0'\5s\0003\6t\0005\au\0B\2\5\1\18\2\1\0'\4\b\0'\5v\0003\6w\0005\ax\0B\2\5\1\18\2\1\0'\4\b\0'\5y\0003\6z\0005\a{\0B\2\5\1\18\2\1\0'\4\b\0'\5|\0003\6}\0005\a~\0B\2\5\1\18\2\1\0'\4\b\0'\5\127\0003\6Ä\0005\aÅ\0B\2\5\1\18\2\1\0'\4\b\0'\5Ç\0003\6É\0005\aÑ\0B\2\5\1\18\2\1\0'\4\b\0'\5Ö\0003\6Ü\0005\aá\0B\2\5\1\18\2\1\0'\4\b\0'\5à\0003\6â\0005\aä\0B\2\5\1\18\2\1\0'\4\b\0'\5ã\0003\6å\0005\aç\0B\2\5\1\18\2\1\0'\4\b\0'\5é\0003\6è\0005\aê\0B\2\5\1\18\2\1\0'\4\b\0'\5ë\0003\6í\0005\aì\0B\2\5\1\18\2\1\0'\4\b\0'\5î\0003\6ï\0005\añ\0B\2\5\1\18\2\1\0'\4\b\0'\5ó\0003\6ò\0005\aô\0B\2\5\1\18\2\1\0'\4\b\0'\5ö\0003\6õ\0005\aú\0B\2\5\1\18\2\1\0'\4\b\0'\5ù\0003\6û\0005\aü\0B\2\5\0012\0\0ÄK\0\1\0\1\0\1\tdesc\26LSP Workspace Symbols\0\15<leader>sS\1\0\1\tdesc\16LSP Symbols\0\15<leader>ss\1\0\1\tdesc\27Goto T[y]pe Definition\0\agy\1\0\1\tdesc\24Goto Implementation\0\agI\1\0\2\tdesc\15References\vnowait\2\0\agr\1\0\1\tdesc\21Goto Declaration\0\agD\1\0\1\tdesc\20Goto Definition\0\agd\1\0\1\tdesc\17Colorschemes\0\15<leader>uC\1\0\1\tdesc\17Undo History\0\15<leader>su\1\0\1\tdesc\vResume\0\15<leader>sR\1\0\1\tdesc\18Quickfix List\0\15<leader>sq\1\0\1\tdesc\27Search for Plugin Spec\0\15<leader>sp\1\0\1\tdesc\14Man Pages\0\15<leader>sM\1\0\1\tdesc\nMarks\0\15<leader>sm\1\0\1\tdesc\18Location List\0\15<leader>sl\1\0\1\tdesc\fKeymaps\0\15<leader>sk\1\0\1\tdesc\nJumps\0\15<leader>sj\1\0\1\tdesc\nIcons\0\15<leader>si\1\0\1\tdesc\15Highlights\0\15<leader>sH\1\0\1\tdesc\15Help Pages\0\15<leader>sh\1\0\1\tdesc\23Buffer Diagnostics\0\15<leader>sD\1\0\1\tdesc\16Diagnostics\0\15<leader>sd\1\0\1\tdesc\rCommands\0\15<leader>sC\1\0\1\tdesc\20Command History\0\15<leader>sc\1\0\1\tdesc\rAutocmds\0\15<leader>sa\1\0\1\tdesc\19Search History\0\15<leader>s/\1\0\1\tdesc\14Registers\0\15<leader>s\"\1\0\1\tdesc\29Visual selection or word\0\15<leader>sw\1\3\0\0\6n\6x\1\0\1\tdesc\tGrep\0\15<leader>sg\1\0\1\tdesc\22Grep Open Buffers\0\15<leader>sB\1\0\1\tdesc\17Buffer Lines\0\15<leader>sb\1\0\1\tdesc\17Git Log File\0\15<leader>gf\1\0\1\tdesc\21Git Diff (Hunks)\0\15<leader>gd\1\0\1\tdesc\14Git Stash\0\15<leader>gS\1\0\1\tdesc\15Git Status\0\15<leader>gs\1\0\1\tdesc\17Git Log Line\0\15<leader>gL\1\0\1\tdesc\fGit Log\0\15<leader>gl\1\0\1\tdesc\17Git Branches\0\15<leader>gb\1\0\1\tdesc\vRecent\0\15<leader>fr\1\0\1\tdesc\rProjects\0\15<leader>fp\1\0\1\tdesc\19Find Git Files\0\15<leader>fg\1\0\1\tdesc\15Find Files\0\15<leader>ff\1\0\1\tdesc\21Find Config File\0\15<leader>fc\1\0\1\tdesc\fBuffers\0\15<leader>fb\1\0\1\tdesc\18File Explorer\0\14<leader>e\1\0\1\tdesc\25Notification History\0\14<leader>n\1\0\1\tdesc\20Command History\0\14<leader>:\1\0\1\tdesc\tGrep\0\14<leader>/\1\0\1\tdesc\fBuffers\0\14<leader>,\1\0\1\tdesc\21Smart Find Files\0\20<leader><space>\6n\0\rexplorer\vpicker\1\0\2\vpicker\0\rexplorer\0\1\0\2\15auto_close\2\venbale\2\nsetup\vsnacks\frequire\0", "config", "snacks.nvim")
time([[Config for snacks.nvim]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
try_loadstring("\27LJ\2\nù\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\tkeys\1\0\1\tkeys\0\1\3\1\0\15<leader>xx(<cmd>Trouble diagnostics toggle<cr>\tdesc\26Diagnostics (Trouble)\nsetup\ftrouble\frequire\0", "config", "trouble.nvim")
time([[Config for trouble.nvim]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
