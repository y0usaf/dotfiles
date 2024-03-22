local lspconfig = require('lspconfig')

lspconfig.nvim_lint.setup{
  cmd = {"nvim-lint", "--stdin-filename", "%filepath", "--stdin", "%"},
  filetypes = {"python", "javascript", "typescript", "css"},
}