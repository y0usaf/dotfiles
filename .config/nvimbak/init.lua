-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
  -- Colorscheme
  { 'sainnhe/gruvbox-material' },

  -- File explorer
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = function()
      require'nvim-tree'.setup {}
    end
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require'telescope'.setup {}
    end
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        highlight = {
          enable = true,
        },
      }
    end
  },

  -- Auto completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip'
    },
    config = function()
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
    end
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require'lspconfig'
      local servers = { 'pyright', 'tsserver', 'clangd' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
        }
      end
    end
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = function()
      require'lualine'.setup {
        options = {
          icons_enabled = true,
          theme = 'gruvbox-material',
        }
      }
    end
  },

  -- Cheatsheet
  {
    'sudormrfbin/cheatsheet.nvim',
    config = function()
    require'cheatsheet'.setup {
    bundled_cheatsheets = {
    enabled = { 'default' },
    },
    bundled_plugin_cheatsheets = {
    enabled = {
    'nvim-tree',
    'telescope',
    'lspconfig',
    },
    },
    }
    end
    },
    -- Git signs
    {
    'lewis6991/gitsigns.nvim',
    config = function()
    require'gitsigns'.setup()
    end
    },
    -- Indent guides
    {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
    require'indent_blankline'.setup {
    show_current_context = true,
    show_current_context_start = true,
    }
    end
    },
    -- Commenting
    {
    'numToStr/Comment.nvim',
    config = function()
    require'Comment'.setup()
    end
    },
    -- Surround
    {
    'kylechui/nvim-surround',
    config = function()
    require'nvim-surround'.setup()
    end
    },
    -- Terminal
    {
    'akinsho/toggleterm.nvim',
    config = function()
    require'toggleterm'.setup()
    end
    },
    })
    -- Set colorscheme
    vim.cmd('colorscheme gruvbox-material')
    -- Set up keymaps
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<space>e', '<cmd>NvimTreeToggle<CR>', opts)
    vim.keymap.set('n', '<space>f', '<cmd>Telescope find_files<CR>', opts)
    vim.keymap.set('n', '<space>g', '<cmd>Telescope live_grep<CR>', opts)
    vim.keymap.set('n', '<space>b', '<cmd>Telescope buffers<CR>', opts)
    vim.keymap.set('n', '<space>h', '<cmd>Telescope help_tags<CR>', opts)
    vim.keymap.set('n', '<space>c', '<cmd>Cheatsheet<CR>', opts)
    vim.keymap.set('n', '<space>t', '<cmd>ToggleTerm<CR>', opts)