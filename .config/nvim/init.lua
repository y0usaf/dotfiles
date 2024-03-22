-- Bootstrap vim-jetpack
local jetpack = require('vim.jetpack')
jetpack.startup(function(use)
  -- Package manager
  use 'tani/vim-jetpack'

  -- Colorscheme
  use 'sainnhe/gruvbox-material'

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons'
  }

  -- Fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Treesitter for better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Auto completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- LSP
  use 'neovim/nvim-lspconfig'

  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
end)

-- Set colorscheme
vim.cmd[[colorscheme gruvbox-material]]

-- Nvim-tree setup
require'nvim-tree'.setup {}

-- Telescope setup
require'telescope'.setup {}

-- Treesitter setup
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
}

-- Nvim-cmp setup
local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- LSP setup
local lspconfig = require'lspconfig'
local servers = { 'pyright', 'tsserver', 'clangd' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
end

-- Lualine setup 
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox-material',
  }
}