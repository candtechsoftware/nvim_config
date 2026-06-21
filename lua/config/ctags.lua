-- ctags-based navigation for C/C++ projects that have NOT opted in to clangd.
-- A project's tags file is generated automatically the first time one of its
-- C/C++ files is opened, refreshed (debounced) on every save afterwards, and
-- :Ctags forces a manual regenerate. Goto-definition itself is just the
-- built-in tag jump — <C-]>, or `gd` set in after/ftplugin/c.lua.
local M = {}

local root_util = require("utils.project_root")

-- Saves of these filetypes trigger a background tags refresh.
local TAG_FILETYPES = {
  c = true, cpp = true, objc = true, objcpp = true,
}

-- The markers that make clangd attach — must stay in sync with the
-- `root_markers` in lsp/clangd.lua, which is `workspace_required`, so these
-- files are exactly the opt-in signal. Where clangd attaches it owns both
-- completion (keymaps.lua routes <Tab> to vim.lsp.completion.get whenever a
-- client is present) and `gd` (rebound on LspAttach in config/lsp.lua), so the
-- tags index is never read there — generating it on open and re-running a
-- full-tree `ctags -R` after every save would be pure waste.
local CLANGD_MARKERS = { ".clangd", "compile_commands.json", "compile_flags.txt" }

---True if this buffer sits in a project that has opted in to clangd.
---@param buf integer
---@return boolean
local function clangd_owns(buf)
  return vim.fs.root(buf, CLANGD_MARKERS) ~= nil
end

-- Tags files live under Neovim's cache dir, one per project, instead of in
-- the project tree — so a large generated `tags` file never pollutes the
-- repo (no stray file to gitignore). Each project gets its own file keyed
-- by a hash of its root; a FileType autocmd points &tags at it.
local TAGS_DIR = vim.fs.joinpath(vim.fn.stdpath("cache"), "tags")

---Resolve the cache tags file path for a project root.
---@param root string
---@return string
local function tags_path(root)
  local name = vim.fs.basename(root):gsub("[^%w._-]", "_")
  return vim.fs.joinpath(TAGS_DIR, name .. "-" .. vim.fn.sha256(root):sub(1, 12))
end

---Project root and cache tags path for a buffer, or nil if it is not a
---C-family filetype.
---@param buf integer
---@return string? root
---@return string? tags
local function resolve(buf)
  if not TAG_FILETYPES[vim.bo[buf].filetype] then return end
  local root = root_util.find({ buf = buf })
  return root, tags_path(root)
end

---Point &path/&suffixesadd at the project's include dirs, so `gf` and `:find`
---resolve `#include` targets.
---@param buf integer
---@param root string
local function set_c_path(buf, root)
  local file = vim.api.nvim_buf_get_name(buf)
  local dir = file ~= "" and vim.fs.dirname(file) or vim.uv.cwd()
  local paths = { ".", dir }
  for _, c in ipairs({ "inc", "include", "src", "lib" }) do
    local p = vim.fs.joinpath(root, c)
    if vim.uv.fs_stat(p) then table.insert(paths, p) end
  end
  local ext = vim.fs.joinpath(root, "external")
  if vim.uv.fs_stat(ext) then
    for name, ty in vim.fs.dir(ext) do
      if ty == "directory" then
        for _, sub in ipairs({ "include", "src" }) do
          local p = vim.fs.joinpath(ext, name, sub)
          if vim.uv.fs_stat(p) then table.insert(paths, p) end
        end
      end
    end
  end
  vim.bo[buf].path = table.concat(paths, ",")
  vim.bo[buf].suffixesadd = ".h,.hpp,.hh,.hxx,.inl"
end

-- Roots with an in-flight `ctags` run, keyed by root path — so a second
-- trigger for the same project is skipped while other projects can still
-- generate in parallel. A trigger that arrives mid-run sets `pending[root]`
-- and is re-fired from the completion callback, so a save during a long scan
-- is never silently dropped.
local generating = {}
local pending = {}

---Regenerate a project's cache tags file in the background.
---@param root string  project root to scan
---@param notify boolean  report success/failure via vim.notify
local function generate(root, notify)
  if generating[root] then
    pending[root] = true
    return
  end
  if vim.fn.executable("ctags") == 0 then
    if notify then
      vim.notify("ctags: executable not found in PATH", vim.log.levels.ERROR)
    end
    return
  end
  local tags = tags_path(root)
  -- --tag-relative=no + an absolute root => absolute paths in the tags file,
  -- required because the file lives outside the project tree (Vim resolves
  -- relative tag paths against the tags file's own directory). --fields=+St
  -- adds the typeref (t) and signature (S) fields the built-in `ccomplete`
  -- omnifunc needs for member completion; pinned so a user .ctags.d can't
  -- drop them.
  local cmd = {
    "ctags", "-R", "--tag-relative=no", "--exclude=.git",
    "--fields=+St", "-f", tags, root,
  }
  generating[root] = true
  vim.system(cmd, { text = true }, function(obj)
    generating[root] = nil
    vim.schedule(function()
      if notify then
        if obj.code == 0 then
          vim.notify("ctags: regenerated " .. tags, vim.log.levels.INFO)
        else
          local msg = (obj.stderr ~= "" and obj.stderr) or ("exit " .. tostring(obj.code))
          vim.notify("ctags failed: " .. msg, vim.log.levels.ERROR)
        end
      end
      -- A save landed while this run was in flight — index it now.
      if pending[root] then
        pending[root] = nil
        generate(root, false)
      end
    end)
  end)
end

function M.setup()
  vim.fn.mkdir(TAGS_DIR, "p")

  -- C/C++/Obj-C buffers: point &tags at the project's cache tags file (the
  -- project-local defaults stay appended as a fallback), and generate that
  -- file once in the background if it does not exist yet — so `gd` works on
  -- a fresh project with no manual :Ctags.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ctags_tagpath", { clear = true }),
    callback = function(args)
      local root, tags = resolve(args.buf)
      if not root then return end
      -- &tags and &path are set unconditionally: they cost nothing, and they
      -- keep <C-n>/<C-x><C-]> and `gf` working even in a clangd project (and
      -- as a fallback if clangd fails to start).
      vim.bo[args.buf].tags = tags .. "," .. vim.go.tags
      set_c_path(args.buf, root)
      if clangd_owns(args.buf) then return end
      if not vim.uv.fs_stat(tags) then
        generate(root, false)
      end
    end,
  })

  -- :Ctags — regenerate the current project's tags file on demand. Works
  -- even before a tags file exists, so it also opts a new project in.
  vim.api.nvim_create_user_command("Ctags", function()
    generate(root_util.find(), true)
  end, { desc = "Regenerate the project tags file" })

  -- Debounced background refresh on save: one reusable timer *per project
  -- root*, re-armed on each save. A single shared timer would let a save in
  -- project B cancel the pending refresh for project A. The fs_stat guard
  -- skips projects with no tags file yet (their first generate happens on
  -- open, above).
  local timers = {}
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("ctags_auto_refresh", { clear = true }),
    callback = function(args)
      local root, tags = resolve(args.buf)
      if not root or not vim.uv.fs_stat(tags) then return end
      if clangd_owns(args.buf) then return end
      local timer = timers[root]
      if not timer then
        timer = assert(vim.uv.new_timer())
        timers[root] = timer
      end
      timer:stop()
      timer:start(2000, 0, function()
        vim.schedule(function() generate(root, false) end)
      end)
    end,
  })
end

return M
