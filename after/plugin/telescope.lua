require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist",
      "build",
      "%.lock",
      "%.sqlite3",
      "%.ipynb",
      "%.min.%%",
      "%.map",
      "%.tmp",
      "%.temp",
      "%.o",
      "%.obj",
      "%.class",
    },
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        preview_height = 0.5,
        results_height = 0.5,
        preview_cutoff = 0,
        width = 0.8,
        height = 0.9,
        mirror = false,
      },
      height = { padding = 0 },
      width = { padding = 0 },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    },
    prompt_prefix = "🔍 ",
    selection_caret = "➤ ",
    path_display = { "truncate" },
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    mappings = {
      i = {
        ["<C-h>"] = "which_key",
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ["<C-b>"] = "preview_scrolling_up",
        ["<C-f>"] = "preview_scrolling_down",
      },
    },
    -- Use ripgrep for faster searching
    find_command = {
      "rg",
      "--files",
      "--hidden",
      "--glob",
      "!**/.git/*",
    },
    scroll_strategy = "cycle",    -- Allow cycling through results
    wrap_results = true,         -- Wrap long result lines
  },
  pickers = {
    find_files = {
      previewer = true,
      hidden = true,
      layout_config = {
        height = 0.9,            -- Increased height for find_files
      },
    },
    live_grep = {
      previewer = true,
      layout_config = {
        height = 0.9,            -- Increased height for live_grep
      },
    },
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      theme = "dropdown",
      previewer = true,
      mappings = {
        i = {
          ["<C-d>"] = "delete_buffer",
        },
        n = {
          ["dd"] = "delete_buffer",
          ["<C-d>"] = "delete_buffer",
        },
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})


-- vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files hidden=true no_ignore=true<CR>")
-- vim.keymap.set("n", "<leader>gg", "<cmd>Telescope git_files<CR>")
-- vim.keymap.set("n", "<leader>bb", "<cmd>Telescope buffers<CR>")
-- vim.keymap.set("n", "<leader>/", "<cmd>Telescope live_grep<CR>")
-- vim.keymap.set("n", "<leader>*", "<cmd>Telescope grep_string<CR>")
-- vim.keymap.set("n", "<leader>hc", "<cmd>Telescope commands<CR>")
-- vim.keymap.set("n", "<leader>hh", "<cmd>Telescope help_tags<CR>")
-- vim.keymap.set("n", "<leader>Gc", "<cmd>Telescope git_commits<CR>")
-- vim.keymap.set("n", "<leader>GB", "<cmd>Telescope git_bcommits<CR>")
-- vim.keymap.set("n", "<leader>Gb", "<cmd>Telescope git_branches<CR>")
-- vim.keymap.set("n", "<leader>Gs", "<cmd>Telescope git_status<CR>")
