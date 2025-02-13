vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- nvim v0.7.2
    use({
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })

    use {
        'folke/snacks.nvim',
        config = function()
            local Snacks = require('snacks')

            -- Setup basic configuration
            Snacks.setup({
                picker = {
                    enbale = true,
                    auto_close = true,
                },
                explorer = {},

            })

            -- Key mappings
            local function map(mode, lhs, rhs, opts)
                opts = opts or {}
                opts.silent = opts.silent ~= false
                vim.keymap.set(mode, lhs, rhs, opts)
            end

            -- Top Pickers & Explorer
            map('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
            map('n', '<leader>,', function() Snacks.picker.buffers() end, { desc = "Buffers" })
            map('n', '<leader>/', function() Snacks.picker.grep() end, { desc = "Grep" })
            map('n', '<leader>:', function() Snacks.picker.command_history() end, { desc = "Command History" })
            map('n', '<leader>n', function() Snacks.picker.notifications() end, { desc = "Notification History" })
            map('n', '<leader>e', function() Snacks.explorer() end, { desc = "File Explorer" })

            -- Find mappings
            map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = "Buffers" })
            map('n', '<leader>fc', function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
                { desc = "Find Config File" })
            map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = "Find Files" })
            map('n', '<leader>fg', function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
            map('n', '<leader>fp', function() Snacks.picker.projects() end, { desc = "Projects" })
            map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = "Recent" })

            -- Git mappings
            map('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = "Git Branches" })
            map('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = "Git Log" })
            map('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = "Git Log Line" })
            map('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = "Git Status" })
            map('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
            map('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)" })
            map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = "Git Log File" })

            -- Grep mappings
            map('n', '<leader>sb', function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
            map('n', '<leader>sB', function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
            map('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = "Grep" })
            map({ 'n', 'x' }, '<leader>sw', function() Snacks.picker.grep_word() end,
                { desc = "Visual selection or word" })

            -- Search mappings
            map('n', '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers" })
            map('n', '<leader>s/', function() Snacks.picker.search_history() end, { desc = "Search History" })
            map('n', '<leader>sa', function() Snacks.picker.autocmds() end, { desc = "Autocmds" })
            map('n', '<leader>sc', function() Snacks.picker.command_history() end, { desc = "Command History" })
            map('n', '<leader>sC', function() Snacks.picker.commands() end, { desc = "Commands" })
            map('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
            map('n', '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
            map('n', '<leader>sh', function() Snacks.picker.help() end, { desc = "Help Pages" })
            map('n', '<leader>sH', function() Snacks.picker.highlights() end, { desc = "Highlights" })
            map('n', '<leader>si', function() Snacks.picker.icons() end, { desc = "Icons" })
            map('n', '<leader>sj', function() Snacks.picker.jumps() end, { desc = "Jumps" })
            map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
            map('n', '<leader>sl', function() Snacks.picker.loclist() end, { desc = "Location List" })
            map('n', '<leader>sm', function() Snacks.picker.marks() end, { desc = "Marks" })
            map('n', '<leader>sM', function() Snacks.picker.man() end, { desc = "Man Pages" })
            map('n', '<leader>sp', function() Snacks.picker.lazy() end, { desc = "Search for Plugin Spec" })
            map('n', '<leader>sq', function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
            map('n', '<leader>sR', function() Snacks.picker.resume() end, { desc = "Resume" })
            map('n', '<leader>su', function() Snacks.picker.undo() end, { desc = "Undo History" })
            map('n', '<leader>uC', function() Snacks.picker.colorschemes() end, { desc = "Colorschemes" })

            -- LSP mappings
            map('n', 'gd', function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
            map('n', 'gD', function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
            map('n', 'gr', function() Snacks.picker.lsp_references() end, { desc = "References", nowait = true })
            map('n', 'gI', function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
            map('n', 'gy', function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
            map('n', '<leader>ss', function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
            map('n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end,
                { desc = "LSP Workspace Symbols" })
        end
    }


    use('sainnhe/sonokai')
    use('neovim/nvim-lspconfig')
    use('ziglang/zig.vim')
    -- nvim v0.7.2
    use 'wbthomason/packer.nvim'
    use 'lewis6991/gitsigns.nvim'
    use('nvimtools/none-ls.nvim')
    use('cryptomilk/nightcity.nvim')
    use 'wbthomason/packer.nvim'
    use 'lewis6991/gitsigns.nvim'
    use('nvimtools/none-ls.nvim')
    use('sainnhe/sonokai')

    use('ziglang/zig.vim')
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.3',
    }


    use('github/copilot.vim')

    use('nvim-lua/plenary.nvim')
    use('jose-elias-alvarez/null-ls.nvim')

    use({
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {
                keys = {
                    "<leader>xx",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)",
                },
            }
        end
    })

    use 'Raimondi/delimitMate'
    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function()
            vim.g.mkdp_filetypes = {
                "markdown" }
        end,
        ft = { "markdown" },
    })
    use('nvim-treesitter/nvim-treesitter')
    use('nvim-treesitter/nvim-treesitter-textobjects')

    use("nvim-treesitter/playground")
    use("theprimeagen/refactoring.nvim")
    use("mbbill/undotree")
    use("tpope/vim-fugitive")
    use('ap29600/tree-sitter-odin')
    use('Tetralux/odin.vim')
    use('nvim-telescope/telescope-fzf-native.nvim')
    use('airblade/vim-gitgutter')


    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }
end)
