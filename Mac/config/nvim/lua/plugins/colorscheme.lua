return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function()
      require('catppuccin').setup({
        flavour = "mocha",
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        -- 🔥 最简集成配置 - 只启用核心功能
        integrations = {
          treesitter = true,
          nvimtree = true,
          telescope = true,
        },
      })
      
      vim.cmd.colorscheme('catppuccin')
    end
  }
}