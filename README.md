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

## Navigation Keybindings

| Category | Key | Action |
|----------|-----|--------|
| **Page Movement** | `<C-d>` | Half page down (centered) |
| | `<C-u>` | Half page up (centered) |
| | `n` / `N` | Search next/prev (centered) |
| **LSP Navigation** | `gd` | Go to definition |
| | `gD` | Go to declaration |
| | `gv` | Definition in vsplit |
| | `<leader>vrr` | Find references |
| | `<leader>gi` | Go to implementation |
| | `<leader>vi` | Incoming calls |
| **Diagnostics** | `[d` / `]d` | Prev/next diagnostic |
| | `<leader>vd` | Show diagnostic float |
| | `<leader>qf` | Diagnostics to quickfix |
| **Telescope Symbols** | `<leader>ds` | Document symbols |
| | `<leader>ws` | Workspace symbols |
| | `<leader>vws` | Workspace symbol (LSP native) |
| **Comments** | `[c` / `]c` | Prev/next comment |
| **Quickfix** | `<C-k>` / `<C-j>` | Next/prev quickfix item |
| | `<leader>k` / `<leader>j` | Next/prev location list |
| **Harpoon** | `<leader>ha` | Add file to harpoon |
| | `<C-h/t/n/s>` | Jump to slots 1-4 |
| | `<C-e>` | Toggle harpoon menu |
| **File Explorer** | `<leader>pv` | Open netrw |
| **Tabs** | `<leader>t` | New tab |
| | `<leader><Tab>` | Next tab |
| | `<leader>tc` | Close tab |

## Search Keybindings

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>/` | Live grep (project root) |
| `<leader>.` | Live grep (cwd) |
| `<leader>gf` | Git files |
| `<leader>pws` | Grep word under cursor |
| `<leader>pWs` | Grep WORD under cursor |
| `<leader>ps` | Grep visual selection |
| `<leader>fg` | Live grep with file type filter (`search --- *.ext`) |

## Git Keybindings

| Key | Action |
|-----|--------|
| `<leader>gc` | Git commits |
| `<leader>gb` | Git branches |
| `<leader>gs` | Git status |

## Editing Keybindings

| Key | Action |
|-----|--------|
| `<leader>f` | Format file (jai-format for .jai, LSP for others) |
| `<leader>s` | Search and replace word under cursor |
| `<leader>y` | Copy to system clipboard |
| `<leader>Y` | Copy line to system clipboard |
| `<leader>d` | Delete without yanking |
| `<leader>p` | Paste without yanking (visual mode) |
| `<leader>pc` | Paste from system clipboard |
| `J` | Join lines (cursor stays in place) |
| `J` / `K` | Move selected lines down/up (visual mode) |

## LSP Actions

| Key | Action |
|-----|--------|
| `<leader>vca` | Code actions |
| `<leader>vrn` | Rename symbol |
| `K` | Hover documentation |
| `<C-h>` | Signature help (insert mode) |

## Completion

| Key | Action |
|-----|--------|
| `<Tab>` / `<S-Tab>` | Navigate completion menu |
| `<CR>` | Accept completion |

## Notes

| Key | Action |
|-----|--------|
| `<leader>n` | Open notes directory |
| `<leader>ns` | Search notes content |
| `<leader>nf` | Find notes by filename |
| `<leader>nn` | Create new note |
| `<leader>ng` | Notes git status |

## Jai Language

| Key | Action |
|-----|--------|
| `<leader>js` | Search Jai module symbols |
| `<leader>jg` | Grep Jai modules |

## Misc

| Key | Action |
|-----|--------|
| `<leader><leader>` | Source current file |
