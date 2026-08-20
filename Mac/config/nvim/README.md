# Neovim 配置

面向 **JSON 配置文件 + Python** 的轻量配置，VS Code 风格 UI。

- Neovim **0.12+**，18 个插件，冷启动约 **15ms**
- 启动时只加载 3 个插件（`lazy.nvim` / `snacks.nvim` / `vscode.nvim`），其余全部按需触发
- Python 链路无 Node 进程：**ty**（类型检查）+ **ruff**（格式化），都是 Rust
- ruff 的 lint 诊断**已关闭**（`lua/plugins/lsp.lua` 里注释掉了 `vim.lsp.enable("ruff")`），格式化不受影响

`<leader>` = **空格**。忘了键位就按一下空格，which-key 会列出来。

---

## 一分钟上手

| 想干什么 | 按什么 |
|---|---|
| 找文件 | `<C-p>` 或 `<leader>ff` |
| 全项目搜内容 | `<leader>fg` |
| 开/关侧边文件树 | `<leader>e` |
| 开/关终端 | `<C-/>` |
| 格式化当前文件 | `<leader>cf` |
| 看这行报错到底说了啥 | `<leader>d` |
| 命令面板（记不住命令时） | `<leader>:` |
| Git 界面 | `<leader>gg` |

---

## 文件与搜索

| 键位 | 作用 |
|---|---|
| `<C-p>` | 查找文件（VS Code 的 Ctrl+P） |
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 全文搜索（ripgrep） |
| `<leader>fb` | Buffer 列表 |
| `<leader>fr` | 最近打开的文件 |
| `<leader>fh` | 帮助文档 |
| `<leader>fs` | 当前文件的符号列表 |
| `<leader>fd` | 全项目诊断列表 |
| `<leader>:` | 命令面板（VS Code 的 Ctrl+Shift+P） |

### 在查找窗口里

| 键位 | 作用 |
|---|---|
| `<C-n>` / `<C-p>`、`<C-j>` / `<C-k>`、方向键 | 上下选择 |
| `<CR>` | 打开 |
| `<C-v>` / `<C-s>` | 竖直 / 水平分屏打开 |
| `<C-t>` | 新标签页打开 |
| `<C-q>` | 全部结果送进 quickfix |
| `<M-p>` | 开关预览 |
| `<M-h>` / `<M-i>` | 开关隐藏文件 / 被 gitignore 的文件 |
| `<C-g>` | 切换 live 模式（边打边搜 ↔ 固定关键词） |
| `<Esc>` | 关闭 |

---

## 文件树（`<leader>e`）

侧边栏会自动跟随当前编辑的文件，并显示 git 状态和诊断标记。

| 键位 | 作用 |
|---|---|
| `l` / `<CR>` | 展开目录 / 打开文件 |
| `h` | 收起目录 |
| `<BS>` | 上一级目录 |
| `a` | 新建文件（结尾加 `/` 建目录） |
| `d` | 删除 |
| `r` | 重命名 |
| `c` / `m` | 复制 / 移动 |
| `y` / `p` | 复制路径 / 粘贴 |
| `H` / `I` | 开关隐藏文件 / 忽略文件 |
| `]g` / `[g` | 跳到下/上一个有 git 改动的文件 |
| `]d` / `[d` | 跳到下/上一个有诊断的文件 |
| `P` | 开关预览 |
| `Z` | 收起所有目录 |
| `<leader>/` | 在选中目录里搜索 |

---

## 窗口与标签页

| 键位 | 作用 |
|---|---|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | 切到左/下/上/右窗口 |
| `<M-↑>` `<M-↓>` | 调窗口高度（Option + 上下） |
| `<M-←>` `<M-→>` | 调窗口宽度 |
| `<S-h>` / `<S-l>` | 上/下一个 buffer |
| `<leader>1` ~ `<leader>9` | 跳到第 N 个标签页 |
| `<leader>bd` | 关闭当前 buffer（保持窗口布局不乱） |
| `<leader>bp` | 固定 / 取消固定标签页 |
| `<leader>bP` | 关闭所有未固定的标签页 |

---

## 代码导航（LSP）

Neovim 0.12 内置了一套 `gr` 前缀的 LSP 键位，这份配置**刻意没有覆盖 `gr`**（覆盖会让每次按 `gr` 都卡 300ms 等待），所以两套都能用。

| 键位 | 作用 | 来源 |
|---|---|---|
| `gd` | 跳转到定义 | 本配置 |
| `gD` | 跳转到声明 | 本配置 |
| `K` | 查看文档 / 类型（来自 ty） | 本配置 |
| `grr` | 查看所有引用 | 内置 |
| `grn` | 重命名符号 | 内置 |
| `gra` | 代码修复建议 | 内置 |
| `gri` | 跳转到实现 | 内置 |
| `grt` | 跳转到类型定义 | 内置 |
| `gO` | 当前文件符号大纲 | 内置 |
| `<C-s>`（插入模式） | 函数签名提示 | 内置 |
| `<leader>rn` | 重命名（`grn` 的别名） | 本配置 |
| `<leader>ca` | 代码修复（`gra` 的别名） | 本配置 |
| `<leader>ci` | 开关 inlay hints（行内类型提示） | 本配置 |

### 面包屑

顶部那行 `文件 > 类 > 函数` 的路径，Python 走 LSP，JSON 走 treesitter 显示 key 路径。

| 键位 | 作用 |
|---|---|
| `<leader>;` | 用键盘在面包屑上跳转 |
| `[;` | 跳到当前上下文的开头 |
| `];` | 选中下一层上下文 |

---

## 诊断（报错和警告）

| 键位 | 作用 |
|---|---|
| `<leader>d` | 看当前行诊断的完整内容 |
| `]d` / `[d` | 跳到下/上一个诊断 |
| `<leader>dl` | 当前文件所有诊断（location list） |
| `<leader>fd` | 全项目诊断（可搜索） |

---

## 补全（blink.cmp）

| 键位 | 作用 |
|---|---|
| `<Tab>` / `<S-Tab>` | 下一项 / 上一项 |
| `<CR>` | 确认选中项 |
| `<C-e>` | 关掉补全菜单 |
| `<C-space>` | 手动唤出补全 / 展开文档 |
| `<C-b>` / `<C-f>` | 上下滚动文档浮窗 |
| `<C-k>` | 开关函数签名浮窗 |

补全菜单里的灰色行内预览就是当前选中项插入后的样子。Python 补全会自动补上 `import`。

---

## 格式化

| 键位 | 作用 |
|---|---|
| `<leader>cf` | 格式化当前文件（可视模式下只格式化选区） |
| `<S-M-f>` | 同上（VS Code 的 Shift+Alt+F） |

**保存时不会自动格式化**，只在你主动按键时才动。

| 文件类型 | 用什么 |
|---|---|
| Python | `ruff`（整理 import + 格式化，输出与 black 一致） |
| JSON | `jq`（2 空格缩进） |
| JSONC | 不格式化（`jq` 会把注释吃掉） |
| Lua | `stylua` |

---

## Git

| 键位 | 作用 |
|---|---|
| `<leader>gg` | 打开 lazygit |
| `<leader>gl` | lazygit 的提交历史 |
| `<leader>gf` | 当前文件的提交历史 |
| `<leader>gb` | 看当前行是谁改的 |
| `<leader>gB` | 在浏览器里打开当前文件（GitHub 等） |

左侧栏的颜色条表示未提交的改动：

| 键位 | 作用 |
|---|---|
| `]h` / `[h` | 跳到下/上一处改动 |
| `<leader>hp` | 预览这处改动的 diff |
| `<leader>hr` | 撤销这处改动 |
| `<leader>hs` | 暂存这处改动 |
| `<leader>hb` | 看这行的完整 blame |

---

## 编辑

| 键位 | 作用 |
|---|---|
| `<leader>w` / `<leader>q` | 保存 / 退出 |
| `<leader>nh` | 取消搜索高亮 |
| `<` / `>`（可视模式） | 缩进，且**保持选中**可以连按 |
| `$` | 跳到行尾**之后**（配合 `virtualedit=onemore`） |
| `e` | 跳到单词最后一个字符**之后** |
| `<leader>v` / `<leader>V` | 按语法结构扩大 / 缩小选区 |

### 包围符号（引号、括号）

| 键位 | 作用 |
|---|---|
| `gsa` + 范围 + 符号 | 加包围，如 `gsaiw"` 给光标所在单词加双引号 |
| `gsd` + 符号 | 删包围，如 `gsd"` 删掉双引号 |
| `gsr` + 旧 + 新 | 换包围，如 `gsr'"` 把单引号换成双引号 |

括号、引号会自动配对补全（mini.pairs）。

---

## 折叠（JSON 深嵌套时很有用）

折叠层级由 treesitter 计算，默认全部展开。

| 键位 | 作用 |
|---|---|
| `za` | 折叠 / 展开光标所在这一层 |
| `zc` / `zo` | 折叠 / 展开 |
| `zM` | 全部折起来（快速看整体结构） |
| `zR` | 全部展开 |

---

## 终端

| 键位 | 作用 |
|---|---|
| `<C-/>` | 开 / 关终端（占屏幕下方 28%） |
| `<C-\><C-n>` | 从终端回到 normal 模式 |

Python 虚拟环境由 zsh 自己处理（`Mac/zsh/config/lazy-loading.zsh` 里的 `_auto_uv_activate`），
Neovim 这边不插手 —— 否则会重复 `source` 一遍，把命令回显到终端里。

---

## 自动行为

不用记键位，这些会自己发生：

- **失去焦点自动保存** —— 切到别的 App 时所有改过的文件自动写盘
- **外部改动自动重载** —— 在别处改了文件，切回来会自动刷新
- **保存时去掉行尾空白** —— 排除 markdown / gitcommit / 纯文本；超过 1MB 的文件跳过
- **记住光标位置** —— 重新打开文件回到上次的位置
- **大文件保护** —— 超过 1.5MB 自动关掉 treesitter、LSP 和折叠，6.8MB 的 JSON 也能秒开
- **缩进自适应** —— Python 4 空格，JSON / YAML / Lua 2 空格
- **tmux 状态栏** —— 进 Neovim 时自动隐藏，退出时恢复
- **Python venv** —— 交给 zsh 的 `_auto_uv_activate` 处理，Neovim 不重复激活

---

## 维护

| 命令 | 作用 |
|---|---|
| `:Lazy` | 插件管理界面（`U` 更新，`X` 清理） |
| `:Lazy update` | 更新插件（**不会自动更新**，后台 git fetch 已关闭） |
| `:StartupTime` | 看各插件的加载耗时 |
| `:Mason` | 管理 LSP / 格式化工具 |
| `:MasonUpdate` | 刷新工具 registry（ty 更新较频繁，偶尔跑一下） |
| `:ConformInfo` | 看当前文件会用哪个格式化工具 |
| `:checkhealth` | 体检 |

### 外部依赖

配置本身不装这些，缺了对应功能会静默降级：

| 工具 | 用途 | 装法 |
|---|---|---|
| `ripgrep` | 全文搜索 | `brew install ripgrep` |
| `fd` | 文件查找 | `brew install fd` |
| `jq` | JSON 格式化 | `brew install jq` |
| `ruff` | Python 格式化（lint 诊断已关闭） | `uv tool install ruff` |
| `lazygit` | Git 界面 | `brew install lazygit` |
| `ty` / `stylua` | Python 类型检查 / Lua 格式化 | 首次打开对应文件时 mason 自动装 |

---

## 关于 ty

Python 类型检查用的是 Astral 的 **ty**（Rust），增量重算比 pyright 快约 80 倍。

**它目前还是 beta**，可能有误报。如果被烦到了，回滚很简单 —— 编辑 `lua/plugins/lsp.lua`：

```lua
-- vim.lsp.enable("ty")      ← 注释掉这行
vim.lsp.enable("pyright")    ← 取消这行的注释
```

pyright 一直装着没删，配置块（含 `.venv` 探测）也写好放在同一个文件里，改完重启即可。

---

## 目录结构

```
init.lua                     入口：禁用内置插件、lazy 引导
lua/config/
  options.lua                所有 vim 选项（启动时唯一同步执行的部分）
  keymaps.lua                全局键位
  autocmds.lua               自动行为
lua/plugins/
  colorscheme.lua            VS Code Dark+ 配色（底色覆盖为 #1a1b26）
  snacks.lua                 UI 底座：查找器/文件树/大文件保护/终端/lazygit
  completion.lua             blink.cmp 补全
  lsp.lua                    ty + lua_ls（ruff 已配置未启用）
  formatting.lua             conform 格式化规则
  treesitter.lua             语法解析
  ui.lua                     状态栏 / 标签页 / 面包屑
  editor.lua                 配对 / 包围 / gitsigns / which-key
```
