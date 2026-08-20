-- ⚡ 选项设置（启动路径上唯一必须同步执行的部分）
local opt = vim.opt

-- 🎨 外观
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false      -- 模式由 lualine 显示，命令行不重复
opt.laststatus = 3        -- 全局状态栏：整个窗口只有一条底栏（VS Code 观感）
opt.pumheight = 10        -- 补全菜单最多 10 项，超过就滚动
opt.splitkeep = "screen"  -- 开新窗口时保持原窗口内容不跳动
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- 📝 编辑体验
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.wrap = false
opt.virtualedit = "onemore"
opt.confirm = true        -- 有未保存改动时 :q 弹确认而不是直接报错

-- 🔍 搜索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- 📁 折叠：treesitter 驱动，对深嵌套 JSON 极其有用（za 折叠 / zR 全展开 / zM 全折叠）
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""         -- 0.10+ 支持空 foldtext，折叠行保留语法高亮
opt.foldlevel = 99        -- 默认全部展开，需要时再手动折
opt.foldlevelstart = 99

-- 💾 文件处理
opt.swapfile = false
opt.backup = false
opt.undofile = true
local undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.fn.mkdir(undodir, "p")  -- 新机器上目录不存在时不至于报错
opt.undodir = undodir
opt.undolevels = 10000

-- shada 瘦身：默认存 1000 行寄存器内容，启动和退出都要读写这堆东西
opt.shada = "!,'100,<50,s10,h"

-- ⚡ 响应速度
opt.updatetime = 250      -- CursorHold / gitsigns / LSP 高亮的触发延迟
opt.timeoutlen = 300      -- 组合键等待时间
opt.redrawtime = 10000    -- 大文件语法高亮的重绘预算

-- 🖱️ 鼠标
opt.mouse = "a"

-- 🔄 分屏
opt.splitright = true
opt.splitbelow = true

-- 📱 滚动
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 🎯 补全
opt.completeopt = "menu,menuone,noselect"

-- 🔧 其他
opt.errorbells = false
opt.visualbell = false

-- 🖱️ 光标形状
opt.guicursor = {
  "n-v-c:ver25-Cursor/lCursor",
  "i-ci-ve:ver25-Cursor/lCursor",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}

-- 📋 剪贴板：延迟设置
-- 启动期设 clipboard 会立刻触发 provider 探测（macOS 上要去找 pbcopy/pbpaste），
-- 扔进 schedule 后这段探测完全离开启动关键路径，实际行为没有任何变化
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- 🚫 禁用语言 provider（不写 remote plugin，纯粹省掉启动时的解释器探测）
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
