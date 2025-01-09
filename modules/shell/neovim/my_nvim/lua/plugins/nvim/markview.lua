return {
	"OXY2DEV/markview.nvim",
	lazy = false, -- Recommended
	-- ft = "markdown" -- If you decide to lazy-load anyway

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("markview").setup({
			--- When using "hybrid mode" if the cursor is inside
			--- specific nodes the decorations will not be removed.
			hybrid_modes = { "n" },
			--- Vim modes where the preview is shown
			modes = { "n", "no", "c" },
		})
	end,
}
