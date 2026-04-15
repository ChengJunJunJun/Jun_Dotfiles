-- keymaps.lua
local keymap = vim.keymap.set

-- 窗口导航
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

-- 取消高亮
keymap("n", "<leader>nh", ":nohl<CR>")

-- 保存退出
keymap("n", "<leader>w", ":w<CR>")
keymap("n", "<leader>q", ":q<CR>")

-- 缓冲区导航
keymap("n", "<S-h>", ":bprevious<CR>")
keymap("n", "<S-l>", ":bnext<CR>")

-- 窗口大小调整（Option + 方向键）
keymap("n", "<M-Up>",    ":resize +2<CR>",          { desc = "增加窗口高度" })
keymap("n", "<M-Down>",  ":resize -2<CR>",          { desc = "减少窗口高度" })
keymap("n", "<M-Left>",  ":vertical resize -2<CR>", { desc = "减少窗口宽度" })
keymap("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "增加窗口宽度" })

