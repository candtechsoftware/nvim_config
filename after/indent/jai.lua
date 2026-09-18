-- Replaces jai.vim's GetJaiIndent. cindent-style rules read `name: Type` as a
-- goto label, so indent from the tree.
require('config.ts_indent').attach()
-- `;` reindents because a `case` only becomes a switch_case once terminated.
vim.bo.indentkeys = '0{,0},0),0],;,!^F,o,O,0=case,0=#'
