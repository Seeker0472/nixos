return {
	"mpas/marp-nvim",
	config = function()
		require("marp").setup({
			port = 9080, -- the port on which the Marp server should listen
			wait_for_response_timeout = 30, -- how long to wait for a response from the server before giving up
			wait_for_response_delay = 1, -- how long to wait between attempts to connect to the server
		})
	end,
}
