# Neovim configuration

For Neovim 0.13 (nightly). Plugins come from `vim.pack`; LSP, treesitter,
completion, the file browser, undotree, multicursor and the pickers are all
builtin. Two plugins:

- **fff** finds files and greps. Its post-install hook in `init.lua` downloads
  or builds its binary.
- **render-markdown.nvim** loads on the first markdown buffer.

`:packupdate` updates them, `:packdel` removes one, and the resolved commits
are in `nvim-pack-lock.json`. Also assumed installed: ripgrep, universal-ctags,
a C compiler (for treesitter parsers) and the language servers in `lsp/`.

Keymaps are in [KEYMAPS.md](KEYMAPS.md).

## Layout

```
init.lua                plugins, module wiring, colorscheme, ui2
lua/config/
  options.lua           options, cmdline autocompletion, no bold/italic/underline
  keymaps.lua           editing, quickfix stepping, <Tab> completion routing
  lsp.lua               servers, completion, clangd unity-build goto-definition
  pickers.lua           fff, plus native :Recent :Grep :Branch, symbols, git
  treesitter.lua        highlighting, :TSInstall/:TSUpdate/:TSList
  ts_indent.lua         indents.scm engine (used by Jai)
  project.lua           project root, vendored dirs every scanner skips
  clangd_setup.lua      :ClangdSetup
  ctags.lua             :Ctags, &tags and &path for C
  c_complete.lua        treesitter + ctags completion for C without an LSP
  c_indent.lua          C indent widths and the case-label indent fix
  format.lua            odinfmt, Prettier, Prettier indent options
  notes.lua dividers.lua comment_tags.lua perf.lua
lua/launch/             launch.json keys, output buffers, build errors
lua/hh/                 scope shading, project macro highlighting, picker dim
                        (set up by the colorscheme)
lsp/                    one file per language server
colors/ll.lua           the colorscheme
after/ ftdetect/ queries/ syntax/
```

## LSP

Servers are enabled in `lua/config/lsp.lua` and configured in `lsp/`. The
builtin commands cover the rest: `:checkhealth vim.lsp`,
`:lsp restart|stop|enable [name]`, `:log lsp`.

Diagnostics are received but never drawn: `<leader>vd`, `<leader>qf` and
`<leader>qq` still show them, and `:lua vim.diagnostic.enable()` turns them on.

## C / C++

These are unity builds.

**clangd is opt-in.** It only attaches where `:ClangdSetup` has written a
`.clangd`: each unity TU's includes become an `-include` chain, scoped to the
directories that TU covers. It also writes a flagless
`compile_commands.json`, because clangd's background indexer only takes its
file list from one. A database a build system writes is kept. Gitignore
`.cache/clangd/` and `compile_commands.json`. Run `:ClangdSetup!` again after
adding a module directory. Include roots outside the project go in
`<root>/.clangd-include-dirs`, one per line.

**Without clangd**, `:Ctags` builds a per-project tags file under
`~/.cache/nvim/tags/`. `gd` is a tag jump, and `<Tab>` completes identifiers
ranked local, file, open buffers, project, plus struct members after `.` and
`->`. Treesitter resolves the variable's type and the tags file supplies the
members.

Indent width is 2 unless the project is listed in `lua/config/c_indent.lua`
or has an `.editorconfig`.

## Formatting

Manual, with `<leader>f`. Odin goes through `odinfmt`, which picks up the
nearest `odinfmt.json` (`vim.g.odinfmt_on_save = true` formats on save). JS/TS
goes through the project's own Prettier, then eslint's fixAll. JS/TS buffers
also take `tabWidth`/`useTabs` from the project's Prettier config, overrides
included.

## launch.json

Per-project keys, bound while you are in the project. `:LaunchInit` writes a
starter.

```jsonc
{
  // JSONC: comments and trailing commas are fine.
  "<F1>": "./build.sh",
  "<F4>": { "cmd": "./build.sh && ./build/game", "out": "*run*" },
  "linux": { "<F1>": "./build_linux.sh" }  // mac/linux/windows override the entries above
}
```

`out` names the output buffer (default `*compilation*`): one buffer per name,
one job per buffer. Starting a command stops whatever was writing there.
Output is a plain buffer fed from a PTY, so it can be searched and yanked.
When a command exits, its error locations become the quickfix list and are
marked in the files. `<M-n>` steps through them, and `<CR>` on an output line
jumps to it. One errorformat covers Jai, clang, gcc, zig, MSVC, Odin, Rust,
CMake and ESLint.

With no `launch.json`, `<leader>b` runs `:Make`, the build command detected
from the project's files (`lua/launch/make.lua`).
