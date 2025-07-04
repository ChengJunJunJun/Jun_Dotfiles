-- lua/plugins/formatting.lua
return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- Python formatting
          null_ls.builtins.formatting.black.with({
            extra_args = { "--line-length", "88" }
          }),
          null_ls.builtins.formatting.isort,
          -- 注意：现在 ruff 作为 LSP 运行，不需要在 null-ls 中配置
        }
      })
      
      -- 格式化快捷键
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file" })
    end
  }
}