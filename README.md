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
`compile_commands.json`. A database a build system already writes is left
alone — its entries carry the real flags a bare one cannot (MinusTable's
`build_mac.sh` rewrites it on every build, `-Isrc -Ithirdparty/libpq/include`),
and either file gives the indexer the same list. A project set up before this
needs one `:ClangdSetup!` to get its index, and so does a new module dir: a
dir no fragment matches gets no `-include` chain at all, which is what clangd
going silent in a freshly created `src/draw/` means. The preamble chain
follows unity aggregates: engine's `src/main.cpp` includes
`modules/base/base_inc.cpp`, which includes
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

**Indent width** (`lua/config/c_width.lua`, wired in `after/ftplugin/c.lua`
and inherited by C++/Obj-C) comes from the project, not the file: the most
common first-level indent among up to 40 `.c`/`.h` under the project root
(`utils.project_root`, skipping `utils.skip_dirs`) decides, so 4-space code
pasted into a 2-space tree is a file to fix rather than a style to follow. A
file with no project above it falls back to its own first indented line, then
to 2 — the raddebugger style. Only 2/4/8 count, so a `*` comment body or an
aligned continuation line cannot set the width, and ties go to the narrower
one. The scan runs once per project root per session. An `.editorconfig` still
wins over all of this, as it runs after the ftplugin.

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

Drop a `launch.json` at the project root, or run `:LaunchInit` for a commented
starter. Each key is a normal-mode mapping, bound while you are in that
project. The value is a shell command, or `{ "cmd", "out" }`.

```jsonc
{
  // Comments and trailing commas are fine, this is parsed as JSONC.
  "<F1>": "./build.sh",
  "<F4>": { "cmd": "./build.sh && ./build/game", "out": "*run*" },
  "<leader>t": { "cmd": "./build/tool --dump", "out": "*tool*" },

  // mac / linux / windows entries override the ones above on that platform.
  "linux": { "<F1>": "./build_linux.sh" }
}
```

`out` names the buffer the output goes to (default `*compilation*`). Every out
works the same way: one buffer per name, one job per buffer, and starting a
command stops whatever was still writing to its buffer. Give anything that
should keep running while you rebuild its own out, like `"out": "*run*"` for
the app above.

The output buffers (`launch://*run*`) are plain text, not terminals, so you can
edit, yank, search and `:w` them. The command runs on a PTY, so a GUI app's
printf output streams line by line instead of arriving when it exits (on a
pipe libc block-buffers it). Colour codes are stripped, and there is no stdin.
The pane opens at the bottom without taking focus and follows new output
unless you scroll up. `q` closes it and leaves the job running, `<C-c>` stops
the job, `<leader>o` brings the pane back, and deleting the buffer stops its
job. `VimLeavePre` stops everything, so nothing outlives the editor.

When a command exits, the error locations in its output become the quickfix
list. `<M-n>` / `<M-N>` step through them, and `<CR>` on any output line jumps
to it. In your files each error line gets a red tint with its message at the
end of the line (warnings get just the message, in yellow) until the next
build. One errorformat covers Jai, clang, gcc, zig, MSVC, Odin, Rust, CMake and
ESLint, whichever buffer you built from. Relative paths resolve against the
project root, and a location only counts if its file exists. A clean rebuild
clears the old errors, and a quickfix list from somewhere else (a grep) is
kept in `:colder` instead of overwritten. `:LaunchQF` re-parses the output
while an app is still running.

`<M-n>` needs Option to send Alt: `macos-option-as-alt = left` in Ghostty
(`ghostty/config`), `neovide_input_macos_option_key_is_meta` in Neovide.

With no `launch.json`, `<leader>b` runs `:Make`, the build command
`utils/make_detect.lua` detects for the project, into the same `*compilation*`
buffer. A project key that shadows an existing mapping gives it back when you
leave the project.

## Layout

```
init.lua              plugin declarations + module wiring
lua/config/           options, keymaps, lsp, ctags, completion, treesitter
lua/hh/               scope shading + project macro highlighting (loaded BY the
                      colorschemes, not by init.lua)
lua/notes/            notes browser
lua/launch/           per-project keys from launch.json
                      init.lua  read launch.json, bind keys, :Make
                      run.lua   out buffers + jobs, errors to quickfix + marks
lua/utils/            project root, build command detection
lsp/                  per-server LSP configs
colors/               handmade (default), fourcoder, naysayer, naysayer_black
after/ftplugin/       filetype overrides (c, cpp, objc, objcpp, markdown)
after/queries/        treesitter query overrides
queries/jai/          Jai treesitter queries
syntax/jai.vim        Jai syntax
ghostty/              terminal config + shaders (not used by Neovim)
```
