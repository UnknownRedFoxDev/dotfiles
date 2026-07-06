vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.netrw_banner = 0

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.smartcase = true
vim.opt.ignorecase = true

require("unknownredfoxo.lazy")
require("unknownredfoxo.customFunc")
require("unknownredfoxo.autocmd")
require("unknownredfoxo.remap")
