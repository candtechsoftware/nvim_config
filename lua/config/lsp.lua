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
    vim.keymap.set("n", "gv", function()
        vim.cmd("vsplit")
        vim.lsp.buf.definition()
    end, opts)
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

    -- Formatting
    vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ async = false })
    end, opts)

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
            prefix = '■ ',
            source = true,
            severity = { min = vim.diagnostic.severity.ERROR },
            spacing = 4,
            suffix = '',
            format = function(diagnostic)
                return string.format("[%s] %s", diagnostic.source or "LSP", diagnostic.message)
            end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
            border = 'rounded',
            header = '',
            prefix = '',
            focusable = false,  -- Performance: don't make diagnostic floats focusable
            max_width = 80,
            max_height = 20,
        },
    })

    -- Debounce diagnostic updates for performance
    local diagnostic_timer = vim.uv.new_timer()
    local original_set_loclist = vim.diagnostic.setloclist
    vim.diagnostic.setloclist = function(...)
        local args = {...}
        diagnostic_timer:stop()
        diagnostic_timer:start(200, 0, vim.schedule_wrap(function()
            original_set_loclist(unpack(args))
        end))
    end

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

    -- Performance optimizations: disable unused capabilities
    capabilities.workspace.workspaceEdit = nil  -- Don't need workspace edits for performance
    capabilities.textDocument.publishDiagnostics = vim.tbl_deep_extend("force",
        capabilities.textDocument.publishDiagnostics or {},
        {
            relatedInformation = false,  -- Disable for performance
            codeActionsInline = false,  -- Disable for performance
        }
    )

    -- Enable optimized completion
    if vim.lsp.completion then
        capabilities.textDocument.completion.completionItem = {
            documentationFormat = { "plaintext" },  -- Faster than markdown
            snippetSupport = false,  -- Keep disabled for performance
            preselectSupport = false,  -- Don't preselect for our use case
            insertReplaceSupport = false,  -- Simple insertion only
            resolveSupport = {
                properties = { "detail" }  -- Only resolve detail, not documentation for speed
            },
            deprecatedSupport = true,
            commitCharactersSupport = false,  -- Don't commit on character for our use case
        }
        capabilities.textDocument.completion.contextSupport = true
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

    -- Enhanced on_attach with optimized auto-completion
    local function enhanced_on_attach(client, bufnr)
        on_attach(client, bufnr)

        -- Performance: set LSP timeouts
        client.server_capabilities = client.server_capabilities or {}
        if client.server_capabilities.hoverProvider then
            client.server_capabilities.hoverProvider = { timeout_ms = 1500 }
        end

        -- Enable LSP completion for this buffer
        -- In Neovim 0.11+, use vim.lsp.completion.enable() instead of omnifunc
        if vim.lsp.completion then
            vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })
        end

        -- Use omnifunc-based completion (Tab keymaps are in keymaps.lua)
        -- Trigger with <C-x><C-o> or auto-trigger on typing
        local completion_timer = vim.uv.new_timer()
        vim.api.nvim_create_autocmd('TextChangedI', {
            buffer = bufnr,
            callback = function()
                completion_timer:stop()
                completion_timer:start(150, 0, vim.schedule_wrap(function()
                    if vim.api.nvim_get_mode().mode == 'i' and vim.fn.pumvisible() == 0 then
                        local line = vim.api.nvim_get_current_line()
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        local before = line:sub(1, col)
                        -- Trigger completion on . or 2+ word chars
                        if before:match('%.$') or before:match('%w%w$') then
                            vim.api.nvim_feedkeys(
                                vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true),
                                'n', false
                            )
                        end
                        -- Trigger signature help on ( or ,
                        if before:match('%($') or before:match(',%s*$') then
                            vim.lsp.buf.signature_help()
                        end
                    end
                end))
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

        -- clangd removed: C/C++ handled by YouCompleteMe (see config/ycm.lua)

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
            end,
        })
    end
end

-- LSP control commands
function M.stop_lsp(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then
        return
    end

    for _, client in ipairs(clients) do
        vim.lsp.buf_detach_client(bufnr, client.id)
    end
end

function M.start_lsp(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

    if not filetype or filetype == "" then
        return
    end

    -- Get the buffer name for root detection
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local capabilities = get_capabilities()

    -- Find matching server config
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
        },
        rust_analyzer = {
            cmd = { 'rust-analyzer' },
            filetypes = { 'rust' },
            root_markers = { 'Cargo.toml', '.git' },
        },
        -- clangd removed: C/C++ handled by YouCompleteMe
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

    -- Add Jai if available
    local jails_path = get_jails_path()
    if jails_path then
        servers.jails = {
            cmd = { jails_path },
            filetypes = { 'jai' },
            root_markers = { 'build.jai', 'first.jai', '.git' },
        }
    end

    -- Find matching server for current filetype
    for server_name, config in pairs(servers) do
        for _, ft in ipairs(config.filetypes) do
            if ft == filetype and vim.fn.executable(config.cmd[1]) == 1 then
                local root_dir = get_workspace_root(bufname, config.root_markers)

                if root_dir or config.single_file_support ~= false then
                    vim.lsp.start({
                        name = server_name,
                        cmd = config.cmd,
                        root_dir = root_dir,
                        capabilities = capabilities,
                        settings = config.settings,
                        init_options = config.init_options,
                        on_attach = function(client, buf)
                            on_attach(client, buf)
                            if vim.lsp.completion then
                                vim.lsp.completion.enable(true, client.id, buf, {
                                    autotrigger = true,
                                })
                            end
                        end,
                    }, { bufnr = bufnr })
                    return
                end
            end
        end
    end

end

-- Create user commands
vim.api.nvim_create_user_command("LspStop", function()
    M.stop_lsp()
end, { desc = "Stop LSP for current buffer" })

vim.api.nvim_create_user_command("LspStart", function()
    M.start_lsp()
end, { desc = "Start LSP for current buffer" })

return M
