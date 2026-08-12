'use strict';

// Minimal stand-in for the `vscode` host module. Installing it into the module
// cache lets the extension's logic run under plain `node`, with no editor and
// no build step. Only the surface the extension actually touches is modelled.
const Module = require('module');
const fs = require('fs');
const path = require('path');

const EXT_ROOT = path.join(__dirname, '..');
const EXAMPLE = path.join(EXT_ROOT, 'example');

const state = {
    config: {},
    workspaceFolders: [{ uri: { scheme: 'file', fsPath: EXAMPLE }, name: 'example' }],
    textDocuments: [],
    visibleTextEditors: [],
    decorationTypes: [],
};

class Position {
    constructor(line, character) {
        this.line = line;
        this.character = character;
    }
}

class Range {
    constructor(a, b, c, d) {
        if (typeof a === 'number') {
            this.start = new Position(a, b);
            this.end = new Position(c, d);
        } else {
            this.start = a;
            this.end = b;
        }
    }
}

class Selection extends Range { }

class MarkdownString {
    constructor() {
        this.value = '';
    }

    appendMarkdown(value) {
        this.value += value;
        return this;
    }
}

const vscode = {
    Position,
    Range,
    Selection,
    MarkdownString,
    Uri: {
        file: (p) => ({ scheme: 'file', fsPath: p, toString: () => `file://${p}` }),
    },
    ThemeColor: class { constructor(id) { this.id = id; } },
    DecorationRangeBehavior: { OpenOpen: 0, ClosedClosed: 1 },
    OverviewRulerLane: { Left: 1, Center: 2, Right: 4, Full: 7 },
    ConfigurationTarget: { Global: 1, Workspace: 2 },
    TextEditorRevealType: { InCenterIfOutsideViewport: 2 },
    window: {
        get visibleTextEditors() { return state.visibleTextEditors; },
        createTextEditorDecorationType: (opts) => {
            const type = { id: state.decorationTypes.length, opts, dispose() { } };
            state.decorationTypes.push(type);
            return type;
        },
        createOutputChannel: () => ({ lines: [], appendLine(l) { this.lines.push(l); }, show() { }, dispose() { } }),
        showInformationMessage: () => Promise.resolve(undefined),
        showQuickPick: () => Promise.resolve(undefined),
        setStatusBarMessage: () => ({ dispose() { } }),
        onDidChangeActiveTextEditor: () => ({ dispose() { } }),
        onDidChangeVisibleTextEditors: () => ({ dispose() { } }),
        onDidChangeWindowState: () => ({ dispose() { } }),
    },
    workspace: {
        get workspaceFolders() { return state.workspaceFolders; },
        get textDocuments() { return state.textDocuments; },
        getWorkspaceFolder: (uri) => state.workspaceFolders.find(
            (folder) => uri.fsPath && uri.fsPath.startsWith(folder.uri.fsPath),
        ),
        getConfiguration: () => ({
            get: (key, fallback) => (key in state.config ? state.config[key] : fallback),
            update: () => Promise.resolve(),
        }),
        createFileSystemWatcher: () => ({
            onDidCreate: () => ({ dispose() { } }),
            onDidChange: () => ({ dispose() { } }),
            onDidDelete: () => ({ dispose() { } }),
            dispose() { },
        }),
        openTextDocument: () => Promise.resolve({}),
        onDidChangeTextDocument: () => ({ dispose() { } }),
        onDidChangeWorkspaceFolders: () => ({ dispose() { } }),
        onDidChangeConfiguration: () => ({ dispose() { } }),
    },
    commands: {
        registerCommand: () => ({ dispose() { } }),
    },
    RelativePattern: class { constructor(base, pattern) { this.base = base; this.pattern = pattern; } },
};

const originalResolve = Module._resolveFilename;
Module._resolveFilename = function resolveFilename(request, ...rest) {
    if (request === 'vscode') return 'vscode';
    return originalResolve.call(this, request, ...rest);
};
require.cache.vscode = { id: 'vscode', filename: 'vscode', loaded: true, exports: vscode };

// ------------------------------------------------------------------ fakes

/**
 * A TextDocument backed by a real file on disk. Pass `scheme` to model a
 * read-only version (e.g. 'git' for the left side of a diff), and `text` to
 * give that version different content than what is on disk.
 */
function makeDocument(fsPath, scheme, text) {
    const source = text === undefined ? fs.readFileSync(fsPath, 'utf8') : text;
    const lines = source.split(/\r?\n/);
    return {
        uri: scheme && scheme !== 'file'
            ? { scheme, fsPath, query: '{"ref":"HEAD"}', toString: () => `${scheme}:${fsPath}?ref=HEAD` }
            : vscode.Uri.file(fsPath),
        lineCount: lines.length,
        getText: () => lines.join('\n'),
        lineAt: (n) => {
            if (n < 0 || n >= lines.length) {
                throw new Error(`lineAt(${n}) out of range 0..${lines.length - 1} for ${fsPath}`);
            }
            return { text: lines[n], range: new Range(n, 0, n, lines[n].length) };
        },
    };
}

function makeEditor(document) {
    const applied = new Map();
    return {
        document,
        applied,
        selection: new Selection(0, 0, 0, 0),
        setDecorations: (type, ranges) => applied.set(type, ranges),
        revealRange: () => { },
        appliedCount() {
            return [...applied.values()].reduce((n, list) => n + list.length, 0);
        },
        byOption(predicate) {
            return [...applied.entries()].filter(([type]) => predicate(type.opts));
        },
        countWhere(predicate) {
            return this.byOption(predicate).reduce((n, [, list]) => n + list.length, 0);
        },
    };
}

// --------------------------------------------------------------- assertions

const results = { passed: 0, failed: 0, failures: [] };

function check(label, actual, expected) {
    const ok = JSON.stringify(actual) === JSON.stringify(expected);
    if (ok) {
        results.passed += 1;
        console.log(`  \x1b[32mPASS\x1b[0m  ${label}`);
        return true;
    }
    results.failed += 1;
    results.failures.push(label);
    console.log(`  \x1b[31mFAIL\x1b[0m  ${label}`);
    console.log(`        expected ${JSON.stringify(expected)}`);
    console.log(`        actual   ${JSON.stringify(actual)}`);
    return false;
}

function section(name) {
    console.log(`\n\x1b[1m${name}\x1b[0m`);
}

function setConfig(config) {
    state.config = config || {};
}

module.exports = {
    vscode, state, EXT_ROOT, EXAMPLE,
    makeDocument, makeEditor, check, section, setConfig, results,
};
