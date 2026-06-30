vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },

        c = { "clang-format", lsp_format = "fallback" },
        cpp = { "clang-format", lsp_format = "fallback" },
    },
    -- format_on_save = {
    -- 	-- These options will be passed to conform.format()
    -- 	timeout_ms = 500,
    -- 	lsp_format = "fallback",
    -- },
})

vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({
		lsp_format = "fallback",
	})
end, { desc = "Format current file" })
