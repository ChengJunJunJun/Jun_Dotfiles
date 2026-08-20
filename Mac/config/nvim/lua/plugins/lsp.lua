-- lua/plugins/lsp.lua
-- Python 链路全 Rust：ty（类型检查/跳转/补全）+ ruff（lint/格式化）
-- 使用 Neovim 0.11+ 的 vim.lsp.config / vim.lsp.enable API
return {
  {
    "neovim/nvim-lspconfig",
    -- 打开文件时才加载，把 mason 注册表那 ~15ms 移出启动路径
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" }, opts = {
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      } },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- ── 诊断显示 ────────────────────────────────────────
      vim.diagnostic.config({
        virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
        underline = true,
        update_in_insert = false, -- 打字时不刷诊断，省一大堆无谓计算
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      -- ── capabilities 来自 blink.cmp ─────────────────────
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- ── mason ───────────────────────────────────────────
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- 注意：automatic_installation 是 v1 的选项，v2 已经移除（会被静默忽略）
        ensure_installed = {
          "ty",      -- Python 类型检查 + LSP（Rust）
          "pyright", -- 不启用，留作 ty 的回滚备份
          "lua_ls",  -- 覆盖 nvim 配置自身
        },
        -- 关掉自动启用：服务器由下面显式 vim.lsp.enable 打开，
        -- 避免 mason 里装了什么就自动起什么
        automatic_enable = false,
      })

      -- mason-lspconfig 的 ensure_installed 只认 LSP server 名，
      -- stylua 这种纯格式化工具得直接走 mason-registry 装。
      -- registry 此刻已经被上面的 setup 加载过了，这里没有额外开销。
      local ok_registry, registry = pcall(require, "mason-registry")
      if ok_registry then
        for _, tool in ipairs({ "stylua" }) do
          local ok_pkg, pkg = pcall(registry.get_package, tool)
          if ok_pkg and not pkg:is_installed() then
            pkg:install()
          end
        end
      end

      -- ══════════════════════════════════════════════════════
      -- ty —— Python 类型检查（Rust，比 pyright 增量快约 80 倍）
      -- ══════════════════════════════════════════════════════
      -- cmd / root_markers 由 nvim-lspconfig 内置的 lsp/ty.lua 提供，这里只覆盖 settings。
      -- venv 不需要手动探测：ty 按 VIRTUAL_ENV → conda → 项目根 .venv → 系统 python 自动发现。
      vim.lsp.config("ty", {
        capabilities = capabilities,
        settings = {
          ty = {
            diagnosticMode = "openFilesOnly", -- "workspace" 会全项目检查，慢很多
            inlayHints = {
              variableTypes = false,     -- beta 期推断未必准，默认关掉少点噪音（<leader>ci 可临时开）
              callArgumentNames = true,  -- 参数名提示很实用
            },
            completions = {
              autoImport = true,                  -- 补全时自动补 import
              completeFunctionParentheses = true, -- 补全函数自动带括号（VS Code 行为）
            },
          },
        },
      })

      -- ══════════════════════════════════════════════════════
      -- ruff —— Python lint（Rust）：已配置但未启用
      -- ══════════════════════════════════════════════════════
      -- 显式指定 cmd 走 PATH 里的 ruff，和 conform 用的是同一个二进制，
      -- 避免和 mason 那份产生版本漂移
      vim.lsp.config("ruff", {
        cmd = { "ruff", "server" },
        capabilities = capabilities,
        on_attach = function(client)
          -- 关掉 ruff 的 hover，否则按 K 拿到的是空框而不是 ty 的类型信息。
          -- 职责切分：ty 管类型/跳转/补全，ruff 管 lint/格式化。
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- ══════════════════════════════════════════════════════
      -- pyright —— 已配置但未启用，作为 ty 的回滚备份
      -- ══════════════════════════════════════════════════════
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
        -- pyright 不像 ty 那样自动找 .venv，得手动指过去
        before_init = function(_, config)
          local venv_python = (config.root_dir or vim.fn.getcwd()) .. "/.venv/bin/python"
          if vim.fn.executable(venv_python) == 1 then
            config.settings.python.pythonPath = venv_python
          end
        end,
      })

      -- ══════════════════════════════════════════════════════
      -- lua_ls
      -- ══════════════════════════════════════════════════════
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim", "Snacks" } },
            telemetry = { enable = false },
          },
        },
      })

      -- ── 启用 ────────────────────────────────────────────
      vim.lsp.enable("ty")
      vim.lsp.enable("lua_ls")

      -- ruff LSP 已关闭：不再有 lint 诊断（F401/E501 那类波浪线）。
      -- 格式化不受影响 —— conform 直接调 PATH 里的 ruff 二进制，不经过 LSP，
      -- <leader>cf 仍然是 ruff_organize_imports + ruff_format。
      -- 想恢复 lint，取消下面这行的注释即可。
      -- vim.lsp.enable("ruff")

      -- 回滚到 pyright：ty 还在 beta，如果误报烦到你了，
      -- 注释掉上面的 vim.lsp.enable("ty")，并取消下面这行的注释即可。
      -- pyright 已经在 ensure_installed 里，不用重装。
      -- vim.lsp.enable("pyright")
    end,
  },
}
