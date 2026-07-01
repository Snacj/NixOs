vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim", "https://github.com/tpope/vim-fugitive" })
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status (Fugitive)" })

require("gitsigns").setup({
    signs = {
        add = { text = "+" },
        change = { text = "+" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },
    signs_staged = {
        add = { text = "+" },
        change = { text = "+" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },
})

vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", {})
