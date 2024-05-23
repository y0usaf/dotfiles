-- Install jetpack
-- vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/anuvyklack/jetpack.nvim.git', '~/.local/share/nvim/site/pack/packer/start/jetpack.nvim'})
vim.o.clipboard = 'unnamedplus'
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
        require'nvim-tree'.setup {
          -- Add some default settings for nvim-tree
          view = {
            adaptive_size = true,
          },
          renderer = {
            highlight_git = true,
          },
          filters = {
            dotfiles = true,
          },
          -- Add this line to open the file explorer by default
          auto_open = true,
        }
      end
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require'telescope'.setup {
        -- Add some default settings for telescope
        defaults = {
          file_sorter = require'telescope.sorters'.get_fzy_sorter,
          generic_sorter = require'telescope.sorters'.get_generic_fzy_sorter,
          file_ignore_patterns = { 'node_modules' },
        },
      }
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
          capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
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
      require('gitsigns').setup {
        signs = {
          add = { hl = 'GitSignAdd' },
          change = { hl = 'GitSignChange' },
          delete = { hl = 'GitSignDelete' },
          topdelete = { hl = 'GitSignDelete' },
          changedelete = { hl = 'GitSignChange' },
        },
      }
    end
  },
})

-- Set leader key
vim.g.mapleader = ','

-- Key mappings
vim.api.nvim_set_keymap('n', '<leader>pv', ':lua require("nvim-tree.api").tree_toggle()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tt', ':lua require("telescope.builtin").find_files()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tg', ':lua require("telescope.builtin").live_grep()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>td', ':lua require("telescope.builtin").diagnostics()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tb', ':lua require("telescope.builtin").buffers()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>th', ':lua require("telescope.builtin").help_tags()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ts', ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>to', ':lua require("telescope.builtin").lsp_document_symbols()<CR>', { noremap = true, silent = true })