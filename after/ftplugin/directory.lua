-- The 0.13 builtin browser (`:h dir`) renders a bare listing: names, a `/` on
-- directories, no colour and no cursor line. Paint it, and add the filesystem
-- keys the browser deliberately leaves out (it is navigation-only: `<CR>`
-- open, `-` up, `R` reload).
local buf = vim.api.nvim_get_current_buf()

-- 'cursorline' is window-local, so it would follow the window into whatever
-- file the listing opens. Tie it to the listing being on screen.
vim.wo.cursorline = true
vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
    buffer = buf,
    desc = "Cursorline only while the directory listing is current",
    callback = function(ev)
        vim.wo.cursorline = ev.event == "BufEnter"
    end,
})

-- What `R` and `<Plug>(nvim-dir-reload)` call: it redraws the listing in
-- place, keeping the cursor where `:edit` would have reset it.
local reload = require("nvim.dir")._reload

local function dirpath()
    return vim.api.nvim_buf_get_name(buf)
end

-- The listing renders a newline in a name as NUL (nvim.dir's encode_name), so
-- decode it before touching the filesystem.
local function entry()
    local line = vim.api.nvim_get_current_line()
    local isdir = line:sub(-1) == "/"
    local name = ((isdir and line:sub(1, -2) or line):gsub("%z", "\n"))
    return name, isdir
end

vim.keymap.set("n", "%", function()
    local name = vim.fn.input("New file: ")
    if name ~= "" then
        vim.cmd.edit(vim.fs.joinpath(dirpath(), name))
    end
end, { buffer = buf, desc = "New file in this directory (:w to create)" })

vim.keymap.set("n", "d", function()
    local name = vim.fn.input("New directory: ")
    if name ~= "" then
        vim.fn.mkdir(vim.fs.joinpath(dirpath(), name), "p")
        reload(buf)
    end
end, { buffer = buf, desc = "New directory here" })

vim.keymap.set("n", "D", function()
    local name, isdir = entry()
    if name == "" then return end
    local what = isdir and ("directory " .. name .. " and its contents") or name
    if vim.fn.confirm("Delete " .. what .. "?", "&Yes\n&No", 2) ~= 1 then
        return
    end
    local path = vim.fs.joinpath(dirpath(), name)
    if vim.fn.delete(path, isdir and "rf" or "") ~= 0 then
        vim.notify("Failed to delete " .. path, vim.log.levels.ERROR)
    end
    reload(buf)
end, { buffer = buf, desc = "Delete entry under cursor" })

vim.keymap.set("n", "r", function()
    local name = entry()
    if name == "" then return end
    local newname = vim.fn.input({ prompt = "Rename to: ", default = name })
    if newname == "" or newname == name then return end
    local from = vim.fs.joinpath(dirpath(), name)
    local to = vim.fs.joinpath(dirpath(), newname)
    if vim.fn.rename(from, to) ~= 0 then
        vim.notify("Failed to rename " .. from, vim.log.levels.ERROR)
    end
    reload(buf)
end, { buffer = buf, desc = "Rename entry under cursor" })

-- The listing is a snapshot: nvim.dir renders it once and redraws only on `R`.
-- Watch the directory with the OS filewatcher that backs 'autoread' so a file
-- created outside this buffer shows up on its own. The keys above still redraw
-- themselves: their feedback should not wait on the debounce.
local ok, unwatch = pcall(vim._watch.watch, dirpath(), { debounce = 100 }, function()
    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
            reload(buf)
        end
    end)
end)

if ok then
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
        buffer = buf,
        desc = "Stop watching the directory behind the listing",
        callback = function()
            unwatch()
        end,
    })
end
