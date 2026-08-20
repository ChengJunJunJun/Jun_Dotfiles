-- VS Code Dark+ 配色
return {
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      style = "dark",
      transparent = false,
      italic_comments = false,
      italic_inlayhints = false,
      underline_links = true,
      terminal_colors = true,
      -- explorer 由 snacks 提供，不需要 nvim-tree 的背景处理
      disable_nvimtree_bg = true,

      -- 底色换成 #1a1b26（Tokyo Night 的背景），其余面板按 VS Code Dark+ 原本的
      -- 明暗差等量平移过来 —— 层次关系不变，只是整体转成蓝调。
      -- 语法高亮一个都没动，还是 Dark+ 那套。
      color_overrides = {
        vscBack           = "#1a1b26", -- 编辑区背景
        vscTabCurrent     = "#1a1b26", -- 当前标签页（VS Code 里就等于编辑区）
        vscTabOther       = "#282934", -- 其他标签页
        vscTabOutside     = "#20212c", -- 标签栏空白处
        vscLeftDark       = "#20212c", -- 侧边栏 / 文件树
        vscPopupBack      = "#1b1c27", -- 补全菜单 / 浮窗
        vscCursorDarkDark = "#1d1e29", -- 当前行高亮
        vscSplitDark      = "#3b4261", -- 窗口分隔线
      },
    },
    config = function(_, opts)
      require("vscode").setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },
}
