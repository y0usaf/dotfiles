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
      require 'nvim-tree'.setup {
        -- Add some default settings for nvim-tree
        view = {
          adaptive_size = true,
        },
        renderer = {
          highlight_git = true,
        },
        filters = {
          dotfiles = true,
        }
      }
    end
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require 'telescope'.setup {
        -- Add some default settings for telescope
        defaults = {
          file_sorter = require 'telescope.sorters'.get_fzy_sorter,
          generic_sorter = require 'telescope.sorters'.get_generic_fzy_sorter,
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
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        highlight = {
          enable = true,
        },
      }
    end
  },

  -- Supermaven plugin
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true },
        color = {
          suggestion_color = "#ff88dd"
        },
      })
    end
  },

  -- Cheatsheet Plugin
  {
    'sudormrfbin/cheatsheet.nvim',
    config = function()
      require('cheatsheet').setup({
        requires = {
          { 'nvim-telescope/telescope.nvim' },
          { 'nvim-lua/plenary.nvim' },
          { 'nvim-lua/popup.nvim' },
        }
      })
    end
  },

  -- edgy.nvim
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {}
  },

-- Linter
{
  'mhartington/formatter.nvim',
  event = "VeryLazy",
  config = function()
    require('formatter').setup({
      filetype = {
        typescript = { function() return { exe = 'prettier', args = { '--write' } } end },
        javascript = { function() return { exe = 'prettier', args = { '--write' } } end },
        json = { function() return { exe = 'prettier', args = { '--write' } } end },
        css = { function() return { exe = 'prettier', args = { '--write' } } end },
        scss = { function() return { exe = 'prettier', args = { '--write' } } end },
        html = { function() return { exe = 'prettier', args = { '--write' } } end },
        markdown = { function() return { exe = 'prettier', args = { '--write' } } end },
        lua = { function() return { exe = 'stylua', args = { '--config-path ~/.config/stylua/stylua.toml' } } end },
        python = { function() return { exe = 'black', args = { '-' } } end },
        sh = { function() return { exe = 'shfmt', args = { '-w' } } end },
        vim = { function() return { exe = 'vint', args = {} } end },
      },
    })
  end
},

  -- Trouble.nvim
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  }
  -- Close lazy.setup
})

-- Set leader key
vim.g.mapleader = ','

-- Key mappings
vim.api.nvim_set_keymap('n', '<leader>pv', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })

-- Set colorscheme
vim.cmd('colorscheme gruvbox-material')
