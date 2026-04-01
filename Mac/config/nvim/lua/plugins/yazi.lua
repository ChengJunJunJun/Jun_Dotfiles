-- This file is used to define the dependencies of this plugin when the user is
-- using lazy.nvim.

---@module "lazy"
---@module "yazi"

---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim"
    },
    -- 👇 添加按键映射
    keys = {
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- 如果想用 yazi 替代 netrw，设置为 true
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
        copy_relative_path_to_selected_files = nil, -- 修复 grealpath 警告
      },
    },
    cmd = {
      "Yazi",
    },
  },
}
