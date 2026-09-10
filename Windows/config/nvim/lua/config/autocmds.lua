-- lua/config/autocmds.lua

local augroup = vim.api.nvim_create_augroup("UserAutoCommands", { clear = true })

-- ══════════════════════════════════════════════════════════
-- 保存时去掉行尾空白
-- ══════════════════════════════════════════════════════════
local trim_whitespace_excluded_ft = {
    gitcommit = true, markdown = true, diff = true,
    help = true, text = true,
}
-- 超过这个大小就跳过：对着几 MB 的 JSON 保存时不该跑全文件正则替换
local TRIM_MAX_BYTES = 1024 * 1024

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
        local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > TRIM_MAX_BYTES then
            return
        end
        local view = vim.fn.winsaveview()
        -- keeppatterns：不把这个内部替换写进搜索历史和 / 寄存器
        vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

-- ══════════════════════════════════════════════════════════
-- 编辑体验
-- ══════════════════════════════════════════════════════════

-- 高亮复制区域（0.12 没有内置这项默认行为，需要自己加）
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- 退出插入模式时保持光标位置，不向左退一格
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

-- 打开文件时恢复上次的光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    pattern = "*",
    callback = function(args)
        -- 普通文件才恢复：commit message、终端、插件面板里乱跳很烦人
        if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].filetype == "gitcommit" then
            return
        end
        local last_pos = vim.fn.line("'\"")
        if last_pos > 0 and last_pos <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end,
})

-- ══════════════════════════════════════════════════════════
-- 按文件类型设缩进
-- ══════════════════════════════════════════════════════════
-- Python 用 4 空格（PEP 8，也是 ruff format 的输出），其余用 2。
-- 之前这两类混在一条规则里都设成 2，导致手写缩进和格式化结果永久打架。
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "python",
    callback = function()
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 4
        vim.bo.tabstop = 4
        vim.bo.softtabstop = 4
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "json", "jsonc", "json5", "yaml", "lua", "toml", "sh", "bash" },
    callback = function()
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
    end,
})

-- 拼写检查（顺带关掉 treesitter，纯文本没必要跑解析器）
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "gitcommit", "text" },
    callback = function(args)
        pcall(vim.treesitter.stop, args.buf)
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_us"
    end,
})

-- 关闭这些窗口只需要按 q
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "query" },
    callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
    end,
})

-- ══════════════════════════════════════════════════════════
-- 文件同步
-- ══════════════════════════════════════════════════════════

-- 失去焦点时自动保存（只保存普通、已命名、可写且确实改过的 buffer）
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

-- 外部改动过的文件自动重载（在别处改了配置文件切回来就能看到）
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup,
    callback = function()
        if vim.o.buftype == "" then
            vim.cmd("checktime")
        end
    end,
})

-- ══════════════════════════════════════════════════════════
-- 终端 / 窗口 / tmux
-- ══════════════════════════════════════════════════════════

-- 注意：这里刻意不做 venv 自动激活。
-- zsh 侧的 _auto_uv_activate（Mac/zsh/config/lazy-loading.zsh）已经在
-- shell 启动和 chpwd 时处理了，而且做得更完整：离开目录会自动 deactivate，
-- 也不会抢占手动激活的其他 venv。在这里再 source 一遍只会把命令回显到终端里。

-- 终端里不需要行号和光标行
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = false
    end,
})

-- 终端尺寸变化时等分窗口
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    pattern = "*",
    command = "wincmd =",
})

-- 在 tmux 中自动隐藏/恢复状态栏
if vim.env.TMUX then
    vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
            vim.fn.system("tmux set status off")
        end,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = augroup,
        pattern = "*",
        callback = function()
            vim.fn.system("tmux set status on")
        end,
    })
end

return {}
