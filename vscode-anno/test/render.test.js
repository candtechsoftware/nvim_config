'use strict';

const fs = require('fs');
const path = require('path');

const { EXAMPLE, EXT_ROOT, check, section, setConfig, makeDocument, makeEditor } = require('./harness');
const { AnnoStore } = require('../src/store');
const { Renderer, buildHover, flatten, truncate } = require('../src/render');

const isGutter = (opts) => Boolean(opts.gutterIconPath);
const isEol = (opts) => Boolean(opts.after);

function run() {
    const authPath = path.join(EXAMPLE, 'src/auth.ts');
    const store = new AnnoStore({ appendLine: () => { } });
    const renderer = new Renderer(store, path.join(EXT_ROOT, 'media'));
    const document = makeDocument(authPath);
    const editor = makeEditor(document);

    const eolTexts = () => editor.byOption(isEol)
        .flatMap(([, list]) => list.map((d) => d.renderOptions.after.contentText));

    section('rendering');
    setConfig({});
    renderer.refresh(editor);

    // Five single-line annotations plus one 7-line range.
    check('gutter marks cover every line of every range', editor.countWhere(isGutter), 12);
    check('exactly one end-of-line label per annotation', editor.countWhere(isEol), 6);
    check('every gutter icon file exists',
        editor.byOption(isGutter).every(([t]) => fs.existsSync(t.opts.gutterIconPath.fsPath)), true);
    check('the stale annotation uses the stale icon',
        editor.byOption(isGutter).some(([t]) => t.opts.gutterIconPath.fsPath.endsWith('stale.svg')), true);

    section('end-of-line labels');
    check('the stale label is marked [stale]', eolTexts().some((t) => t.startsWith('[stale] ')), true);
    check('no label contains a newline', eolTexts().every((t) => !/\n/.test(t)), true);
    check('labels respect the 120-char cap', eolTexts().every((t) => t.length <= 120), true);
    check('every kind is named in a label',
        ['why', 'explain', 'warning', 'review', 'todo'].every((k) => eolTexts().some((t) => t.includes(`${k} ·`))), true);

    section('flatten and truncate');
    check('flatten collapses newlines', flatten('a\n\nb\nc'), 'a · b · c');
    const long = truncate('x'.repeat(200), 40);
    check('truncate obeys the cap', long.length <= 40, true);
    check('truncated text ends in an ellipsis', long.endsWith('…'), true);
    check('a cap of 0 disables truncation', truncate('x'.repeat(200), 0).length, 200);
    check('short text passes through untouched', truncate('short', 40), 'short');

    section('disabling');
    setConfig({ enabled: false });
    check('disabled resolves no annotations', renderer.visible(document).length, 0);
    renderer.refresh(editor);
    check('disabled clears every decoration', editor.appliedCount(), 0);

    section('hover');
    setConfig({});
    renderer.refresh(editor);
    const items = renderer.visible(document);

    const why = items.find((a) => a.id === 'a3f19c');
    const hover = buildHover(why);
    check('hover carries the full message body',
        hover.value.includes('asymmetric key management is pure overhead'), true);
    check('hover names the kind', hover.value.includes('**why**'), true);
    check('hover has no command links', hover.value.includes('command:'), false);
    check('stale hover says stale', buildHover(items.find((a) => a.stale)).value.includes('**stale**'), true);
    check('re-anchored hover reports the original line',
        buildHover(items.find((a) => a.moved)).value.includes('re-anchored from line 20'), true);

    section('diff editors');
    // The working-tree side of a git diff is an ordinary file: document.
    const modifiedSide = makeDocument(authPath);
    const modifiedEditor = makeEditor(modifiedSide);
    renderer.refresh(modifiedEditor);
    check('the working-tree side of a diff renders', renderer.visible(modifiedSide).length, 6);
    check('...with decorations applied', modifiedEditor.appliedCount() > 0, true);

    // The left side is a read-only git: document; it never renders.
    const originalSide = makeDocument(authPath, 'git');
    const originalEditor = makeEditor(originalSide);
    renderer.refresh(originalEditor);
    check('the read-only side is silent', renderer.visible(originalSide).length, 0);
    check('...and gets no decorations', originalEditor.appliedCount(), 0);

    section('non-file schemes are never resolved');
    for (const scheme of ['untitled', 'output', 'debug']) {
        const doc = makeDocument(authPath, scheme);
        check(`${scheme}: resolves no annotations`, renderer.visible(doc).length, 0);
    }

    section('no annotations at all');
    const emptyDoc = makeDocument(path.join(EXT_ROOT, 'package.json'));
    const emptyEditor = makeEditor(emptyDoc);
    renderer.refresh(emptyEditor);
    check('an unannotated file gets no decorations', emptyEditor.appliedCount(), 0);
}

module.exports = { run };
