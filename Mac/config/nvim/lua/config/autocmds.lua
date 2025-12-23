-- lua/config/autocmds.lua

-- 创建 augroup 以便于管理自动命令
local augroup = vim.api.nvim_create_augroup("UserAutoCommands", { clear = true })

-- 在编辑文件时自动删除行尾空白
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- 高亮复制区域
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- 打开文件时恢复光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        local last_pos = vim.fn.line("'\"")
        if last_pos > 0 and last_pos <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end,
})

-- 自动设置某些文件类型的缩进和语法高亮
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "lua", "python", "javascript", "typescript", "json", "yaml" },
    callback = function()
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
    end,
})

-- 为特定文件启用拼写检查
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "markdown", "gitcommit", "text" },
    callback = function()
        vim.wo.spell = true
        vim.wo.spelllang = "en_us"
    end,
})

-- 当 Neovim 失去焦点时自动保存
vim.api.nvim_create_autocmd({ "FocusLost" }, {
    group = augroup,
    pattern = "*",
    command = "silent! wa",
})

-- 自动调整窗口大小
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    pattern = "*",
    command = "wincmd =",

})

-- 在 tmux 中自动隐藏/显示状态栏
if vim.env.TMUX then
    -- 进入 Neovim 时隐藏 tmux 状态栏
    vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
            vim.fn.system("tmux set status off")
        end,
    })

    -- 离开 Neovim 时恢复 tmux 状态栏
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = augroup,
        pattern = "*",
        callback = function()
            vim.fn.system("tmux set status on")
        end,
    })
end

return {} -- 返回一个空表，以便可以被 require

