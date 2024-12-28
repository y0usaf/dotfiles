-- Set options
vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true
-- vim.opt.relativenumber = true

-- Set leader key
vim.g.mapleader = ','

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
      require('nvim-tree').setup {
        view = { adaptive_size = true },
        renderer = { highlight_git = true },
        filters = { dotfiles = true }
      }
    end
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('telescope').setup {
        defaults = {
          file_sorter = require('telescope.sorters').get_fzy_sorter,
          generic_sorter = require('telescope.sorters').get_generic_fzy_sorter,
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
      require('nvim-treesitter.configs').setup {
        ensure_installed = "all",
        highlight = { enable = true },
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
        color = { suggestion_color = "#ff88dd" },
        use_default_keymaps = false,  -- Disable default keymaps
        enable_cmp = true,  -- Enable cmp integration
      })
    end
  },

  -- Cheatsheet Plugin
  {
    'sudormrfbin/cheatsheet.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-lua/popup.nvim',
    },
    config = function()
      require('cheatsheet').setup()
    end
  },

  -- edgy.nvim
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {}
  },

  -- Formatter
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
          lua = { function() return { exe = 'stylua', args = { '--config-path', '~/.config/stylua/stylua.toml' } } end },
          python = { function() return { exe = 'black', args = { '-' } } end },
          sh = { function() return { exe = 'shfmt', args = { '-w' } } end },
          vim = { function() return { exe = 'vint' } end },
        },
      })
    end
  },

  -- Trouble.nvim
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- nvim-cmp
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'supermaven-inc/supermaven-nvim',  -- Add Supermaven as a dependency
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'supermaven' },  -- Add Supermaven as a source
        }),
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
      })
    end
  },

  -- Obsidian.nvim
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = false,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.opt.conceallevel = 1  -- Set conceallevel to 1 (or 2 if you prefer)
      require("obsidian").setup({
        workspaces = {
          {
            name = "personal",
            path = "~/Obsidian",
          },
        },
        notes_subdir = "notes",
        daily_notes = {
          folder = "notes/dailies",
          date_format = "%Y-%m-%d",
        },
        completion = {
          nvim_cmp = pcall(require, 'cmp'),
          min_chars = 2,
        },
        new_notes_location = "notes_subdir",
        wiki_link_func = function(opts)
          return require("obsidian.util").wiki_link_id_prefix(opts)
        end,
        preferred_link_style = "wiki",
        ui = {
          enable = true,  -- Set this to false if you want to disable Obsidian's UI features
        },
      })
    end
  },
})

-- Key mappings
local keymap = vim.keymap.set
keymap('n', '<leader>pv', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })

-- Obsidian keymaps
keymap("n", "<leader>on", ":ObsidianNew<CR>", { desc = "New Obsidian note" })
keymap("n", "<leader>oo", ":ObsidianOpen<CR>", { desc = "Open Obsidian" })
keymap("n", "<leader>os", ":ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })
keymap("n", "<leader>of", ":ObsidianFollowLink<CR>", { desc = "Follow Link" })
keymap("n", "<leader>ob", ":ObsidianBacklinks<CR>", { desc = "Show Backlinks" })

-- Set colorscheme
vim.cmd('colorscheme gruvbox-material')

-- Autocommands
local augroup = vim.api.nvim_create_augroup("CustomAutocommands", { clear = true })

-- Format on save
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*",
  command = "FormatWrite",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})
