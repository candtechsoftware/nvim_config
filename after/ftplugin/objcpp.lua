-- Reuse C ftplugin settings for Objective-C++
dofile(vim.fn.stdpath("config") .. "/after/ftplugin/c.lua")

-- Override indentexpr: extend C version to also neutralize id<Protocol> angle brackets
-- that confuse cindent (it treats < > as operators, breaking indentation)
local macros = { internal = true, global = true, local_persist = true, ["function"] = true }

local function objcpp_indentexpr()
  local lnum = vim.v.lnum
  local saved = {}

  for i = 1, lnum do
    local line = vim.fn.getline(i)
    local new_line = line
    local changed = false

    -- Replace custom storage-class macros with 'static'
    local ws, word, rest = new_line:match('^(%s*)(%w+)(.*)')
    if word and macros[word] then
      new_line = ws .. 'static' .. rest
      changed = true
    end

    -- Replace id<Protocol> with plain typedef so cindent doesn't choke on angle brackets
    if new_line:find('id<') then
      new_line = new_line:gsub('id<([%w_]+)>', 'id_%1')
      changed = true
    end

    if changed then
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

_G._objcpp_indentexpr = objcpp_indentexpr
vim.bo.indentexpr = 'v:lua._objcpp_indentexpr()'
