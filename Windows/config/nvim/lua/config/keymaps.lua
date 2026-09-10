-- keymaps.lua
local keymap = vim.keymap.set

-- ══════════════════════════════════════════════════════════
-- 窗口 / 缓冲区
-- ══════════════════════════════════════════════════════════
-- C-hjkl 的窗口切换已移交 vim-tmux-navigator (lua/plugins/tmux.lua)：
-- 同样的键，但走到 nvim 分屏边缘时会继续跳进相邻的 tmux 面板。
-- 在这里再 keymap 一遍会和插件的 lazy 按键触发器打架。

keymap("n", "<M-Up>", ":resize +2<CR>", { silent = true, desc = "增加窗口高度" })
keymap("n", "<M-Down>", ":resize -2<CR>", { silent = true, desc = "减少窗口高度" })
keymap("n", "<M-Left>", ":vertical resize -2<CR>", { silent = true, desc = "减少窗口宽度" })
keymap("n", "<M-Right>", ":vertical resize +2<CR>", { silent = true, desc = "增加窗口宽度" })

keymap("n", "<S-h>", ":bprevious<CR>", { silent = true, desc = "上一个 buffer" })
keymap("n", "<S-l>", ":bnext<CR>", { silent = true, desc = "下一个 buffer" })

-- 关闭 buffer 但保持窗口布局（VS Code 的 Ctrl+W）
keymap("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "关闭当前 buffer" })

-- <leader>1..9 跳到第 N 个标签页（VS Code 的 Alt+1..9）
for i = 1, 9 do
  keymap("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "跳到第 " .. i .. " 个标签页" })
end

-- ══════════════════════════════════════════════════════════
-- 常用操作
-- ══════════════════════════════════════════════════════════
keymap("n", "<leader>nh", ":nohl<CR>", { silent = true, desc = "取消搜索高亮" })
keymap("n", "<leader>w", ":w<CR>", { silent = true, desc = "保存" })
keymap("n", "<leader>q", ":q<CR>", { silent = true, desc = "退出" })

-- 可视模式缩进后保持选中，方便连续调整
keymap("v", "<", "<gv", { desc = "左缩进并保持选中" })
keymap("v", ">", ">gv", { desc = "右缩进并保持选中" })

-- 行尾：停在最后一个字符之后，配合 virtualedit=onemore
-- 只映射 normal 模式，d$ / c$ 走的是 operator-pending，不受影响
keymap("n", "$", function()
  vim.cmd("normal! $")
  vim.cmd("normal! l")
end, { desc = "跳到行尾之后" })

-- 单词尾：停在单词最后一个字符之后
keymap("n", "e", function()
  vim.cmd("normal! " .. vim.v.count1 .. "e")
  vim.cmd("normal! l")
end, { desc = "跳到单词尾之后" })

-- ══════════════════════════════════════════════════════════
-- 诊断
-- ══════════════════════════════════════════════════════════
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "查看当前行诊断详情" })
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "所有诊断列表" })
-- vim.diagnostic.jump 是 0.11+ 的新 API，goto_next/goto_prev 已废弃并将在 0.13 移除
keymap("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "跳到下一个诊断" })
keymap("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "跳到上一个诊断" })

-- ══════════════════════════════════════════════════════════
-- LSP（attach 之后才生效）
-- ══════════════════════════════════════════════════════════
-- 注意：这里刻意不映射 `gr`。Neovim 0.12 内置了 grn(重命名) / gra(code action) /
-- grr(引用) / gri(实现) / grt(类型定义)，映射 `gr` 会遮蔽整个前缀，
-- 导致每次按 gr 都要等满 timeoutlen 才能判断你是不是要按 grr。
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local function map(mode, lhs, rhs, desc)
      keymap(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end
    map("n", "K", vim.lsp.buf.hover, "查看文档")
    map("n", "gd", vim.lsp.buf.definition, "跳转到定义")
    map("n", "gD", vim.lsp.buf.declaration, "跳转到声明")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "代码修复建议")
    map("n", "<leader>rn", vim.lsp.buf.rename, "重命名符号")
    map("n", "<leader>ci", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, "切换 inlay hints")
  end,
})

-- ══════════════════════════════════════════════════════════
-- 格式化
-- ══════════════════════════════════════════════════════════
-- 从 <leader>f 挪到 <leader>cf：<leader>f 现在是 ff/fg/fb/fh 的前缀，
-- 占着它等于每次按 <leader>f 都要等 300ms 才知道你是不是要接着按 f
local function format()
  require("conform").format({ async = true, lsp_format = "fallback" })
end
keymap({ "n", "v" }, "<leader>cf", format, { desc = "格式化" })
keymap({ "n", "v" }, "<S-M-f>", format, { desc = "格式化（VS Code 键位）" })
