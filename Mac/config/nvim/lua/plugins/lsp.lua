-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim"
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- 首先设置 Mason
      require('mason').setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
      
      local mason_lspconfig = require('mason-lspconfig')
      mason_lspconfig.setup({
        ensure_installed = { 
          "pyright",  -- Python 类型检查
          "ruff"      -- Python linting (新版本)
        },
        automatic_installation = true,  -- 自动安装
      })

      -- 配置 Pyright
      require("lspconfig").pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            }
          }
        }
      })
      
      -- 配置 Ruff (新版本)
      require("lspconfig").ruff.setup({
        capabilities = capabilities,
      })
    end
  }
}