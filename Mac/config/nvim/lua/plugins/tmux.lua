-- lua/plugins/tmux.lua —— 与 tmux 的窗口/面板无缝导航
return {
  -- C-hjkl 在 nvim 分屏和 tmux 面板之间连续移动：
  -- 到了 nvim 最左边的窗口再按 C-h，会直接跳到左边那个 tmux 面板，反之亦然。
  --
  -- 原理：tmux 侧（plugins/vim-tmux-navigator/vim-tmux-navigator.tmux）把无 prefix 的
  -- C-hjkl 拦下来，用 ps 检查当前面板跑的是不是 vim/nvim/fzf；是就把按键透传进来交给
  -- 本插件处理，不是就自己 select-pane。所以两侧必须同时装，缺一边就退化成普通切窗口。
  {
    "christoomey/vim-tmux-navigator",
    -- 只在真的按到这几个键时才加载，不拖慢启动
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    init = function()
      -- 关掉插件自带的映射，改由下面的 keys 统一声明，
      -- 否则 lazy 的按键触发器和插件自己的映射会各绑一遍
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "切到左窗口 / tmux 面板" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "切到下窗口 / tmux 面板" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "切到上窗口 / tmux 面板" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "切到右窗口 / tmux 面板" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "切到上一个窗口 / tmux 面板" },
    },
  },
}
