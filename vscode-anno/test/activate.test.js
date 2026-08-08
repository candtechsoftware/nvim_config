'use strict';

const path = require('path');

const { vscode, EXT_ROOT, check, section, setConfig } = require('./harness');

function run() {
    section('activation');
    setConfig({});

    const registered = [];
    const originalRegister = vscode.commands.registerCommand;
    vscode.commands.registerCommand = (id, handler) => {
        registered.push({ id, handler });
        return { dispose() { } };
    };

    const providers = [];
    const originalContent = vscode.workspace.registerTextDocumentContentProvider;
    vscode.workspace.registerTextDocumentContentProvider = (scheme, provider) => {
        providers.push({ scheme, provider });
        return { dispose() { } };
    };

    const lensProviders = [];
    const originalLens = vscode.languages.registerCodeLensProvider;
    vscode.languages.registerCodeLensProvider = (selector, provider) => {
        lensProviders.push(provider);
        return { dispose() { } };
    };

    const { activate, deactivate } = require('../src/extension');
    const context = { extensionPath: EXT_ROOT, subscriptions: [] };

    let threw = null;
    try {
        activate(context);
    } catch (err) {
        threw = err;
    }

    check('activate() completes without throwing', threw && threw.stack ? threw.stack : null, null);
    if (threw) return;

    section('contributed commands are all implemented');
    const manifest = require('../package.json');
    const declared = manifest.contributes.commands.map((c) => c.command).sort();
    const implemented = registered.map((c) => c.id).sort();
    for (const id of declared) {
        check(`${id} is registered`, implemented.includes(id), true);
    }
    check('aiAnno.reveal is registered for tree clicks', implemented.includes('aiAnno.reveal'), true);
    check('every registered handler is a function', registered.every((c) => typeof c.handler === 'function'), true);

    section('providers');
    check('the anno: detail scheme is registered', providers.map((p) => p.scheme), ['anno']);
    check('a CodeLens provider is registered', lensProviders.length, 1);
    check('the CodeLens provider exposes a change event',
        typeof lensProviders[0].onDidChangeCodeLenses, 'function');

    const detail = providers[0].provider.provideTextDocumentContent({
        query: JSON.stringify({ annoPath: path.join(EXT_ROOT, 'example/.anno.json'), id: 'a3f19c' }),
    });
    check('detail provider renders a known annotation', detail.includes('HS256 over RS256'), true);

    const missing = providers[0].provider.provideTextDocumentContent({
        query: JSON.stringify({ annoPath: path.join(EXT_ROOT, 'example/.anno.json'), id: 'gone' }),
    });
    check('detail provider explains a vanished annotation', missing.includes('no longer in'), true);

    const garbage = providers[0].provider.provideTextDocumentContent({ query: 'not-json' });
    check('detail provider survives a malformed uri', garbage.includes('Unreadable'), true);

    section('cleanup');
    check('everything disposable landed in subscriptions', context.subscriptions.length > 10, true);
    check('every subscription is disposable',
        context.subscriptions.every((s) => s && typeof s.dispose === 'function'), true);

    let disposeThrew = null;
    try {
        for (const sub of context.subscriptions) sub.dispose();
        deactivate();
    } catch (err) {
        disposeThrew = err;
    }
    check('disposing everything does not throw',
        disposeThrew && disposeThrew.stack ? disposeThrew.stack : null, null);

    vscode.commands.registerCommand = originalRegister;
    vscode.workspace.registerTextDocumentContentProvider = originalContent;
    vscode.languages.registerCodeLensProvider = originalLens;
}

module.exports = { run };
