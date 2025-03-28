return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		-- TODO:Config!
		-- If you want insert `(` after select function or method item
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local handlers = require("nvim-autopairs.completion.handlers")
		local npairs = require("nvim-autopairs")
		local cmp = require("cmp")

		npairs.setup({
			check_ts = true, -- 启用 Treesitter 集成
			ts_config = {
				lua = { "string" }, -- 在 Lua 中不在字符串节点内添加配对
				--            javascript = {'template_string'}, -- 在 JavaScript 的模板字符串中不添加配对
				--            java = false, -- 不对 Java 使用 Treesitter 检查
			},
		})

		cmp.event:on(
			"confirm_done",
			cmp_autopairs.on_confirm_done({
				filetypes = {
					-- "*" is a alias to all filetypes
					["*"] = {
						["("] = {
							kind = {
								cmp.lsp.CompletionItemKind.Function,
								cmp.lsp.CompletionItemKind.Method,
							},
							handler = handlers["*"],
						},
					},
					--[[             lua = {
              ["("] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method
                },
                ---@param char string
                ---@param item table item completion
                ---@param bufnr number buffer number
                ---@param rules table
                ---@param commit_character table<string>
                handler = function(char, item, bufnr, rules, commit_character)
                  -- Your handler function. Inspect with print(vim.inspect{char, item, bufnr, rules, commit_character})
                end
              }
            }, ]]
					-- Disable for tex
					tex = false,
				},
			})
		)
	end,
}
