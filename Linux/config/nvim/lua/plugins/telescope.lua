return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    lazy = true,  -- 🔥 这些插件可以延迟加载
    event = "VeryLazy",
    dependencies = { 
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      }
    },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      
      -- 快捷键
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules", ".git/", "%.jpg", "%.jpeg", 
            "%.png", "%.svg", "%.otf", "%.ttf", "%.lock"
          },
        },
      })
      
      -- 加载 fzf 扩展
      pcall(telescope.load_extension, 'fzf')
    end
  }
}