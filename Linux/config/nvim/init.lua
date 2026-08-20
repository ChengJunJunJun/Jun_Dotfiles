-- ⚡ 性能优先的 Neovim 配置（Neovim 0.12+）
-- 主力场景：JSON 配置文件 + Python
-- 设计原则：启动路径上只做必须做的事，其余全部延迟到真正用到的那一刻

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 禁用内置的远古 vim 插件（这些用 vim.g 关，lazy 的 rtp.disabled_plugins 管不到全部）
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- 选项必须在启动时设置（影响后续所有 buffer 的创建）
require("config.options")

-- keymaps / autocmds 不影响首屏渲染，推迟到 UI 出来之后再加载
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    require("config.keymaps")
    require("config.autocmds")
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = {
    colorscheme = { "vscode", "habamax" },
  },
  -- 关掉后台 git fetch：更新改成手动 :Lazy update
  -- 每小时对全部插件跑一次 fetch 是编辑期卡顿和「今天怎么突然坏了」的常见来源
  checker = { enabled = false },
  -- 关掉配置文件监视：改完配置手动重启即可
  change_detection = { enabled = false },
  -- 没有任何插件需要 luarocks，关掉可以少一堆 checkhealth 噪音
  rocks = { enabled = false },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        -- matchparen 保持启用：编辑深嵌套 JSON 时括号配对高亮价值
        -- 远大于它那点 CursorMoved 开销，大文件由 snacks.bigfile 兜底
        "netrwPlugin",
        "rplugin",
        "spellfile",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = { border = "rounded" },
})

-- 启动耗时分析
vim.api.nvim_create_user_command("StartupTime", function()
  vim.cmd("Lazy profile")
end, { desc = "查看插件加载耗时" })
