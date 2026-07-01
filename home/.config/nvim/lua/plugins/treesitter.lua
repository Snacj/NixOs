vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require("nvim-treesitter").setup({
	branch = "main",
	build = ":TSUpdate",
	lazy = false,

	config = function()
		-- Parsers to auto-install
		local ensure_installed = {
			"lua", "python", "typescript", "javascript", "rust", "go",
			"bash", "json", "yaml", "toml", "markdown", "markdown_inline",
			"html", "css", "c", "cpp", "wgsl",
		}

		local ts = require("nvim-treesitter")
		if ts.install then
			local installed = require("nvim-treesitter.config").get_installed()
			local to_install = vim.iter(ensure_installed)
				:filter(function(p) return not vim.tbl_contains(installed, p) end)
				:totable()
			if #to_install > 0 then
				ts.install(to_install)
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
				vim.wo[0][0].foldmethod = "expr"
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo[0][0].foldlevel = 99
			end,
		})
	end,
})
