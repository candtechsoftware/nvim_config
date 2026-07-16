-- Reuse C ftplugin settings for Objective-C++
dofile(vim.fn.stdpath("config") .. "/after/ftplugin/c.lua")

-- Override indentexpr: extend the C version to also neutralize id<Protocol>
-- angle brackets that confuse cindent (it treats < > as operators, breaking
-- indentation).
--
-- Only the line rewrite differs from C — the scan window comes from
-- config.c_indent. This file used to carry its own full copy of the indentexpr,
-- which is how it kept `for i = 1, lnum` (the O(file length) scan) long after
-- c.lua had been fixed: `.m`/`.mm` still froze for ~2.7s on a 300-line `=`
-- motion. Sharing the machinery is what stops that drift recurring.
local c_indent = require('config.c_indent')

_G._objcpp_indentexpr = c_indent.make_indentexpr(function(line)
  line = c_indent.sub_macros(line)
  if line:find('id<') then
    line = line:gsub('id<([%w_]+)>', 'id_%1')
  end
  return line
end)
vim.bo.indentexpr = 'v:lua._objcpp_indentexpr()'
