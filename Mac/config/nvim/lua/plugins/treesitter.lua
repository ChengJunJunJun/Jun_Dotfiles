return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" }, -- 延迟加载
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      -- 只安装必要的语言解析器
      ensure_installed = {
        "lua", "vim", "vimdoc", "python", "javascript", 
        "typescript", "json", "yaml", "toml", "bash", "markdown"
      },
      
      -- 性能优化
      sync_install = false,
      auto_install = false, -- 禁用自动安装以避免启动延迟
      
      highlight = {
        enable = true,
        -- 对大文件禁用高亮以提升性能
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false, -- 禁用 vim 正则高亮
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