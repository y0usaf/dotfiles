-- plugins.lua
return { -- Plugin management
'wbthomason/packer.nvim', -- Colorscheme
'folke/tokyonight.nvim', -- Telescope fuzzy finder
{
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    dependencies = {'nvim-lua/plenary.nvim'}
}, -- Treesitter for better syntax highlighting
{
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
}, -- Autocomplete with nvim-cmp
'hrsh7th/nvim-cmp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'hrsh7th/cmp-cmdline', 'saadparwaiz1/cmp_luasnip',
'L3MON4D3/LuaSnip', -- File explorer
{
    'nvim-tree/nvim-tree.lua',
    dependencies = {'nvim-tree/nvim-web-devicons'}
}, -- Buffer tabs
{
    'akinsho/bufferline.nvim',
    dependencies = {'nvim-tree/nvim-web-devicons'}
}, -- Statusline
{
    'nvim-lualine/lualine.nvim',
    dependencies = {'nvim-tree/nvim-web-devicons'}
}, -- Homepage
{
    'goolord/alpha-nvim',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
        require('alpha').setup(require('alpha.themes.startify').config)
    end
}, -- Obsidian
{
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = {
        workspaces = {{
            name = "personal",
            path = "~/Documents/Obsidian Vault"
        }}
    }
}, -- VSCode-like file tree viewer
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    }
}}

