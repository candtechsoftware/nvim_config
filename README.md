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
- **undotree** — undo history browser (`<leader>u`)
- **render-markdown.nvim** — markdown rendering. Loaded with a no-op `load`
  handler and `:packadd`ed from a one-shot `FileType markdown` autocmd. Its
  `plugin/` file pulls in ~20 modules and cost ~4ms of a ~38ms startup for
  something only markdown buffers use. Note `load = false` would NOT have been
  enough: that is already the default while `init.lua` is sourcing, and it only
  means `:packadd!` — the plugin still lands on `runtimepath` and the normal
  post-init rtp scan sources it anyway.

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

## Building and running (`launch.json`)

Drop a `launch.json` at the project root — or run `:LaunchInit` to write a
commented starter. `<leader>b` builds, `<leader>r` runs, and a count picks the
target: `2<leader>r` runs the second one.

```jsonc
{
  // Comments and trailing commas are fine — this is parsed as JSONC.
  "build": ["make -j", "make -j RELEASE=1"],

  "run": [
    "./bin/tool --verbose",

    // Long form, when a target needs options:
    //   depends  build target to run first; only launches on exit 0
    //   height   output pane height in lines
    { "name": "game", "cmd": "./build/game", "depends": "build", "height": 20 }
  ]

  // Any of the above may be platform-keyed:
  //   "run": { "mac": ["./build/app"], "linux": ["./build/app"] }
}
```

The two kinds behave differently on purpose:

- **build** runs buffered, parses output through the `errorformat` that
  `utils/make_detect.lua` detected for the project, and gives you a quickfix
  list plus inline diagnostics. You don't want to watch a compile scroll past;
  you want the errors.
- **run** gets a **PTY terminal pane**, streaming. The PTY matters: a program
  whose stdout is a pipe gets libc's block buffering, so a long-running app
  produces nothing observable until it exits. On a tty it line-buffers, so
  output appears as it happens — and you also get ANSI colour and a working
  stdin for an interactive CLI.

Re-running a target kills its previous instance first, so a GUI app started
twice can't leave an unreachable orphan, and `VimLeavePre` stops everything so
nothing outlives the editor. `:LaunchQF` pushes the output pane through
`errorformat` into quickfix, for a run that prints compiler-style errors.

With no `launch.json`, `<leader>b` still builds: it falls back to the detected
makeprg. The older `{"key_map": {"<F5>": "make"}}` form is still honored, and
still restores any mapping it shadows when you switch projects.

## Layout

```
init.lua              plugin declarations + module wiring
lua/config/           options, keymaps, lsp, ctags, completion, treesitter
lua/hh/               scope shading + project macro highlighting (loaded BY the
                      colorschemes, not by init.lua)
lua/notes/            notes browser
lua/launch/           build/run targets from launch.json
                      init.lua  config + target resolution + keymaps
                      run.lua   job registry + terminal output pane
lua/utils/            project root, makeprg detection
lsp/                  per-server LSP configs
colors/               handmade (default), fourcoder, naysayer, naysayer_black
after/ftplugin/       filetype overrides (c, cpp, objc, objcpp, markdown)
after/queries/        treesitter query overrides
queries/jai/          Jai treesitter queries
syntax/jai.vim        Jai syntax
ghostty/              terminal config + shaders (not used by Neovim)
```
