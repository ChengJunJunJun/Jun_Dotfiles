-- lua/plugins/formatting.lua
-- conform.nvim 统一管理格式化
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        -- Python：ruff（Rust）一把梭，比 isort + black 快 10-100 倍，
        -- 输出与 black 兼容所以代码风格不会变
        python = { "ruff_organize_imports", "ruff_format" },
        -- JSON：jq 已装，瞬时完成
        json = { "jq" },
        -- JSONC 刻意留空：jq 会把注释吃掉
        jsonc = {},
        lua = { "stylua" },
      },
      -- 不在保存时自动格式化，只通过 <leader>cf / <S-M-f> 手动触发
      format_on_save = false,
      -- 工具不存在时静默跳过，不弹错误
      notify_on_error = false,
      formatters = {
        -- 缩进 2 空格，和 FileType autocmd 里给 json 设的 shiftwidth 保持一致
        jq = { prepend_args = { "--indent", "2" } },
      },
    },
  },
}
