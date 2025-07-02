-- ⚡ 性能优化的选项配置

local opt = vim.opt

-- 🔢 行号配置
opt.number = true
opt.relativenumber = true

-- 📏 缩进配置
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 📄 显示设置
opt.wrap = false
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "88,100"

-- 🖱️ 交互设置
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

-- 🪟 窗口分割
opt.splitright = true
opt.splitbelow = true

-- 🔍 搜索优化
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 🎨 外观设置
opt.termguicolors = true
opt.background = "dark"

-- ⚡ 性能优化设置
opt.lazyredraw = true      -- 宏执行时不重绘
opt.regexpengine = 0       -- 自动选择最快的正则引擎
opt.synmaxcol = 240        -- 限制语法高亮的列数
opt.updatetime = 250       -- 更快的 swap 文件写入
opt.timeoutlen = 300       -- 更快的按键超时
opt.ttimeoutlen = 10       -- 更快的按键码超时

-- 💾 备份和撤销
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- 📝 编辑增强
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.confirm = true
opt.conceallevel = 0

-- 🔄 补全设置
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10         -- 限制补全菜单高度
opt.pumwidth = 15          -- 限制补全菜单宽度

-- 🚫 禁用一些功能以提升性能
opt.foldenable = false     -- 禁用代码折叠
opt.foldmethod = "manual"  -- 手动折叠模式
