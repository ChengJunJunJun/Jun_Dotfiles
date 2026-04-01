-- ⚡ 性能优化的 Neovim 配置

-- 🚀 启动性能优化
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 禁用一些内置插件以提升启动速度
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

-- 基础配置
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Neovim 0.12 + 现有 markdown parser/query 组合在这套环境里会触发 highlighter 崩溃。
-- 在上游组合稳定前，统一拦截 Markdown 的 Treesitter 高亮启动，回退到内置语法高亮。
do
  local ts_start = vim.treesitter.start
  vim.treesitter.start = function(bufnr, lang)
    bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
    local ft = bufnr and vim.bo[bufnr].filetype or ""
    local ts_lang = lang or vim.treesitter.language.get_lang(ft)

    if ft == "markdown" or ts_lang == "markdown" or ts_lang == "markdown_inline" then
      return false
    end

    return ts_start(bufnr, lang)
  end

  if vim.bo.filetype == "markdown" then
    pcall(vim.treesitter.stop)
  end
end

-- ⚡ 性能优化设置
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.opt.redrawtime = 10000

-- 光标设置
vim.opt.guicursor = {
  'n-v-c:ver25-Cursor/lCursor',
  'i-ci-ve:ver25-Cursor/lCursor',
  'r-cr:hor20',
  'o:hor50',
  'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor',
  'sm:block-blinkwait175-blinkoff150-blinkon175'
}

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

-- ⚡ 修复后的 Lazy.nvim 配置
require("lazy").setup({
  spec = {
    { import = "plugins" }
  },
  defaults = {
    -- 🔥 关键修复：不要默认延迟加载所有插件
    -- lazy = true,  -- 删除这行！
    -- 让每个插件自己决定是否延迟加载
  },
  install = { 
    colorscheme = { "catppuccin", "habamax" } 
  },
  checker = { 
    enabled = true,
    frequency = 3600,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen", 
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- 启动时间监控命令
vim.api.nvim_create_user_command('StartupTime', function()
  vim.cmd('Lazy profile')
end, {})
