-- ================================
-- which-key 键位提示（不依赖 LazyVim）
-- ================================
-- 按 leader 或前缀键时弹出可用键位说明，帮助记忆和发现键位
-- 文档：https://github.com/folke/which-key.nvim

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- 延迟加载，减少启动时间
    opts = {
      -- 界面风格：classic | modern | helix | false
      preset = "helix",
      -- 自定义分组：仅定义「前缀 + 分组名」，不创建实际键位；实际键位由各插件/配置注册
      spec = {
        -- leader 前缀分组（n=普通模式, x=可视模式）
        { mode = { "n", "x" }, { "<leader>c", group = "code" } },
        { mode = { "n", "x" }, { "<leader>f", group = "file/find" } },
        { mode = { "n", "x" }, { "<leader>g", group = "git" } },
        { mode = { "n", "x" }, { "<leader>s", group = "search" } },
        { mode = { "n", "x" }, { "<leader>q", group = "quit/session" } },
        { mode = { "n", "x" }, { "<leader>x", group = "diagnostics/quickfix" } },
        { mode = { "n", "x" }, { "<leader>m", group = "message" } },
        -- 无前缀单键分组（用于 g / [ / ] / z 等）
        { mode = { "n", "x" }, { "[", group = "prev" } },
        { mode = { "n", "x" }, { "]", group = "next" } },
        { mode = { "n", "x" }, { "g", group = "goto" } },
        { mode = { "n", "x" }, { "z", group = "fold" } },
      },
    },
    -- 仅展示当前 buffer 的键位（不含全局），便于查看本文件/插件绑定的键
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps" },
    },
  },
}
