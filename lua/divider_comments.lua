-- Divider Comments: Render horizontal lines above //- style comments
local M = {}

local ns_id = vim.api.nvim_create_namespace("divider_comments")
local pending_timer = nil

-- Pattern to match section comments: //- (C/C++), #- (shell/python), --- (lua)
local section_pattern = "^%s*//%-"
local alt_patterns = { "^%s*#%-", "^%s*%-%-%-" }

local function is_section_comment(line)
    if line:match(section_pattern) then return true end
    for _, pat in ipairs(alt_patterns) do
        if line:match(pat) then return true end
    end
    return false
end

-- Jump to next section comment
function M.goto_next_section()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    for i = current_line + 1, #lines do
        if is_section_comment(lines[i]) then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            vim.cmd("normal! zz")
            return
        end
    end
    vim.notify("No more sections below", vim.log.levels.INFO)
end

-- Jump to previous section comment
function M.goto_prev_section()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    for i = current_line - 1, 1, -1 do
        if is_section_comment(lines[i]) then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            vim.cmd("normal! zz")
            return
        end
    end
    vim.notify("No more sections above", vim.log.levels.INFO)
end

-- Get all section comments in current buffer
function M.get_sections()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local sections = {}

    for i, line in ipairs(lines) do
        if is_section_comment(line) then
            -- Extract the comment text (remove comment prefix and leading whitespace)
            local text = line:gsub("^%s*//%-+%s*", "")
                             :gsub("^%s*#%-+%s*", "")
                             :gsub("^%s*%-%-%-+%s*", "")
            table.insert(sections, {
                lnum = i,
                text = text ~= "" and text or "(section)",
                line = line,
            })
        end
    end

    return sections
end

-- Telescope picker for section comments
function M.telescope_sections()
    local ok, telescope = pcall(require, "telescope")
    if not ok then
        vim.notify("Telescope not available", vim.log.levels.ERROR)
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local sections = M.get_sections()

    if #sections == 0 then
        vim.notify("No section comments found in buffer", vim.log.levels.INFO)
        return
    end

    pickers.new({}, {
        prompt_title = "Section Comments",
        finder = finders.new_table({
            results = sections,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format("%4d: %s", entry.lnum, entry.text),
                    ordinal = entry.text,
                    lnum = entry.lnum,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
                    vim.cmd("normal! zz")
                end
            end)
            return true
        end,
    }):find()
end

function M.render_dividers()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Clear existing extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local width = vim.api.nvim_win_get_width(0)

  for i, line in ipairs(lines) do
    if is_section_comment(line) then
      local divider_line = string.rep("─", width)
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
        virt_lines_above = true,
        virt_lines = { { { divider_line, "Comment" } } },
      })
    end
  end
end

local function render_debounced()
  if pending_timer then
    vim.uv.timer_stop(pending_timer)
  end
  pending_timer = vim.defer_fn(function()
    pending_timer = nil
    M.render_dividers()
  end, 50)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("DividerComments", { clear = true })

  -- Immediate render for these events (no conflict with treesitter)
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "WinResized" }, {
    group = group,
    callback = function()
      M.render_dividers()
    end,
  })

  -- Debounced render for text changes (avoids race with treesitter)
  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    group = group,
    callback = function()
      render_debounced()
    end,
  })

  -- Keymaps for section navigation
  vim.keymap.set("n", "]s", M.goto_next_section, { desc = "Go to next section comment" })
  vim.keymap.set("n", "[s", M.goto_prev_section, { desc = "Go to previous section comment" })
  vim.keymap.set("n", "<leader>ss", M.telescope_sections, { desc = "Search section comments" })
end

return M
