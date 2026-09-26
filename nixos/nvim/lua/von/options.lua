local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = "100"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.breakindent = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.updatetime = 200
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.mouse = "a"

vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})
