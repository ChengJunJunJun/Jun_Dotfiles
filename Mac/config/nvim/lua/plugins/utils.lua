-- lua/plugins/utils.lua
return {
    -- 自动配对
    {
      "echasnovski/mini.pairs",
      event = "VeryLazy",
      config = function()
        require('mini.pairs').setup()
      end
    },
    
    -- 包围操作
    {
      "echasnovski/mini.surround",
      config = function()
        require('mini.surround').setup()
      end
    },
    
    -- 缩进指示线
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {}
    },
    
    -- 终端
    {
      "akinsho/toggleterm.nvim",
      event = "VeryLazy",
      version = "*",
      opts = {
        size = 10,
        open_mapping = "<C-t>",
      }
    }
  }