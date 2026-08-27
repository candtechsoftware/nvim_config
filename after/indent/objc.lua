-- Indent scripts load after ftplugins, and the runtime indent/objc.vim sets
-- indentexpr=GetObjCIndent(), which colon-aligns consecutive `case X:` labels
-- and threw away the C-family indentexpr from after/ftplugin. Put it back,
-- with C's default indentkeys instead of objc's `<:>`.
vim.bo.indentexpr = 'v:lua._c_indentexpr()'
vim.cmd('setlocal indentkeys&')
