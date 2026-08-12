'use strict';

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

    section('contributed commands match registered commands');
    const manifest = require('../package.json');
    const declared = manifest.contributes.commands.map((c) => c.command).sort();
    const implemented = registered.map((c) => c.id).sort();
    check('the declared and registered command sets are identical', implemented, declared);
    check('every registered handler is a function', registered.every((c) => typeof c.handler === 'function'), true);

    section('cleanup');
    check('everything disposable landed in subscriptions', context.subscriptions.length > 5, true);
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
}

module.exports = { run };
