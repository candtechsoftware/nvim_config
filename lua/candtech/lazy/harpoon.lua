return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({})

    local fzf = require("fzf-lua")

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

    -- Replace Telescope with fzf-lua
    local function toggle_fzf(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      fzf.fzf_exec(file_paths, {
        prompt = "Harpoon❯ ",
        actions = {
          ["default"] = function(selected)
            for i, item in ipairs(harpoon_files.items) do
              if item.value == selected[1] then
                harpoon:list():select(i)
                return
              end
            end
          end,
        },
      })
    end

    vim.keymap.set("n", "<C-e>", function()
      toggle_fzf(harpoon:list())
    end, { desc = "Open harpoon (fzf-lua)" })
  end,
}

