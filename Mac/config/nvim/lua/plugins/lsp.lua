-- lua/plugins/lsp.lua
-- LSP 配置文件 - 使用 Neovim 0.11+ 的新 API
-- 提供 Python 语言服务器支持（Pyright 和 Ruff）

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

      -- 使用新的 vim.lsp.config API (Neovim 0.11+)
      -- 配置 Pyright
      vim.lsp.config.pyright = {
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
      }
      
      -- 配置 Ruff (新版本)
      vim.lsp.config.ruff = {
        capabilities = capabilities,
      }

      -- 启用 LSP 服务器
      vim.lsp.enable('pyright')
      vim.lsp.enable('ruff')
    end
  }
}