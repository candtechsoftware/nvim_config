vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- nvim v0.7.2
    use({
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        requires = {
            "nvim-lua/plenary.nvim",
        }
    })
    use( "whizikxd/naysayer-colors.nvim")
    use('sainnhe/sonokai')
    use("luisiacc/gruvbox-baby")
    use("sainnhe/gruvbox-material")

   -- nvim v0.7.2
    use 'wbthomason/packer.nvim'
    use 'lewis6991/gitsigns.nvim'
    use ('nvimtools/none-ls.nvim')
    use('cryptomilk/nightcity.nvim')

    use('ziglang/zig.vim')
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.3',
    }

    use('ThePrimeagen/harpoon')

    use('github/copilot.vim')

    use('nvim-lua/plenary.nvim')
    use('jose-elias-alvarez/null-ls.nvim')

    use({
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {
                -- your configuration comes hee
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
                --  keys = {
                    keys = {
                        "<leader>xx",
                        "<cmd>Trouble diagnostics toggle<cr>",
                        desc = "Diagnostics (Trouble)",
                   },
            }
        end
    })

    use 'Raimondi/delimitMate'
    use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = {
            "markdown" } end, ft = { "markdown" }, })
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
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }



end)
