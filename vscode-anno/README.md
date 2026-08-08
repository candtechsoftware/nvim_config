# ai-anno for VS Code

Renders the line-anchored annotations in a gitignored `.anno.json` next to the
code they describe — the VS Code counterpart to the Neovim renderer.

Zero dependencies, zero build step. Plain CommonJS that the extension host
loads directly.

## What it shows

| Surface | What it gives you |
|---|---|
| **Gutter bar** | A colored bar on every line the annotation covers, one color per kind. |
| **End-of-line text** | `why · HS256 over RS256 because we own both ends…` after the anchored line. |
| **Hover** | The complete markdown message, provenance, and actions (Detail / Copy / open `.anno.json` / Delete). |
| **CodeLens** | A clickable summary line above the anchor. |
| **Detail view** | Full message rendered as a markdown preview beside the code. |
| **Sidebar tree** | Every annotation in the workspace, grouped by file, with a count badge. |
| **Overview ruler** | Marks in the scrollbar so you can see annotation density at a glance. |
| **Status bar** | Annotation count for the active file; click to search them all. |
| **Problems panel** | Optional — set `aiAnno.diagnostics` to `true`. |

### One honest limitation

VS Code has no virtual-lines API. Unlike the Neovim renderer, it **cannot** show
a multi-line message as inline text below the code — extension decorations are
strictly single-line. So the inline surface is a one-line summary, and the full
markdown lives in the hover (instant, no click) and the detail view. Set
`aiAnno.eolContent` to `"message"` if you'd rather see the whole message
inline with newlines collapsed to `·`.

### Drift handling

Annotations re-anchor on every render, per `spec/SPEC.md`:

1. Snippet matches at the stored line → render there.
2. Otherwise find the closest trimmed snippet match anywhere in the file →
   render there, and the hover notes `re-anchored from line N`.
3. No match at all → the annotation is **stale**: dimmed, marked `[stale]`,
   shown at the clamped stored line. Never silently dropped.

This is load-bearing, not theoretical: across the 94 annotations currently in
`~/work/percipio-repo/*`, 52 matched exactly, **26 needed re-anchoring**, and
2 were stale.

## In the diff editor

Annotations render in diffs, which is where they're most useful — the whole
point of an annotation is to tell a reviewer something while they read a change.

- **The working-tree side always renders.** In a git diff that side is an
  ordinary `file:` document, so gutter bars, end-of-line text, and hovers all
  appear with no extra setting.
- **The read-only side is opt-in** via `aiAnno.diffOriginalSide` (default
  `false`). It's off by default because annotations describe the code as it is
  now, so repeating them on the "before" text is usually noise.
- **When it is on, annotations re-anchor against the older text.** A note about
  a line the change introduced simply doesn't appear there — its snippet isn't
  in the old version. Notes on unchanged code appear at their old line numbers.
  Stale markers are suppressed on that side entirely, since "this line didn't
  exist yet" is true of every added line and tells you nothing.

This also covers files opened from git history, and commit-to-commit diffs
(where both sides are read-only versions).

**Two VS Code quirks worth knowing:**

1. **CodeLens is hidden in diff editors** unless you set
   `"diffEditor.codeLens": true`. That's VS Code's setting, not this
   extension's. Gutter marks, end-of-line text, and hovers are unaffected.
2. **Diagnostics are never published for a diff side**, even with
   `aiAnno.diagnostics` on — they're keyed by URI, so doing it would duplicate
   every entry in the Problems panel under a `git:` path.

## Install

The extension is plain JS, so "install" is just getting the folder into the
extensions directory. Symlink it so edits here take effect on the next reload.

```sh
# VS Code
ln -s ~/.config/nvim/vscode-anno ~/.vscode/extensions/ai-anno

# Cursor (same API, same extension)
ln -s ~/.config/nvim/vscode-anno ~/.cursor/extensions/ai-anno
```

Then reload: **Cmd+Shift+P → Developer: Reload Window**.

To confirm it loaded, open the Annotations icon in the activity bar, or run
**ai-anno: Show Log** from the palette — it prints `ai-anno activated.`

> Your `code` CLI isn't on `PATH`. If you want it (needed for the `.vsix` route
> below), run **Shell Command: Install 'code' command in PATH** from the
> palette.

### Alternative: a real `.vsix`

```sh
cd ~/.config/nvim/vscode-anno
npx @vscode/vsce package          # produces ai-anno-0.1.0.vsix
code --install-extension ai-anno-0.1.0.vsix
```

## Test it locally

**1. The logic suite** — 108 checks, no editor needed. Runs the real
`store.js` / `render.js` / `tree.js` / `extension.js` against a stubbed
`vscode` module:

```sh
cd ~/.config/nvim/vscode-anno
node test/run.js        # or: npm test
```

It covers parsing, upward `.anno.json` discovery, all six re-anchoring cases,
malformed-input tolerance, the mtime cache, deletion rewrites, every display
mode, truncation, diagnostics, hover/detail contents, the tree, and that every
command declared in `package.json` is actually registered.

**2. The extension host** — open this folder in VS Code and press **F5**. That
launches a second window with the extension loaded and `example/` open. Open
`example/src/auth.ts`: six annotations, one per kind, deliberately including

- `b21d84` — stored at line 20 but its snippet lives at 23, so you should see it
  render at 23 and the hover say `re-anchored from line 20`.
- `9db3c6` — a snippet that doesn't exist, so it must appear dimmed and
  `[stale]` at the end of the file.

If those two behave, re-anchoring and stale handling both work.

**3. Against your real annotations** — open any repo that has a `.anno.json`:

```sh
ls ~/work/percipio-repo/*/.anno.json
```

Things worth poking at: edit a line above an annotation and watch it follow the
code; delete its anchor line and watch it go `[stale]`; have Claude append an
entry and watch it appear without a reload (the file watcher picks it up, and a
window refocus re-reads annotation files that live outside the workspace).

## Commands

All under the `ai-anno:` prefix in the command palette.

| Command | Purpose |
|---|---|
| Toggle Annotations | Show/hide everything. |
| Cycle Display Mode | `both` → `eol` → `codelens` → `gutter`. |
| Go to Next / Previous Annotation | Jump between anchors in the current file. |
| Show Annotation Detail | Full markdown beside the code. |
| List All Annotations | Searchable quick pick across the workspace. |
| Copy Message | Message body to the clipboard. |
| Delete Annotation | Remove one entry from `.anno.json` (confirms first). |
| Open / Create `.anno.json` | Edit the annotation file directly. |
| Show Log | Parse errors and skipped entries. |

No default keybindings, to avoid stomping on yours. To bind next/previous:

```json
{ "key": "alt+]", "command": "aiAnno.next", "when": "editorTextFocus" },
{ "key": "alt+[", "command": "aiAnno.prev", "when": "editorTextFocus" }
```

## Settings

| Setting | Default | Meaning |
|---|---|---|
| `aiAnno.enabled` | `true` | Master switch. |
| `aiAnno.displayMode` | `both` | `eol` · `codelens` · `both` · `gutter`. |
| `aiAnno.eolContent` | `summary` | `summary` (first line) or `message` (all of it, flattened). |
| `aiAnno.eolMaxLength` | `120` | Truncation cap; `0` disables. |
| `aiAnno.kinds` | all five | Which kinds to render. |
| `aiAnno.showStale` | `true` | Show unmatched annotations dimmed. |
| `aiAnno.diffOriginalSide` | `false` | Also render on the read-only side of a diff. |
| `aiAnno.diagnostics` | `false` | Also publish to the Problems panel. |
| `aiAnno.statusBar` | `true` | Count for the active file. |
| `aiAnno.scanDepth` | `3` | Levels below each workspace folder to scan for `.anno.json`. |

Kind colors are themeable: override `aiAnno.why`, `aiAnno.explain`,
`aiAnno.warning`, `aiAnno.review`, `aiAnno.todo`, and `aiAnno.stale` in
`workbench.colorCustomizations`.

### Why `scanDepth` instead of workspace search

`.anno.json` is gitignored by design, and `workspace.findFiles` honors ignore
files — so search-based discovery would find nothing. Discovery is therefore a
bounded directory walk (skipping `node_modules`, `dist`, `.git`, and friends),
plus an upward walk from each open file, which also covers files opened outside
any workspace folder.
