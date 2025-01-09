return {
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = { "stylua", "jq", "black","clang-format","nixpkgs-fmt" },
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.completion.spell,
					null_ls.builtins.formatting.black,
					null_ls.builtins.formatting.clang_format,
					null_ls.builtins.formatting.nixpkgs_fmt,

					--        require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
				},
			})
			vim.api.nvim_set_keymap(
				"n",
				"<leader>f",
				"<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
