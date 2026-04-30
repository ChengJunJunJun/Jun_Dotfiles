-- Yazi Lua 初始化配置。
-- 这里放插件 setup；TOML 负责布局、键位和打开规则。

-- 让内置 zoxide 插件在 yazi 内切换目录时同步更新 zoxide 数据库。
-- 这样在 yazi 里常去的目录，回到 shell 后也能被 zoxide 记住。
require("zoxide"):setup {
	update_db = true,
}

-- 把 yazi 的目录导航限制在 /Users/cj 下面。
-- 注意: 这是 yazi 内部导航保护，不是 macOS 层面的文件权限沙箱。
require("cj-only"):setup {
	root = "/Users/cj",
}
