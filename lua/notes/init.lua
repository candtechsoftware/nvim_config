local M = {}

-- Notes configuration
M.config = {
    notes_dir = vim.fn.expand("~/notes"),
    auto_commit = true,
    auto_push = false, -- Set to true to auto-push on save
    file_extensions = { ".md", ".txt", ".markdown" },
    default_extension = ".md",
}

local function validate_notes_dir()
    if _G.notes_cached_dir then
        return _G.notes_cached_dir
    end

    local notes_dir = M.config.notes_dir
    if vim.fn.isdirectory(notes_dir) == 1 then
        -- Check if it's a git repo
        local git_dir = notes_dir .. "/.git"
        if vim.fn.isdirectory(git_dir) == 1 then
            _G.notes_cached_dir = notes_dir
            return notes_dir
        else
            return nil
        end
    else
        return nil
    end
end

-- Get all note files recursively (async)
local function scan_notes_async(callback)
    local notes_dir = validate_notes_dir()
    if not notes_dir then
        callback({})
        return
    end

    local files = {}
    local extensions = M.config.file_extensions

    local function scan_directory(dir, cb)
        vim.uv.fs_scandir(dir, function(err, handle)
            if err or not handle then
                cb()
                return
            end

            local function iter()
                local name, type = vim.uv.fs_scandir_next(handle)
                if not name then
                    cb()
                    return
                end

                local full_path = dir .. "/" .. name

                if type == "directory" and not name:match("^%.") then
                    -- Recursively scan subdirectories
                    scan_directory(full_path, iter)
                elseif type == "file" then
                    -- Check if file has valid extension
                    for _, ext in ipairs(extensions) do
                        if name:match(vim.pesc(ext) .. "$") then
                            table.insert(files, full_path)
                            break
                        end
                    end
                    iter()
                else
                    iter()
                end
            end

            iter()
        end)
    end

    scan_directory(notes_dir, function()
        callback(files)
    end)
end

-- Create a new note
function M.new_note(name)
    local notes_dir = validate_notes_dir()
    if not notes_dir then return end

    name = name or vim.fn.input("Note name: ")
    if name == "" then return end

    -- Sanitize filename and add extension if missing
    name = name:gsub("[^%w%s%-_]", ""):gsub("%s+", "-")
    if not name:match("%.%w+$") then
        name = name .. M.config.default_extension
    end

    local filepath = notes_dir .. "/" .. name

    -- Check if file already exists
    if vim.fn.filereadable(filepath) == 1 then
        vim.cmd("edit " .. filepath)
        return
    end

    -- Create the note with a basic template
    local template = string.format("# %s\n\nCreated: %s\n\n",
        name:gsub(M.config.default_extension .. "$", ""):gsub("%-", " "),
        os.date("%Y-%m-%d %H:%M")
    )

    vim.fn.writefile(vim.split(template, '\n'), filepath)
    vim.cmd("edit " .. filepath)
    vim.cmd("normal! G")
end

-- Open notes directory in vertical split
function M.open_notes_dir()
    local notes_dir = validate_notes_dir()
    if not notes_dir then return end

    vim.cmd("vsplit")
    vim.cmd("cd " .. vim.fn.fnameescape(notes_dir))
    vim.cmd("edit .")
end

-- Search notes using telescope
function M.search_notes()
    local telescope_ok, builtin = pcall(require, "telescope.builtin")
    if not telescope_ok then
        return
    end

    local notes_dir = validate_notes_dir()
    if not notes_dir then return end

    builtin.live_grep({
        cwd = notes_dir,
        prompt_title = "Search Notes",
        search_dirs = { notes_dir },
        additional_args = function()
            return { "--type", "md", "--type", "txt" }
        end
    })
end

-- Find notes by filename (optimized with async scanning)
function M.find_notes()
    local notes_dir = validate_notes_dir()
    if not notes_dir then return end

    local telescope_ok, pickers = pcall(require, "telescope.pickers")
    local finders_ok, finders = pcall(require, "telescope.finders")
    local conf_ok, conf = pcall(require, "telescope.config")

    if not (telescope_ok and finders_ok and conf_ok) then
        return
    end

    scan_notes_async(function(files)
        -- Convert absolute paths to relative paths for display
        local display_files = {}
        for _, file in ipairs(files) do
            local relative_path = file:gsub("^" .. vim.pesc(notes_dir) .. "/", "")
            table.insert(display_files, {
                value = file,
                display = relative_path,
                ordinal = relative_path,
            })
        end

        vim.schedule(function()
            pickers.new({}, {
                prompt_title = "Find Notes",
                finder = finders.new_table({
                    results = display_files,
                    entry_maker = function(entry)
                        return {
                            value = entry.value,
                            display = entry.display,
                            ordinal = entry.ordinal,
                        }
                    end,
                }),
                sorter = conf.values.generic_sorter({}),
                previewer = conf.values.file_previewer({}),
                attach_mappings = function(_, map)
                    map("i", "<CR>", function(prompt_bufnr)
                        local selection = require("telescope.actions.state").get_selected_entry()
                        require("telescope.actions").close(prompt_bufnr)
                        if selection then
                            vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
                        end
                    end)
                    return true
                end,
            }):find()
        end)
    end)
end

-- Git operations
function M.git_status()
    local notes_dir = validate_notes_dir()
    if not notes_dir then return end

    vim.cmd("split")
    vim.cmd("terminal")
    local term_cmd = "cd " .. vim.fn.shellescape(notes_dir) .. " && git status"
    vim.fn.chansend(vim.b.terminal_job_id, term_cmd .. "\r")
end

-- Auto-commit function
function M.auto_commit(filepath)
    if not M.config.auto_commit then return end

    local notes_dir = validate_notes_dir()
    if not notes_dir then return end

    -- Check if file is in notes directory
    if not vim.startswith(filepath, notes_dir) then return end

    local filename = vim.fn.fnamemodify(filepath, ":t")
    local commit_msg = string.format("Auto-save: %s - %s", filename, os.date("%Y-%m-%d %H:%M"))

    -- Run git commands asynchronously
    vim.system({
        "git", "-C", notes_dir, "add", filepath
    }, {}, function(result)
        if result.code == 0 then
            vim.system({
                "git", "-C", notes_dir, "commit", "-m", commit_msg
            }, {}, function(commit_result)
                if commit_result.code == 0 then

                    -- Auto-push if enabled
                    if M.config.auto_push then
                        vim.system({
                            "git", "-C", notes_dir, "push"
                        }, {}, function(push_result)
                            if push_result.code ~= 0 then
                                vim.schedule(function()
                                    vim.notify("Failed to auto-push note: " .. filename, vim.log.levels.WARN)
                                end)
                            end
                        end)
                    end
                else
                    vim.schedule(function()
                        vim.notify("Failed to auto-commit note: " .. filename, vim.log.levels.WARN)
                    end)
                end
            end)
        end
    end)
end

-- Setup function
function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend("force", M.config, opts)

    -- Validate notes directory on setup
    if not validate_notes_dir() then
        return
    end

    -- Set up auto-commit on save for notes files
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = M.config.notes_dir .. "/*",
        callback = function(args)
            M.auto_commit(args.file)
        end,
        desc = "Auto-commit notes on save"
    })

    -- Create user commands
    vim.api.nvim_create_user_command("NotesNew", function(cmd)
        M.new_note(cmd.args)
    end, {
        nargs = "?",
        desc = "Create a new note",
        complete = function()
            return {}
        end
    })

    vim.api.nvim_create_user_command("NotesSearch", M.search_notes, { desc = "Search notes content" })
    vim.api.nvim_create_user_command("NotesFind", M.find_notes, { desc = "Find notes by filename" })
    vim.api.nvim_create_user_command("NotesDir", M.open_notes_dir, { desc = "Open notes directory" })
    vim.api.nvim_create_user_command("NotesGit", M.git_status, { desc = "Show git status for notes" })

    -- Clear cache command
    vim.api.nvim_create_user_command("NotesReset", function()
        _G.notes_cached_dir = nil
    end, { desc = "Reset notes directory cache" })

    -- Keymaps
    vim.keymap.set("n", "<leader>ns", M.search_notes, { desc = "Search notes content" })
    vim.keymap.set("n", "<leader>nf", M.find_notes, { desc = "Find notes by filename" })
    vim.keymap.set("n", "<leader>nn", M.new_note, { desc = "Create new note" })
    vim.keymap.set("n", "<leader>n", M.open_notes_dir, { desc = "Open notes directory" })
    vim.keymap.set("n", "<leader>ng", M.git_status, { desc = "Notes git status" })
end

return M