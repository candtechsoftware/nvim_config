'use strict';

// Runs the extension's logic under plain node against a stubbed `vscode`.
// No editor, no build step, no dependencies: `npm test`.
const { results } = require('./harness');

const suites = [
    ['store', require('./store.test')],
    ['render', require('./render.test')],
    ['activate', require('./activate.test')],
];

for (const [name, suite] of suites) {
    console.log(`\n\x1b[1m\x1b[4m${name}\x1b[0m`);
    try {
        suite.run();
    } catch (err) {
        results.failed += 1;
        results.failures.push(`${name}: threw`);
        console.log(`  \x1b[31mTHREW\x1b[0m  ${err && err.stack ? err.stack : err}`);
    }
}

const total = results.passed + results.failed;
console.log(`\n${'-'.repeat(56)}`);
if (results.failed) {
    console.log(`\x1b[31m${results.failed} of ${total} checks failed\x1b[0m`);
    for (const failure of results.failures) console.log(`  · ${failure}`);
    process.exit(1);
}
console.log(`\x1b[32mall ${total} checks passed\x1b[0m`);
