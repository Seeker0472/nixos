return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
				PATH = "prepend",
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				cmd = { "clangd", "--background-index", "--clang-tidy", "--query-driver=gcc" },
			})
			lspconfig.jedi_language_server.setup({})
			lspconfig.jdtls.setup({})
			lspconfig.rust_analyzer.setup({})
			lspconfig.bashls.setup({})
			--			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {})
			--			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			--			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			--			vim.keymap.set({ "n" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		-- see https://github.com/williamboman/mason-lspconfig.nvim
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "jdtls", "jedi_language_server", "bashls" },
				automatic_installation = true,
			})
		end,
	},
}
