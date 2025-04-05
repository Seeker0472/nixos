return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	-- TODO:Config!
	config = function()
		require("nvim-tree").setup({})
	end,
}
