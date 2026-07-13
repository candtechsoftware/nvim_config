-- Treesitter parser management (replaces nvim-treesitter for parser installation)
-- Compiles parsers from source using system cc/c++

local M = {}

local parser_dir = vim.fn.stdpath("data") .. "/site/parser"

-- Parser registry: url, optional location (for monorepos like typescript)
local parsers = {
    cpp         = { url = "https://github.com/tree-sitter/tree-sitter-cpp", inherits = "c" },
    rust        = { url = "https://github.com/tree-sitter/tree-sitter-rust" },
    go          = { url = "https://github.com/tree-sitter/tree-sitter-go" },
    javascript  = { url = "https://github.com/tree-sitter/tree-sitter-javascript" },
    typescript  = { url = "https://github.com/tree-sitter/tree-sitter-typescript", location = "typescript", inherits = "javascript" },
    tsx         = { url = "https://github.com/tree-sitter/tree-sitter-typescript", location = "tsx", inherits = "javascript" },
    json        = { url = "https://github.com/tree-sitter/tree-sitter-json" },
    yaml        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-yaml" },
    toml        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-toml" },
    bash        = { url = "https://github.com/tree-sitter/tree-sitter-bash" },
    glsl        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-glsl" },
    hlsl        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-hlsl" },
    odin        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-odin" },
    zig         = { url = "https://github.com/tree-sitter-grammars/tree-sitter-zig" },
    jai         = { url = "https://github.com/constantitus/tree-sitter-jai" },
    objc        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-objc", inherits = "c" },
}

-- Languages to install on startup if missing
M.ensure_installed = {
    "cpp", "rust", "go",
    "javascript", "typescript", "tsx",
    "json", "yaml", "toml", "bash",
    "glsl", "hlsl", "objc",
}

local function parser_exists(lang)
    local ok = pcall(vim.treesitter.language.add, lang)
    return ok
end

local function parser_names()
    local names = {}
    for name, _ in pairs(parsers) do names[#names + 1] = name end
    table.sort(names)
    return names
end

local function compile_parser(src_dir, output_path)
    -- Collect source files
    local c_files = {}
    local use_cpp = false

    local parser_c = src_dir .. "/parser.c"
    if vim.fn.filereadable(parser_c) == 1 then
        table.insert(c_files, parser_c)
    else
        return false, "parser.c not found in " .. src_dir
    end

    -- Check for scanner (C or C++)
    local scanner_cc = src_dir .. "/scanner.cc"
    local scanner_c = src_dir .. "/scanner.c"
    if vim.fn.filereadable(scanner_cc) == 1 then
        table.insert(c_files, scanner_cc)
        use_cpp = true
    elseif vim.fn.filereadable(scanner_c) == 1 then
        table.insert(c_files, scanner_c)
    end

    local compiler = use_cpp and "c++" or "cc"
    local cmd = {
        compiler,
        "-shared",
        "-fPIC",
        "-o", output_path,
        "-I", src_dir,
        "-O2",
    }
    -- macOS resolves tree-sitter's undefined symbols against the host nvim
    -- at load time and needs this flag to permit them. On Linux/BSD `ld`
    -- rejects it ("cannot find dynamic_lookup"), which fails every parser
    -- build — so gate it to macOS only.
    if vim.fn.has("mac") == 1 then
        table.insert(cmd, "-undefined")
        table.insert(cmd, "dynamic_lookup")
    end
    for _, f in ipairs(c_files) do
        table.insert(cmd, f)
    end

    local result = vim.system(cmd):wait()
    if result.code ~= 0 then
        return false, (result.stderr or "compilation failed")
    end
    return true
end

function M.install(lang, opts)
    opts = opts or {}
    local info = parsers[lang]
    if not info then
        vim.notify("Unknown parser: " .. lang, vim.log.levels.ERROR)
        return
    end

    local tmp_dir = vim.fn.tempname()
    local function notify(msg, level)
        if not opts.silent then
            vim.notify(msg, level)
        end
    end

    notify("Installing " .. lang .. " parser...", vim.log.levels.INFO)

    -- Clone
    vim.system({ "git", "clone", "--depth", "1", "--filter=blob:none", info.url, tmp_dir }):wait()

    -- Find src directory
    local src_dir = tmp_dir
    if info.location then
        src_dir = src_dir .. "/" .. info.location
    end
    src_dir = src_dir .. "/src"

    if vim.fn.isdirectory(src_dir) == 0 then
        vim.fn.delete(tmp_dir, "rf")
        notify("src/ directory not found for " .. lang, vim.log.levels.ERROR)
        return
    end

    -- Ensure output directory exists
    vim.fn.mkdir(parser_dir, "p")

    local output = parser_dir .. "/" .. lang .. ".so"
    local ok, err = compile_parser(src_dir, output)

    -- Copy queries if they exist. Prefer per-location queries (e.g. monorepo
    -- subdirs), fall back to the repo-root queries directory.
    local queries_src
    if info.location then
        local located = tmp_dir .. "/" .. info.location .. "/queries"
        if vim.fn.isdirectory(located) == 1 then
            queries_src = located
        end
    end
    if not queries_src then
        queries_src = tmp_dir .. "/queries"
    end
    if vim.fn.isdirectory(queries_src) == 1 then
        local queries_dst = vim.fn.stdpath("data") .. "/site/queries/" .. lang
        vim.fn.mkdir(queries_dst, "p")
        local files = vim.fn.glob(queries_src .. "/*.scm", false, true)
        for _, f in ipairs(files) do
            local name = vim.fn.fnamemodify(f, ":t")
            local content = vim.fn.readfile(f)
            -- Prepend ; inherits: directive for parsers that extend another language
            if info.inherits and name == "highlights.scm" then
                table.insert(content, 1, "; inherits: " .. info.inherits)
            end
            vim.fn.writefile(content, queries_dst .. "/" .. name)
        end
    end

    -- Cleanup
    vim.fn.delete(tmp_dir, "rf")

    if ok then
        -- Register the parser
        pcall(vim.treesitter.language.add, lang)
        notify("Installed " .. lang .. " parser", vim.log.levels.INFO)
    else
        notify("Failed to compile " .. lang .. ": " .. (err or ""), vim.log.levels.ERROR)
    end
end

-- M.install above clones and compiles with :wait() — it BLOCKS. That is fine
-- inside the `nvim --headless` child spawned below (a batch process with no UI
-- to freeze), but calling it from the UI process locks the editor for the whole
-- clone+compile. Every entry point in the UI must go through install_async.
--
---Install `langs` one at a time, each in its own headless child, without
---blocking the editor.
---@param langs string[]
local function install_async(langs)
    if #langs == 0 then return end
    vim.notify(("Installing %d treesitter parser(s)..."):format(#langs), vim.log.levels.INFO)

    local function install_next(i)
        if i > #langs then
            vim.notify("All parsers installed", vim.log.levels.INFO)
            return
        end
        local lang = langs[i]
        vim.system(
            { "nvim", "--headless",
              "-c", ("lua require('config.ts_parsers').install(%q, {silent=true})"):format(lang),
              "-c", "qa" },
            {},
            vim.schedule_wrap(function(result)
                if result.code == 0 then
                    pcall(vim.treesitter.language.add, lang)
                    vim.notify(("Installed %s (%d/%d)"):format(lang, i, #langs), vim.log.levels.INFO)
                else
                    vim.notify(("Failed: %s\n%s"):format(lang, result.stderr or ""), vim.log.levels.ERROR)
                end
                install_next(i + 1)
            end)
        )
    end
    install_next(1)
end

function M.setup()
    -- Install missing parsers asynchronously on startup
    vim.schedule(function()
        -- install_async spawns `nvim --headless`, and that child loads this
        -- same init.lua — so without this guard the child runs setup() too,
        -- sees the parsers still missing, and spawns a grandchild. Each child
        -- seeds an independent self-perpetuating chain, all compiling to the
        -- same parser/<lang>.so concurrently. Headless has no UI attached; bail
        -- out there. (Neovim itself uses this guard in _core/ui2.lua.)
        if #vim.api.nvim_list_uis() == 0 then return end

        local missing = {}
        for _, lang in ipairs(M.ensure_installed) do
            if not parser_exists(lang) then
                table.insert(missing, lang)
            end
        end
        install_async(missing)
    end)

    -- Commands
    vim.api.nvim_create_user_command("TSInstall", function(cmd_opts)
        local lang = cmd_opts.args
        if lang == "" then
            vim.notify("Usage: :TSInstall <lang>", vim.log.levels.WARN)
            return
        end
        install_async({ lang })
    end, {
        nargs = 1,
        complete = parser_names,
    })

    vim.api.nvim_create_user_command("TSUpdate", function(cmd_opts)
        local lang = cmd_opts.args
        install_async(lang ~= "" and { lang } or vim.deepcopy(M.ensure_installed))
    end, {
        nargs = "?",
        complete = parser_names,
    })

    vim.api.nvim_create_user_command("TSList", function()
        local lines = {}
        for _, name in ipairs(parser_names()) do
            local installed = parser_exists(name)
            local marker = installed and "[x]" or "[ ]"
            table.insert(lines, marker .. " " .. name)
        end
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
    end, {})
end

return M
