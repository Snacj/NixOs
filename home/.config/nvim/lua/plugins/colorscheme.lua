-- General background tone
vim.opt.background = "dark"

-- My Custom Theme
vim.pack.add({ "https://github.com/snacj/gelb.nvim" })
-- Gruvbox
vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })
require("gruvbox").setup({
	contrast = "hard",
})
-- Gruber Darker
vim.pack.add({
	"https://github.com/blazkowolf/gruber-darker.nvim",
})
-- Monokai (pro)
vim.pack.add({
	"https://github.com/tanvirtin/monokai.nvim",
})
-- Coal
vim.pack.add({
	"https://github.com/cranberry-clockworks/coal.nvim",
})
-- Rose Pine
vim.pack.add({
	"https://github.com/rose-pine/neovim",
})
-- Bluloco dependency (lush)
vim.pack.add({
    "https://github.com/rktjmp/lush.nvim"
})
-- Bluloco
vim.pack.add({
	"https://github.com/uloco/bluloco.nvim",
})
-- Dookie
vim.pack.add({
	"https://github.com/pebeto/dookie.nvim",
})
-- Nightfox
vim.pack.add({
	"https://github.com/EdenEast/nightfox.nvim",
})
-- Vague
vim.pack.add({
    "https://github.com/vague-theme/vague.nvim",
})
-- Hardhat
vim.pack.add({
    "https://github.com/g-kirti/hardhat.nvim",
})

-- === SET COLORSCHEME HERE ===
-- vim.cmd.colorscheme("gelb")
vim.cmd.colorscheme("industry")
