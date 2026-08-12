'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');

const { EXAMPLE, check, section, setConfig } = require('./harness');
const { AnnoStore, anchor, summarize, resolveAgainstSource } = require('../src/store');

function run() {
    setConfig({});
    const logs = [];
    const store = new AnnoStore({ appendLine: (m) => logs.push(m) });
    const authPath = path.join(EXAMPLE, 'src/auth.ts');

    section('discovery');
    check('findAnnoDir walks up from src/ to the example root', store.findAnnoDir(authPath), EXAMPLE);
    check('discover finds the example dir', store.discover(), [EXAMPLE]);

    section('parsing');
    const all = store.load(EXAMPLE);
    check('parses every annotation', all.length, 6);
    check('all five kinds represented', all.map((a) => a.kind).sort(),
        ['explain', 'explain', 'review', 'todo', 'warning', 'why']);
    check('file path resolved against the .anno.json dir', all[0].absPath, authPath);
    check('endLine kept when greater than line', all.find((a) => a.id === '5c7e10').endLine, 20);
    check('summary is the first non-empty line', all.find((a) => a.id === 'a3f19c').summary,
        'HS256 over RS256 because we own both ends of this token');

    section('re-anchoring against the real fixture');
    const lines = fs.readFileSync(authPath, 'utf8').split(/\r?\n/);
    const at = (id) => anchor(lines, all.find((a) => a.id === id));

    check('fixture line count matches the lineCount convention', lines.length, 36);
    check('exact snippet match stays put', at('a3f19c'), { start: 10, end: 10, stale: false, moved: false });
    check('range spans line..endLine', at('5c7e10'), { start: 13, end: 19, stale: false, moved: false });
    check('warning anchors at its stored line', at('8f3a2b'), { start: 2, end: 2, stale: false, moved: false });
    check('drifted snippet re-anchors and reports moved', at('b21d84'), { start: 22, end: 22, stale: false, moved: true });
    check('todo anchors at its stored line', at('e4a0f7'), { start: 28, end: 28, stale: false, moved: false });
    check('absent snippet is stale, clamped to the last line', at('9db3c6'), { start: 35, end: 35, stale: true, moved: false });

    section('re-anchoring edge cases');
    check('duplicate snippets pick the match closest to the stored line',
        anchor(['x', 'dup', 'y', 'dup', 'z'], { line: 5, endLine: null, snippet: 'dup' }),
        { start: 3, end: 3, stale: false, moved: true });
    check('surrounding whitespace ignored on both sides',
        anchor(['', '   const a = 1;   '], { line: 2, endLine: null, snippet: 'const a = 1;' }),
        { start: 1, end: 1, stale: false, moved: false });
    check('missing snippet falls back to the stored line',
        anchor(['a', 'b', 'c'], { line: 2, endLine: null, snippet: '' }),
        { start: 1, end: 1, stale: false, moved: false });
    check('line past EOF clamps without claiming a match',
        anchor(['a', 'b'], { line: 900, endLine: null, snippet: '' }),
        { start: 1, end: 1, stale: false, moved: false });
    check('range end clamps to EOF',
        anchor(['a', 'b', 'c'], { line: 2, endLine: 99, snippet: 'b' }),
        { start: 1, end: 2, stale: false, moved: false });
    check('empty file does not throw',
        anchor([''], { line: 5, endLine: null, snippet: 'nope' }),
        { start: 0, end: 0, stale: true, moved: false });

    section('per-file lookup');
    check('forFile returns every annotation sorted by line',
        store.forFile(authPath).map((a) => a.line), [3, 11, 14, 20, 29, 40]);
    check('forFile on an unannotated sibling returns none',
        store.forFile(path.join(EXAMPLE, 'src/nope.ts')).length, 0);

    section('resolveAgainstSource (disk-backed, no open buffer)');
    const drifted = resolveAgainstSource(all.find((a) => a.id === 'b21d84'));
    check('re-anchors against the file on disk', { start: drifted.start, moved: drifted.moved }, { start: 22, moved: true });
    const gone = resolveAgainstSource(Object.assign({}, all[0], { absPath: path.join(EXAMPLE, 'src/gone.ts') }));
    check('a missing source file is flagged, not thrown', gone.missing, true);

    section('malformed input is skipped, not fatal');
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'anno-test-'));
    const tmpFile = path.join(tmp, '.anno.json');
    const write = (value) => fs.writeFileSync(tmpFile, JSON.stringify(value));

    write({
        version: 1,
        annotations: [
            { id: 'ok1', file: 'a.ts', line: 1, kind: 'why', message: 'fine', snippet: 'x' },
            { id: 'bad1', file: 'a.ts', kind: 'why', message: 'no line' },
            { id: 'bad2', line: 4, kind: 'why', message: 'no file' },
            { id: 'bad3', file: 'a.ts', line: 0, kind: 'why', message: 'line below 1' },
            { id: 'bad4', file: 'a.ts', line: 2, kind: 'why', message: '' },
            { id: 'weird', file: 'a.ts', line: 3, kind: 'nonsense', message: 'unknown kind' },
            null,
            { file: 'a.ts', line: 7, kind: 'todo', message: 'id omitted' },
        ],
    });
    logs.length = 0;
    const mixed = store.load(tmp);
    check('keeps only the usable entries', mixed.map((a) => a.id), ['ok1', 'weird', 'a.ts:7']);
    check('unknown kind degrades to explain', mixed.find((a) => a.id === 'weird').kind, 'explain');
    check('every rejection is logged', logs.join('\n').split('\n').length, 6);

    write({ version: 1 });
    check('missing annotations array yields none', store.load(tmp).length, 0);

    fs.writeFileSync(tmpFile, '{ not json');
    check('invalid JSON yields none', store.load(tmp).length, 0);

    section('mtime/size cache');
    write({ version: 1, annotations: [{ id: 'v1', file: 'a.ts', line: 1, kind: 'why', message: 'one', snippet: 'x' }] });
    const first = store.load(tmp);
    check('reads the first revision', first.map((a) => a.id), ['v1']);
    check('repeat load returns the same cached array', store.load(tmp) === first, true);

    write({
        version: 1,
        annotations: [
            { id: 'v2', file: 'a.ts', line: 1, kind: 'why', message: 'two', snippet: 'x' },
            { id: 'v2b', file: 'a.ts', line: 2, kind: 'todo', message: 'also', snippet: 'y' },
        ],
    });
    check('a rewrite busts the cache', store.load(tmp).map((a) => a.id), ['v2', 'v2b']);

    fs.rmSync(tmp, { recursive: true, force: true });
    check('a deleted .anno.json yields no annotations', store.load(tmp).length, 0);

    section('summaries');
    check('markdown heading stripped', summarize('# Title here\n\nbody'), 'Title here');
    check('leading blank lines skipped', summarize('\n\nreal line\nmore'), 'real line');
}

module.exports = { run };
