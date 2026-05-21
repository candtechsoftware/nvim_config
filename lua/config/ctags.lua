-- ctags-based navigation for unity-build C/C++ projects (no LSP).
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

local generating = false

---Regenerate a project's cache tags file in the background.
---@param root string  project root to scan
---@param notify boolean  report success/failure via vim.notify
local function generate(root, notify)
  if generating then return end
  if vim.fn.executable("ctags") == 0 then
    if notify then
      vim.notify("ctags: executable not found in PATH", vim.log.levels.ERROR)
    end
    return
  end
  vim.fn.mkdir(TAGS_DIR, "p")
  local tags = tags_path(root)
  -- Recursive scan, default kinds (one tag per definition, so a function name
  -- resolves to a single definition — no prototype noise).
  -- --tag-relative=no + an absolute root => absolute paths in the tags file,
  -- which is required because the file lives outside the project tree (Vim
  -- resolves relative tag paths against the tags file's own directory).
  local cmd = {
    "ctags", "-R", "--tag-relative=no", "--exclude=.git",
    -- Fields the built-in `ccomplete` omnifunc needs for member completion:
    --   t = typeref (a variable/member -> its type), S = function signature
    --   (shown in the omni menu). struct:/union:/class: scope is in the
    --   default scope field. Pinned so a user .ctags.d can't disable them.
    "--fields=+St",
    "-f", tags, root,
  }
  generating = true
  vim.system(cmd, { text = true }, function(obj)
    generating = false
    if not notify then return end
    vim.schedule(function()
      if obj.code == 0 then
        vim.notify("ctags: regenerated " .. tags, vim.log.levels.INFO)
      else
        local msg = (obj.stderr ~= "" and obj.stderr) or ("exit " .. tostring(obj.code))
        vim.notify("ctags failed: " .. msg, vim.log.levels.ERROR)
      end
    end)
  end)
end

function M.setup()
  -- For C/C++/Obj-C buffers: point &tags at the project's cache tags file
  -- (so :tjump, <C-]> and <C-x><C-]> resolve through it; the project-local
  -- defaults stay appended as a fallback), and generate that file once in
  -- the background if it does not exist yet — so `gd` works on a fresh
  -- project with no manual :Ctags. The cache lives outside the project tree,
  -- so this drops no stray file into the repo.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ctags_tagpath", { clear = true }),
    callback = function(args)
      if not TAG_FILETYPES[vim.bo[args.buf].filetype] then return end
      local root = root_util.find()
      local tags = tags_path(root)
      vim.bo[args.buf].tags = tags .. "," .. vim.go.tags
      if not vim.uv.fs_stat(tags) then
        generate(root, false)
      end
    end,
  })

  -- :Ctags — regenerate the current project's tags file on demand.
  -- Works even before a tags file exists (unlike the auto-refresh below),
  -- so it's also how you opt a new project into tag navigation.
  vim.api.nvim_create_user_command("Ctags", function()
    generate(root_util.find(), true)
  end, { desc = "Regenerate the project tags file" })

  -- Debounced background refresh on save. Guarded on the cache tags file
  -- existing — normally it does (generated on first open above); this just
  -- avoids racing the initial generate before that file has been written.
  local debounce
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("ctags_auto_refresh", { clear = true }),
    callback = function(args)
      if not TAG_FILETYPES[vim.bo[args.buf].filetype] then return end
      local root = root_util.find()
      if not vim.uv.fs_stat(tags_path(root)) then return end
      if debounce and not debounce:is_closing() then
        debounce:stop()
        debounce:close()
      end
      local timer = vim.uv.new_timer()
      debounce = timer
      timer:start(2000, 0, function()
        timer:stop()
        timer:close()
        vim.schedule(function() generate(root, false) end)
      end)
    end,
  })
end

return M
