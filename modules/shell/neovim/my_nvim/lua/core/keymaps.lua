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
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口
--
keymap.set("n", "<leader>w", ":w<CR>")

-- ---------- 插件 ---------- ---
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

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

-- marp
keymap.set("n", "<leader>mt", "<cmd>MarpToggle<cr>", { noremap = true, silent = true })
keymap.set("n", "<leader>ms", "<cmd>MarpStatus<cr>", { noremap = true, silent = true })
