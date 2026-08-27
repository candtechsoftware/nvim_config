# Keymaps Reference

Leader: `<Space>`

## General (keymaps.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pv` | n | Open netrw |
| `J` / `K` | v | Move lines down/up |
| `J` | n | Join lines (cursor stays) |
| `<C-d>` / `<C-u>` | n | Half-page down/up (centered) |
| `n` / `N` | n | Search next/prev (centered) |
| `<leader>p` | x | Paste without yanking |
| `<leader>d` | n,v | Delete to black hole register |
| `<C-,>` | n | Cycle splits |
| `<C-.>` | n | Swap to alternate buffer |
| `<leader>t` | n | New tab |
| `<leader><Tab>` | n | Next tab |
| `<leader>tc` | n | Close tab |
| `<leader>s` | n | Search and replace word under cursor |
| `<leader><leader>` | n | Source current file |
| `]c` / `[c` | n | Next/prev comment |

## Quickfix & Location List

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<C-k>` / `<C-j>` | n | Next/prev quickfix (centered) | keymaps.lua |
| `<leader>k` / `<leader>j` | n | Next/prev loclist (centered) | keymaps.lua |
| `]q` / `[q` | n | Next/prev quickfix | make_detect.lua |
| `]Q` / `[Q` | n | Last/first quickfix | make_detect.lua |
| `<leader>qo` / `<leader>qc` | n | Open/close quickfix | make_detect.lua |
| `<leader>qf` | n | Diagnostics to quickfix | lsp.lua |
| `<leader>qq` | n | Diagnostics to loclist | lsp.lua |

## LSP (lsp.lua)

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition (LSP; falls back to the workspace index by name when clangd only sees an implicit declaration; ctags when no LSP) |
| `gD` | n | Go to declaration |
| `gv` | n | Go to definition in vsplit |
| `<leader>gi` | n | Jump via ctags |
| `<leader>vws` | n | Workspace symbols (LSP or ctags) |
| `<leader>vd` | n | Diagnostic float |
| `<leader>vi` | n | Incoming calls |
| `<leader>f` | n | Format (odinfmt for .odin; Prettier then eslint `source.fixAll` for TS/JS; no-op otherwise) |

### Built-in 0.12 Defaults (no config needed)

| Key | Mode | Action |
|-----|------|--------|
| `grn` | n | Rename symbol |
| `grr` | n | References |
| `gra` | n | Code action |
| `grt` | n | Type definition |
| `gO` | n | Document symbols |
| `K` | n | Hover |
| `<C-s>` | i | Signature help |

## Telescope (telescope.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files |
| `<leader>fb` | n | Buffers (most-recent first) |
| `<leader>fo` | n | Recent files, this project |
| `<leader>/` | n | Live grep (use `**glob` to filter files) |
| `<leader>.` | n | Live grep (current dir) |
| `<leader>pws` | n | Grep word under cursor |
| `<leader>pWs` | n | Grep WORD under cursor |
| `<leader>ps` | v | Grep selection |
| `<leader>fg` | n | Grep with `--- *.ext` filter |
| `<leader>gf` | n | Git files |
| `<leader>gc` | n | Git commits |
| `<leader>gb` | n | Git branches |
| `<leader>gs` | n | Git status |
| `<leader>ds` | n | Document symbols |
| `<leader>ws` | n | Workspace symbols |
| `<leader>js` | n | Jai module symbols |
| `<leader>jg` | n | Grep Jai modules |

### Telescope Picker Keys

| Key | Mode | Action |
|-----|------|--------|
| `<C-j>` / `<C-k>` | i,n | Next/prev selection |
| `<C-q>` | i,n | Send to quickfix |
| `<Esc>` / `q` | i/n | Close |

## Build & run (launch/)

Targets come from `<root>/launch.json` — see the README for the schema, or run
`:LaunchInit` to drop a commented starter file into the current project.

A count picks the target: `<leader>b` builds target 1, `2<leader>b` builds
target 2. (Counts rather than `<leader>b1`/`<leader>b2`, so a bare `<leader>b`
fires immediately instead of waiting out `timeoutlen` to see if a digit is
coming.)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>b` | n | Build target 1 (quickfix + inline diagnostics) |
| `N<leader>b` | n | Build target N |
| `<leader>r` | n | Run target 1 (streaming terminal pane) |
| `N<leader>r` | n | Run target N |
| `<leader>o` | n | Toggle the output pane (job keeps running) |
| `<leader>x` | n | Stop running jobs |
| `<leader>ft` | n | Pick a target |
| `q` | n | *(in the output pane)* hide the pane, leave the job running |
| `<C-c>` | n | *(in the output pane)* stop this job |

With no `launch.json`, `<leader>b` falls back to the makeprg detected by
`utils/make_detect.lua`, so it still builds any Makefile/Cargo/zig project.

| Command | Action |
|---|---|
| `:Launch [name\|index]` | Run a target |
| `:LaunchStop [name]` | Stop one job, or all |
| `:LaunchList` | Targets + running state |
| `:LaunchQF` | Push the output pane through `errorformat` into quickfix |
| `:LaunchInit` | Write a starter `launch.json` |
| `:LaunchReload` | Re-read `launch.json` after editing it |
| `:Make [args]` | Async build via the detected makeprg |

## Clipboard (clipboard.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ca` / `<leader>cA` | n,v | Paste from register 'a' |
| `<leader>ch` | n | Clipboard history |
| `<leader>cc` | n | Clear history |

## Notes (notes/init.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>n` | n | Open notes directory |
| `<leader>ns` | n | Search notes |
| `<leader>nf` | n | Find notes by filename |
| `<leader>nn` | n | New note |
| `<leader>ng` | n | Notes git status |

## Section Comments (divider_comments.lua)

| Key | Mode | Action |
|-----|------|--------|
| `]s` / `[s` | n | Next/prev section comment |
| `<leader>ss` | n | Search sections (Telescope) |

## Treesitter Debug (treesitter.lua)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ts` | n | Debug treesitter info |
| `<leader>hh` | n | Show captures at cursor |
| `<leader>hi` | n | Inspect highlight groups |
