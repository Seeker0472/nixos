require("core.common")

if vim.g.vscode then
  require("core.vscode")
else
  require("core.nvim")
end

