-- No more nvim-lspconfig dependency needed

local M = {}

local project_root = require("utils.project_root")

-- Helper function for workspace root detection
local function get_workspace_root(fname, patterns)
    return project_root.find({
        startpath = fname,
        markers = patterns,
        fallback_to_initial_cwd = true,
    })
end

-- LSP keymaps and attach function
local function on_attach(client, bufnr)
    local opts = { buffer = bufnr, silent = true }

    -- Navigation
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)

    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

    -- Actions
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>vi", vim.lsp.buf.incoming_calls, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

    -- Diagnostics
    vim.keymap.set("n", "<leader>qf", function()
        vim.diagnostic.setqflist({ open = true })
    end, opts)
    vim.keymap.set("n", "<leader>qq", function()
        vim.diagnostic.setloclist({ open = true })
    end, opts)
end

-- Global diagnostic configuration
local function setup_diagnostics()
    vim.diagnostic.config({
        virtual_text = {
            prefix = '●',
            source = "if_many",
            severity = { min = vim.diagnostic.severity.WARN },
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
            border = 'rounded',
            header = '',
            prefix = '',
        },
    })

    -- Configure LSP floating window appearance
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = 80,
        max_height = 20,
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
        max_width = 80,
        max_height = 15,
        anchor_bias = "above", -- Show above cursor when possible
        close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
    })
end

-- Native LSP capabilities (built-in completion support in 0.11+)
local function get_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Enable completion if available
    if vim.lsp.completion then
        capabilities.textDocument.completion.completionItem.snippetSupport = false
        capabilities.textDocument.completion.completionItem.resolveSupport = {
            properties = { "documentation", "detail", "additionalTextEdits" }
        }
    end

    return capabilities
end

-- Helper function to find Jails LSP
local function get_jails_path()
    local paths = {
        vim.fn.expand("~/bins/jails"),
        vim.fn.expand("~/.local/bin/jails"),
        "/usr/local/bin/jails",
        vim.fn.exepath("jails")
    }

    for _, p in ipairs(paths) do
        if p and p ~= "" and vim.fn.executable(p) == 1 then
            return p
        end
    end

    local platform = vim.uv.os_uname().sysname:lower()
    local arch = vim.uv.os_uname().machine:lower()
    if arch == "x86_64" then arch = "amd64" end

    local binary_name = string.format("jails-%s-%s", platform, arch)
    if platform == "windows" then
        binary_name = binary_name .. ".exe"
    end

    local platform_specific = vim.fn.exepath(binary_name)
    if platform_specific and platform_specific ~= "" then
        return platform_specific
    end

    return nil
end

function M.setup()
    setup_diagnostics()

    local capabilities = get_capabilities()

    -- Enhanced on_attach with auto-completion that shows but doesn't auto-complete
    local function enhanced_on_attach(client, bufnr)
        on_attach(client, bufnr)

        -- Set omnifunc for completion
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Enable auto-completion that shows as you type
        if vim.lsp.completion then
            vim.lsp.completion.enable(true, client.id, bufnr, {
                autotrigger = true, -- Show completions as you type
            })
        end

        -- Auto-trigger completion as you type (but don't auto-select)
        vim.api.nvim_create_autocmd({ 'TextChangedI' }, {
            buffer = bufnr,
            callback = function()
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local before_cursor = line:sub(1, col)

                -- Trigger completion after typing letters (not spaces or symbols)
                if before_cursor:match('%w$') and vim.fn.pumvisible() == 0 then
                    vim.schedule(function()
                        if vim.api.nvim_get_mode().mode == 'i' then
                            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), 'n')
                        end
                    end)
                end
            end,
        })
    end

    -- Use the modern vim.lsp.config API properly
    local servers = {
        lua_ls = {
            cmd = { 'lua-language-server' },
            filetypes = { 'lua' },
            root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                },
            },
        },

        gopls = {
            cmd = { 'gopls' },
            filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
            root_markers = { 'go.mod', 'go.sum', '.git' },
        },

        ts_ls = {
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
            root_markers = { 'package.json', 'tsconfig.json', '.git' },
            settings = {
                typescript = {
                    preferences = {
                        includePackageJsonAutoImports = "on",
                        includeAutomaticOptionalChainCompletions = true,
                    },
                },
                javascript = {
                    preferences = {
                        includePackageJsonAutoImports = "on",
                    },
                },
            },
        },

        rust_analyzer = {
            cmd = { 'rust-analyzer' },
            filetypes = { 'rust' },
            root_markers = { 'Cargo.toml', '.git' },
        },

        clangd = {
            cmd = {
                "clangd",
                "--background-index",
                "--header-insertion=never",
                "--completion-style=bundled",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
                "--pch-storage=memory",
                "-j=4",
            },
            filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
            root_markers = { 'compile_commands.json', '.clangd', 'CMakeLists.txt', 'Makefile', '.git' },
        },

        zls = {
            cmd = { 'zls' },
            filetypes = { 'zig' },
            root_markers = { 'build.zig', '.git' },
        },

        ols = {
            cmd = { 'ols' },
            filetypes = { 'odin' },
            root_markers = { 'ols.json', '.git' },
        },
    }

    -- Add Jai Language Server if available
    local jails_path = get_jails_path()
    if jails_path then
        servers.jails = {
            cmd = { jails_path },
            filetypes = { 'jai' },
            root_markers = { 'build.jai', 'first.jai', '.git' },
            single_file_support = false,
        }
    end

    -- Auto-start LSP servers for matching filetypes
    for server_name, config in pairs(servers) do
        if vim.fn.executable(config.cmd[1]) == 1 then
            vim.api.nvim_create_autocmd("FileType", {
                pattern = config.filetypes,
                callback = function(args)
                    local root_dir = get_workspace_root(vim.api.nvim_buf_get_name(args.buf), config.root_markers)
                    if not root_dir and not config.single_file_support then
                        return
                    end

                    vim.lsp.start({
                        name = server_name,
                        cmd = config.cmd,
                        root_dir = root_dir,
                        capabilities = capabilities,
                        settings = config.settings,
                        init_options = config.init_options,
                        on_attach = function(client, bufnr)
                            enhanced_on_attach(client, bufnr)
                        end,
                    })
                end,
            })
        end
    end

    -- Show warning for missing Jai LSP
    if not jails_path then
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "jai",
            once = true,
            callback = function()
                vim.notify(
                    "Jai Language Server not found. Please install jails from https://github.com/SogoCZE/Jails",
                    vim.log.levels.WARN
                )
            end,
        })
    end
end

return M
