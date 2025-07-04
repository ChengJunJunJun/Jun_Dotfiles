-- Snacks.nvim - 现代化的 Neovim UI 组件集合
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,  -- 重要：不要延迟加载
    opts = {
      -- 只启用需要的功能，禁用不需要的以减少警告
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      image = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      
      -- 启用有用的功能
      lazygit = { enabled = true },
      terminal = { enabled = true },
      toggle = { enabled = false }, -- 需要 which-key
    },
    keys = {
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
      { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
      { "<c-_>", function() Snacks.terminal() end, desc = "Toggle Terminal" },  -- 在某些终端中 Ctrl+/ 被识别为 Ctrl+_
    },
  }
} 