'use strict';

const path = require('path');
const vscode = require('vscode');

const KIND_ICON = {
    why: 'lightbulb',
    explain: 'book',
    warning: 'warning',
    review: 'eye',
    todo: 'checklist',
};

function flatten(message) {
    return message.replace(/\s*\r?\n+\s*/g, ' · ').replace(/[ \t]+/g, ' ').trim();
}

function truncate(text, maxLength) {
    if (!maxLength || text.length <= maxLength) return text;
    return `${text.slice(0, Math.max(1, maxLength - 1)).trimEnd()}…`;
}

function detailUri(anno) {
    return vscode.Uri.from({
        scheme: 'anno',
        path: `/${anno.kind}-${anno.id.replace(/[^\w.-]/g, '_')}.md`,
        query: JSON.stringify({ annoPath: anno.annoPath, id: anno.id }),
    });
}

function buildHover(anno) {
    const md = new vscode.MarkdownString(undefined, true);
    md.isTrusted = true;
    md.supportHtml = false;

    const meta = [anno.author, anno.created ? anno.created.slice(0, 10) : ''].filter(Boolean).join(' · ');
    md.appendMarkdown(`$(${KIND_ICON[anno.kind] || 'comment'}) **${anno.kind}**`);
    if (meta) md.appendMarkdown(`  —  ${meta}`);
    if (anno.stale) md.appendMarkdown('  —  $(warning) **stale** (snippet no longer matches)');
    else if (anno.moved) md.appendMarkdown(`  —  re-anchored from line ${anno.line}`);
    md.appendMarkdown('\n\n');
    md.appendMarkdown(anno.message);
    md.appendMarkdown('\n\n');

    const args = encodeURIComponent(JSON.stringify([{ annoPath: anno.annoPath, id: anno.id }]));
    md.appendMarkdown([
        `[$(book) Detail](command:aiAnno.show?${args})`,
        `[$(clippy) Copy](command:aiAnno.copy?${args})`,
        `[$(json) .anno.json](command:aiAnno.openFile?${args})`,
        `[$(trash) Delete](command:aiAnno.delete?${args})`,
    ].join('  |  '));

    return md;
}

function buildDetail(anno) {
    const meta = [
        anno.author ? `**author** ${anno.author}` : '',
        anno.created ? `**created** ${anno.created}` : '',
        anno.commit ? `**commit** \`${anno.commit}\`` : '',
    ].filter(Boolean).join(' · ');

    const range = anno.endLine ? `${anno.line}–${anno.endLine}` : `${anno.line}`;

    return [
        `# ${anno.kind} — ${anno.summary}`,
        '',
        `\`${anno.file}:${range}\` · id \`${anno.id}\``,
        meta,
        '',
        '---',
        '',
        anno.message,
        '',
        '---',
        '',
        '**Anchor snippet**',
        '',
        '```',
        anno.snippet || '(none)',
        '```',
        '',
        `Source: \`${anno.annoPath}\``,
        '',
    ].join('\n');
}

class Renderer {
    constructor(store, mediaDir) {
        this.store = store;
        this.mediaDir = mediaDir;
        this.types = new Map();
        this.diagnostics = vscode.languages.createDiagnosticCollection('ai-anno');
        this.codeLensChanged = new vscode.EventEmitter();
        this.lastByEditor = new WeakMap();
    }

    config() {
        const cfg = vscode.workspace.getConfiguration('aiAnno');
        return {
            enabled: cfg.get('enabled', true),
            displayMode: cfg.get('displayMode', 'both'),
            eolContent: cfg.get('eolContent', 'summary'),
            eolMaxLength: cfg.get('eolMaxLength', 120),
            kinds: cfg.get('kinds', ['why', 'explain', 'warning', 'review', 'todo']),
            showStale: cfg.get('showStale', true),
            diffOriginalSide: cfg.get('diffOriginalSide', false),
            diagnostics: cfg.get('diagnostics', false),
            statusBar: cfg.get('statusBar', true),
            scanDepth: cfg.get('scanDepth', 3),
        };
    }

    gutterType(kind, stale) {
        const key = `gutter:${kind}:${stale ? 'stale' : 'live'}`;
        if (!this.types.has(key)) {
            const file = stale ? 'stale.svg' : `${kind}.svg`;
            this.types.set(key, vscode.window.createTextEditorDecorationType({
                gutterIconPath: vscode.Uri.file(path.join(this.mediaDir, file)),
                gutterIconSize: 'contain',
                overviewRulerColor: new vscode.ThemeColor(stale ? 'aiAnno.stale' : `aiAnno.${kind}`),
                overviewRulerLane: vscode.OverviewRulerLane.Right,
                isWholeLine: true,
                rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
            }));
        }
        return this.types.get(key);
    }

    eolType(kind, stale) {
        const key = `eol:${kind}:${stale ? 'stale' : 'live'}`;
        if (!this.types.has(key)) {
            this.types.set(key, vscode.window.createTextEditorDecorationType({
                after: {
                    color: new vscode.ThemeColor(stale ? 'aiAnno.stale' : `aiAnno.${kind}`),
                    margin: '0 0 0 2ch',
                    fontStyle: 'italic',
                },
                rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
            }));
        }
        return this.types.get(key);
    }

    /** Annotations for a document, filtered by config and re-anchored. */
    visible(document) {
        const cfg = this.config();
        if (!cfg.enabled) return { cfg, items: [] };

        // A non-file scheme means a read-only version of the file: the left side
        // of a diff, or something opened from git history. Annotations describe
        // the working tree, so these are opt-in, and only ones that still anchor
        // in the older text are shown — a stale marker there says nothing except
        // "this note is about code that did not exist yet".
        const readOnlyVersion = document.uri.scheme !== 'file';
        if (readOnlyVersion && !cfg.diffOriginalSide) return { cfg, items: [] };

        const items = this.store.forDocument(document).filter((anno) => {
            if (!cfg.kinds.includes(anno.kind)) return false;
            if (anno.stale && (readOnlyVersion || !cfg.showStale)) return false;
            return true;
        });
        return { cfg, items };
    }

    clear(editor) {
        for (const type of this.types.values()) editor.setDecorations(type, []);
    }

    refresh(editor) {
        if (!editor) return;

        const { cfg, items } = this.visible(editor.document);
        const buckets = new Map();
        const push = (type, entry) => {
            if (!buckets.has(type)) buckets.set(type, []);
            buckets.get(type).push(entry);
        };

        const showEol = cfg.displayMode === 'eol' || cfg.displayMode === 'both';

        for (const anno of items) {
            const hover = buildHover(anno);
            for (let line = anno.start; line <= anno.end; line += 1) {
                push(this.gutterType(anno.kind, anno.stale), {
                    range: editor.document.lineAt(line).range,
                    hoverMessage: hover,
                });
            }

            if (!showEol) continue;

            const raw = cfg.eolContent === 'message' ? flatten(anno.message) : anno.summary;
            const label = `${anno.stale ? '[stale] ' : ''}${anno.kind} · ${flatten(raw)}`;
            const endOfLine = editor.document.lineAt(anno.start).range.end;
            push(this.eolType(anno.kind, anno.stale), {
                range: new vscode.Range(endOfLine, endOfLine),
                renderOptions: {
                    after: { contentText: truncate(label, cfg.eolMaxLength) },
                },
            });
        }

        for (const type of this.types.values()) {
            editor.setDecorations(type, buckets.get(type) || []);
        }

        this.publishDiagnostics(editor.document, cfg, items);
        this.codeLensChanged.fire();
    }

    publishDiagnostics(document, cfg, items) {
        // Diagnostics are keyed by uri, so publishing for a diff side would
        // duplicate every entry in the Problems panel under a git: path.
        if (!cfg.diagnostics || document.uri.scheme !== 'file') {
            this.diagnostics.delete(document.uri);
            return;
        }
        const list = items.map((anno) => {
            const range = new vscode.Range(
                new vscode.Position(anno.start, 0),
                document.lineAt(anno.end).range.end,
            );
            const prefix = anno.stale ? '[stale] ' : '';
            const diagnostic = new vscode.Diagnostic(
                range,
                `${prefix}${anno.kind}: ${anno.summary}`,
                vscode.DiagnosticSeverity.Information,
            );
            diagnostic.source = 'anno';
            diagnostic.code = anno.id;
            return diagnostic;
        });
        this.diagnostics.set(document.uri, list);
    }

    refreshAll() {
        for (const editor of vscode.window.visibleTextEditors) this.refresh(editor);
    }

    provideCodeLenses(document) {
        const { cfg, items } = this.visible(document);
        if (cfg.displayMode !== 'codelens' && cfg.displayMode !== 'both') return [];
        return items.map((anno) => new vscode.CodeLens(
            new vscode.Range(anno.start, 0, anno.start, 0),
            {
                title: `$(${KIND_ICON[anno.kind] || 'comment'}) ${anno.stale ? '[stale] ' : ''}${anno.kind} · ${truncate(anno.summary, 90)}`,
                command: 'aiAnno.show',
                arguments: [{ annoPath: anno.annoPath, id: anno.id }],
                tooltip: anno.message,
            },
        ));
    }

    dispose() {
        for (const type of this.types.values()) type.dispose();
        this.types.clear();
        this.diagnostics.dispose();
        this.codeLensChanged.dispose();
    }
}

module.exports = { Renderer, buildDetail, buildHover, detailUri, KIND_ICON, flatten, truncate };
