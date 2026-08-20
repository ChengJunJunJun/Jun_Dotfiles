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
    },
    config = function(_, opts)
      require("vscode").setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },
}
