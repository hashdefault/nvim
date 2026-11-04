-- Config minimalista para Neovim 0.12+. Testar com: NVIM_APPNAME=nvim-min nvim
-- Cada módulo de lua/config/ cuida de um assunto e instala os próprios plugins (vim.pack.add).
vim.g.mapleader = " "

require("config.options")
require("config.colors") -- cedo, para o resto já nascer com as cores do tema
require("config.treesitter")
require("config.git")
require("config.wiki")
require("config.lsp")
require("config.completion")
require("config.format")
require("config.pickers")
require("config.explorer")
require("config.statusline")
require("config.keymaps")
require("config.autocmds")
