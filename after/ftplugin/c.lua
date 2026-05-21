-- Detect indent width from file content (2 vs 4 spaces)
local function detect_indent()
  local count = math.min(100, vim.api.nvim_buf_line_count(0))
  for i = 0, count - 1 do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
    local spaces = line:match('^( +)%S')
    if spaces and #spaces <= 8 then return #spaces end
  end
  return vim.bo.shiftwidth
end

local sw = detect_indent()
vim.bo.shiftwidth = sw
vim.bo.tabstop = sw
vim.bo.softtabstop = sw
vim.bo.cinoptions = 't0,:0,l1,(0,Ws'

-- Identifier completion for unity-build C/C++ with no LSP. <Tab> (see
-- lua/config/keymaps.lua) routes completion by context:
--   * after `.` / `->` / `::`  -> built-in `ccomplete` omnifunc (members)
--   * on a plain identifier    -> the `completefunc` below: variable and
--     function names from the buffer's treesitter tree + ctags, ranked by
--     scope (local -> file -> project). See lua/config/c_complete.lua.
vim.bo.completefunc = "v:lua.require'config.c_complete'.complete"

-- Drop 'fuzzy' for these buffers so the completefunc's scope ranking is
-- preserved instead of being re-sorted by fuzzy match score. 'noselect'
-- (nothing pre-selected) is kept.
vim.bo.completeopt = 'menu,menuone,noselect'

-- Manual <C-n> keyword completion still works as a fallback: tags first
-- (real symbols), then the current buffer.
vim.bo.complete = 't,.'

-- Custom indentexpr: temporarily replace custom storage-class macros
-- (internal, global, local_persist) with 'static' so cindent understands them.
-- Combined with cinoptions=t0 for "return type on its own line" style.
local macros = { internal = true, global = true, local_persist = true, ["function"] = true }

local function c_indentexpr()
  local lnum = vim.v.lnum
  local saved = {}

  local start = 1
  for i = start, lnum do
    local line = vim.fn.getline(i)
    local ws, word, rest = line:match('^(%s*)(%w+)(.*)')
    if word and macros[word] then
      saved[i] = line
      vim.fn.setline(i, ws .. 'static' .. rest)
    end
  end

  local result = vim.fn.cindent(lnum)

  for i, orig in pairs(saved) do
    vim.fn.setline(i, orig)
  end

  return result
end

_G._c_indentexpr = c_indentexpr
vim.bo.indentexpr = 'v:lua._c_indentexpr()'
vim.bo.smartindent = false

-- Goto-definition via the project tags file. These are unity-build C/C++
-- projects with no LSP, so `gd` is a tag jump: `:tjump` goes straight to a
-- single match and only prompts a picker when a name is ambiguous.
-- The built-in <C-]> (jump) and <C-t> (jump back) work too.
vim.keymap.set('n', 'gd', function()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end
  local ok, err = pcall(vim.cmd, 'tjump ' .. word)
  if not ok then
    vim.notify((tostring(err):gsub('^Vim%b():', '')), vim.log.levels.WARN)
  end
end, { buffer = true, silent = true, desc = 'Go to definition (tags)' })
