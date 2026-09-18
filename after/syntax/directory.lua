-- Nothing ships a syntax for the builtin browser. Directories last, so a hidden directory still reads as one.
vim.cmd([[
  syntax match directoryHidden "^\..*$"
  syntax match directoryDir "^.*/$"
  highlight default link directoryHidden Comment
  highlight default link directoryDir Directory
]])
