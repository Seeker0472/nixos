return {
	"HiPhish/rainbow-delimiters.nvim",
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
			rainbow = {
				enable = true,
				extended_mod = true,
				max_file_lines = nil,
			},
		})
	end,
}
