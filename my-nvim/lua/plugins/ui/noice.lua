-- ================================
-- Noice 命令行/消息 UI
-- ================================
-- 现代化 cmdline、消息与补全浮层。:echo "发送测试消息"

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      -- LSP：用 Noice 的 Markdown 渲染替代默认，hover/签名等文档更美观
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      -- 消息路由：匹配到的消息用指定视图显示，减少刷屏
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },   -- 如 "10L, 20B" 行/字节统计
              { find = "; after #%d+" }, -- 如 "; after #1" 跳转提示
              { find = "; before #%d+" }, -- 如 "; before #1" 跳转提示
            },
          },
          view = "mini", -- 上述消息用 mini 小窗显示
        },
      },
      -- 预设：底部搜索栏、命令面板式 cmdline、长消息拆成 split
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    keys = {
      { "<leader>mh", function() require("noice").cmd("history") end, desc = "消息历史" },
      {
        "<leader>mc",
        function()
          local last = vim.v.statusmsg
          if last == "" then
            vim.notify("无上一条消息", vim.log.levels.WARN)
            return
          end
          vim.fn.setreg('"', last)
          if vim.fn.has("clipboard") == 1 then
            vim.fn.setreg("+", last)
          end
          vim.notify("已复制最后一条消息", vim.log.levels.INFO)
        end,
        desc = "复制最后一条消息",
      },
    },
    config = function(_, opts)
      -- 在 Lazy 界面加载时清空消息，避免启动时刷屏
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },
}
