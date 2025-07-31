return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({})

    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Harpoon add file" })

    vim.keymap.set("n", "<C-h>", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", "<C-t>", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", "<C-n>", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", "<C-s>", function()
      harpoon:list():select(4)
    end)

    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev()
    end, { desc = "Harpoon prev file" })
    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next()
    end, { desc = "Harpoon next file" })

    -- Use telescope for harpoon menu
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
          results = file_paths,
        }),
        previewer = require("telescope.config").values.file_previewer({}),
        sorter = require("telescope.config").values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          require("telescope.actions.set").select:replace(function()
            require("telescope.actions").close(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            for i, item in ipairs(harpoon_files.items) do
              if item.value == selection[1] then
                harpoon:list():select(i)
                return
              end
            end
          end)
          return true
        end,
      }):find()
    end

    vim.keymap.set("n", "<C-e>", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Open harpoon (telescope)" })
  end,
}

