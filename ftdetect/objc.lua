-- Detect Objective-C and Objective-C++ files
vim.filetype.add({
  extension = {
    m = "objc",
    mm = "objcpp",
  },
})

-- Register objcpp to use the objc treesitter parser
vim.treesitter.language.register("objc", "objcpp")
