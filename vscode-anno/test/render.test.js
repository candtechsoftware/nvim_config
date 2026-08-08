'use strict';

const fs = require('fs');
const path = require('path');

const { EXAMPLE, EXT_ROOT, check, section, setConfig, makeDocument, makeEditor } = require('./harness');
const { AnnoStore } = require('../src/store');
const { Renderer, buildDetail, buildHover } = require('../src/render');
const { AnnoTreeProvider } = require('../src/tree');

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

    section('default display mode ("both")');
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
    check('labels respect the 120-char default cap', eolTexts().every((t) => t.length <= 120), true);
    check('every kind is named in a label',
        ['why', 'explain', 'warning', 'review', 'todo'].every((k) => eolTexts().some((t) => t.includes(`${k} ·`))), true);

    section('CodeLens');
    const lenses = renderer.provideCodeLenses(document);
    check('one lens per annotation', lenses.length, 6);
    check('lenses sit on the re-anchored lines',
        lenses.map((l) => l.range.start.line).sort((a, b) => a - b), [2, 10, 13, 22, 28, 35]);
    check('lenses open the detail view', lenses.every((l) => l.command.command === 'aiAnno.show'), true);

    section('display modes');
    setConfig({ displayMode: 'gutter' });
    renderer.refresh(editor);
    check('gutter mode: no end-of-line text', editor.countWhere(isEol), 0);
    check('gutter mode: gutter still marked', editor.countWhere(isGutter), 12);
    check('gutter mode: no lenses', renderer.provideCodeLenses(document).length, 0);

    setConfig({ displayMode: 'eol' });
    renderer.refresh(editor);
    check('eol mode: labels present', editor.countWhere(isEol), 6);
    check('eol mode: no lenses', renderer.provideCodeLenses(document).length, 0);

    setConfig({ displayMode: 'codelens' });
    renderer.refresh(editor);
    check('codelens mode: no end-of-line text', editor.countWhere(isEol), 0);
    check('codelens mode: lenses present', renderer.provideCodeLenses(document).length, 6);

    section('filters');
    setConfig({ kinds: ['warning'] });
    renderer.refresh(editor);
    check('kind filter keeps only the selected kind', renderer.visible(document).items.map((a) => a.kind), ['warning']);

    setConfig({ showStale: false });
    renderer.refresh(editor);
    check('showStale=false hides the stale entry', renderer.visible(document).items.length, 5);

    setConfig({ enabled: false });
    renderer.refresh(editor);
    check('disabled clears every decoration', editor.appliedCount(), 0);
    check('disabled emits no lenses', renderer.provideCodeLenses(document).length, 0);

    section('truncation');
    setConfig({ eolContent: 'message', eolMaxLength: 40 });
    renderer.refresh(editor);
    check('message mode obeys the cap', eolTexts().every((t) => t.length <= 40), true);
    check('truncated labels end in an ellipsis', eolTexts().some((t) => t.endsWith('…')), true);
    check('message mode collapses newlines', eolTexts().every((t) => !/\n/.test(t)), true);

    setConfig({ eolContent: 'message', eolMaxLength: 0 });
    renderer.refresh(editor);
    check('a cap of 0 disables truncation', eolTexts().some((t) => t.length > 200), true);

    section('diagnostics');
    setConfig({ diagnostics: true });
    renderer.refresh(editor);
    check('one diagnostic per annotation', renderer.diagnostics.store.get(authPath).length, 6);
    check('diagnostics are Information severity',
        renderer.diagnostics.store.get(authPath).every((d) => d.severity === 2), true);

    setConfig({ diagnostics: false });
    renderer.refresh(editor);
    check('diagnostics cleared when disabled', renderer.diagnostics.store.has(authPath), false);

    section('hover and detail view');
    setConfig({});
    renderer.refresh(editor);
    const items = renderer.visible(document).items;

    const why = items.find((a) => a.id === 'a3f19c');
    const hover = buildHover(why);
    check('hover carries the full message body',
        hover.value.includes('asymmetric key management is pure overhead'), true);
    check('hover exposes all four actions',
        ['aiAnno.show', 'aiAnno.copy', 'aiAnno.openFile', 'aiAnno.delete']
            .every((c) => hover.value.includes(c)), true);
    check('stale hover says stale', buildHover(items.find((a) => a.stale)).value.includes('**stale**'), true);
    check('re-anchored hover reports the original line',
        buildHover(items.find((a) => a.moved)).value.includes('re-anchored from line 20'), true);

    const detail = buildDetail(why);
    check('detail shows the anchor snippet', detail.includes('return jwt.sign(payload, SECRET'), true);
    check('detail shows provenance', detail.includes('claude-opus-5'), true);

    section('sidebar tree');
    const tree = new AnnoTreeProvider(store, renderer);
    const roots = tree.getChildren();
    check('grouped by file', roots.length, 1);
    check('file node holds every annotation', roots[0].annotations.length, 6);

    const fileItem = tree.getTreeItem(roots[0]);
    check('file node labelled by basename', fileItem.label, 'auth.ts');
    check('file node shows dir and count', fileItem.description, 'src  6');

    const children = tree.getChildren(roots[0]);
    check('children sorted by anchored line', children.map((c) => c.anno.start), [2, 10, 13, 22, 28, 35]);

    const childItems = children.map((c) => tree.getTreeItem(c));
    check('drifted child shows its original line', childItems.some((i) => /was :20/.test(i.description)), true);
    check('stale child is marked stale', childItems.some((i) => /stale/.test(i.description)), true);
    check('every child jumps on click', childItems.every((i) => i.command.command === 'aiAnno.reveal'), true);
    check('child ids are unique', new Set(childItems.map((i) => i.id)).size, 6);
    check('getParent resolves a child back to its file node',
        tree.getParent(children[0]) === roots[0], true);

    section('diff editors');
    setConfig({});

    // The working-tree side of a git diff is an ordinary file: document.
    const modifiedSide = makeDocument(authPath);
    const modifiedEditor = makeEditor(modifiedSide);
    renderer.refresh(modifiedEditor);
    check('the working-tree side of a diff renders', renderer.visible(modifiedSide).items.length, 6);
    check('...with decorations applied', modifiedEditor.appliedCount() > 0, true);

    // The left side is a git: document holding the pre-change text.
    const original = fs.readFileSync(authPath, 'utf8')
        .replace("  if (session.scopes.includes('admin')) {\n    return true;\n  }\n", '');
    const originalSide = makeDocument(authPath, 'git', original);
    const originalEditor = makeEditor(originalSide);

    renderer.refresh(originalEditor);
    check('the read-only side is silent by default', renderer.visible(originalSide).items.length, 0);
    check('...and gets no decorations', originalEditor.appliedCount(), 0);
    check('...and no lenses', renderer.provideCodeLenses(originalSide).length, 0);

    setConfig({ diffOriginalSide: true });
    renderer.refresh(originalEditor);
    const originalItems = renderer.visible(originalSide).items;
    check('opting in renders on the read-only side', originalItems.length > 0, true);
    check('annotations whose snippet is gone are dropped, not shown stale',
        originalItems.every((a) => !a.stale), true);
    check('the review annotation is dropped — its anchor does not exist yet',
        originalItems.some((a) => a.id === 'b21d84'), false);
    check('the fixture-stale annotation is also dropped',
        originalItems.some((a) => a.id === '9db3c6'), false);
    check('annotations anchored in unchanged code survive',
        originalItems.map((a) => a.id).sort(), ['5c7e10', '8f3a2b', 'a3f19c', 'e4a0f7']);
    check('they re-anchor to the older line numbers',
        originalItems.find((a) => a.id === 'e4a0f7').start, 25);

    setConfig({ diffOriginalSide: true, diagnostics: true });
    renderer.refresh(originalEditor);
    check('a diff side never publishes diagnostics', renderer.diagnostics.store.has(authPath), false);
    renderer.refresh(modifiedEditor);
    check('the working-tree side still does', renderer.diagnostics.store.get(authPath).length, 6);

    section('opaque schemes are never resolved');
    setConfig({ diffOriginalSide: true });
    for (const scheme of ['anno', 'untitled', 'output', 'debug']) {
        const doc = makeDocument(authPath, scheme);
        check(`${scheme}: resolves no annotations`, renderer.visible(doc).items.length, 0);
    }

    section('no annotations at all');
    setConfig({});
    const emptyDoc = makeDocument(path.join(EXT_ROOT, 'package.json'));
    const emptyEditor = makeEditor(emptyDoc);
    renderer.refresh(emptyEditor);
    check('an unannotated file gets no decorations', emptyEditor.appliedCount(), 0);
    check('an unannotated file gets no lenses', renderer.provideCodeLenses(emptyDoc).length, 0);
}

module.exports = { run };
