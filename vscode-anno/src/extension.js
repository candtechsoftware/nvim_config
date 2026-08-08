'use strict';

const fs = require('fs');
const path = require('path');
const vscode = require('vscode');

const { AnnoStore, ANNO_FILE, normalize } = require('./store');
const { Renderer, buildDetail, detailUri, KIND_ICON, truncate } = require('./render');
const { AnnoTreeProvider, resolveAgainstSource } = require('./tree');

const MODES = ['both', 'eol', 'codelens', 'gutter'];

function activate(context) {
    const output = vscode.window.createOutputChannel('ai-anno');
    const store = new AnnoStore(output);
    const renderer = new Renderer(store, path.join(context.extensionPath, 'media'));
    const tree = new AnnoTreeProvider(store, renderer);

    context.subscriptions.push(output, renderer, tree);

    const treeView = vscode.window.createTreeView('aiAnno.tree', {
        treeDataProvider: tree,
        showCollapseAll: true,
    });
    context.subscriptions.push(treeView);

    const statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusBar.command = 'aiAnno.list';
    context.subscriptions.push(statusBar);

    // ---------------------------------------------------------------- helpers

    const refreshEverything = () => {
        renderer.refreshAll();
        tree.refresh();
        updateStatusBar();
        updateBadge();
    };

    const reload = () => {
        store.reset();
        refreshEverything();
    };

    function updateStatusBar() {
        const cfg = renderer.config();
        const editor = vscode.window.activeTextEditor;
        if (!cfg.statusBar || !editor || editor.document.uri.scheme !== 'file') {
            statusBar.hide();
            return;
        }

        const { items } = renderer.visible(editor.document);
        if (!items.length) {
            statusBar.hide();
            return;
        }

        const counts = new Map();
        let stale = 0;
        for (const anno of items) {
            counts.set(anno.kind, (counts.get(anno.kind) || 0) + 1);
            if (anno.stale) stale += 1;
        }

        statusBar.text = `$(comment-discussion) ${items.length}${stale ? ` $(warning) ${stale}` : ''}`;
        statusBar.tooltip = [...counts.entries()].map(([kind, n]) => `${n} ${kind}`).join(' · ')
            + (stale ? `\n${stale} stale` : '')
            + '\n\nClick to list all annotations.';
        statusBar.show();
    }

    function updateBadge() {
        const total = store.all(renderer.config().scanDepth).length;
        treeView.badge = total ? { value: total, tooltip: `${total} annotation${total === 1 ? '' : 's'}` } : undefined;
    }

    function resolveArg(arg) {
        if (arg && arg.annoPath && arg.id) return store.byId(arg.annoPath, arg.id);
        if (arg && arg.anno) return arg.anno;

        const editor = vscode.window.activeTextEditor;
        if (!editor) return null;
        const items = renderer.visible(editor.document).items;
        if (!items.length) return null;
        const cursor = editor.selection.active.line;
        return items.find((a) => cursor >= a.start && cursor <= a.end)
            || items.reduce((best, a) => (
                Math.abs(a.start - cursor) < Math.abs(best.start - cursor) ? a : best
            ), items[0]);
    }

    async function reveal(target) {
        const doc = await vscode.workspace.openTextDocument(vscode.Uri.file(target.absPath));
        const editor = await vscode.window.showTextDocument(doc, { preserveFocus: false });
        const line = Math.min(target.line, Math.max(0, doc.lineCount - 1));
        const end = Math.min(target.end === undefined ? line : target.end, Math.max(0, doc.lineCount - 1));
        editor.selection = new vscode.Selection(line, 0, line, 0);
        editor.revealRange(new vscode.Range(line, 0, end, 0), vscode.TextEditorRevealType.InCenterIfOutsideViewport);
        renderer.refresh(editor);
    }

    function jump(direction) {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;
        const items = renderer.visible(editor.document).items;
        if (!items.length) {
            vscode.window.setStatusBarMessage('$(info) ai-anno: no annotations in this file', 2500);
            return;
        }
        const cursor = editor.selection.active.line;
        const ordered = [...items].sort((a, b) => a.start - b.start);
        const next = direction > 0
            ? ordered.find((a) => a.start > cursor) || ordered[0]
            : [...ordered].reverse().find((a) => a.start < cursor) || ordered[ordered.length - 1];
        editor.selection = new vscode.Selection(next.start, 0, next.start, 0);
        editor.revealRange(
            new vscode.Range(next.start, 0, next.end, 0),
            vscode.TextEditorRevealType.InCenterIfOutsideViewport,
        );
        vscode.window.setStatusBarMessage(`$(${KIND_ICON[next.kind] || 'comment'}) ${next.kind}: ${truncate(next.summary, 80)}`, 4000);
    }

    // ------------------------------------------------------- detail documents

    const detailProvider = {
        provideTextDocumentContent(uri) {
            let ref;
            try {
                ref = JSON.parse(uri.query);
            } catch (err) {
                return `# ai-anno\n\nUnreadable annotation reference.\n`;
            }
            const anno = store.byId(ref.annoPath, ref.id);
            if (!anno) return `# ai-anno\n\nAnnotation \`${ref.id}\` is no longer in \`${ref.annoPath}\`.\n`;
            return buildDetail(resolveAgainstSource(anno));
        },
    };
    context.subscriptions.push(
        vscode.workspace.registerTextDocumentContentProvider('anno', detailProvider),
    );

    // -------------------------------------------------------------- providers

    context.subscriptions.push(
        vscode.languages.registerCodeLensProvider({ language: '*' }, {
            onDidChangeCodeLenses: renderer.codeLensChanged.event,
            provideCodeLenses: (document) => renderer.provideCodeLenses(document),
        }),
    );

    // --------------------------------------------------------------- commands

    const register = (id, handler) => {
        context.subscriptions.push(vscode.commands.registerCommand(id, handler));
    };

    register('aiAnno.reload', () => {
        reload();
        vscode.window.setStatusBarMessage('$(check) ai-anno: reloaded', 2000);
    });

    register('aiAnno.showOutput', () => output.show(true));

    register('aiAnno.toggle', async () => {
        const cfg = vscode.workspace.getConfiguration('aiAnno');
        const next = !cfg.get('enabled', true);
        await cfg.update('enabled', next, vscode.ConfigurationTarget.Global);
        vscode.window.setStatusBarMessage(`$(eye) ai-anno: ${next ? 'on' : 'off'}`, 2000);
    });

    register('aiAnno.cycleMode', async () => {
        const cfg = vscode.workspace.getConfiguration('aiAnno');
        const current = cfg.get('displayMode', 'both');
        const next = MODES[(MODES.indexOf(current) + 1) % MODES.length];
        await cfg.update('displayMode', next, vscode.ConfigurationTarget.Global);
        vscode.window.setStatusBarMessage(`$(list-selection) ai-anno mode: ${next}`, 2000);
    });

    register('aiAnno.next', () => jump(1));
    register('aiAnno.prev', () => jump(-1));

    register('aiAnno.reveal', (target) => reveal(target));

    register('aiAnno.show', async (arg) => {
        const anno = resolveArg(arg);
        if (!anno) {
            vscode.window.showInformationMessage('ai-anno: no annotation at the cursor.');
            return;
        }
        const uri = detailUri(anno);
        try {
            await vscode.commands.executeCommand('markdown.showPreviewToSide', uri);
        } catch (err) {
            const doc = await vscode.workspace.openTextDocument(uri);
            await vscode.window.showTextDocument(doc, { preview: true, viewColumn: vscode.ViewColumn.Beside });
        }
    });

    register('aiAnno.copy', async (arg) => {
        const anno = resolveArg(arg);
        if (!anno) {
            vscode.window.showInformationMessage('ai-anno: no annotation at the cursor.');
            return;
        }
        await vscode.env.clipboard.writeText(anno.message);
        vscode.window.setStatusBarMessage('$(clippy) ai-anno: message copied', 2000);
    });

    register('aiAnno.openFile', async (arg) => {
        const anno = resolveArg(arg);
        let target = anno && anno.annoPath;

        if (!target) {
            const dirs = store.discover(renderer.config().scanDepth);
            if (!dirs.length) {
                vscode.window.showInformationMessage(`ai-anno: no ${ANNO_FILE} found.`);
                return;
            }
            if (dirs.length === 1) {
                target = path.join(dirs[0], ANNO_FILE);
            } else {
                const pick = await vscode.window.showQuickPick(
                    dirs.map((dir) => ({ label: path.basename(dir), description: dir, dir })),
                    { title: `Which ${ANNO_FILE}?` },
                );
                if (!pick) return;
                target = path.join(pick.dir, ANNO_FILE);
            }
        }

        const doc = await vscode.workspace.openTextDocument(vscode.Uri.file(target));
        await vscode.window.showTextDocument(doc);
    });

    register('aiAnno.createFile', async () => {
        const folders = vscode.workspace.workspaceFolders || [];
        if (!folders.length) {
            vscode.window.showWarningMessage('ai-anno: open a folder first.');
            return;
        }
        let root = folders[0].uri.fsPath;
        if (folders.length > 1) {
            const pick = await vscode.window.showQuickPick(
                folders.map((f) => ({ label: f.name, description: f.uri.fsPath, fsPath: f.uri.fsPath })),
                { title: `Create ${ANNO_FILE} in which folder?` },
            );
            if (!pick) return;
            root = pick.fsPath;
        }

        const target = path.join(root, ANNO_FILE);
        if (!fs.existsSync(target)) {
            fs.writeFileSync(target, `${JSON.stringify({ version: 1, annotations: [] }, null, 2)}\n`, 'utf8');
        }
        reload();
        const doc = await vscode.workspace.openTextDocument(vscode.Uri.file(target));
        await vscode.window.showTextDocument(doc);
    });

    register('aiAnno.delete', async (arg) => {
        const anno = resolveArg(arg);
        if (!anno) {
            vscode.window.showInformationMessage('ai-anno: no annotation at the cursor.');
            return;
        }
        const choice = await vscode.window.showWarningMessage(
            `Delete this annotation from ${ANNO_FILE}?`,
            { modal: true, detail: `${anno.kind} · ${anno.file}:${anno.line}\n\n${anno.summary}` },
            'Delete',
        );
        if (choice !== 'Delete') return;

        try {
            const removed = store.remove(anno.annoPath, anno.id);
            if (!removed) {
                vscode.window.showWarningMessage(`ai-anno: ${anno.id} was not found in ${anno.annoPath}.`);
            }
        } catch (err) {
            vscode.window.showErrorMessage(`ai-anno: could not update ${anno.annoPath} — ${err.message}`);
            return;
        }
        refreshEverything();
    });

    register('aiAnno.list', async () => {
        const cfg = renderer.config();
        const all = store.all(cfg.scanDepth).filter((anno) => cfg.kinds.includes(anno.kind));
        if (!all.length) {
            vscode.window.showInformationMessage(`ai-anno: no annotations found. Scanned ${cfg.scanDepth} levels deep.`);
            return;
        }

        const active = vscode.window.activeTextEditor;
        const activePath = active && active.document.uri.scheme === 'file'
            ? normalize(active.document.uri.fsPath)
            : null;

        const picks = all
            .map((raw) => resolveAgainstSource(raw))
            .sort((a, b) => {
                const aActive = activePath && normalize(a.absPath) === activePath ? 0 : 1;
                const bActive = activePath && normalize(b.absPath) === activePath ? 0 : 1;
                if (aActive !== bActive) return aActive - bActive;
                const byFile = a.file.localeCompare(b.file);
                return byFile !== 0 ? byFile : a.start - b.start;
            })
            .map((anno) => ({
                label: `$(${anno.stale || anno.missing ? 'circle-slash' : (KIND_ICON[anno.kind] || 'comment')}) ${anno.summary}`,
                description: `${anno.kind}${anno.stale ? ' · stale' : ''}${anno.missing ? ' · missing file' : ''}`,
                detail: `${anno.file}:${anno.start + 1}`,
                anno,
            }));

        const pick = await vscode.window.showQuickPick(picks, {
            title: `${picks.length} annotation${picks.length === 1 ? '' : 's'}`,
            matchOnDescription: true,
            matchOnDetail: true,
            placeHolder: 'Filter by summary, kind, or path',
        });
        if (!pick || pick.anno.missing) return;
        await reveal({ absPath: pick.anno.absPath, line: pick.anno.start, end: pick.anno.end });
    });

    // ----------------------------------------------------------------- events

    const watchers = [];
    const setupWatchers = () => {
        while (watchers.length) watchers.pop().dispose();
        for (const folder of vscode.workspace.workspaceFolders || []) {
            const watcher = vscode.workspace.createFileSystemWatcher(
                new vscode.RelativePattern(folder, `**/${ANNO_FILE}`),
            );
            const onChange = (uri) => {
                store.invalidate(uri.fsPath);
                refreshEverything();
            };
            watcher.onDidCreate(onChange);
            watcher.onDidChange(onChange);
            watcher.onDidDelete(onChange);
            watchers.push(watcher);
            context.subscriptions.push(watcher);
        }
    };
    setupWatchers();

    context.subscriptions.push(
        vscode.window.onDidChangeActiveTextEditor((editor) => {
            if (editor) renderer.refresh(editor);
            updateStatusBar();
        }),
        vscode.window.onDidChangeVisibleTextEditors(() => refreshEverything()),
        vscode.window.onDidChangeTextEditorSelection(() => updateStatusBar()),
        vscode.workspace.onDidChangeTextDocument((event) => {
            for (const editor of vscode.window.visibleTextEditors) {
                if (editor.document === event.document) renderer.refresh(editor);
            }
        }),
        vscode.workspace.onDidSaveTextDocument(() => {
            tree.refresh();
            updateStatusBar();
        }),
        vscode.workspace.onDidChangeWorkspaceFolders(() => {
            setupWatchers();
            reload();
        }),
        vscode.workspace.onDidChangeConfiguration((event) => {
            if (event.affectsConfiguration('aiAnno')) refreshEverything();
        }),
        vscode.window.onDidChangeWindowState((state) => {
            if (state.focused) reload();
        }),
    );

    refreshEverything();
    output.appendLine('ai-anno activated.');
}

function deactivate() { }

module.exports = { activate, deactivate };
