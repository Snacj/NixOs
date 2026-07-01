-- set space as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("plugins")

vim.keymap.set("n", "<leader><Enter>", "<CMD>Oil --float<CR>")
