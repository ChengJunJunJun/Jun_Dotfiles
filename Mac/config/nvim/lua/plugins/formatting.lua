-- lua/plugins/formatting.lua
return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local sources = {}

      if vim.fn.executable("black") == 1 then
        table.insert(sources, null_ls.builtins.formatting.black.with({
          extra_args = { "--line-length", "88" }
        }))
      end

      if vim.fn.executable("isort") == 1 then
        table.insert(sources, null_ls.builtins.formatting.isort)
      end

      null_ls.setup({
        sources = sources
      })
      
      -- 格式化快捷键
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file" })
    end
  }
}
