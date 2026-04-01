return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" }, -- 延迟加载
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter"

    pcall(vim.fn.mkdir, parser_install_dir, "p")
    if not vim.tbl_contains(vim.opt.runtimepath:get(), parser_install_dir) then
      vim.opt.runtimepath:append(parser_install_dir)
    end

    configs.setup({
      parser_install_dir = parser_install_dir,
      -- 只安装必要的语言解析器
      ensure_installed = {
        "lua", "vim", "vimdoc", "python", "javascript", 
        "typescript", "json", "yaml", "toml", "bash", "markdown", "markdown_inline"
      },
      
      -- 性能优化
      sync_install = false,
      auto_install = false, -- 禁用自动安装以避免启动延迟
      
      highlight = {
        enable = true,
        -- 对大文件禁用高亮以提升性能
        disable = function(lang, buf)
          -- Neovim 0.12 下 Markdown Treesitter 高亮偶发崩溃，先回退到内置语法高亮
          if lang == "markdown" or lang == "markdown_inline" then
            return true
          end

          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = { "markdown" }, -- Markdown 回退到内置语法高亮
      },
      
      indent = {
        enable = true,
        -- 对某些语言禁用缩进以避免性能问题
        disable = { "python", "yaml" }
      },
      
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>v",
          node_incremental = "<leader>v",
          node_decremental = "<leader>V"
        }
      },
    })
  end
}
