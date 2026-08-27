-- Reuse C ftplugin settings for Objective-C++ (indentexpr included: plain
-- cindent handles id<Protocol> fine, and indentexpr cannot rewrite the buffer
-- anyway, see config.c_indent).
dofile(vim.fn.stdpath("config") .. "/after/ftplugin/c.lua")
