-- Treesitter parser management (replaces nvim-treesitter for parser installation)
-- Compiles parsers from source using system cc/c++

local M = {}

local parser_dir = vim.fn.stdpath("data") .. "/site/parser"

-- Parser registry: url, optional location (for monorepos like typescript)
local parsers = {
    cpp         = { url = "https://github.com/tree-sitter/tree-sitter-cpp" },
    rust        = { url = "https://github.com/tree-sitter/tree-sitter-rust" },
    go          = { url = "https://github.com/tree-sitter/tree-sitter-go" },
    javascript  = { url = "https://github.com/tree-sitter/tree-sitter-javascript" },
    typescript  = { url = "https://github.com/tree-sitter/tree-sitter-typescript", location = "typescript" },
    tsx         = { url = "https://github.com/tree-sitter/tree-sitter-typescript", location = "tsx" },
    json        = { url = "https://github.com/tree-sitter/tree-sitter-json" },
    yaml        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-yaml" },
    toml        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-toml" },
    bash        = { url = "https://github.com/tree-sitter/tree-sitter-bash" },
    glsl        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-glsl" },
    hlsl        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-hlsl" },
    odin        = { url = "https://github.com/tree-sitter-grammars/tree-sitter-odin" },
    zig         = { url = "https://github.com/tree-sitter-grammars/tree-sitter-zig" },
}

-- Languages to install on startup if missing
M.ensure_installed = {
    "cpp", "rust", "go",
    "javascript", "typescript", "tsx",
    "json", "yaml", "toml", "bash",
    "glsl", "hlsl",
}

local function parser_exists(lang)
    local ok = pcall(vim.treesitter.language.add, lang)
    return ok
end

local function compile_parser(src_dir, output_path, lang)
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
        "-o", output_path,
        "-I", src_dir,
        "-O2",
        "-undefined", "dynamic_lookup", -- macOS
    }
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
    local notify = opts.silent and function() end or function(msg, level)
        vim.notify(msg, level)
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
    local ok, err = compile_parser(src_dir, output, lang)

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

function M.update(lang)
    -- Reinstall (re-clone and recompile)
    if lang then
        M.install(lang)
    else
        for _, l in ipairs(M.ensure_installed) do
            M.install(l)
        end
    end
end

function M.setup()
    -- Install missing parsers asynchronously on startup
    vim.schedule(function()
        local missing = {}
        for _, lang in ipairs(M.ensure_installed) do
            if not parser_exists(lang) then
                table.insert(missing, lang)
            end
        end
        if #missing > 0 then
            vim.notify("Installing " .. #missing .. " treesitter parsers...", vim.log.levels.INFO)
            -- Install sequentially in background to avoid overwhelming the system
            local function install_next(i)
                if i > #missing then
                    vim.notify("All parsers installed", vim.log.levels.INFO)
                    return
                end
                vim.system(
                    { "nvim", "--headless",
                      "-c", "lua require('config.ts_parsers').install('" .. missing[i] .. "', {silent=true})",
                      "-c", "qa" },
                    {},
                    vim.schedule_wrap(function(result)
                        if result.code == 0 then
                            pcall(vim.treesitter.language.add, missing[i])
                            vim.notify("Installed " .. missing[i] .. " (" .. i .. "/" .. #missing .. ")", vim.log.levels.INFO)
                        else
                            vim.notify("Failed: " .. missing[i], vim.log.levels.ERROR)
                        end
                        install_next(i + 1)
                    end)
                )
            end
            install_next(1)
        end
    end)

    -- Commands
    vim.api.nvim_create_user_command("TSInstall", function(cmd_opts)
        local lang = cmd_opts.args
        if lang == "" then
            vim.notify("Usage: :TSInstall <lang>", vim.log.levels.WARN)
            return
        end
        M.install(lang)
    end, {
        nargs = 1,
        complete = function(_, _, _)
            local names = {}
            for name, _ in pairs(parsers) do
                table.insert(names, name)
            end
            table.sort(names)
            return names
        end,
    })

    vim.api.nvim_create_user_command("TSUpdate", function(cmd_opts)
        local lang = cmd_opts.args
        M.update(lang ~= "" and lang or nil)
    end, {
        nargs = "?",
        complete = function(_, _, _)
            local names = {}
            for name, _ in pairs(parsers) do
                table.insert(names, name)
            end
            table.sort(names)
            return names
        end,
    })

    vim.api.nvim_create_user_command("TSList", function()
        local lines = {}
        local all_langs = {}
        for name, _ in pairs(parsers) do
            table.insert(all_langs, name)
        end
        table.sort(all_langs)
        for _, name in ipairs(all_langs) do
            local installed = parser_exists(name)
            local marker = installed and "[x]" or "[ ]"
            table.insert(lines, marker .. " " .. name)
        end
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
    end, {})
end

return M
