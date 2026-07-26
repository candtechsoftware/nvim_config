-- Interactive performance probe for "this buffer feels sluggish".
--
-- Everything here exists because the slowness could NOT be reproduced from a
-- headless nvim: `redraw` is a no-op with no UI attached, and `feedkeys`
-- without the 'x' flag only queues, so synthetic keystroke benchmarks report
-- ~0ms no matter how slow the real editor feels. The only trustworthy
-- measurement is one taken in the session that is actually lagging, which is
-- what :PerfProbe and :PerfToggle are for.
--
--   :PerfProbe    one-shot report — what this buffer costs, per subsystem
--   :PerfToggle   A/B a single subsystem off and on, live, while it feels slow
--
-- Usage when it lags: run :PerfProbe first (it names the expensive subsystem
-- outright when one dominates). If nothing stands out, :PerfToggle lsp, type
-- for a few seconds, and keep going down the list until the lag disappears —
-- whatever you turned off last is the culprit.

local M = {}

---Median of `n` timed runs, in ms. Median, not mean: one GC pause or a stray
---LSP response otherwise dominates a short sample and reads as a hot path.
---@param fn fun()
---@param n integer
---@return number
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

---@param buf integer
---@return integer
local function error_nodes(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return 0 end
  local tree = (parser:parse() or {})[1]
  if not tree then return 0 end
  local n = 0
  local function walk(node)
    if node:type() == 'ERROR' then n = n + 1 end
    for c in node:iter_children() do walk(c) end
  end
  walk(tree:root())
  return n
end

---Time one screenful of the highlight query — the unit that actually matters
---for redraw. Whole-file query time is reported by :PerfProbe too, but nvim
---only ever runs the query over the visible range plus a margin.
---@param buf integer
---@return number? per_screen_ms, number? whole_file_ms
local function highlight_cost(buf)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end
  local tree = (parser:parse() or {})[1]
  if not tree then return end
  local q = vim.treesitter.query.get(parser:lang(), 'highlights')
  if not q then return end
  local root = tree:root()
  local top = vim.fn.line('w0') - 1
  local bot = vim.fn.line('w$')
  local screen = ms(function()
    for _ in q:iter_captures(root, buf, top, bot) do end
  end, 9)
  local whole = ms(function()
    for _ in q:iter_captures(root, buf, 0, -1) do end
  end, 3)
  return screen, whole
end

---Cost of one `==` at the cursor. This is the custom cindent-wrapper in
---config.c_indent, which rewrites storage-class macros to `static` via
---setline() and restores them — every one of those writes fires the buffer
---change path (treesitter reparse + LSP didChange), so it is measured as a
---real indent, not as a bare function call.
---@return number?
local function indent_cost()
  if vim.bo.indentexpr == '' then return end
  local view = vim.fn.winsaveview()
  local ok, r = pcall(ms, function() vim.cmd('silent! normal! ==') end, 9)
  vim.fn.winrestview(view)
  return ok and r or nil
end

---@param bytes integer
---@return string
local function human(bytes)
  if bytes >= 1e6 then return ('%.1f MB'):format(bytes / 1e6) end
  return ('%.0f KB'):format(bytes / 1024)
end

function M.probe()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local nlines = vim.api.nvim_buf_line_count(buf)
  local st = name ~= '' and vim.uv.fs_stat(name) or nil
  local out = {}
  local function add(fmt, ...) out[#out + 1] = fmt:format(...) end

  add('buffer   %s', name ~= '' and vim.fn.fnamemodify(name, ':~:.') or '[No Name]')
  add('         %d lines, %s, ft=%s', nlines, st and human(st.size) or '?', vim.bo.filetype)

  -- LSP
  local clients = vim.lsp.get_clients({ bufnr = buf })
  if #clients == 0 then
    add('lsp      none attached')
  else
    for _, c in ipairs(clients) do
      add('lsp      %s  root=%s', c.name, vim.fn.fnamemodify(tostring(c.config.root_dir), ':~'))
      add('         semantic_tokens=%s  folding=%s  diagnostics=%d',
        tostring(c.server_capabilities.semanticTokensProvider ~= nil),
        tostring(c.server_capabilities.foldingRangeProvider ~= nil),
        #vim.diagnostic.get(buf))
    end
  end

  -- treesitter
  local has_ts = vim.treesitter.highlighter.active[buf] ~= nil
  add('treesitter %s   syntax=%s', has_ts and 'on' or 'OFF',
    vim.bo.syntax == '' and '(none)' or vim.bo.syntax)
  if has_ts then
    local parse = ms(function()
      local p = vim.treesitter.get_parser(buf)
      p:invalidate(true)
      p:parse(true)
    end, 3)
    local screen, whole = highlight_cost(buf)
    add('         full reparse      %7.2f ms', parse)
    if screen then
      add('         highlight/screen  %7.2f ms   (whole file %.1f ms)', screen, whole)
    end
    add('         ERROR nodes       %7d   (storage-class macros; inflates the query)',
      error_nodes(buf))
  end

  -- fold + indent, the two per-keystroke expressions
  add('fold     foldmethod=%s%s', vim.wo.foldmethod,
    vim.wo.foldexpr ~= '' and (' foldexpr=' .. vim.wo.foldexpr) or '')
  -- Only the LSP foldexpr is timed directly: it is a Lua function, so it can
  -- be called per line. An arbitrary vimscript foldexpr would need v:lnum set
  -- by the fold engine, which cannot be faked from here.
  if vim.wo.foldmethod == 'expr' and vim.wo.foldexpr:find('lsp.foldexpr', 1, true) then
    local n = math.min(nlines, 2000)
    add('         foldexpr x%-5d   %7.2f ms', n, ms(function()
      for line = 1, n do vim.lsp.foldexpr(line) end
    end, 3))
  end
  local ind = indent_cost()
  if ind then
    local ok_ci, ci = pcall(require, 'config.c_indent')
    local win = ok_ci and (vim.fn.line('.') - ci.scan_start(vim.fn.line('.'))) or -1
    add('indent   one `==`          %7.2f ms   (rewrite window %d lines)', ind, win)
  end

  -- tags: the completion path reads this on every <Tab>
  local tagfile = vim.split(vim.bo.tags, ',', { trimempty = true })[1]
  local tst = tagfile and vim.uv.fs_stat(tagfile)
  add('tags     %s', tst and ('%s  (%s)'):format(vim.fn.fnamemodify(tagfile, ':~'), human(tst.size))
    or 'none built')
  local root_ok, root_util = pcall(require, 'utils.project_root')
  if root_ok then
    add('         project root = %s', vim.fn.fnamemodify(root_util.find({ buf = buf }), ':~'))
  end

  -- Session-level state. Per-buffer numbers came back clean on files that
  -- nonetheless felt slow, and a fresh nvim types these same files at
  -- ~0.4ms/keystroke — so what differs is everything a long session
  -- accumulates: buffers, one clangd per project root, and the completion
  -- caches that scale with both.
  local loaded, ctype, listed = 0, 0, 0
  local CFT = { c = true, cpp = true, objc = true, objcpp = true }
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      loaded = loaded + 1
      if vim.bo[b].buflisted then listed = listed + 1 end
      if CFT[vim.bo[b].filetype] then ctype = ctype + 1 end
    end
  end
  add('session  %d buffers loaded (%d listed, %d C-family)', loaded, listed, ctype)

  -- Every loaded C buffer is walked by the <Tab> completefunc, and each keeps
  -- a live treesitter parser.
  local all = vim.lsp.get_clients()
  local roots = {}
  for _, c in ipairs(all) do
    roots[#roots + 1] = ('%s:%s'):format(c.name, vim.fn.fnamemodify(tostring(c.config.root_dir), ':t'))
  end
  add('         %d LSP client(s): %s', #all,
    #roots > 0 and table.concat(roots, ', ') or 'none')

  -- One clangd process per distinct root — the per-subproject .clangd layout
  -- trades a single huge index for several small ones, so the count matters.
  local ps = vim.system({ 'sh', '-c',
    "ps -Ao rss,comm | awk '/clangd/ {n++; s+=$1} END {printf \"%d %d\", n+0, s/1024}'" },
    { text = true }):wait()
  if ps.code == 0 and ps.stdout then
    local n, mb = ps.stdout:match('(%d+)%s+(%d+)')
    if n then add('         %s clangd process(es), %s MB resident total', n, mb) end
  end

  vim.notify(table.concat(out, '\n'), vim.log.levels.INFO)
end

-- Live A/B switches. Each returns a short status string so :PerfToggle can
-- report what state it left things in.
local toggles = {
  lsp = function(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf })
    if #clients > 0 then
      for _, c in ipairs(clients) do vim.lsp.buf_detach_client(buf, c.id) end
      vim.diagnostic.reset(nil, buf)
      return 'LSP detached from this buffer (:edit to reattach)'
    end
    vim.cmd('edit')
    return 'reloaded buffer — LSP will reattach'
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
    if vim.wo.foldmethod == 'expr' then
      vim.wo.foldmethod, vim.wo.foldexpr = 'manual', ''
      return 'foldmethod=manual (LSP foldexpr off)'
    end
    vim.wo.foldmethod, vim.wo.foldexpr = 'expr', 'v:lua.vim.lsp.foldexpr()'
    return 'foldmethod=expr (LSP foldexpr on)'
  end,
  diag = function(buf)
    local on = vim.diagnostic.is_enabled({ bufnr = buf })
    vim.diagnostic.enable(not on, { bufnr = buf })
    return 'diagnostics ' .. (on and 'OFF' or 'ON')
  end,
  indent = function()
    if vim.bo.indentexpr ~= '' then
      vim.b._perf_saved_indentexpr = vim.bo.indentexpr
      vim.bo.indentexpr = ''
      return 'indentexpr OFF (cindent wrapper disabled)'
    end
    vim.bo.indentexpr = vim.b._perf_saved_indentexpr or ''
    return 'indentexpr ON'
  end,
  matchparen = function()
    if vim.g.loaded_matchparen == 1 then
      vim.cmd('NoMatchParen')
      vim.g.loaded_matchparen = 0
      return 'matchparen OFF'
    end
    vim.cmd('DoMatchParen')
    vim.g.loaded_matchparen = 1
    return 'matchparen ON'
  end,
}

function M.setup()
  vim.api.nvim_create_user_command('PerfProbe', function() M.probe() end,
    { desc = 'Report per-subsystem cost for the current buffer' })

  vim.api.nvim_create_user_command('PerfToggle', function(cmd)
    local fn = toggles[cmd.args]
    if not fn then
      vim.notify('PerfToggle: unknown target ' .. cmd.args, vim.log.levels.ERROR)
      return
    end
    vim.notify('PerfToggle: ' .. fn(vim.api.nvim_get_current_buf()), vim.log.levels.INFO)
  end, {
    nargs = 1,
    complete = function() return vim.tbl_keys(toggles) end,
    desc = 'Toggle one subsystem off/on to bisect interactive lag',
  })
end

return M
