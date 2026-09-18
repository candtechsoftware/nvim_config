-- For "this buffer feels slow". Only the lagging session can measure it:
-- headless nvim has no redraw, so synthetic benchmarks read ~0ms.
--   :PerfProbe            what this buffer and session cost, per subsystem
--   :PerfToggle {target}  switch one subsystem off/on to bisect the lag
local M = {}

-- Median of n runs in ms, so one GC pause does not read as a hot path.
local function ms(fn, n)
  local t = {}
  for i = 1, n do
    local t0 = vim.uv.hrtime()
    fn()
    t[i] = (vim.uv.hrtime() - t0) / 1e6
  end
  table.sort(t)
  return t[math.ceil(n / 2)]
end

local function size(bytes)
  return bytes >= 1e6 and ('%.1f MB'):format(bytes / 1e6) or ('%.0f KB'):format(bytes / 1024)
end

local function treesitter_lines(buf, add)
  local parser = vim.treesitter.get_parser(buf)
  local root = parser:parse()[1]:root()
  add('         full reparse      %7.2f ms', ms(function()
    parser:invalidate(true)
    parser:parse(true)
  end, 3))

  -- nvim only runs the highlight query over the visible range.
  local query = vim.treesitter.query.get(parser:lang(), 'highlights')
  if query then
    local top, bot = vim.fn.line('w0') - 1, vim.fn.line('w$')
    local screen = ms(function() for _ in query:iter_captures(root, buf, top, bot) do end end, 9)
    local whole = ms(function() for _ in query:iter_captures(root, buf, 0, -1) do end end, 3)
    add('         highlight/screen  %7.2f ms   (whole file %.1f ms)', screen, whole)
  end

  local errors = 0
  local function walk(node)
    if node:type() == 'ERROR' then errors = errors + 1 end
    for child in node:iter_children() do walk(child) end
  end
  walk(root)
  add('         ERROR nodes       %7d   (storage-class macros inflate the query)', errors)
end

function M.probe()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local nlines = vim.api.nvim_buf_line_count(buf)
  local st = name ~= '' and vim.uv.fs_stat(name)
  local out = {}
  local function add(fmt, ...) out[#out + 1] = fmt:format(...) end

  add('buffer   %s', name ~= '' and vim.fn.fnamemodify(name, ':~:.') or '[No Name]')
  add('         %d lines, %s, ft=%s', nlines, st and size(st.size) or '?', vim.bo.filetype)

  local clients = vim.lsp.get_clients({ bufnr = buf })
  if #clients == 0 then add('lsp      none attached') end
  for _, c in ipairs(clients) do
    add('lsp      %s  root=%s', c.name, vim.fn.fnamemodify(tostring(c.config.root_dir), ':~'))
    add('         semantic_tokens=%s  folding=%s  diagnostics=%d',
      tostring(c.server_capabilities.semanticTokensProvider ~= nil),
      tostring(c.server_capabilities.foldingRangeProvider ~= nil),
      #vim.diagnostic.get(buf))
  end

  local has_ts = vim.treesitter.highlighter.active[buf] ~= nil
  add('treesitter %s   syntax=%s', has_ts and 'on' or 'OFF', vim.bo.syntax == '' and '(none)' or vim.bo.syntax)
  if has_ts then treesitter_lines(buf, add) end

  add('fold     foldmethod=%s  foldexpr=%s', vim.wo.foldmethod, tostring(vim.wo.foldexpr))
  -- Only the LSP foldexpr can be timed: it is a Lua function callable per line.
  if vim.wo.foldmethod == 'expr' and tostring(vim.wo.foldexpr):find('lsp.foldexpr', 1, true) then
    local n = math.min(nlines, 2000)
    add('         foldexpr x%-5d   %7.2f ms', n, ms(function()
      for line = 1, n do vim.lsp.foldexpr(line) end
    end, 3))
  end
  if vim.bo.indentexpr ~= '' then
    local view = vim.fn.winsaveview()
    add('indent   one `==`          %7.2f ms', ms(function() vim.cmd('silent! normal! ==') end, 9))
    vim.fn.winrestview(view)
  end

  local tagfile = vim.split(vim.bo.tags, ',', { trimempty = true })[1]
  local tst = tagfile and vim.uv.fs_stat(tagfile)
  add('tags     %s', tst and ('%s  (%s)'):format(vim.fn.fnamemodify(tagfile, ':~'), size(tst.size)) or 'none built')
  add('         project root = %s', vim.fn.fnamemodify(require('config.project').root(buf), ':~'))

  -- What a long session accumulates: every loaded C buffer is walked by the
  -- <Tab> completefunc, and each project root gets its own clangd.
  local loaded, listed, cfamily = 0, 0, 0
  local C = { c = true, cpp = true, objc = true, objcpp = true }
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      loaded = loaded + 1
      if vim.bo[b].buflisted then listed = listed + 1 end
      if C[vim.bo[b].filetype] then cfamily = cfamily + 1 end
    end
  end
  add('session  %d buffers loaded (%d listed, %d C-family)', loaded, listed, cfamily)
  local roots = vim.tbl_map(function(c)
    return c.name .. ':' .. vim.fn.fnamemodify(tostring(c.config.root_dir), ':t')
  end, vim.lsp.get_clients())
  add('         %d LSP client(s): %s', #roots, #roots > 0 and table.concat(roots, ', ') or 'none')
  local ps = vim.system({ 'sh', '-c',
    "ps -Ao rss,comm | awk '/clangd/ {n++; s+=$1} END {printf \"%d %d\", n+0, s/1024}'" }, { text = true }):wait()
  local n, mb = (ps.stdout or ''):match('(%d+)%s+(%d+)')
  if n then add('         %s clangd process(es), %s MB resident total', n, mb) end

  vim.notify(table.concat(out, '\n'))
end

-- Saved 'indentexpr' per buffer while the indent toggle has it off.
local saved_indentexpr = {}

local toggles = {
  lsp = function(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf })
    if #clients == 0 then
      vim.cmd.edit()
      return 'reloaded buffer, LSP will reattach'
    end
    for _, c in ipairs(clients) do vim.lsp.buf_detach_client(buf, c.id) end
    vim.diagnostic.reset(nil, buf)
    return 'LSP detached from this buffer (:edit to reattach)'
  end,
  ts = function(buf)
    if vim.treesitter.highlighter.active[buf] then
      vim.treesitter.stop(buf)
      return 'treesitter highlighting OFF'
    end
    vim.treesitter.start(buf)
    return 'treesitter highlighting ON'
  end,
  syntax = function()
    local off = vim.bo.syntax == 'off'
    vim.bo.syntax = off and vim.bo.filetype or 'off'
    return 'syntax ' .. (off and 'ON' or 'OFF')
  end,
  fold = function()
    local on = vim.wo.foldmethod ~= 'expr'
    vim.wo.foldmethod = on and 'expr' or 'manual'
    vim.wo.foldexpr = on and 'v:lua.vim.lsp.foldexpr()' or ''
    return 'LSP foldexpr ' .. (on and 'ON' or 'OFF')
  end,
  diag = function(buf)
    local on = not vim.diagnostic.is_enabled({ bufnr = buf })
    vim.diagnostic.enable(on, { bufnr = buf })
    return 'diagnostics ' .. (on and 'ON' or 'OFF')
  end,
  indent = function(buf)
    if saved_indentexpr[buf] then
      vim.bo.indentexpr = saved_indentexpr[buf]
      saved_indentexpr[buf] = nil
      return 'indentexpr ON'
    end
    saved_indentexpr[buf] = vim.bo.indentexpr
    vim.bo.indentexpr = ''
    return 'indentexpr OFF'
  end,
  matchparen = function()
    local on = vim.g.loaded_matchparen ~= 1
    vim.cmd(on and 'DoMatchParen' or 'NoMatchParen')
    vim.g.loaded_matchparen = on and 1 or 0
    return 'matchparen ' .. (on and 'ON' or 'OFF')
  end,
}

function M.setup()
  vim.api.nvim_create_user_command('PerfProbe', M.probe, { desc = 'Per-subsystem cost of this buffer' })
  vim.api.nvim_create_user_command('PerfToggle', function(o)
    local toggle = toggles[o.args]
    if toggle then
      vim.notify('PerfToggle: ' .. toggle(vim.api.nvim_get_current_buf()))
    else
      vim.notify('PerfToggle: unknown target ' .. o.args, vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function() return vim.tbl_keys(toggles) end,
    desc = 'Toggle one subsystem to bisect lag',
  })
end

return M
