-- lua/plugins/editor.lua —— 编辑增强
return {
  -- 自动配对：只在插入模式有意义
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- 包围操作：按到才加载（gsa 添加 / gsd 删除 / gsr 替换）
  {
    "echasnovski/mini.surround",
    keys = {
      { "gsa", desc = "添加包围", mode = { "n", "v" } },
      { "gsd", desc = "删除包围" },
      { "gsr", desc = "替换包围" },
      { "gsf", desc = "查找右侧包围" },
      { "gsF", desc = "查找左侧包围" },
      { "gsh", desc = "高亮包围" },
    },
    opts = {},
  },

  -- Git 提示：左侧 gutter 的增删改标记（VS Code 观感），
  -- 同时是 lualine diff 组件的数据源
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "下一处改动")
        map("n", "[h", function() gs.nav_hunk("prev") end, "上一处改动")
        map("n", "<leader>hp", gs.preview_hunk, "预览改动")
        map("n", "<leader>hr", gs.reset_hunk, "还原改动")
        map("n", "<leader>hs", gs.stage_hunk, "暂存改动")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame 当前行")
      end,
    },
  },

  -- 键位提示：按下 <leader> 后弹出可用键位
  -- 纯便利性，约 5ms，不需要的话整块删掉即可，其余部分不受影响
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
      },
    },
  },
}
