# Neovim Configuration

Neovim 0.12+ configuration. No plugin-manager plugin, no LSP installer, no
completion plugin: it leans on what ships with Neovim — `vim.pack` for plugins,
native LSP, native treesitter, and built-in completion driven by a custom
`completefunc`.

Requires **Neovim 0.12 or newer** (`vim.pack`, `vim.lsp.config`,
`vim.lsp.completion`).

## Installation

```bash
brew install neovim
git clone git@github.com:candtechsoftware/nvim_config.git ~/.config/nvim
```

Start `nvim`. `vim.pack` installs the plugins listed in `init.lua` on first
launch and writes the resolved commits to `nvim-pack-lock.json`.
`telescope-fzf-native` is built automatically by the `PackChanged` hook in
`init.lua`.

## Plugins

Declared in `init.lua` via `vim.pack.add`:

- **plenary.nvim** — dependency of telescope
- **telescope.nvim** + **telescope-fzf-native.nvim** — fuzzy finding
- **harpoon** (`harpoon2` branch) — file marks
- **render-markdown.nvim** — markdown rendering

Managing them:

| Action | How |
|---|---|
| Update all | `:lua vim.pack.update()` |
| Update one | `:lua vim.pack.update({ 'telescope.nvim' })` |
| Remove | `:lua vim.pack.del({ 'name' })` |
| List | `:lua vim.pack.get()` |

## C / C++

These are unity-build codebases, and the setup is built around that.

**clangd is opt-in.** It attaches only in a project where `:ClangdSetup` has
generated a `.clangd` describing the unity build (see
`lua/config/clangd_setup.lua`). There is no `compile_commands.json`.

**Everywhere else, ctags + treesitter do the work:**

- `lua/config/ctags.lua` generates a per-project tags file under
  `~/.cache/nvim/tags/` (never in the project tree), refreshed in the background
  on save. `:Ctags` regenerates on demand.
- `gd` is a tag jump (`:tjump`); `<C-]>` / `<C-t>` work too.
- `lua/config/c_complete.lua` drives `<Tab>` completion: treesitter resolves the
  type before a `.` / `->`, then the tags index supplies that type's members.
  Plain identifiers are ranked local → file → project.

The custom storage-class macros (`internal`, `global`, `local_persist`,
`function`) are understood by neither `cindent` nor tree-sitter, so both the
indent path (`lua/config/c_indent.lua`) and the completion path rewrite them to
`static` before parsing.

Requires `ctags` (`brew install universal-ctags`) and `rg`.

## Language servers

Configured per-server in `lsp/*.lua`, enabled in `lua/config/lsp.lua`. Install
whichever you need:

| Language | Server | Install |
|---|---|---|
| C/C++ | clangd | `brew install llvm` |
| Lua | lua_ls | [releases](https://github.com/LuaLS/lua-language-server/releases) |
| Go | gopls | `go install golang.org/x/tools/gopls@latest` |
| Rust | rust_analyzer | `rustup component add rust-analyzer` |
| TypeScript | ts_ls, eslint | `npm i -g typescript-language-server typescript` |
| Zig | zls | [releases](https://github.com/zigtools/zls/releases) |
| Odin | ols | [ols](https://github.com/DanielGavin/ols) |
| Jai | jails | [Jails](https://github.com/SogoCZE/Jails) |

`:LspInfo` summarizes state for the current buffer, `:LspRestart` restarts, and
`:checkhealth vim.lsp` is the deeper view.

Other tools assumed present: **ripgrep** (telescope, project macro scanning).

## Keymaps

See [KEYMAPS.md](KEYMAPS.md) — it is the single source of truth, and it marks
which mappings are Neovim 0.12 built-ins (`grn`, `grr`, `gra`, `gO`, `K`) rather
than config.

Leader is `<Space>`.

## Layout

```
init.lua              plugin declarations + module wiring
lua/config/           options, keymaps, lsp, ctags, completion, treesitter
lua/hh/               scope shading + project macro highlighting (loaded BY the
                      colorschemes, not by init.lua)
lua/notes/            notes browser
lua/launch/           run/build helpers
lua/utils/            project root, makeprg detection
lsp/                  per-server LSP configs
colors/               8 colorschemes (`handmade` is the default)
after/ftplugin/       filetype overrides (c, cpp, objc, objcpp, markdown)
after/queries/        treesitter query overrides
queries/jai/          Jai treesitter queries
syntax/jai.vim        Jai syntax
ghostty/              terminal config + shaders (not used by Neovim)
```
