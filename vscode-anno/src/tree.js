'use strict';

const fs = require('fs');
const path = require('path');
const vscode = require('vscode');

const { anchor, normalize } = require('./store');
const { KIND_ICON } = require('./render');

const MAX_ANCHOR_BYTES = 4 * 1024 * 1024;

/** Re-anchor against the open buffer if there is one, else against disk. */
function resolveAgainstSource(anno) {
    const open = vscode.workspace.textDocuments.find(
        (doc) => doc.uri.scheme === 'file' && normalize(doc.uri.fsPath) === normalize(anno.absPath),
    );
    if (open) return Object.assign({}, anno, anchor(open.getText().split(/\r?\n/), anno));

    try {
        const stat = fs.statSync(anno.absPath);
        if (stat.size > MAX_ANCHOR_BYTES) return Object.assign({}, anno, { start: anno.line - 1, end: anno.line - 1 });
        const lines = fs.readFileSync(anno.absPath, 'utf8').split(/\r?\n/);
        return Object.assign({}, anno, anchor(lines, anno));
    } catch (err) {
        return Object.assign({}, anno, { start: anno.line - 1, end: anno.line - 1, missing: true });
    }
}

class FileNode {
    constructor(absPath, relPath, annotations) {
        this.type = 'file';
        this.absPath = absPath;
        this.relPath = relPath;
        this.annotations = annotations;
    }
}

class AnnoNode {
    constructor(anno) {
        this.type = 'annotation';
        this.anno = anno;
    }
}

class AnnoTreeProvider {
    constructor(store, renderer) {
        this.store = store;
        this.renderer = renderer;
        this.changed = new vscode.EventEmitter();
        this.onDidChangeTreeData = this.changed.event;
        this.nodes = [];
    }

    refresh() {
        this.changed.fire();
    }

    getParent(element) {
        if (element instanceof AnnoNode) {
            return this.nodes.find((node) => normalize(node.absPath) === normalize(element.anno.absPath)) || null;
        }
        return null;
    }

    getChildren(element) {
        if (element instanceof FileNode) {
            return element.annotations.map((anno) => new AnnoNode(anno));
        }
        if (element) return [];

        const cfg = this.renderer.config();
        const grouped = new Map();

        for (const raw of this.store.all(cfg.scanDepth)) {
            if (!cfg.kinds.includes(raw.kind)) continue;
            const anno = resolveAgainstSource(raw);
            const key = normalize(anno.absPath);
            if (!grouped.has(key)) grouped.set(key, []);
            grouped.get(key).push(anno);
        }

        this.nodes = [...grouped.values()]
            .map((annotations) => {
                annotations.sort((a, b) => a.start - b.start);
                const first = annotations[0];
                return new FileNode(first.absPath, first.file, annotations);
            })
            .sort((a, b) => a.relPath.localeCompare(b.relPath));

        return this.nodes;
    }

    getTreeItem(element) {
        if (element instanceof FileNode) {
            const item = new vscode.TreeItem(
                path.basename(element.relPath),
                vscode.TreeItemCollapsibleState.Expanded,
            );
            const dir = path.dirname(element.relPath);
            item.description = `${dir === '.' ? '' : `${dir}  `}${element.annotations.length}`;
            item.tooltip = element.absPath;
            item.resourceUri = vscode.Uri.file(element.absPath);
            item.iconPath = vscode.ThemeIcon.File;
            item.contextValue = 'file';
            item.id = `file:${normalize(element.absPath)}`;
            return item;
        }

        const anno = element.anno;
        const item = new vscode.TreeItem(anno.summary, vscode.TreeItemCollapsibleState.None);

        const flags = [];
        if (anno.missing) flags.push('missing file');
        else if (anno.stale) flags.push('stale');
        else if (anno.moved) flags.push(`was :${anno.line}`);

        item.description = `${anno.kind}  :${anno.start + 1}${flags.length ? `  ${flags.join(' · ')}` : ''}`;
        item.iconPath = new vscode.ThemeIcon(
            anno.stale || anno.missing ? 'circle-slash' : (KIND_ICON[anno.kind] || 'comment'),
            new vscode.ThemeColor(anno.stale || anno.missing ? 'aiAnno.stale' : `aiAnno.${anno.kind}`),
        );

        const tooltip = new vscode.MarkdownString(undefined, true);
        tooltip.appendMarkdown(`**${anno.kind}** · \`${anno.file}:${anno.start + 1}\`\n\n`);
        tooltip.appendMarkdown(anno.message);
        item.tooltip = tooltip;

        item.contextValue = 'annotation';
        item.id = `anno:${normalize(anno.annoPath)}:${anno.id}`;
        item.command = {
            command: 'aiAnno.reveal',
            title: 'Reveal Annotation',
            arguments: [{ absPath: anno.absPath, line: anno.start, end: anno.end }],
        };
        return item;
    }

    dispose() {
        this.changed.dispose();
    }
}

module.exports = { AnnoTreeProvider, resolveAgainstSource, FileNode, AnnoNode };
