# Neovim Configuration

A minimal Neovim configuration with no plugin manager, using Vim's native plugin system.

## Installation 

```bash
brew install neovim
```

Clone this repo:
```bash
git clone --recurse-submodules git@github.com:candtechsoftware/nvim_config.git ~/.config/nvim
```

Note: Use `--recurse-submodules` to automatically clone all plugin submodules.

## Plugins

This configuration uses Vim's native plugin system (`pack/plugins/start/`) with the following plugins as git submodules:

- **harpoon** - Quick file navigation
- **jai.vim** - Jai language support 
- **nvim-treesitter** - Syntax highlighting and parsing
- **plenary.nvim** - Lua utility functions (dependency for other plugins)
- **telescope-fzf-native.nvim** - Fast fuzzy finder for Telescope
- **telescope.nvim** - Fuzzy finder and picker

## Updating Plugins

Since plugins are managed as git submodules, use these commands to update them:

### Update All Plugins

```bash
git submodule update --remote
```

### Update a Specific Plugin

```bash
git submodule update --remote pack/plugins/start/PLUGIN_NAME
```

For example:
```bash
git submodule update --remote pack/plugins/start/telescope.nvim
```

### Check Plugin Status

```bash
git submodule status
```

### After Updates

After updating plugins, you may need to:

1. **Restart Neovim** to load the updated plugins
2. **Update Treesitter parsers** (if nvim-treesitter was updated):
   ```vim
   :TSUpdate
   ```
3. **Rebuild telescope-fzf-native** (if telescope-fzf-native was updated):
   ```bash
   cd pack/plugins/start/telescope-fzf-native.nvim
   make
   ```

## Adding New Plugins

To add a new plugin as a submodule:

```bash
git submodule add PLUGIN_GIT_URL pack/plugins/start/PLUGIN_NAME
```

## Removing Plugins

To remove a plugin:

```bash
git submodule deinit pack/plugins/start/PLUGIN_NAME
git rm pack/plugins/start/PLUGIN_NAME
```

## Installing Dependencies: Language Servers and Tools (macOS & Ubuntu)

1. **Ripgrep** (required for searching)
2. **Node.js** (required for some language servers)
3. **TypeScript Language Server** (for JavaScript/TypeScript) [docs](https://github.com/typescript-language-server/typescript-language-server)
4. **Rust Analyzer** (for Rust) [docs](https://rust-analyzer.github.io/manual.html#installation)
5. **gopls** (for Go) [docs](https://pkg.go.dev/golang.org/x/tools/gopls)
6. **zls** (for Zig) [docs](https://github.com/zigtools/zls) 

### Install Ripgrep

Ripgrep is a fast search tool used by many plugins like Telescope for searching file contents.

#### macOS:
```bash
brew install ripgrep
```

#### Ubuntu:
```bash
sudo apt-get install ripgrep
```

## Updating Language Servers

Your config includes several LSPs that can be updated independently:

### TypeScript Language Server
```bash
npm update -g typescript-language-server
npm update -g typescript
```

### Other LSPs
- **Go**: `go install golang.org/x/tools/gopls@latest`
- **Rust**: `rustup update` (rust-analyzer updates with rustup)
- **Lua**: Download latest from [lua-language-server releases](https://github.com/LuaLS/lua-language-server/releases)
- **C/C++**: `brew install llvm` (macOS) or install clang/clangd via package manager
- **Zig**: `zig install zls` or download from [ZLS releases](https://github.com/zigtools/zls/releases)

### Checking LSP Status
- `:LspInfo` - Show active LSP clients
- `:LspStop` - Stop LSP for current buffer
- `:LspStart` - Start LSP for current buffer
