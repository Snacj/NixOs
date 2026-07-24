vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
require("fidget").setup({})

vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

require("mason").setup()

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.pack.add({ "https://github.com/mason-org/mason-lspconfig.nvim" })

require("mason-lspconfig").setup({
	automatic_enable = false,
})

vim.pack.add({ "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" })

vim.pack.add({ "https://github.com/mfussenegger/nvim-jdtls" })

require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
        "zls",
        "html-lsp",
        "css-lsp",
        "typescript-language-server",
        "emmet-ls",
        "jdtls",
	},
})

-- ============================================================================
-- SERVER SPECIFIC OVERRIDES
-- ============================================================================
-- LUA
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})
-- CSS
vim.lsp.config("cssls", {})
-- HTML + emmet
vim.lsp.config("html", {})
vim.lsp.config("emmet_ls", {})
-- TYPESCRIPT
vim.lsp.config("ts_ls", {})
-- JAVA
vim.lsp.config("jdtls", {
  root_markers = {
    "settings.gradle",
    "settings.gradle.kts",
    "build.gradle",
    "build.gradle.kts",
    "gradlew",
    ".git",
  },
  settings = {
    java = {
      import = {
        gradle = {
          enabled = true,
          wrapper = {
            enabled = true,
          },
        },
      },
      configuration = {
        updateBuildConfiguration = "automatic",
      },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
    },
  },
})
-- STILL JAVA
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    local root_dir = vim.fs.root(args.buf, {
      "settings.gradle",
      "settings.gradle.kts",
      "gradlew",
      ".git",
    })
    if not root_dir then
      return
    end

    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
    local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name

    local cfg = vim.tbl_deep_extend("force", vim.lsp.config.jdtls or {}, {
      cmd = { "jdtls", "-data", workspace_dir },
      root_dir = root_dir,
    })

    require('jdtls').start_or_attach(cfg)
  end,
})

-- ============================================================================
-- ENABLE SERVERS
-- ============================================================================
vim.lsp.enable({
	"lua_ls",
    "zls",
    "html",
    "cssls",
    "ts_ls",
    "emmet_ls",
})

-- ============================================================================
-- KEYBINDINGS
-- ============================================================================
local fzf = require("fzf-lua")
fzf.register_ui_select()

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end
		map("n", "gd", fzf.lsp_definitions, "[G]oto [D]efinition")
		map("n", "gr", fzf.lsp_references, "[G]oto [R]eferences")
		map("n", "gI", fzf.lsp_implementations, "[G]oto [I]mplementation")
		map("n", "<leader>D", fzf.lsp_typedefs, "Type [D]efinition")
		map("n", "<leader>ds", fzf.lsp_document_symbols, "[D]ocument [S]ymbols")
		map("n", "<leader>ws", fzf.lsp_live_workspace_symbols, "[W]orkspace [S]ymbols")

		map("n", "<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
		map({ "n", "x" }, "<leader>ca", fzf.lsp_code_actions, "[C]ode [A]ction")
		map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	end,
})
