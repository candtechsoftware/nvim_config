-- The runtime indent/objc.vim loads after ftplugins and replaces the C indentexpr.
vim.bo.indentexpr = require('config.c_indent').indent
vim.cmd('setlocal indentkeys&')
