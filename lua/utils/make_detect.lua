-- Build system auto-detection for makeprg/errorformat

local M = {}

-- small helper: does a file exist in CWD?
local function exists(fname)
  return vim.uv.fs_stat(vim.uv.cwd() .. "/" .. fname) ~= nil
end

-- tiny helper: does a dir exist?
local function dexists(dname)
  local st = vim.uv.fs_stat(vim.uv.cwd() .. "/" .. dname)
  return st ~= nil and st.type == "directory"
end

-- Error format patterns for different build systems
local errorformats = {
  zig = table.concat({
    "%f:%l:%c: error: %m",           -- zig error format
    "%f:%l:%c: note: %m",            -- zig notes
    "%-G%.%#",                        -- ignore other lines
  }, ","),

  rust = table.concat({
    "%Eerror[E%n]: %m",              -- error[E0001]: message
    "%Eerror: %m",                   -- error: message
    "%Wwarning: %m",                 -- warning: message
    "%Inote: %m",                    -- note: message
    "%C %#--> %f:%l:%c",             -- --> file:line:col
    "%-G%.%#",                       -- ignore other lines
  }, ","),

  c_cpp = table.concat({
    "%f:%l:%c: %trror: %m",          -- GCC/Clang error
    "%f:%l:%c: %tarning: %m",        -- GCC/Clang warning
    "%f:%l:%c: %tote: %m",           -- GCC/Clang note
    "%f:%l: %trror: %m",             -- GCC/Clang error (no column)
    "%f:%l: %tarning: %m",           -- GCC/Clang warning (no column)
    "%-G%.%#",                       -- ignore other lines
  }, ","),

  jai = table.concat({
    "%f:%l\\,%c: Error: %m",         -- Jai error format: file:line,col: Error: message
    "%f:%l\\,%c: Warning: %m",       -- Jai warning format
    "%f:%l: Error: %m",              -- Jai error (no column)
    "%f:%l: Warning: %m",            -- Jai warning (no column)
    "%-G%.%#",                       -- ignore other lines
  }, ","),

  odin = table.concat({
    "%f(%l:%c) Error: %m",           -- Odin error format: file(line:col) Error: message
    "%f(%l:%c) Warning: %m",         -- Odin warning format
    "%f(%l:%c) %m",                  -- Odin generic format
    "%-G%.%#",                       -- ignore other lines
  }, ","),

  cmake = table.concat({
    "%f:%l: %m",                     -- CMake errors
    "CMake Error at %f:%l %m",       -- CMake Error format
    "%-G%.%#",                       -- ignore other lines
  }, ","),

  node = table.concat({
    "%f(%l\\,%c): error %m",         -- TypeScript format
    "%f:%l:%c - error %m",           -- ESLint format
    "%+A %#%f:%l:%c",                -- Generic file:line:col
    "%+C %m",                        -- continuation
    "%-G%.%#",                       -- ignore other lines
  }, ","),

  default = table.concat({
    "%f:%l:%c: %m",                  -- generic file:line:col: message
    "%f:%l: %m",                     -- generic file:line: message
    "%f(%l): %m",                    -- file(line): message
    "%-G%.%#",                       -- ignore other lines
  }, ","),
}

-- Detect the best build command for the current project
local function detect_makeprg(buf_ft)
  -- Highest priority: explicit project hint
  if exists(".project_type") then
    local t = vim.fn.trim(vim.fn.readfile(".project_type")[1] or "")
    if t == "zig" then return "zig build" end
    if t == "node" then
      if exists("pnpm-lock.yaml") then return "pnpm run build" end
      if exists("yarn.lock") then return "yarn build" end
      return "npm run build"
    end
    if t == "rust" then return "cargo build" end
    if t == "c" or t == "cpp" then return "make -j" end
    if t == "jai" then
      if exists("build.jai") then return "jai-macos build.jai" end
      return "jai-macos %"
    end
    if t == "odin" then return "odin build ." end
  end

  -- Per-language quick wins (based on filetype)
  if buf_ft == "zig" then return "zig build" end
  if buf_ft == "rust" then return "cargo build" end

  if buf_ft == "javascript" or buf_ft == "typescript" or buf_ft == "typescriptreact" or buf_ft == "javascriptreact" then
    if exists("pnpm-lock.yaml") then return "pnpm run build" end
    if exists("yarn.lock") then return "yarn build" end
    if exists("package.json") then return "npm run build" end
  end

  if buf_ft == "c" or buf_ft == "cpp" then
    if exists("Makefile") or exists("makefile") then return "make -j" end
    if exists("CMakeLists.txt") then
      -- prefer build dir if present
      if dexists("build") then
        return "cmake --build build --config Debug"
      else
        return "cmake -S . -B build && cmake --build build --config Debug"
      end
    end
  end

  -- Jai support (macOS)
  if buf_ft == "jai" then
    -- common patterns:
    --   - project has a build.jai entrypoint
    --   - otherwise compile current file
    if exists("build.jai") then
      return "jai-macos build.jai"
    else
      -- % expands to the buffer's file; add -x to run if desired (commented)
      -- return "jai-macos -x %"  -- build & run
      return "jai-macos %"
    end
  end

  -- Odin support
  if buf_ft == "odin" then
    return "odin build ."
  end

  -- Repo-level heuristics regardless of filetype
  if exists("build.zig") then return "zig build" end
  if exists("Cargo.toml") then return "cargo build" end
  if exists("pnpm-lock.yaml") then return "pnpm run build" end
  if exists("yarn.lock") then return "yarn build" end
  if exists("package.json") then return "npm run build" end
  if exists("Makefile") or exists("makefile") then return "make -j" end
  if exists("CMakeLists.txt") then
    if dexists("build") then
      return "cmake --build build --config Debug"
    else
      return "cmake -S . -B build && cmake --build build --config Debug"
    end
  end
  if exists("build.jai") then return "jai-macos build.jai" end

  -- Fallback: plain make
  return "make"
end

-- Detect the appropriate errorformat based on makeprg
local function detect_errorformat(makeprg, buf_ft)
  -- Match based on the makeprg command
  if makeprg:match("^zig") then
    return errorformats.zig
  elseif makeprg:match("^cargo") then
    return errorformats.rust
  elseif makeprg:match("^jai%-macos") then
    return errorformats.jai
  elseif makeprg:match("^odin") then
    return errorformats.odin
  elseif makeprg:match("^cmake") then
    return errorformats.cmake
  elseif makeprg:match("npm") or makeprg:match("yarn") or makeprg:match("pnpm") then
    return errorformats.node
  elseif makeprg:match("^make") and (buf_ft == "c" or buf_ft == "cpp") then
    return errorformats.c_cpp
  else
    return errorformats.default
  end
end

-- Apply detection and wire up commands/autocmds
local cache = {} -- [cwd] = { [ft] = { makeprg = ..., errorformat = ... } }

function M.apply()
  local ft = vim.bo.filetype
  local cwd = vim.uv.cwd()
  local by_ft = cache[cwd]
  local entry = by_ft and by_ft[ft]
  if not entry then
    local makeprg = detect_makeprg(ft)
    entry = { makeprg = makeprg, errorformat = detect_errorformat(makeprg, ft) }
    cache[cwd] = by_ft or {}
    cache[cwd][ft] = entry
  end
  vim.opt.makeprg = entry.makeprg
  vim.opt.errorformat = entry.errorformat
end

function M.setup()
  -- command to force re-detect
  vim.api.nvim_create_user_command("MakeDetect", function()
    cache[vim.uv.cwd()] = nil
    M.apply()
    print("makeprg → " .. vim.o.makeprg)
  end, {})

  -- ultra-convenient :Make wrapper (detect → :make → auto-open quickfix)
  vim.api.nvim_create_user_command("Make", function(opts)
    M.apply()
    -- pass user args to :make (e.g., :Make --release)
    local args = table.concat(opts.fargs, " ")
    if args ~= "" then
      vim.cmd("make " .. args)
    else
      vim.cmd("make")
    end

    -- Auto-open quickfix list if there are errors
    vim.defer_fn(function()
      local qf_list = vim.fn.getqflist()
      if #qf_list > 0 then
        vim.cmd("copen")
      end
    end, 100)
  end, { nargs = "*" })

  -- Quickfix navigation keybindings
  vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
  vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
  vim.keymap.set("n", "]Q", "<cmd>clast<cr>", { desc = "Last quickfix item" })
  vim.keymap.set("n", "[Q", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
  vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix list" })
  vim.keymap.set("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix list" })

  -- keep it fresh as you navigate.
  -- FileType handles initial open per buffer; DirChanged covers :cd.
  -- BufEnter was redundant (every switch within a project re-ran the full
  -- detect ladder) — the per-(cwd, ft) cache makes repeat opens free.
  local grp = vim.api.nvim_create_augroup("CustomMakeDetect", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType", "DirChanged" }, {
    group = grp,
    callback = function(ev)
      if ev.event == "DirChanged" then cache = {} end
      M.apply()
    end,
    desc = "Auto-detect makeprg per project/language (incl. Jai)",
  })
end

return M
