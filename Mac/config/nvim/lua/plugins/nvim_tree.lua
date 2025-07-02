return {
  "nvim-tree/nvim-tree.lua",
  event = "VeryLazy",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("nvim-tree").setup({
      -- 性能优化
      disable_netrw = true,
      hijack_netrw = true,
      update_focused_file = {
        enable = false, -- 禁用自动定位以提升性能
      },
      view = {
        width = 30,
        side = "left",
      },
      filters = {
        dotfiles = false,
        custom = { "node_modules", ".git" }
      },
      git = {
        enable = false, -- 禁用 git 集成以提升性能
      },
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
    })
    
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
  end
}
