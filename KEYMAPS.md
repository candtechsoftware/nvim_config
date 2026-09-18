# Keymaps

Leader is `<Space>`. Built-in Neovim defaults are listed where the config relies on them.

## Editing (config/keymaps.lua)

| Key | Mode | Action |
|---|---|---|
| `<leader>pv` | n | Directory browser at the current file's dir |
| `J` / `K` | v | Move lines down/up |
| `J` | n | Join lines, cursor stays |
| `<C-d>` / `<C-u>` | n | Half page down/up, centered |
| `n` / `N` | n | Next/prev match, centered |
| `<Esc>` | n | Clear search highlight |
| `<leader>p` | x | Paste without yanking |
| `<leader>d` | n,v | Delete without yanking |
| `<leader>s` | n | Substitute the word under the cursor |
| `<leader>f` | n | Format: odinfmt for Odin, Prettier then eslint fixAll for JS/TS |
| `<leader>u` | n | Undotree (builtin `nvim.undotree`) |
| `<leader>ih` | n | Toggle inlay hints |
| `<leader><leader>` | n | Source the current file |
| `]c` / `[c` | n | Next/prev comment line |
| `<C-,>` | n | Cycle splits |
| `<C-.>` | n | Alternate buffer |
| `<leader>t` / `<leader><Tab>` / `<leader>tc` | n | New / next / close tab |

## Completion

Nothing opens the popup on its own. `<Tab>` does.

| Key | Mode | Action |
|---|---|---|
| `<Tab>` | i | LSP completion; without an LSP: omni after `.` `->` `::`, the C completefunc, else keyword |
| `<Tab>` / `<S-Tab>` | i | Next/prev item while the popup is open |
| `<CR>` | i | Accept the selected item, else newline |
| `<C-]>` | i | Tag completion |
| `<C-s>` | i | Signature help (builtin); also shown on `(` and `,` |

## Multicursor (builtin, `:h multicursor`)

Follow-mode replays motions and Visual sequences at every cursor. `Q` and
`[count]Q` leave it off, so `diw` cascades but `viwd` does not.

| Key | Mode | Action |
|---|---|---|
| `<leader>Q` | n | Cursor on every search match, follow-mode on |
| `Q` | n | Toggle a cursor here |
| `[count]Q` | n | Cursor at every match of the last search |
| `Q` | v | Cursor on each selected line, follow-mode on |
| `q=` | n | Toggle follow-mode |
| `<C-l>` / `gQ` | n | Clear / restore cursors |
| `]C` / `[C` | n | Next/prev cursor |

## Finding things (config/pickers.lua)

fff handles files and grep. The rest are native: a command whose fuzzy
completion pops up as you type (cmdline autocompletion), or a quickfix or
location list.

| Key | Mode | Action |
|---|---|---|
| `<leader>ff` | n | Find files in the repo (fff) |
| `<leader>/` | n | Grep the repo (fff; `*.c`, `src/**` and `!dir/` filters work in the query) |
| `<leader>.` | n | Grep the cwd (fff) |
| `<leader>pws` | n,v | Grep the word under the cursor / the selection (fff) |
| `<leader>pWs` | n | Grep the WORD under the cursor (fff) |
| `<leader>fr` | n | Resume the last fff picker |
| `<leader>jg` / `<leader>js` | n | Grep Jai modules / by symbol kind (fff) |
| `<leader>fb` | n | Buffers, most recent first (`:b`) |
| `<leader>fo` | n | Recent files under the cwd (`:Recent`) |
| `<leader>pg` | n | Grep including gitignored files into quickfix (`:Grep`) |
| `<leader>ds` | n | Document symbols to the location list (LSP, else ctags on the file) |
| `<leader>ws` | n | Workspace symbols (LSP into quickfix, else `:tag` completion) |
| `<leader>gs` | n | Git status into quickfix |
| `<leader>gc` | n | Git log in a split; `<CR>` shows the commit, `q` closes |
| `<leader>gb` | n | Switch branch (`:Branch`) |
| `<leader>ss` | n | Section comments to the location list |
| `]s` / `[s` | n | Next/prev section comment |

Inside fff: `<C-j>`/`<C-k>` move, `<S-Tab>` cycles plain/regex/fuzzy grep, `<C-q>` sends to quickfix.
In a cmdline popup: `<Tab>` picks, `<Up>`/`<Down>` walk history.

## Quickfix and location list

| Key | Mode | Action |
|---|---|---|
| `<C-k>` / `<C-j>` | n | Next/prev quickfix item; the first press on a new list lands on item 1 |
| `<M-n>` / `<M-N>` | n | Same, 4coder's Alt-N (left Option as Alt) |
| `<leader>k` / `<leader>j` | n | Next/prev location list item |
| `<leader>qo` / `<leader>qc` | n | Open/close quickfix |
| `<leader>qf` / `<leader>qq` | n | Diagnostics to quickfix / location list |
| `<leader>vd` | n | Diagnostics for the line in a float |
| `]q` `[q` `]Q` `[Q` | n | Builtin quickfix stepping |

## LSP (config/lsp.lua)

| Key | Mode | Action |
|---|---|---|
| `gd` | n | Definition; asks the index by name when clangd answers with the call site. Without an LSP in C, a tag jump |
| `gv` | n | Definition in the other split |
| `gD` | n | Declaration |
| `<leader>vi` | n | Incoming calls |
| `K` | n | Hover (builtin) |
| `grn` `grr` `gra` `gri` `grt` `gO` | n | Rename, references, code action, implementation, type definition, document symbols (builtin) |

## Build and run (launch/)

| Key | Mode | Action |
|---|---|---|
| *launch.json keys* | n | Run that command into its output buffer |
| `<leader>b` | n | `:Make` with the detected build command, unless launch.json binds it |
| `<leader>o` | n | Toggle the output pane (the job keeps running) |
| `<leader>x` | n | Stop running jobs |
| `<leader>ft` | n | Pick a launch.json command |
| `<CR>` / `q` / `<C-c>` | n | In an output buffer: jump to the error / close the window / stop the job |

## Notes (config/notes.lua)

| Key | Mode | Action |
|---|---|---|
| `<leader>n` | n | Open ~/notes |
| `<leader>nn` | n | New note |
| `<leader>nf` / `<leader>ns` | n | Find notes by name / search their contents (fff) |
| `<leader>ng` | n | Notes git status |

## Directory browser (after/ftplugin/directory.lua)

| Key | Mode | Action |
|---|---|---|
| `<CR>` / `-` / `R` | n | Open, up, reload (builtin) |
| `%` | n | New file here (`:w` creates it) |
| `d` | n | New directory |
| `D` | n | Delete the entry (confirms) |
| `r` | n | Rename the entry |

## Treesitter

| Key | Mode | Action |
|---|---|---|
| `<leader>ts` | n | Show the buffer's parser |
| `<leader>hh` | n | Captures under the cursor |
| `<leader>hi` | n | `:Inspect` |
