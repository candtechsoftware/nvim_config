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

const EOL_MAX_LENGTH = 120;

function flatten(message) {
    return message.replace(/\s*\r?\n+\s*/g, ' · ').replace(/[ \t]+/g, ' ').trim();
}

function truncate(text, maxLength) {
    if (!maxLength || text.length <= maxLength) return text;
    return `${text.slice(0, Math.max(1, maxLength - 1)).trimEnd()}…`;
}

function buildHover(anno) {
    const md = new vscode.MarkdownString(undefined, true);

    const meta = [anno.author, anno.created ? anno.created.slice(0, 10) : ''].filter(Boolean).join(' · ');
    md.appendMarkdown(`$(${KIND_ICON[anno.kind] || 'comment'}) **${anno.kind}**`);
    if (meta) md.appendMarkdown(`  —  ${meta}`);
    if (anno.stale) md.appendMarkdown('  —  $(warning) **stale** (snippet no longer matches)');
    else if (anno.moved) md.appendMarkdown(`  —  re-anchored from line ${anno.line}`);
    md.appendMarkdown('\n\n');
    md.appendMarkdown(anno.message);

    return md;
}

class Renderer {
    constructor(store, mediaDir) {
        this.store = store;
        this.mediaDir = mediaDir;
        this.types = new Map();
    }

    enabled() {
        return vscode.workspace.getConfiguration('aiAnno').get('enabled', true);
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

    /** Annotations for a document, re-anchored. Empty when disabled. */
    visible(document) {
        if (!this.enabled()) return [];
        return this.store.forDocument(document);
    }

    refresh(editor) {
        if (!editor) return;

        const items = this.visible(editor.document);
        const buckets = new Map();
        const push = (type, entry) => {
            if (!buckets.has(type)) buckets.set(type, []);
            buckets.get(type).push(entry);
        };

        for (const anno of items) {
            const hover = buildHover(anno);
            for (let line = anno.start; line <= anno.end; line += 1) {
                push(this.gutterType(anno.kind, anno.stale), {
                    range: editor.document.lineAt(line).range,
                    hoverMessage: hover,
                });
            }

            const label = `${anno.stale ? '[stale] ' : ''}${anno.kind} · ${flatten(anno.summary)}`;
            const endOfLine = editor.document.lineAt(anno.start).range.end;
            push(this.eolType(anno.kind, anno.stale), {
                range: new vscode.Range(endOfLine, endOfLine),
                renderOptions: {
                    after: { contentText: truncate(label, EOL_MAX_LENGTH) },
                },
            });
        }

        for (const type of this.types.values()) {
            editor.setDecorations(type, buckets.get(type) || []);
        }
    }

    refreshAll() {
        for (const editor of vscode.window.visibleTextEditors) this.refresh(editor);
    }

    dispose() {
        for (const type of this.types.values()) type.dispose();
        this.types.clear();
    }
}

module.exports = { Renderer, buildHover, KIND_ICON, flatten, truncate };
