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

-- Custom indentexpr: temporarily replace custom storage-class macros
-- (internal, global, local_persist) with 'static' so cindent understands them.
-- Combined with cinoptions=t0 for "return type on its own line" style.
local macros = { internal = true, global = true, local_persist = true }

local function c_indentexpr()
  local lnum = vim.v.lnum
  local saved = {}

  local start = math.max(1, lnum - 50)
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
