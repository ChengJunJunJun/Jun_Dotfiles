return {
  "nvim-treesitter/nvim-treesitter",
  -- 继续钉在 master：现有解析器都是用它编译的，
  -- 切 main 分支要全部重编，属于纯风险无收益
  branch = "master",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
  config = function()
    local configs = require("nvim-treesitter.configs")
    local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"

    pcall(vim.fn.mkdir, parser_install_dir, "p")
    if not vim.tbl_contains(vim.opt.runtimepath:get(), parser_install_dir) then
      vim.opt.runtimepath:append(parser_install_dir)
    end

    configs.setup({
      parser_install_dir = parser_install_dir,
      -- 按主力场景（JSON + Python）精简，去掉了 javascript / typescript
      ensure_installed = {
        "python",
        "json",
        "jsonc",
        "yaml",
        "toml",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "bash",
        "markdown",
        "markdown_inline",
      },

      sync_install = false,
      auto_install = false, -- 禁用自动安装以避免打开陌生文件类型时卡住

      highlight = {
        enable = true,
        disable = function(lang, buf)
          -- Neovim 0.12 下 Markdown Treesitter 高亮偶发崩溃，回退到内置语法高亮
          if lang == "markdown" or lang == "markdown_inline" then
            return true
          end
          -- 大文件阈值：外层还有 snacks.bigfile 兜着，这里不必卡太死
          local max_filesize = 256 * 1024
          local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = { "markdown" },
      },

      indent = {
        enable = true,
        -- treesitter 的 python / yaml 缩进有已知问题，用内置的更稳
        disable = { "python", "yaml" },
      },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>v",
          node_incremental = "<leader>v",
          node_decremental = "<leader>V",
        },
      },
    })
  end,
}
