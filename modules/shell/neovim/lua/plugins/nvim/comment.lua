return {
	"numToStr/Comment.nvim",
	opts = {
		-- add any options here
	},
	config = function()
		local api = require("Comment.api")
		local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
		vim.keymap.set("n", "<C-/>", api.toggle.linewise.current)
		-- Toggle selection (blockwise)
		-- x-包括可视行模式和可视块
		vim.keymap.set("x", "<C-/>", function()
			vim.api.nvim_feedkeys(esc, "nx", false)
			api.toggle.blockwise(vim.fn.visualmode())
		end)
	end,
}
