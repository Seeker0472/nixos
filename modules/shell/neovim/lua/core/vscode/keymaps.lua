vim.g.mapleader = " "

local keymap = vim.keymap

-- ---------- 插入模式 ---------- ---
-- esc
keymap.set("i", "jk", "<ESC>")

-- ---------- 视觉模式 ---------- ---
-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- ---------- 正常模式 ---------- ---

keymap.set("n", "<leader>w", ":w<CR>")
-- TODO
keymap.set("n", "<leader>e", function ()
  require("vscode-neovim").call('workbench.explorer.fileView.focus')
--  require("vscode-neovim").call('workbench.action.toggleSidebarVisibility')
end)
keymap.set("n", "<leader>x", function ()
  require('vscode').call('workbench.action.closeSidebar') -- 关闭侧边栏
  require('vscode').call('workbench.action.focusActiveEditorGroup') -- 聚焦编辑器
end)


-- ---------- lsp -----------------
--
keymap.set("n", "K", vim.lsp.buf.hover, {})
keymap.set("n", "gd", vim.lsp.buf.definition, {})
keymap.set("n", "gi", vim.lsp.buf.implementation, {})
keymap.set({ "n" }, "<leader>ca", vim.lsp.buf.code_action, {})

-- 切换buffer
keymap.set("n", "<S-L>", ":bnext<CR>")
keymap.set("n", "<S-H>", ":bprevious<CR>")

-- close buffer
keymap.set("n", "<leader>q", ":bd<CR>")

