-- ================================
-- which-key 键位提示（不依赖 LazyVim）
-- ================================
-- 按 leader 或前缀键时弹出可用键位说明，帮助记忆和发现键位
-- 文档：https://github.com/folke/which-key.nvim

local icons = require("utils").icons

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- 延迟加载，减少启动时间
    cond = function()
      return not vim.g.vscode -- 在 VSCode 中禁用此插件
    end,
    opts = {
      -- 界面风格：classic | modern | helix | false
      preset = "helix",
      -- 自定义分组：仅定义「前缀 + 分组名」，不创建实际键位；实际键位由各插件/配置注册
      spec = {
        {
          mode = { "n", "x" },
          -- leader 前缀分组
          { "<leader>c", group = "code", icon = { icon = icons.code, color = "green" } },
          { "<leader>b", group = "buffers", icon = { icon = icons.buffers, color = "blue" } },
          { "<leader>f", group = "file/find", icon = { icon = icons.find_file, color = "blue" } },
          { "<leader>g", group = "git", icon = { icon = icons.git_status, color = "red" } },
          { "<leader>s", group = "search", icon = { icon = icons.grep, color = "cyan" } },
          { "<leader>q", group = "quit/session", icon = { icon = icons.save, color = "azure" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = icons.diagnostics, color = "orange" } },
          { "<leader>m", group = "message | markdown", icon = { icon = icons.message, color = "green" } },
          { "<leader>l", group = "lsp", icon = { icon = icons.scope, color = "cyan" } },
          { "<leader>w", group = "window/layout", icon = { icon = icons.window, color = "purple" } },

          -- 无前缀单键分组（用于 g / [ / ] / z 等）
          { "[", group = "prev", icon = { icon = icons.prev, color = "grey" } },
          { "]", group = "next", icon = { icon = icons.next, color = "grey" } },
          { "g", group = "goto", icon = { icon = icons.jumps, color = "grey" } },
          { "z", group = "fold", icon = { icon = "󰘖", color = "grey" } },
        },
      },
    },
    -- 仅展示当前 buffer 的键位（不含全局），便于查看本文件/插件绑定的键
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = icons.keymaps .. " 当前缓冲区快捷键" },
    },
  },
}
