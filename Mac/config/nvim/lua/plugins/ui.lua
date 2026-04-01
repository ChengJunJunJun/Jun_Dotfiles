-- lua/plugins/ui.lua
return {
    -- 状态栏
    {
      "nvim-lualine/lualine.nvim",
      event = "VeryLazy",
      opts = function()
        return {
          options = {
            icons_enabled = true,
            theme = require("catppuccin.utils.lualine")("mocha"),
            component_separators = '|',
            section_separators = '',
          },
          -- 🔥 明确指定sections，避免使用默认配置
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename'},
            lualine_x = {
              'encoding',
              {
                'fileformat',
                symbols = {
                  unix = '🍎',
                }
              },
              'filetype'
            },
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
        }
      end,
    },
    
    -- 缓冲区标签页
    {
      "akinsho/bufferline.nvim",
      version = "v4.*",
      dependencies = "nvim-tree/nvim-web-devicons",
      event = "VeryLazy",
      keys = {
        { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc="Toggle Buffer Pin" },
        { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc="Close Unpinned Buffers" },
      },
      opts = {
        options = {
          diagnostics = "nvim_lsp",
          numbers = "buffer_id",
          always_show_bufferline = false
        }
      }
    }
  }
