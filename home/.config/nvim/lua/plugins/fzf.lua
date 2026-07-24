vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

require("fzf-lua").setup({})

local fzf = require("fzf-lua")

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[Find] [f]iles in project directory" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "[Find] by [g]repping project directory" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Find keymaps" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "[F]ind current [w]ord" })
vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD, { desc = "[F]ind current [W]ORD" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "Resume last search" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "Old files" })
vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "Buffers" })
vim.keymap.set('n', '<leader>fc', require('fzf-lua').lsp_live_workspace_symbols, { desc = 'Search classes/symbols (live)' })

vim.keymap.set('n', '<leader>fs', require('fzf-lua').lsp_document_symbols, { desc = 'Symbols in file' })
