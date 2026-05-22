-- lua/config/autocmds.lua

-- 创建 augroup 以便于管理自动命令
local augroup = vim.api.nvim_create_augroup("UserAutoCommands", { clear = true })

-- 在编辑文件时自动删除行尾空白（只对普通代码文件生效）
-- 白名单：排除不应自动修改的文件类型
local trim_whitespace_excluded_ft = {
    gitcommit = true, markdown = true, diff = true,
    help = true, text = true,
}
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function(args)
        local bufnr = args.buf
        if not vim.bo[bufnr].modifiable
            or vim.bo[bufnr].readonly
            or vim.bo[bufnr].buftype ~= ""
            or trim_whitespace_excluded_ft[vim.bo[bufnr].filetype]
        then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd([[silent! %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

-- 高亮复制区域
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- 退出插入模式时保持插入光标所在位置，不向左退一格
vim.api.nvim_create_autocmd("InsertLeavePre", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.b.insert_leave_cursor = vim.api.nvim_win_get_cursor(0)
    end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
    group = augroup,
    pattern = "*",
    callback = function()
        local pos = vim.b.insert_leave_cursor
        if pos then
            pcall(vim.api.nvim_win_set_cursor, 0, pos)
            vim.b.insert_leave_cursor = nil
        end
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
    pattern = { "gitcommit", "text" },
    callback = function(args)
        pcall(vim.treesitter.stop, args.buf)
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_us"
    end,
})

-- 当 Neovim 失去焦点时自动保存（只保存普通、已命名、可写的 buffer）
vim.api.nvim_create_autocmd("FocusLost", {
    group = augroup,
    callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buftype == ""
                and vim.bo[buf].modifiable
                and not vim.bo[buf].readonly
                and vim.api.nvim_buf_get_name(buf) ~= ""
                and vim.bo[buf].modified
            then
                pcall(vim.api.nvim_buf_call, buf, function()
                    vim.cmd("silent! write")
                end)
            end
        end
    end,
})

-- 打开终端时自动激活当前目录的 Python 虚拟环境（.venv）
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        local venv = vim.fn.getcwd() .. "/.venv/bin/activate"
        if vim.fn.filereadable(venv) == 1 then
            vim.fn.chansend(vim.b.terminal_job_id, "source " .. venv .. "\n")
        end
    end,
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
