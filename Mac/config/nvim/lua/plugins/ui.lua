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
      opts = function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        return {
          highlights = {
            fill                = { bg = p.mantle },
            background          = { fg = p.overlay0, bg = p.mantle },
            buffer_visible      = { fg = p.overlay1, bg = p.mantle },
            buffer_selected     = { fg = p.text,     bg = p.base, bold = true, italic = false },
            separator           = { fg = p.mantle,   bg = p.mantle },
            separator_visible   = { fg = p.mantle,   bg = p.mantle },
            separator_selected  = { fg = p.mantle,   bg = p.base },
            indicator_selected  = { fg = p.lavender, bg = p.base },
            modified_selected   = { fg = p.peach,    bg = p.base },
          },
          options = {
            diagnostics = "nvim_lsp",
            numbers = "buffer_id",
            always_show_bufferline = false,
            offsets = {
              {
                filetype = "NvimTree",
                text = "",
                separator = false,
              },
            },
          },
        }
      end
    }
  }
