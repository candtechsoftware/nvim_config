-- Comment tag highlights: NOTE(alex), TODO(alex), PERF(alex), etc.

local M = {}

local function set_highlights()
    local set = vim.api.nvim_set_hl
    set(0, "CommentTagNote",  { fg = "#2ab34f" })
    set(0, "CommentTagTodo",  { fg = "#ffa900" })
    set(0, "CommentTagPerf",  { fg = "#2895c7" })
    set(0, "CommentTagFixme", { fg = "#ff0000" })
    set(0, "CommentTagHack",  { fg = "#FF44DD" })
end

function M.setup()
    set_highlights()

    -- Re-apply after colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = set_highlights,
    })

    -- Match patterns for NOTE(name)/TODO(name)/PERF(name) style comments
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
            vim.fn.matchadd("CommentTagNote",  [[\v<NOTE(\([^)]*\))?:?]])
            vim.fn.matchadd("CommentTagTodo",  [[\v<TODO(\([^)]*\))?:?]])
            vim.fn.matchadd("CommentTagPerf",  [[\v<PERF(\([^)]*\))?:?]])
            vim.fn.matchadd("CommentTagFixme", [[\v<FIXME(\([^)]*\))?:?]])
            vim.fn.matchadd("CommentTagHack",  [[\v<HACK(\([^)]*\))?:?]])
            vim.fn.matchadd("CommentTagHack",  [[\v<XXX(\([^)]*\))?:?]])
        end,
    })
end

return M
