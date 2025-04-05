return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	after = "catppuccin",
	config = function()
		-- TODO:add jump shortcut
		require("bufferline").setup({
			options = {
				-- 使用 nvim 内置lsp
				diagnostics = "nvim_lsp",
				-- 左侧让出 nvim-tree 的位置
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						highlight = "Directory",
						text_align = "left",
					},
				},
				separator_style = "slant",
				always_show_bufferline = true,
				-- highlights = require("catppuccin.groups.integrations.bufferline").get(),
			},
		})
	end,
}
