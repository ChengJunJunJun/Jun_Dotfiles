-- ⚡ 性能优化的选项设置
local opt = vim.opt

-- 🎨 外观设置
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true

-- 📝 编辑体验
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.wrap = false
opt.virtualedit = "onemore"

-- 🔍 搜索设置
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- 💾 文件处理
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- ⚡ 性能优化
opt.updatetime = 250
opt.timeoutlen = 300

-- 🖱️ 鼠标支持
opt.mouse = "a"

-- 📋 剪贴板
opt.clipboard = "unnamedplus"

-- 🔄 分屏行为
opt.splitright = true
opt.splitbelow = true

-- 🚫 禁用提供者以减少警告和提升启动速度
vim.g.loaded_python3_provider = 0  -- 禁用 Python3 提供者
vim.g.loaded_ruby_provider = 0     -- 禁用 Ruby 提供者
vim.g.loaded_perl_provider = 0     -- 禁用 Perl 提供者
vim.g.loaded_node_provider = 0     -- 禁用 Node.js 提供者

-- 📱 滚动设置
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 🎯 补全设置
opt.completeopt = "menu,menuone,noselect"

-- 🔧 其他优化
opt.errorbells = false
opt.visualbell = false
