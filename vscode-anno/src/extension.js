'use strict';

const path = require('path');
const vscode = require('vscode');

const { AnnoStore, ANNO_FILE, normalize, resolveAgainstSource } = require('./store');
const { Renderer, KIND_ICON, truncate } = require('./render');

function activate(context) {
    const output = vscode.window.createOutputChannel('ai-anno');
    const store = new AnnoStore(output);
    const renderer = new Renderer(store, path.join(context.extensionPath, 'media'));

    context.subscriptions.push(output, renderer);

    const reload = () => {
        store.reset();
        renderer.refreshAll();
    };

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
        const items = renderer.visible(editor.document);
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

    // --------------------------------------------------------------- commands

    const register = (id, handler) => {
        context.subscriptions.push(vscode.commands.registerCommand(id, handler));
    };

    register('aiAnno.reload', () => {
        reload();
        vscode.window.setStatusBarMessage('$(check) ai-anno: reloaded', 2000);
    });

    register('aiAnno.toggle', async () => {
        const cfg = vscode.workspace.getConfiguration('aiAnno');
        const next = !cfg.get('enabled', true);
        await cfg.update('enabled', next, vscode.ConfigurationTarget.Global);
        vscode.window.setStatusBarMessage(`$(eye) ai-anno: ${next ? 'on' : 'off'}`, 2000);
    });

    register('aiAnno.next', () => jump(1));
    register('aiAnno.prev', () => jump(-1));

    register('aiAnno.list', async () => {
        const all = store.all();
        if (!all.length) {
            vscode.window.showInformationMessage(`ai-anno: no ${ANNO_FILE} annotations found.`);
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
                renderer.refreshAll();
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
        }),
        vscode.window.onDidChangeVisibleTextEditors(() => renderer.refreshAll()),
        vscode.workspace.onDidChangeTextDocument((event) => {
            for (const editor of vscode.window.visibleTextEditors) {
                if (editor.document === event.document) renderer.refresh(editor);
            }
        }),
        vscode.workspace.onDidChangeWorkspaceFolders(() => {
            setupWatchers();
            reload();
        }),
        vscode.workspace.onDidChangeConfiguration((event) => {
            if (event.affectsConfiguration('aiAnno')) renderer.refreshAll();
        }),
        // Annotation files are usually edited by an agent outside the editor;
        // a refocus re-reads them even when they live outside the workspace.
        vscode.window.onDidChangeWindowState((state) => {
            if (state.focused) reload();
        }),
    );

    renderer.refreshAll();
    output.appendLine('ai-anno activated.');
}

function deactivate() { }

module.exports = { activate, deactivate };
