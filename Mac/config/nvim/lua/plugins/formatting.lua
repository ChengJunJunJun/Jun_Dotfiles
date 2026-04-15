-- lua/plugins/formatting.lua
-- 使用 conform.nvim 统一管理格式化，比 none-ls 更轻量直接
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format file",
      },
    },
    opts = {
      -- 格式化工具映射（工具不在 PATH 时 conform 会跳过，不报错）
      formatters_by_ft = {
        -- Python：先 isort 整理 import，再 black 格式化
        python = function()
          local fmts = {}
          if vim.fn.executable("isort") == 1 then table.insert(fmts, "isort") end
          if vim.fn.executable("black") == 1 then table.insert(fmts, "black") end
          return fmts
        end,
        -- Lua：用 stylua（:MasonInstall stylua）
        lua = { "stylua" },
      },
      -- 不在保存时自动格式化，只通过 <leader>f 手动触发
      format_on_save = false,
      -- 工具不存在时静默跳过，不弹错误
      notify_on_error = false,
    },
  },
}
