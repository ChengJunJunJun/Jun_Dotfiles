-- 补全：blink.cmp（Rust 模糊匹配器）
-- 替代了原来的 nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-path + cmp_luasnip + LuaSnip 六件套
return {
  {
    "saghen/blink.cmp",
    -- v2 有大量 breaking change，钉在 v1 稳定分支
    version = "1.*",
    event = "InsertEnter",
    -- friendly-snippets 是纯数据仓库，blink 惰性读取，没有运行时开销
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        -- 保持原有习惯：Tab 下一项 / S-Tab 上一项 / CR 确认
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      -- 优先用 Rust 匹配器（下载预编译二进制，无需本地工具链），失败自动降级到 Lua
      fuzzy = { implementation = "prefer_rust_with_warning" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        -- 行内灰字预览，VS Code 的效果
        ghost_text = { enabled = true },
        menu = { draw = { treesitter = { "lsp" } } },
      },
      -- 函数签名浮窗，写 Python 调用时很有用
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
