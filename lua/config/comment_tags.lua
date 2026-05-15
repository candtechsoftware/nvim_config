-- Comment tag highlights: NOTE(alex), TODO(alex), PERF(alex), etc.

local M = {}

-- matchadd is window-local. Track ids per-window so the same window
-- doesn't accumulate duplicate matches every time FileType fires.
local match_ids = {}

local function set_highlights()
    local set = vim.api.nvim_set_hl
    set(0, "CommentTagNote",  { fg = "#2ab34f" })
    set(0, "CommentTagTodo",  { fg = "#ffa900" })
    set(0, "CommentTagPerf",  { fg = "#2895c7" })
    set(0, "CommentTagFixme", { fg = "#ff0000" })
    set(0, "CommentTagHack",  { fg = "#FF44DD" })
end

local function setup_matches()
    local winid = vim.api.nvim_get_current_win()
    if match_ids[winid] then return end
    match_ids[winid] = {}

    local function add(group, pattern)
        local id = vim.fn.matchadd(group, pattern)
        table.insert(match_ids[winid], id)
    end

    add("CommentTagNote",  [[\v<NOTE(\([^)]*\))?:?]])
    add("CommentTagTodo",  [[\v<TODO(\([^)]*\))?:?]])
    add("CommentTagPerf",  [[\v<PERF(\([^)]*\))?:?]])
    add("CommentTagFixme", [[\v<FIXME(\([^)]*\))?:?]])
    add("CommentTagHack",  [[\v<HACK(\([^)]*\))?:?]])
    add("CommentTagHack",  [[\v<XXX(\([^)]*\))?:?]])
end

function M.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = set_highlights,
    })

    local group = vim.api.nvim_create_augroup("CommentTags", { clear = true })

    vim.api.nvim_create_autocmd({ "FileType", "WinEnter" }, {
        group = group,
        callback = setup_matches,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = function(ev)
            local wid = tonumber(ev.match)
            if wid then match_ids[wid] = nil end
        end,
    })
end

return M
