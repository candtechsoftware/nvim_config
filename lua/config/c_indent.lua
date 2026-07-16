-- Shared indent machinery for the C-family ftplugins.
--
-- `cindent` does not understand this codebase's storage-class macros
-- (`internal`, `global`, ...), so the trick everywhere here is to rewrite those
-- lines to `static`, call `cindent`, then restore. The rewrite window is the
-- part that has to be right: it lives in `scan_start` so C and Obj-C++ cannot
-- drift apart. They already did once — the O(file length) scan was fixed in
-- after/ftplugin/c.lua but the copy in objcpp.lua kept its `for i = 1, lnum`,
-- so `.m`/`.mm` still hung on a `=` motion long after C was fast.
local M = {}

M.macros = { internal = true, global = true, local_persist = true, ["function"] = true }

-- Hard ceiling on the rewrite window for the pathological case: a function
-- longer than this, or a file with no top-level `}` above the cursor at all.
local MAX_SCAN = 500

---First line the rewrite has to cover for `cindent(lnum)` to be correct.
---
---This used to be line 1, which made every single indent O(file length): one
---getline per line from the top of the file, on every `o`, `}`, <CR> and each
---line of a `=` motion. At line 16000 of a 17k-line unity build that was 9ms
---per line, so reindenting a 300-line region took ~2.7s and the editor read as
---hung. cindent never looks above the `}` at column 0 that closes the previous
---top-level definition, so rewriting anything above it was pure waste.
---@param lnum integer
---@return integer
function M.scan_start(lnum)
  local floor = math.max(1, lnum - MAX_SCAN)
  for i = lnum - 1, floor, -1 do
    if vim.fn.getline(i):match('^}') then return i + 1 end
  end
  return floor
end

---Build an indentexpr that rewrites each line in the scan window via `transform`
---before handing off to `cindent`, then restores the buffer verbatim.
---@param transform fun(line: string): string?  nil / unchanged means "leave alone"
---@return fun(): integer
function M.make_indentexpr(transform)
  return function()
    local lnum = vim.v.lnum
    local saved = {}

    for i = M.scan_start(lnum), lnum do
      local line = vim.fn.getline(i)
      local new_line = transform(line)
      if new_line and new_line ~= line then
        saved[i] = line
        vim.fn.setline(i, new_line)
      end
    end

    local result = vim.fn.cindent(lnum)

    for i, orig in pairs(saved) do
      vim.fn.setline(i, orig)
    end

    return result
  end
end

---Rewrite a leading storage-class macro to `static`.
---@param line string
---@return string
function M.sub_macros(line)
  local ws, word, rest = line:match('^(%s*)(%w+)(.*)')
  if word and M.macros[word] then
    return ws .. 'static' .. rest
  end
  return line
end

return M
