-- lua/plugins/ui.lua —— VS Code 风格的三件套布局
return {
  -- ════════════════════════════════════════════════════════
  -- 底部状态栏
  -- ════════════════════════════════════════════════════════
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      -- 当前 Python 虚拟环境名（和终端里自动 source 的 .venv 对应）
      local function venv()
        local v = vim.env.VIRTUAL_ENV
        if not v then
          local cwd_venv = vim.fn.getcwd() .. "/.venv"
          if vim.fn.isdirectory(cwd_venv) == 1 then
            v = cwd_venv
          end
        end
        if not v then
          return ""
        end
        return " " .. vim.fn.fnamemodify(v, ":t")
      end

      -- lualine 自带的 vscode 主题把背景写死成 #262626 / #373737，
      -- 不跟 colorscheme.lua 里的 color_overrides 走，这里按新底色重刷一遍
      local function lualine_theme()
        local t = vim.deepcopy(require("lualine.themes.vscode"))
        for _, mode in pairs(t) do
          if mode.b then mode.b.bg = "#20212c" end
          if mode.c then mode.c.bg = "#1a1b26" end
        end
        t.inactive.a.bg = "#1a1b26"
        return t
      end

      return {
        options = {
          icons_enabled = true,
          theme = lualine_theme(),
          component_separators = "|",
          section_separators = "",
          globalstatus = true, -- 配合 laststatus=3，整个窗口一条底栏
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            { venv, cond = function() return vim.bo.filetype == "python" end },
            "encoding",
            { "fileformat", symbols = { unix = "🍎" } },
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "lazy", "mason", "quickfix" },
      }
    end,
  },

  -- ════════════════════════════════════════════════════════
  -- 顶部标签页
  -- ════════════════════════════════════════════════════════
  {
    "akinsho/bufferline.nvim",
    version = "v4.*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "固定/取消固定标签页" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "关闭所有未固定标签页" },
    },
    opts = function()
      local c = require("vscode.colors").get_colors()
      return {
        highlights = {
          fill = { bg = c.vscTabOther },
          background = { fg = c.vscLineNumber, bg = c.vscTabOther },
          buffer_visible = { fg = c.vscGray, bg = c.vscTabOther },
          buffer_selected = { fg = c.vscFront, bg = c.vscTabCurrent, bold = true, italic = false },
          separator = { fg = c.vscTabOther, bg = c.vscTabOther },
          separator_visible = { fg = c.vscTabOther, bg = c.vscTabOther },
          separator_selected = { fg = c.vscTabOther, bg = c.vscTabCurrent },
          indicator_selected = { fg = c.vscBlue, bg = c.vscTabCurrent },
          modified_selected = { fg = c.vscOrange, bg = c.vscTabCurrent },
        },
        options = {
          diagnostics = "nvim_lsp",
          -- ordinal 配合 <leader>1..9 跳转（VS Code 的 Alt+1..9）
          numbers = "ordinal",
          always_show_bufferline = false,
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "thin",
          offsets = {
            {
              -- snacks.explorer 的侧边栏窗口
              filetype = "snacks_layout_box",
              text = "EXPLORER",
              text_align = "left",
              separator = true,
            },
          },
        },
      }
    end,
  },

  -- ════════════════════════════════════════════════════════
  -- 面包屑导航（VS Code 顶部的 file > class > function 路径）
  -- ════════════════════════════════════════════════════════
  {
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
    -- 零依赖：自动在 LSP document symbol 和 treesitter 之间降级，
    -- 所以 Python 走 LSP 显示 class > def，JSON 走 treesitter 显示 key 路径
    keys = {
      { "<leader>;", function() require("dropbar.api").pick() end, desc = "面包屑键盘导航" },
      { "[;", function() require("dropbar.api").goto_context_start() end, desc = "跳到当前上下文开头" },
      { "];", function() require("dropbar.api").select_next_context() end, desc = "选中下一层上下文" },
    },
    opts = function()
      local sources = require("dropbar.sources")
      local utils = require("dropbar.utils")
      local configs = require("dropbar.configs")

      -- JSON 的默认 treesitter 路径会把 object 容器节点也算进去，
      -- 而每个 object 又是用它第一个 key 命名的，于是
      -- database.pool.max 会显示成 name > database > pool > pool > max > max。
      -- 调用时临时摘掉容器类型，只保留 pair，得到和 VS Code 一致的
      -- database > pool > max。
      local json_source = {
        get_symbols = function(buf, win, cursor)
          local ts = configs.opts.sources.treesitter
          local original = ts.valid_types
          local filtered = {}
          for _, t in ipairs(original) do
            if t ~= "object" and t ~= "array" and t ~= "value" then
              filtered[#filtered + 1] = t
            end
          end
          ts.valid_types = filtered
          local ok, symbols = pcall(sources.treesitter.get_symbols, buf, win, cursor)
          ts.valid_types = original
          return ok and symbols or {}
        end,
      }

      return {
        bar = {
          -- 大文件不画面包屑，省掉一次全文件符号解析
          enable = function(buf, win, _)
            if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
              return false
            end
            if vim.bo[buf].buftype ~= "" or vim.fn.win_gettype(win) ~= "" then
              return false
            end
            local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > 1024 * 1024 then
              return false
            end
            return true
          end,
          sources = function(buf, _)
            local ft = vim.bo[buf].filetype
            if ft == "json" or ft == "jsonc" then
              return { sources.path, json_source }
            end
            if ft == "markdown" then
              return { sources.path, sources.markdown }
            end
            if vim.bo[buf].buftype == "terminal" then
              return { sources.terminal }
            end
            -- Python 等：优先 LSP 符号，拿不到就退回 treesitter
            return {
              sources.path,
              utils.source.fallback({ sources.lsp, sources.treesitter }),
            }
          end,
        },
      }
    end,
  },
}
