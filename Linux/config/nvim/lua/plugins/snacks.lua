-- snacks.nvim —— UI 底座
-- 它本来就在启动时加载，所以让它把活干满：picker 替掉 telescope，
-- explorer 替掉 nvim-tree，indent 替掉 indent-blankline。
-- 各模块内部是惰性的（用到才 require），启用不等于启动开销。
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- bigfile / quickfile 必须在读文件之前就位
    ---@type snacks.Config
    opts = {
      -- ── 性能兜底 ────────────────────────────────────────
      -- 打开大文件时自动关掉 treesitter / LSP / 语法高亮。
      -- 对着几 MB 的 JSON 时这一项是「秒开」和「卡死」的区别。
      bigfile = { enabled = true, size = 1.5 * 1024 * 1024 },
      -- 插件加载完成前先把文件画出来
      quickfile = { enabled = true },

      -- ── 查找 ────────────────────────────────────────────
      picker = {
        enabled = true,
        ui_select = true, -- 接管 vim.ui.select
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
          explorer = {
            -- 其余默认值已经就是 VS Code 行为：
            -- sidebar 布局 / follow_file / git_status / diagnostics / auto_close=false
            hidden = true,
            win = { list = { keys = { ["<BS>"] = "explorer_up" } } },
          },
        },
      },
      explorer = { enabled = true, replace_netrw = true },

      -- ── 视觉 ────────────────────────────────────────────
      indent = {
        enabled = true,
        indent = { char = "│" },
        scope = { char = "│", hl = "SnacksIndentScope" },
        animate = { enabled = false }, -- 动画纯属浪费帧，关掉
      },
      scope = { enabled = true },
      input = { enabled = true },      -- 重命名/输入用浮窗（VS Code 观感）
      notifier = { enabled = true, timeout = 3000 },

      -- ── Git / 终端 ──────────────────────────────────────
      lazygit = { enabled = true },
      gitbrowse = { enabled = true },
      terminal = {
        enabled = true,
        win = { height = 0.28 },
      },
      bufdelete = { enabled = true },

      -- ── 明确关闭 ────────────────────────────────────────
      dashboard = { enabled = false },
      image = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      zen = { enabled = false },
      animate = { enabled = false },
      toggle = { enabled = false },
      profiler = { enabled = false },
      dim = { enabled = false },
    },
    keys = {
      -- ── 查找（保持原有键位）────────────────────────────
      { "<leader>ff", function() Snacks.picker.files() end, desc = "查找文件" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "全文搜索" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffer 列表" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "帮助文档" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "最近打开的文件" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "全项目诊断" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "文档符号" },

      -- ── VS Code 键位 ───────────────────────────────────
      { "<C-p>", function() Snacks.picker.files() end, desc = "查找文件 (Ctrl+P)" },
      { "<leader>:", function() Snacks.picker.commands() end, desc = "命令面板" },
      { "<leader>e", function() Snacks.explorer() end, desc = "切换文件树" },

      -- ── Git ────────────────────────────────────────────
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame 当前行" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "在浏览器打开" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "当前文件的提交历史" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log" },

      -- ── 终端 ───────────────────────────────────────────
      { "<c-/>", function() Snacks.terminal() end, desc = "切换终端" },
      -- 某些终端把 Ctrl+/ 识别成 Ctrl+_
      { "<c-_>", function() Snacks.terminal() end, desc = "切换终端" },
    },
  },
}
