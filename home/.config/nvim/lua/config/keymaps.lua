local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove highlight with Escape" })

-- Move lines up/down (Alt+j/k)
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Diagnostics float
map("n", "<leader>gl", function()
	vim.diagnostic.open_float()
end, { desc = "Open Diagnostics in Float" })

-- Better line start/end
-- map("n", "gl", "$", { desc = "Go to end of line" })
-- map("n", "gh", "^", { desc = "Go to start of line" })
-- map("n", "<A-h>", "^", { desc = "Go to start of line", silent = true })
-- map("n", "<A-l>", "$", { desc = "Go to end of line", silent = true })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Toggle line wrapping
map("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Toggle Wrap", silent = true })
