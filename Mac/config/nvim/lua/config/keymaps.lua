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

-- 行尾：停在最后一个字符之后，配合 virtualedit=onemore
keymap("n", "$", function()
    vim.cmd("normal! $")
    vim.cmd("normal! l")
end, { desc = "Go to after end of line" })

-- 单词尾：停在单词最后一个字符之后
keymap("n", "e", function()
    vim.cmd("normal! " .. vim.v.count1 .. "e")
    vim.cmd("normal! l")
end, { desc = "Go to after end of word" })

-- LSP 诊断查看与跳转
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "查看当前行诊断详情" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "跳到下一个诊断" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "跳到上一个诊断" })
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "所有诊断列表" })

-- LSP 代码操作（修复建议）
-- 这些键位在 LSP attach 之后生效
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local buf = args.buf
        local opts = { buffer = buf }
        keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "查看文档" }))
        keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "跳转到定义" }))
        keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "查看所有引用" }))
        keymap("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "代码修复建议" }))
        keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "重命名符号" }))
    end,
})

-- 窗口大小调整（Option + 方向键）
keymap("n", "<M-Up>", ":resize +2<CR>", { desc = "增加窗口高度" })
keymap("n", "<M-Down>", ":resize -2<CR>", { desc = "减少窗口高度" })
keymap("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "减少窗口宽度" })
keymap("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "增加窗口宽度" })
