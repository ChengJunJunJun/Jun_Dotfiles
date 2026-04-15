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
            theme = "tokyonight",
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
        local c = require("tokyonight.colors").setup({ style = "night" })
        return {
          highlights = {
            fill               = { bg = c.bg_dark },
            background         = { fg = c.dark3,    bg = c.bg_dark },
            buffer_visible     = { fg = c.dark5,    bg = c.bg_dark },
            buffer_selected    = { fg = c.fg,       bg = c.bg, bold = true, italic = false },
            separator          = { fg = c.bg_dark,  bg = c.bg_dark },
            separator_visible  = { fg = c.bg_dark,  bg = c.bg_dark },
            separator_selected = { fg = c.bg_dark,  bg = c.bg },
            indicator_selected = { fg = c.blue,     bg = c.bg },
            modified_selected  = { fg = c.orange,   bg = c.bg },
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
