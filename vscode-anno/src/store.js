'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const vscode = require('vscode');

const ANNO_FILE = '.anno.json';
const KINDS = ['why', 'explain', 'warning', 'review', 'todo'];
const SCAN_DEPTH = 3;
const MAX_ANCHOR_BYTES = 4 * 1024 * 1024;
const SKIP_DIRS = new Set([
    'node_modules', '.git', '.hg', '.svn', 'dist', 'build', 'out', 'target',
    'vendor', 'coverage', '.next', '.nuxt', '.venv', 'venv', '__pycache__',
    'Pods', '.gradle', '.terraform', '.turbo', '.cache', 'bin', 'obj',
]);

const CASE_INSENSITIVE = process.platform === 'darwin' || process.platform === 'win32';

function normalize(p) {
    const abs = path.resolve(p);
    return CASE_INSENSITIVE ? abs.toLowerCase() : abs;
}

function clamp(value, min, max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

function summarize(message) {
    const lines = String(message).split(/\r?\n/);
    for (const line of lines) {
        const trimmed = line.replace(/^#+\s*/, '').trim();
        if (trimmed) return trimmed;
    }
    return String(message).trim();
}

function parse(annoDir, problems) {
    const annoPath = path.join(annoDir, ANNO_FILE);
    let raw;
    try {
        raw = fs.readFileSync(annoPath, 'utf8');
    } catch (err) {
        if (err.code !== 'ENOENT') problems.push(`${annoPath}: ${err.message}`);
        return [];
    }

    let data;
    try {
        data = JSON.parse(raw);
    } catch (err) {
        problems.push(`${annoPath}: invalid JSON — ${err.message}`);
        return [];
    }

    if (!data || !Array.isArray(data.annotations)) {
        problems.push(`${annoPath}: missing top-level "annotations" array`);
        return [];
    }

    const out = [];
    data.annotations.forEach((entry, index) => {
        if (!entry || typeof entry !== 'object') {
            problems.push(`${annoPath}[${index}]: skipped — not an object`);
            return;
        }

        const file = typeof entry.file === 'string' ? entry.file.trim() : '';
        const line = Number(entry.line);
        const message = typeof entry.message === 'string' ? entry.message : '';

        if (!file || !Number.isFinite(line) || line < 1 || !message) {
            problems.push(`${annoPath}[${index}]: skipped — needs "file", "line" >= 1, and "message"`);
            return;
        }

        const known = KINDS.includes(entry.kind);
        if (!known) {
            problems.push(`${annoPath}[${index}]: unknown kind ${JSON.stringify(entry.kind)} — rendered as "explain"`);
        }

        const rawEnd = Number(entry.endLine);
        const endLine = Number.isFinite(rawEnd) && rawEnd > line ? Math.floor(rawEnd) : null;

        out.push({
            id: typeof entry.id === 'string' && entry.id ? entry.id : `${file}:${line}`,
            kind: known ? entry.kind : 'explain',
            message,
            summary: summarize(message),
            file: file.replace(/\\/g, '/'),
            absPath: path.resolve(annoDir, file),
            line: Math.floor(line),
            endLine,
            snippet: typeof entry.snippet === 'string' ? entry.snippet : '',
            author: typeof entry.author === 'string' ? entry.author : '',
            created: typeof entry.created === 'string' ? entry.created : '',
            commit: typeof entry.commit === 'string' ? entry.commit : '',
            annoDir,
            annoPath,
        });
    });

    return out;
}

/**
 * Re-anchor an annotation against the current text of its file, per SPEC.md:
 * exact trimmed snippet match at the stored line wins; otherwise the trimmed
 * match closest to the stored line; otherwise the annotation is stale and is
 * shown at the clamped stored line rather than dropped.
 */
function anchor(lines, anno) {
    const lastIndex = Math.max(0, lines.length - 1);
    const stored = clamp(anno.line - 1, 0, lastIndex);
    const target = anno.snippet.trim();
    const span = anno.endLine ? anno.endLine - anno.line : 0;

    const resolve = (start, stale, moved) => ({
        start,
        end: clamp(start + span, start, lastIndex),
        stale,
        moved,
    });

    if (!target) return resolve(stored, false, false);
    if (lines[stored] !== undefined && lines[stored].trim() === target) return resolve(stored, false, false);

    let best = -1;
    let bestDistance = Infinity;
    for (let i = 0; i < lines.length; i += 1) {
        if (lines[i].trim() !== target) continue;
        const distance = Math.abs(i - (anno.line - 1));
        if (distance < bestDistance) {
            bestDistance = distance;
            best = i;
        }
    }

    if (best >= 0) return resolve(best, false, best !== anno.line - 1);
    return resolve(stored, true, false);
}

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

class AnnoStore {
    constructor(output) {
        this.output = output;
        this.byDir = new Map();
        this.dirLookup = new Map();
        this.discovered = null;
    }

    reset() {
        this.byDir.clear();
        this.dirLookup.clear();
        this.discovered = null;
    }

    invalidate(annoPath) {
        this.byDir.delete(path.dirname(path.resolve(annoPath)));
        this.dirLookup.clear();
        this.discovered = null;
    }

    load(annoDir) {
        const annoPath = path.join(annoDir, ANNO_FILE);
        let stamp;
        try {
            const stat = fs.statSync(annoPath);
            stamp = `${stat.mtimeMs}:${stat.size}`;
        } catch (err) {
            this.byDir.delete(annoDir);
            return [];
        }

        const cached = this.byDir.get(annoDir);
        if (cached && cached.stamp === stamp) return cached.annotations;

        const problems = [];
        const annotations = parse(annoDir, problems);
        if (problems.length) {
            this.output.appendLine(problems.join('\n'));
        }
        this.byDir.set(annoDir, { stamp, annotations });
        return annotations;
    }

    boundaryFor(fsPath) {
        const folder = vscode.workspace.getWorkspaceFolder(vscode.Uri.file(fsPath));
        return folder ? folder.uri.fsPath : os.homedir();
    }

    findAnnoDir(fsPath) {
        const startDir = path.dirname(path.resolve(fsPath));
        const cached = this.dirLookup.get(normalize(startDir));
        if (cached !== undefined) return cached;

        const boundary = normalize(this.boundaryFor(fsPath));
        const visited = [];
        let dir = startDir;
        let found = null;

        for (;;) {
            visited.push(normalize(dir));
            if (fs.existsSync(path.join(dir, ANNO_FILE))) {
                found = dir;
                break;
            }
            const parent = path.dirname(dir);
            if (normalize(dir) === boundary || parent === dir) break;
            dir = parent;
        }

        for (const key of visited) this.dirLookup.set(key, found);
        return found;
    }

    forFile(fsPath) {
        const annoDir = this.findAnnoDir(fsPath);
        if (!annoDir) return [];
        const target = normalize(fsPath);
        return this.load(annoDir)
            .filter((anno) => normalize(anno.absPath) === target)
            .sort((a, b) => a.line - b.line);
    }

    forDocument(document) {
        // Only real files: `git:`, `anno:`, `untitled:` and friends either do not
        // name a source file or are read-only versions of one.
        if (document.uri.scheme !== 'file') return [];
        const annotations = this.forFile(document.uri.fsPath);
        if (!annotations.length) return [];
        const lines = document.getText().split(/\r?\n/);
        return annotations.map((anno) => Object.assign({}, anno, anchor(lines, anno)));
    }

    /** Workspace-folder walk for .anno.json, memoized until something invalidates. */
    scanWorkspace() {
        if (this.discovered) return this.discovered;

        const dirs = [];
        const seen = new Set();
        const add = (dir) => {
            const key = normalize(dir);
            if (seen.has(key)) return;
            seen.add(key);
            dirs.push(dir);
        };

        const walk = (dir, depth) => {
            let entries;
            try {
                entries = fs.readdirSync(dir, { withFileTypes: true });
            } catch (err) {
                return;
            }
            if (entries.some((e) => e.name === ANNO_FILE && !e.isDirectory())) add(dir);
            if (depth >= SCAN_DEPTH) return;
            for (const entry of entries) {
                if (!entry.isDirectory() || entry.isSymbolicLink()) continue;
                if (SKIP_DIRS.has(entry.name) || entry.name.startsWith('.')) continue;
                walk(path.join(dir, entry.name), depth + 1);
            }
        };

        for (const folder of vscode.workspace.workspaceFolders || []) {
            if (folder.uri.scheme !== 'file') continue;
            walk(folder.uri.fsPath, 0);
        }

        this.discovered = dirs;
        return dirs;
    }

    discover() {
        const dirs = [...this.scanWorkspace()];
        const seen = new Set(dirs.map(normalize));

        for (const editor of vscode.window.visibleTextEditors) {
            if (editor.document.uri.scheme !== 'file') continue;
            const annoDir = this.findAnnoDir(editor.document.uri.fsPath);
            if (!annoDir) continue;
            const key = normalize(annoDir);
            if (seen.has(key)) continue;
            seen.add(key);
            dirs.push(annoDir);
        }

        return dirs;
    }

    all() {
        const out = [];
        for (const dir of this.discover()) out.push(...this.load(dir));
        return out;
    }
}

module.exports = { AnnoStore, ANNO_FILE, KINDS, anchor, normalize, summarize, resolveAgainstSource };
