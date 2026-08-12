# ai-anno for VS Code

Renders the line-anchored annotations in a gitignored `.anno.json` next to the
code they describe — the VS Code counterpart to the Neovim renderer.

Zero dependencies, zero build step. Plain CommonJS that the extension host
loads directly. The whole design: **find `.anno.json`, render its annotations
inline.**

## What it shows

| Surface | What it gives you |
|---|---|
| **Gutter bar** | A colored bar on every line the annotation covers, one color per kind. |
| **End-of-line text** | `why · HS256 over RS256 because we own both ends…` after the anchored line. |
| **Hover** | The complete markdown message with kind and provenance. |
| **Overview ruler** | Marks in the scrollbar so you can see annotation density at a glance. |

### One honest limitation

VS Code has no virtual-lines API. Unlike the Neovim renderer, it **cannot** show
a multi-line message as inline text below the code — extension decorations are
strictly single-line. So the inline surface is a one-line summary capped at
120 characters, and the full markdown lives in the hover (instant, no click).

### Drift handling

Annotations re-anchor on every render:

1. Snippet matches at the stored line → render there.
2. Otherwise find the closest trimmed snippet match anywhere in the file →
   render there, and the hover notes `re-anchored from line N`.
3. No match at all → the annotation is **stale**: dimmed, marked `[stale]`,
   shown at the clamped stored line. Never silently dropped.

### In the diff editor

The working-tree side of a git diff is an ordinary `file:` document, so gutter
bars, end-of-line text, and hovers all appear there — which is where
annotations are most useful. The read-only side (`git:` and friends) never
renders: annotations describe the code as it is now, so repeating them on the
"before" text is noise.

## Install

The extension is plain JS, so "install" is just getting the folder into the
extensions directory. Symlink it so edits here take effect on the next reload.

```sh
# VS Code
ln -s ~/.config/nvim/vscode-anno ~/.vscode/extensions/ai-anno

# Cursor (same API, same extension)
ln -s ~/.config/nvim/vscode-anno ~/.cursor/extensions/ai-anno
```

Then reload: **Cmd+Shift+P → Developer: Reload Window**. To confirm it loaded,
open the Output panel and pick `ai-anno` — it prints `ai-anno activated.`

### Alternative: a real `.vsix`

```sh
cd ~/.config/nvim/vscode-anno
npx @vscode/vsce package          # produces ai-anno-0.1.0.vsix
code --install-extension ai-anno-0.1.0.vsix
```

## Test it locally

**1. The logic suite** — no editor needed. Runs the real `store.js` /
`render.js` / `extension.js` against a stubbed `vscode` module:

```sh
cd ~/.config/nvim/vscode-anno
node test/run.js        # or: npm test
```

It covers parsing, upward `.anno.json` discovery, all six re-anchoring cases,
malformed-input tolerance, the mtime cache, rendering, truncation, hover
contents, and that every command declared in `package.json` is actually
registered.

**2. The extension host** — open this folder in VS Code and press **F5**. That
launches a second window with the extension loaded and `example/` open. Open
`example/src/auth.ts`: six annotations, one per kind, deliberately including

- `b21d84` — stored at line 20 but its snippet lives at 23, so you should see it
  render at 23 and the hover say `re-anchored from line 20`.
- `9db3c6` — a snippet that doesn't exist, so it must appear dimmed and
  `[stale]` at the end of the file.

If those two behave, re-anchoring and stale handling both work.

**3. Against your real annotations** — open any repo that has a `.anno.json`.
Edit a line above an annotation and watch it follow the code; delete its anchor
line and watch it go `[stale]`; have Claude append an entry and watch it appear
without a reload (the file watcher picks it up, and a window refocus re-reads
annotation files that live outside the workspace).

## Commands

All under the `ai-anno:` prefix in the command palette.

| Command | Purpose |
|---|---|
| Toggle Annotations | Show/hide everything (writes the one setting, `aiAnno.enabled`). |
| Reload Annotations | Drop caches and rescan. |
| Go to Next / Previous Annotation | Jump between anchors in the current file. |
| List All Annotations | Searchable quick pick across the workspace; picking one jumps to it. |

No default keybindings, to avoid stomping on yours. To bind next/previous:

```json
{ "key": "alt+]", "command": "aiAnno.next", "when": "editorTextFocus" },
{ "key": "alt+[", "command": "aiAnno.prev", "when": "editorTextFocus" }
```

Kind colors are themeable: override `aiAnno.why`, `aiAnno.explain`,
`aiAnno.warning`, `aiAnno.review`, `aiAnno.todo`, and `aiAnno.stale` in
`workbench.colorCustomizations`.

## How discovery works

`.anno.json` is gitignored by design, and `workspace.findFiles` honors ignore
files — so search-based discovery would find nothing. Discovery is therefore a
bounded directory walk (3 levels below each workspace folder, skipping
`node_modules`, `dist`, `.git`, and friends), plus an upward walk from each
open file, which also covers files opened outside any workspace folder.
