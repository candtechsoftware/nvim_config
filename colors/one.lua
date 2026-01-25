-- One: Minimal colorscheme with good contrast and low color noise
-- Philosophy: Use few colors, reserve color for semantic meaning

local M = {}

local colors = {
  -- Exact fleury/4coder colors
  bg            = "#0c0c0c",     -- defcolor_back
  fg            = "#a08563",     -- defcolor_text_default
  comment       = "#686868",     -- defcolor_comment
  keyword       = "#ac7b0b",     -- defcolor_keyword (amber)
  literal       = "#6b8e23",     -- defcolor_str_constant (olive)
  preproc       = "#dab98f",     -- defcolor_preproc (light tan)
  type          = "#d8a51d",     -- fleury_color_index_type (gold)
  func          = "#cc5735",     -- fleury_color_index_function (rust)
  macro         = "#478980",     -- fleury_color_index_macro (teal)
  syntax_crap   = "#907553",     -- fleury_color_syntax_crap (brown)
  special       = "#ff0000",     -- defcolor_special_character
  ghost         = "#5b4d3c",     -- defcolor_ghost_character
  error         = "#ff0000",     -- error

  -- UI colors
  ui_dim        = "#404040",     -- defcolor_line_numbers_text
  line_num_bg   = "#101010",     -- defcolor_line_numbers_back
  cursor_line   = "#1f1f27",     -- defcolor_highlight_cursor_line
  list_hover    = "#171e20",     -- defcolor_list_item_hover
  list_active   = "#2d3640",     -- defcolor_list_item_active
  search_bg     = "#315268",     -- defcolor_highlight
  search_fg     = "#c4b82b",     -- defcolor_at_highlight
  bar_bg        = "#1f1f27",     -- defcolor_bar
  base          = "#cb9401",     -- defcolor_base

  -- Scope background cycle (subtle)
  back_cycle = {
    "#0e0e0e",
    "#101010",
    "#121212",
    "#141414",
    "#161616",
    "#181818",
    "#1a1a1a",
    "#1c1c1c",
  },
}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "one"
  vim.o.background = "dark"
  vim.o.termguicolors = true

  local hl = vim.api.nvim_set_hl

  -- UI Elements
  hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
  hl(0, "NormalNC", { fg = colors.fg, bg = colors.bg })
  hl(0, "NormalFloat", { fg = colors.fg, bg = colors.list_hover })
  hl(0, "FloatBorder", { fg = colors.syntax_crap, bg = colors.list_hover })
  hl(0, "FloatTitle", { fg = colors.base, bg = colors.list_hover })

  hl(0, "Cursor", { fg = colors.bg, bg = "#00ee00" })
  hl(0, "CursorLine", { bg = colors.cursor_line })
  hl(0, "CursorColumn", { bg = colors.cursor_line })
  hl(0, "ColorColumn", { bg = colors.cursor_line })
  hl(0, "Visual", { bg = colors.search_bg })
  hl(0, "VisualNOS", { bg = colors.search_bg })

  hl(0, "LineNr", { fg = colors.ui_dim, bg = colors.line_num_bg })
  hl(0, "CursorLineNr", { fg = colors.fg, bg = colors.line_num_bg })
  hl(0, "SignColumn", { bg = colors.line_num_bg })

  hl(0, "StatusLine", { fg = colors.base, bg = colors.bar_bg })
  hl(0, "StatusLineNC", { fg = colors.ui_dim, bg = colors.bar_bg })
  hl(0, "WinBar", { fg = colors.fg, bg = colors.bg })
  hl(0, "WinBarNC", { fg = colors.comment, bg = colors.bg })
  hl(0, "TabLine", { fg = colors.fg, bg = colors.bar_bg })
  hl(0, "TabLineFill", { bg = colors.bar_bg })
  hl(0, "TabLineSel", { fg = colors.base, bg = colors.bg })

  hl(0, "VertSplit", { fg = colors.bg })
  hl(0, "WinSeparator", { fg = colors.bg })

  hl(0, "Search", { fg = colors.search_fg, bg = colors.search_bg })
  hl(0, "IncSearch", { fg = colors.bg, bg = colors.base })
  hl(0, "CurSearch", { fg = colors.bg, bg = "#00ee00" })
  hl(0, "Substitute", { fg = colors.bg, bg = "#ffbb00" })

  hl(0, "Pmenu", { fg = colors.fg, bg = colors.list_hover })
  hl(0, "PmenuSel", { fg = colors.search_fg, bg = colors.list_active })
  hl(0, "PmenuSbar", { bg = colors.list_hover })
  hl(0, "PmenuThumb", { bg = colors.ui_dim })

  hl(0, "MsgArea", { fg = colors.fg })
  hl(0, "ModeMsg", { fg = colors.base })
  hl(0, "MoreMsg", { fg = colors.base })
  hl(0, "Question", { fg = colors.base })
  hl(0, "ErrorMsg", { fg = colors.error })
  hl(0, "WarningMsg", { fg = colors.base })

  hl(0, "Folded", { fg = colors.comment, bg = colors.cursor_line })
  hl(0, "FoldColumn", { fg = colors.comment, bg = colors.line_num_bg })
  hl(0, "EndOfBuffer", { fg = colors.bg })
  hl(0, "NonText", { fg = colors.ghost })
  hl(0, "SpecialKey", { fg = colors.ghost })
  hl(0, "Whitespace", { fg = colors.ghost })
  hl(0, "Directory", { fg = colors.type })
  hl(0, "Title", { fg = colors.base, bold = true })
  hl(0, "Conceal", { fg = colors.ghost })
  hl(0, "WildMenu", { fg = colors.search_fg, bg = colors.list_active })
  hl(0, "QuickFixLine", { bg = colors.list_active })

  hl(0, "MatchParen", { fg = colors.base, bg = colors.list_active, bold = true })

  -- Diff
  hl(0, "DiffAdd", { bg = "#1a2a1a" })
  hl(0, "DiffChange", { bg = "#2a2510" })
  hl(0, "DiffDelete", { fg = colors.error, bg = "#2a1a1a" })
  hl(0, "DiffText", { bg = "#3a3520", bold = true })

  -- Spell
  hl(0, "SpellBad", { sp = colors.error, undercurl = true })
  hl(0, "SpellCap", { sp = colors.keyword, undercurl = true })
  hl(0, "SpellLocal", { sp = colors.literal, undercurl = true })
  hl(0, "SpellRare", { sp = colors.ui_dim, undercurl = true })

  -- Syntax: Exact fleury colors
  hl(0, "Comment", { fg = colors.comment })
  hl(0, "Constant", { fg = colors.literal })
  hl(0, "String", { fg = colors.literal })
  hl(0, "Character", { fg = colors.literal })
  hl(0, "Number", { fg = colors.literal })
  hl(0, "Boolean", { fg = colors.literal })
  hl(0, "Float", { fg = colors.literal })

  hl(0, "Identifier", { fg = colors.fg })
  hl(0, "Function", { fg = colors.func })

  hl(0, "Statement", { fg = colors.keyword })
  hl(0, "Conditional", { fg = colors.keyword })
  hl(0, "Repeat", { fg = colors.keyword })
  hl(0, "Label", { fg = colors.keyword })
  hl(0, "Operator", { fg = colors.syntax_crap })
  hl(0, "Keyword", { fg = colors.keyword })
  hl(0, "Exception", { fg = colors.keyword })

  hl(0, "PreProc", { fg = colors.preproc })
  hl(0, "Include", { fg = colors.preproc })
  hl(0, "Define", { fg = colors.preproc })
  hl(0, "Macro", { fg = colors.macro })
  hl(0, "PreCondit", { fg = colors.preproc })

  hl(0, "Type", { fg = colors.type })
  hl(0, "StorageClass", { fg = colors.keyword })
  hl(0, "Structure", { fg = colors.type })
  hl(0, "Typedef", { fg = colors.type })

  hl(0, "Special", { fg = colors.special })
  hl(0, "SpecialChar", { fg = colors.special })
  hl(0, "Tag", { fg = colors.keyword })
  hl(0, "Delimiter", { fg = colors.syntax_crap })
  hl(0, "SpecialComment", { fg = colors.comment })
  hl(0, "Debug", { fg = colors.error })

  hl(0, "Underlined", { fg = colors.func, underline = true })
  hl(0, "Ignore", { fg = colors.ghost })
  hl(0, "Error", { fg = colors.error })
  hl(0, "Todo", { fg = "#00a000", bg = colors.cursor_line, bold = true })

  -- Treesitter (exact fleury colors)
  hl(0, "@variable", { fg = colors.fg })
  hl(0, "@variable.builtin", { fg = colors.fg })
  hl(0, "@variable.parameter", { fg = colors.fg })
  hl(0, "@variable.member", { fg = colors.fg })

  hl(0, "@constant", { fg = colors.literal })
  hl(0, "@constant.builtin", { fg = colors.literal })
  hl(0, "@constant.macro", { fg = colors.macro })

  hl(0, "@module", { fg = colors.preproc })
  hl(0, "@label", { fg = colors.keyword })

  hl(0, "@string", { fg = colors.literal })
  hl(0, "@string.documentation", { fg = colors.literal })
  hl(0, "@string.regexp", { fg = colors.literal })
  hl(0, "@string.escape", { fg = colors.special })
  hl(0, "@string.special", { fg = colors.special })
  hl(0, "@string.special.symbol", { fg = colors.literal })
  hl(0, "@string.special.path", { fg = colors.preproc })
  hl(0, "@string.special.url", { fg = colors.func, underline = true })

  hl(0, "@character", { fg = colors.literal })
  hl(0, "@character.special", { fg = colors.special })

  hl(0, "@boolean", { fg = colors.literal })
  hl(0, "@number", { fg = colors.literal })
  hl(0, "@number.float", { fg = colors.literal })

  hl(0, "@type", { fg = colors.type })
  hl(0, "@type.builtin", { fg = colors.type })
  hl(0, "@type.definition", { fg = colors.type })

  hl(0, "@attribute", { fg = colors.preproc })
  hl(0, "@attribute.builtin", { fg = colors.preproc })
  hl(0, "@property", { fg = colors.fg })

  hl(0, "@function", { fg = colors.func })
  hl(0, "@function.builtin", { fg = colors.func })
  hl(0, "@function.call", { fg = colors.func })
  hl(0, "@function.macro", { fg = colors.macro })
  hl(0, "@function.method", { fg = colors.func })
  hl(0, "@function.method.call", { fg = colors.func })

  hl(0, "@constructor", { fg = colors.type })
  hl(0, "@operator", { fg = colors.syntax_crap })

  hl(0, "@keyword", { fg = colors.keyword })
  hl(0, "@keyword.coroutine", { fg = colors.keyword })
  hl(0, "@keyword.function", { fg = colors.keyword })
  hl(0, "@keyword.operator", { fg = colors.syntax_crap })
  hl(0, "@keyword.import", { fg = colors.preproc })
  hl(0, "@keyword.type", { fg = colors.keyword })
  hl(0, "@keyword.modifier", { fg = colors.keyword })
  hl(0, "@keyword.repeat", { fg = colors.keyword })
  hl(0, "@keyword.return", { fg = colors.keyword })
  hl(0, "@keyword.debug", { fg = colors.error })
  hl(0, "@keyword.exception", { fg = colors.keyword })
  hl(0, "@keyword.conditional", { fg = colors.keyword })
  hl(0, "@keyword.directive", { fg = colors.preproc })
  hl(0, "@keyword.directive.define", { fg = colors.preproc })

  hl(0, "@punctuation", { fg = colors.syntax_crap })
  hl(0, "@punctuation.delimiter", { fg = colors.syntax_crap })
  hl(0, "@punctuation.bracket", { fg = colors.syntax_crap })
  hl(0, "@punctuation.special", { fg = colors.syntax_crap })

  hl(0, "@comment", { fg = colors.comment })
  hl(0, "@comment.documentation", { fg = colors.comment })
  hl(0, "@comment.error", { fg = "#a00000" })
  hl(0, "@comment.warning", { fg = colors.base })
  hl(0, "@comment.todo", { fg = "#00a000", bold = true })
  hl(0, "@comment.note", { fg = "#00a000" })

  hl(0, "@markup", { fg = colors.fg })
  hl(0, "@markup.strong", { bold = true })
  hl(0, "@markup.italic", { italic = true })
  hl(0, "@markup.strikethrough", { strikethrough = true })
  hl(0, "@markup.underline", { underline = true })
  hl(0, "@markup.heading", { fg = colors.keyword, bold = true })
  hl(0, "@markup.quote", { fg = colors.ui_dim })
  hl(0, "@markup.math", { fg = colors.literal })
  hl(0, "@markup.link", { fg = colors.keyword, underline = true })
  hl(0, "@markup.raw", { fg = colors.literal })
  hl(0, "@markup.list", { fg = colors.fg })

  hl(0, "@tag", { fg = colors.keyword })
  hl(0, "@tag.attribute", { fg = colors.fg })
  hl(0, "@tag.delimiter", { fg = colors.fg })

  -- LSP semantic tokens
  hl(0, "@lsp.type.class", { fg = colors.type })
  hl(0, "@lsp.type.comment", { fg = colors.comment })
  hl(0, "@lsp.type.decorator", { fg = colors.keyword })
  hl(0, "@lsp.type.enum", { fg = colors.type })
  hl(0, "@lsp.type.enumMember", { fg = colors.literal })
  hl(0, "@lsp.type.function", { fg = colors.func })
  hl(0, "@lsp.type.interface", { fg = colors.type })
  hl(0, "@lsp.type.macro", { fg = colors.keyword })
  hl(0, "@lsp.type.method", { fg = colors.func })
  hl(0, "@lsp.type.namespace", { fg = colors.type })
  hl(0, "@lsp.type.parameter", { fg = colors.fg })
  hl(0, "@lsp.type.property", { fg = colors.fg })
  hl(0, "@lsp.type.struct", { fg = colors.type })
  hl(0, "@lsp.type.type", { fg = colors.type })
  hl(0, "@lsp.type.typeParameter", { fg = colors.type })
  hl(0, "@lsp.type.variable", { fg = colors.fg })

  -- Diagnostics
  hl(0, "DiagnosticError", { fg = colors.error })
  hl(0, "DiagnosticWarn", { fg = colors.literal })
  hl(0, "DiagnosticInfo", { fg = colors.keyword })
  hl(0, "DiagnosticHint", { fg = colors.ui_dim })
  hl(0, "DiagnosticOk", { fg = colors.literal })

  hl(0, "DiagnosticVirtualTextError", { fg = colors.error, bg = "#1a0c0c" })
  hl(0, "DiagnosticVirtualTextWarn", { fg = colors.literal, bg = "#1a1a0c" })
  hl(0, "DiagnosticVirtualTextInfo", { fg = colors.keyword, bg = "#1a160c" })
  hl(0, "DiagnosticVirtualTextHint", { fg = colors.ui_dim })

  hl(0, "DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
  hl(0, "DiagnosticUnderlineWarn", { sp = colors.literal, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo", { sp = colors.keyword, undercurl = true })
  hl(0, "DiagnosticUnderlineHint", { sp = colors.ui_dim, undercurl = true })

  hl(0, "DiagnosticSignError", { fg = colors.error, bg = colors.bg })
  hl(0, "DiagnosticSignWarn", { fg = colors.literal, bg = colors.bg })
  hl(0, "DiagnosticSignInfo", { fg = colors.keyword, bg = colors.bg })
  hl(0, "DiagnosticSignHint", { fg = colors.ui_dim, bg = colors.bg })

  -- Git signs
  hl(0, "GitSignsAdd", { fg = colors.literal, bg = colors.bg })
  hl(0, "GitSignsChange", { fg = colors.keyword, bg = colors.bg })
  hl(0, "GitSignsDelete", { fg = colors.error, bg = colors.bg })

  -- Telescope
  hl(0, "TelescopeNormal", { fg = colors.fg, bg = colors.bg })
  hl(0, "TelescopeBorder", { fg = colors.border, bg = colors.bg })
  hl(0, "TelescopePromptNormal", { fg = colors.fg, bg = colors.bg })
  hl(0, "TelescopePromptBorder", { fg = colors.border, bg = colors.bg })
  hl(0, "TelescopePromptTitle", { fg = colors.ui_dim, bg = colors.bg })
  hl(0, "TelescopePromptPrefix", { fg = colors.keyword, bg = colors.bg })
  hl(0, "TelescopeResultsNormal", { fg = colors.fg, bg = colors.bg })
  hl(0, "TelescopeResultsBorder", { fg = colors.border, bg = colors.bg })
  hl(0, "TelescopeResultsTitle", { fg = colors.ui_dim, bg = colors.bg })
  hl(0, "TelescopePreviewNormal", { fg = colors.fg, bg = colors.bg })
  hl(0, "TelescopePreviewBorder", { fg = colors.border, bg = colors.bg })
  hl(0, "TelescopePreviewTitle", { fg = colors.ui_dim, bg = colors.bg })
  hl(0, "TelescopeSelection", { fg = colors.fg, bg = colors.bg_light })
  hl(0, "TelescopeSelectionCaret", { fg = colors.keyword, bg = colors.bg_light })
  hl(0, "TelescopeMultiSelection", { fg = colors.literal, bg = colors.bg_light })
  hl(0, "TelescopeMatching", { fg = colors.keyword, bold = true })

  -- Jai-specific
  hl(0, "@keyword.jai", { fg = colors.keyword })
  hl(0, "@keyword.repeat.jai", { fg = colors.keyword })
  hl(0, "@keyword.conditional.jai", { fg = colors.keyword })
  hl(0, "@keyword.function.jai", { fg = colors.keyword })
  hl(0, "@keyword.return.jai", { fg = colors.keyword })
  hl(0, "@keyword.modifier.jai", { fg = colors.keyword })
  hl(0, "@keyword.type.jai", { fg = colors.keyword })
  hl(0, "@keyword.operator.jai", { fg = colors.fg })
  hl(0, "@storageclass.jai", { fg = colors.keyword })
  hl(0, "@function.jai", { fg = colors.func })
  hl(0, "@function.call.jai", { fg = colors.func })
  hl(0, "@operator.jai", { fg = colors.fg })
  hl(0, "@punctuation.special.jai", { fg = colors.keyword })
  hl(0, "@punctuation.delimiter.jai", { fg = colors.fg })
  hl(0, "@punctuation.bracket.jai", { fg = colors.fg })
  hl(0, "@variable.jai", { fg = colors.fg })
  hl(0, "@variable.builtin.jai", { fg = colors.fg })
  hl(0, "@variable.parameter.jai", { fg = colors.fg })
  hl(0, "@constant.jai", { fg = colors.literal })
  hl(0, "@constant.builtin.jai", { fg = colors.literal })
  hl(0, "@type.jai", { fg = colors.type })
  hl(0, "@type.builtin.jai", { fg = colors.type })
  hl(0, "@string.jai", { fg = colors.literal })
  hl(0, "@number.jai", { fg = colors.literal })
  hl(0, "@boolean.jai", { fg = colors.literal })
  hl(0, "@comment.jai", { fg = colors.comment })

  -- Indent guides
  hl(0, "IblIndent", { fg = colors.border })
  hl(0, "IblScope", { fg = colors.ui_dim })

  -- Which-key
  hl(0, "WhichKey", { fg = colors.keyword })
  hl(0, "WhichKeyGroup", { fg = colors.fg })
  hl(0, "WhichKeyDesc", { fg = colors.fg })
  hl(0, "WhichKeySeperator", { fg = colors.ui_dim })
  hl(0, "WhichKeyFloat", { bg = colors.bg_float })
  hl(0, "WhichKeyValue", { fg = colors.literal })

  -- Lazy.nvim
  hl(0, "LazyNormal", { fg = colors.fg, bg = colors.bg_float })
  hl(0, "LazyBorder", { fg = colors.border, bg = colors.bg_float })
  hl(0, "LazyTitle", { fg = colors.keyword, bg = colors.bg_float })
  hl(0, "LazyButton", { fg = colors.fg, bg = colors.bg_light })
  hl(0, "LazyButtonActive", { fg = colors.bg, bg = colors.keyword })
  hl(0, "LazyH1", { fg = colors.keyword })
  hl(0, "LazyH2", { fg = colors.keyword })
  hl(0, "LazyComment", { fg = colors.ui_dim })
  hl(0, "LazyCommit", { fg = colors.literal })
  hl(0, "LazyDimmed", { fg = colors.ui_dim })
  hl(0, "LazyProgressDone", { fg = colors.literal })
  hl(0, "LazyProgressTodo", { fg = colors.ui_dim })
  hl(0, "LazySpecial", { fg = colors.keyword })
  hl(0, "LazyTaskError", { fg = colors.error })
  hl(0, "LazyTaskOutput", { fg = colors.fg })

  -- Scope highlight groups
  for i, bg in ipairs(colors.back_cycle) do
    hl(0, "OneScope" .. i, { bg = bg })
  end
end

-- Export colors
M.colors = colors

-- Scope highlighting
local scope_ns = vim.api.nvim_create_namespace("one_scope_highlight")
local scope_cache = {}

local scope_queries = {
  c = [[(compound_statement) @scope]],
  cpp = [[(compound_statement) @scope]],
  jai = [[(block) @scope]],
  lua = [[
    (function_definition) @scope
    (if_statement) @scope
    (for_statement) @scope
    (while_statement) @scope
  ]],
  typescript = [[(statement_block) @scope]],
  tsx = [[(statement_block) @scope]],
  javascript = [[(statement_block) @scope]],
}

local function parse_scopes(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return nil end

  local tree = parser:parse()[1]
  if not tree then return nil end

  local root = tree:root()
  local lang = parser:lang()
  local query_string = scope_queries[lang]
  if not query_string then return nil end

  local query
  local success = pcall(function()
    query = vim.treesitter.query.parse(lang, query_string)
  end)
  if not success or not query then return nil end

  local all_scopes = {}
  for _, node in query:iter_captures(root, bufnr, 0, -1) do
    local start_row, _, end_row, _ = node:range()
    table.insert(all_scopes, {
      start_row = start_row,
      end_row = end_row,
      size = end_row - start_row,
    })
  end
  return all_scopes
end

local function find_containing_scopes(all_scopes, cursor_row)
  if not all_scopes then return {} end
  local containing = {}
  for _, scope in ipairs(all_scopes) do
    if cursor_row >= scope.start_row and cursor_row <= scope.end_row then
      table.insert(containing, scope)
    end
  end
  table.sort(containing, function(a, b) return a.size < b.size end)
  return containing
end

local function scope_fingerprint(scopes)
  if not scopes or #scopes == 0 then return "" end
  local parts = {}
  for _, s in ipairs(scopes) do
    table.insert(parts, s.start_row .. ":" .. s.end_row)
  end
  return table.concat(parts, ",")
end

function M.highlight_scopes(bufnr, winid, force)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  winid = winid or vim.api.nvim_get_current_win()

  if not scope_cache[bufnr] then
    scope_cache[bufnr] = { all_scopes = nil, last_fingerprint = "", dirty = true }
  end

  local cache = scope_cache[bufnr]
  if cache.dirty or not cache.all_scopes then
    cache.all_scopes = parse_scopes(bufnr)
    cache.dirty = false
  end

  local cursor = vim.api.nvim_win_get_cursor(winid)
  local cursor_row = cursor[1] - 1
  local containing_scopes = find_containing_scopes(cache.all_scopes, cursor_row)
  local fingerprint = scope_fingerprint(containing_scopes)

  if not force and fingerprint == cache.last_fingerprint then return end
  cache.last_fingerprint = fingerprint

  vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)

  for depth, scope in ipairs(containing_scopes) do
    local cycle_idx = ((depth - 1) % #colors.back_cycle) + 1
    local hl_group = "OneScope" .. cycle_idx
    for line = scope.start_row, scope.end_row do
      vim.api.nvim_buf_set_extmark(bufnr, scope_ns, line, 0, {
        line_hl_group = hl_group,
        priority = 100 - depth,
      })
    end
  end
end

local function mark_dirty(bufnr)
  if scope_cache[bufnr] then scope_cache[bufnr].dirty = true end
end

local debounce_timers = {}
local DEBOUNCE_MS = 50

local function debounced_highlight(bufnr)
  if debounce_timers[bufnr] then
    debounce_timers[bufnr]:stop()
    debounce_timers[bufnr] = nil
  end
  local timer = vim.uv.new_timer()
  debounce_timers[bufnr] = timer
  timer:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.highlight_scopes(bufnr)
    end
    if debounce_timers[bufnr] == timer then
      debounce_timers[bufnr] = nil
    end
    timer:stop()
    timer:close()
  end))
end

function M.enable_scope_highlight(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  scope_cache[bufnr] = { all_scopes = nil, last_fingerprint = "", dirty = true }

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.highlight_scopes(bufnr, nil, true)
    end
  end)

  local group = vim.api.nvim_create_augroup("OneScopeHighlight" .. bufnr, { clear = true })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    buffer = bufnr,
    callback = function() debounced_highlight(bufnr) end,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      mark_dirty(bufnr)
      debounced_highlight(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    buffer = bufnr,
    callback = function()
      scope_cache[bufnr] = nil
      if debounce_timers[bufnr] then
        debounce_timers[bufnr]:stop()
        debounce_timers[bufnr]:close()
        debounce_timers[bufnr] = nil
      end
    end,
  })
end

function M.disable_scope_highlight(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, scope_ns, 0, -1)
  pcall(vim.api.nvim_del_augroup_by_name, "OneScopeHighlight" .. bufnr)
  scope_cache[bufnr] = nil
  if debounce_timers[bufnr] then
    debounce_timers[bufnr]:stop()
    debounce_timers[bufnr]:close()
    debounce_timers[bufnr] = nil
  end
end

function M.setup_scope_highlight()
  local group = vim.api.nvim_create_augroup("OneScopeSetup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "c", "cpp", "jai", "lua", "typescript", "typescriptreact", "javascript", "javascriptreact" },
    callback = function(ev)
      vim.schedule(function() M.enable_scope_highlight(ev.buf) end)
    end,
  })

  local ft = vim.bo.filetype
  if ft == "c" or ft == "cpp" or ft == "jai" or ft == "lua" or ft == "typescript" or ft == "typescriptreact" or ft == "javascript" or ft == "javascriptreact" then
    vim.schedule(function() M.enable_scope_highlight(vim.api.nvim_get_current_buf()) end)
  end
end

M.setup()
vim.g.one_theme = M
M.setup_scope_highlight()

return M
