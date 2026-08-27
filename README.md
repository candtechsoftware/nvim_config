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
`lua/config/clangd_setup.lua`). It also writes a bare `compile_commands.json`
— no flags, `.clangd` owns those — because a compilation database is the only
file list clangd's background indexer will take; without one nothing is ever
indexed and `gd` stops at prototypes instead of reaching definitions in other
unity members. Shards go to `<root>/.cache/clangd/`; gitignore that and
`compile_commands.json`. A project set up before this needs one
`:ClangdSetup!` to get its index. The preamble chain follows unity aggregates:
engine's `src/main.cpp` includes `modules/base/base_inc.cpp`, which includes
`third_party/xxhash/xxhash.h` before its own `.cpp` files, so every member
compiles with that header and `gd` on `XXH3_64bits_withSeed` lands in
`third_party/`. Foreign-platform headers (`win32/`, `linux/` on a Mac) are
left out of the chain. One blind spot survives even with the index:
a function with no prototype in any header (only a definition in another
member) is an implicit declaration in the open file's standalone parse, and
clangd's goto-definition answers with the call site. `gd` detects that reply
and asks the index by name instead (`goto_definition` in `lua/config/lsp.lua`).

**Everywhere else, ctags + treesitter do the work:**

- `lua/config/ctags.lua` generates a per-project tags file under
  `~/.cache/nvim/tags/` (never in the project tree), refreshed in the background
  on save. `:Ctags` regenerates on demand.
- `gd` is a tag jump (`:tjump`); `<C-]>` / `<C-t>` work too.
- `lua/config/c_complete.lua` drives `<Tab>` completion: treesitter resolves the
  type before a `.` / `->`, then the tags index supplies that type's members.
  Plain identifiers are ranked local → file → project.

The custom storage-class macros (`internal`, `global`, `local_persist`,
`function`) are not understood by tree-sitter, so the completion path rewrites
them to `static` before parsing. Indentation is plain `cindent` (which copes
with the macros) plus one fix in `lua/config/c_indent.lua`: a `{` on its own
line after a `case X:` label sits at the label's indent, where cindent would
push it right — and, after a `default: {}break;`, under that `{}`. An
indentexpr runs under textlock, so it cannot rewrite the buffer; every fix
there is a computed indent. `cinoptions` indents `case` one level under
`switch` (`:s`), the raddebugger layout.

**Indent width** (`after/ftplugin/c.lua`, inherited by C++/Obj-C) defaults to
the raddebugger style — 2 spaces — but a file that already has an indent
keeps it: the buffer's first indented line decides, then a sibling `.c`/`.h`
in the same directory (a prototype-only header or a new file has no indent
of its own), then 2. Only 2/4/8 count, so a `*` comment body or an aligned
continuation line cannot set the width. An `.editorconfig` still wins over all
of this, as it runs after the ftplugin.

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

### Formatting

`<leader>f` is manual and routed by filetype: Odin goes through `odinfmt`,
TypeScript/JavaScript through Prettier and then eslint's `source.fixAll`,
everything else is a no-op. `odinfmt` is built from the ols repo
(`./odinfmt.sh`, binary lands next to `ols`) and takes its style from the
nearest `odinfmt.json` above the file being formatted, not above nvim's cwd.
Odin buffers also get `:Odinfmt`, plus format-on-save behind
`vim.g.odinfmt_on_save = true` (off by default). A buffer that does not parse
is reported and left untouched. See `lua/config/odinfmt.lua`.

**Prettier** (`lua/config/prettier.lua`) is the project's own: the
`node_modules/.bin/prettier` nearest the file, else one on PATH; nothing is
installed globally. JS/TS buffers also take their indent options from the
project's Prettier config — `tabWidth`/`useTabs` from the nearest
`package.json` `"prettier"` key, `.prettierrc*` or `prettier.config.*`,
`overrides` included, with Prettier's own defaults (2 spaces) when there is no
config — so what you type indents the way `prettier --write` would leave it.
An explicit `tabWidth` beats `.editorconfig`, as it does for Prettier itself.
JSON configs are parsed properly; YAML/JS/TOML ones are scanned for the two
keys, so a shared config referenced by name yields the defaults. `:Prettier`
runs Prettier alone (no eslint pass). Prettier runs synchronously first, so in
the eslint-plugin-prettier projects the eslint step only applies its own fixes.

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
