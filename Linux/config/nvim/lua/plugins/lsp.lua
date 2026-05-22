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
          "pyright",   -- Python 类型检查
          "ruff",      -- Python linting
          "lua_ls",    -- Lua（覆盖自己的 nvim 配置）
        },
        automatic_installation = true,
      })

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

      -- 配置 Ruff
      vim.lsp.config.ruff = {
        capabilities = capabilities,
      }

      -- 配置 lua_ls，识别 vim 全局变量和运行时 API
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = {
              globals = { "vim" },
            },
            telemetry = { enable = false },
          },
        },
      }

      -- 启用 LSP 服务器
      vim.lsp.enable('pyright')
      vim.lsp.enable('ruff')
      vim.lsp.enable('lua_ls')
    end
  }
}