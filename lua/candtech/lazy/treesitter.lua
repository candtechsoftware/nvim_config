return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.install").prefer_git = true
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "vimdoc", "javascript", "typescript", "c", "lua", "rust",
        "jsdoc", "bash", "jai",
      },
      sync_install = false,
      auto_install = false,
      ignore_install = { "zig" },
      indent = {
        enable = true,
      },
      highlight = {
        enable = true,
        disable = function(lang, buf)
          if lang == "zig" or lang == "html" then
            return true
          end
          local max_filesize = 100 * 1024
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            vim.notify("File larger than 100KB, Treesitter disabled", vim.log.levels.WARN, { title = "Treesitter" })
            return true
          end
        end,
        additional_vim_regex_highlighting = { "markdown" },
      },
    })

    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

    parser_config.templ = {
      install_info = {
        url = "https://github.com/vrischmann/tree-sitter-templ.git",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "master",
      },
    }

    -- Override parsers to point to their main branch
    parser_config.javascript.install_info.branch = "main"
    parser_config.typescript.install_info.branch = "main"
    parser_config.jsdoc.install_info.branch = "main"
    parser_config.lua.install_info.branch = "main"

    -- Remove zig
    parser_config.zig = nil

    -- Add Jai parser
    parser_config.jai = {
      install_info = {
        url = 'https://github.com/constantitus/tree-sitter-jai',
        files = { 'src/parser.c', 'src/scanner.c' },
      },
      filetype = 'jai',
    }

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.zig",
      callback = function()
        vim.bo.filetype = "zig"
        vim.cmd("setlocal syntax=on")
        pcall(vim.cmd, "TSBufDisable highlight")
        pcall(vim.cmd, "TSBufDisable indent")
      end,
    })
  end,
}

