return {
	"lewis699/gitsigns.nvim",
	url = "git@github.com:lewis6991/gitsigns.nvim.git",
	config = function()
		require("gitsigns").setup({
			-- TODO: Configure
			signs = {
				add = { text = "+" },
				change = { text = "C" },
				delete = { text = "D" },
				topdelete = { text = "TD" },
				changedelete = { text = "CD" },
				untracked = { text = "U" },
			},
		})
	end,
}
