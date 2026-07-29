-- Jai filetype detection + options (native, no plugin)
vim.filetype.add({ extension = { jai = "jai" } })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "jai",
  callback = function()
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
    -- Indent from the treesitter tree (queries/jai/indents.scm), not from
    -- text heuristics. The hand-rolled predecessor looked exactly one line
    -- back -- "previous line ends with `{` or `(` -> add a shiftwidth" -- so a
    -- parameter list wrapped across lines got no indent at all, because line
    -- one does not *end* with `(`:
    --
    --     emit_sprite_quad :: (x0: float, y0: float, x1: float,
    --     y1: float, u0: float, v_bottom: float) {
    --
    -- The query knows where the `(` is and aligns under it. cindent is not an
    -- option either: it reads `name: Type` as a C goto-label and flushes the
    -- line to column 0.
    require('config.ts_indent').attach()
    -- `;` is in here because a `case` label only becomes a `switch_case` node
    -- once its terminator exists -- typing `case .B` alone leaves the tree in
    -- an error state, so the reindent has to wait for the `;`. For every other
    -- statement the recomputed indent is the one it already had.
    vim.bo.indentkeys = '0{,0},0),0],;,!^F,o,O,0=case,0=#'
    -- No errorformat here. This used to set "%f:%l\,%c:%m", which raced the
    -- richer jai errorformat in utils/make_detect.lua from a second FileType
    -- autocmd — whichever ran last won, so which one you got depended on
    -- autocmd registration order. make_detect owns errorformat.
    vim.bo.define = "^\\s*\\w\\+\\s*:.*:.*\\s*[({]"
  end,
})
