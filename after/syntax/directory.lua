-- No syntax file ships for the builtin browser's `directory` filetype. Two
-- rules are enough: an entry is a directory when the listing gave it a
-- trailing `/`, and the dot-prefixed ones are the noise you skim past. The
-- directory rule is defined last so a hidden directory still reads as one.
vim.cmd([[
  syntax match directoryHidden "^\..*$"
  syntax match directoryDir "^.*/$"
  highlight default link directoryHidden Comment
  highlight default link directoryDir Directory
]])
