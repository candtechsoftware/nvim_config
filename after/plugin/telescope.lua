require("telescope").setup {
  defaults = {
    file_ignore_patterns = {
        "node_modules",
        "dist"
    },
    layout_config = {
        horizontal = {
            preview_cutoff = 0
        }
    },
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      theme = "dropdown",
      mappings = {
        i = {
          ["<C-d>"] = "delete_buffer",
        },
        n = {
          dd = "delete_buffer",
          ["<C-d>"] = "delete_buffer",
        }
      }
    },
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
    fzf = {} -- use defaults
  }
}

vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files hidden=true no_ignore=true<CR>")
vim.keymap.set("n", "<leader>gg", "<cmd>Telescope git_files<CR>")
vim.keymap.set("n", "<leader>bb", "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "<leader>/", "<cmd>Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>*", "<cmd>Telescope grep_string<CR>")
vim.keymap.set("n", "<leader>hc", "<cmd>Telescope commands<CR>")
vim.keymap.set("n", "<leader>hh", "<cmd>Telescope help_tags<CR>")
vim.keymap.set("n", "<leader>Gc", "<cmd>Telescope git_commits<CR>")
vim.keymap.set("n", "<leader>GB", "<cmd>Telescope git_bcommits<CR>")
vim.keymap.set("n", "<leader>Gb", "<cmd>Telescope git_branches<CR>")
vim.keymap.set("n", "<leader>Gs", "<cmd>Telescope git_status<CR>")

local p = {
  teal = "#062329",
  lteal = "#7AD0C6",
  blue = "#0000FF",
  lblue = "#ADD8E6",
  gold = "#D1B897",
  yellow = "#F9FF54",
  lyellow = "#FCE094",
  dgreen = "#2EC09C", -- Dark green
  lgreen = "#44B340", -- Lighter green
  mgreen = "#8CDE94", -- Mid green??
  darkgrey1 = "#4F5258", -- NvimDarkGrey4
  darkgrey2 = "#2C2E33", -- NvimDarkGrey3
  white = "#FFFFFF",
  pink = "#FF008C",
  red = "#D64C42",
  lred = "#FFBBBB",
  lcyan = "#8CF8F7",
}

vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = p.darkgrey1, bg = p.teal })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = p.darkgrey1, bg = p.teal })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = p.darkgrey1, bg = p.teal })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = p.darkgrey1, bg = p.teal })

vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = p.gold, bg = p.teal })
vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { fg = p.gold, bg = p.teal })
vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { fg = p.gold, bg = p.teal })

vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = p.white, bg = p.darkgrey2 })
vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { fg = p.yellow, bg = p.darkgrey2 })
vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = p.lcyan, bg = p.teal })

vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = p.teal, bg = p.gold })
vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = p.teal, bg = p.gold })
vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = p.teal, bg = p.gold })

vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = p.pink, bg = p.teal })
vim.api.nvim_set_hl(0, "TelescopeNormal", { fg = p.gold, bg = p.teal })
