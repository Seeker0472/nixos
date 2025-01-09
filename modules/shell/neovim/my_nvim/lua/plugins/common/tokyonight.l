return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		require("tokyonight").setup({
			on_highlights = function(hl, c)
        -- local c = require('tokyonight.colors').setup() -- 获取 tokyonight 颜色
        --BufferLineBuffer
				hl.BufferLineBufferSelected = { fg =  c.git.change }
				hl.BufferLineBuffer = { fg =  c.git.change }
			end,
		})
	end,
}
