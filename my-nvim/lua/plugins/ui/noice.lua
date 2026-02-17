-- ================================
-- Noice 命令行/消息 UI
-- ================================
-- 现代化 cmdline、消息与补全浮层。:echo "发送测试消息"
---@module "noice"
local icons = require("utils").icons

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    cond = function()
      return not vim.g.vscode -- 在 VSCode 中禁用此插件
    end,
    ---@type NoiceConfig
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
              { find = "%d+L, %d+B" },    -- 如 "10L, 20B" 行/字节统计
              { find = "; after #%d+" },  -- 如 "; after #1" 跳转提示
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
      { "<leader>mh", function() require("noice").cmd("history") end, desc = icons.command_history .. " " .. "消息历史" },
      {
        "<leader>mc",
        function()
          -- 使用 noice 的 "all" 命令显示所有消息（包括启动错误）
          -- 这会打开一个 split 窗口显示所有消息
          require("noice").cmd("all")

          -- 等待窗口打开后读取内容
          vim.schedule(function()
            vim.defer_fn(function()
              -- 优先查找 filetype 为 "noice" 的窗口，而不是简单拿当前窗口
              local target_win = nil
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(win) then
                  local b = vim.api.nvim_win_get_buf(win)
                  local ft = vim.api.nvim_buf_get_option(b, "filetype")
                  if ft == "noice" then
                    target_win = win
                    break
                  end
                end
              end

              -- 如果没找到 Noice 窗口，则提示用户手动复制
              if not target_win then
                vim.notify("未找到 Noice 消息窗口，请确认已成功打开", vim.log.levels.WARN)
                return
              end

              local buf = vim.api.nvim_win_get_buf(target_win)

              -- 尝试读取缓冲区内容
              local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

              -- 如果缓冲区有内容，复制它
              if #lines > 0 then
                -- 过滤掉空行和 noice 的 UI 元素
                local filtered_lines = {}
                for _, line in ipairs(lines) do
                  -- 跳过 noice 的 UI 装饰行
                  if line:match("%S") and not line:match("^[│┌┐└┘├┤┬┴╭╮╰╯]") then
                    table.insert(filtered_lines, line)
                  end
                end

                if #filtered_lines > 0 then
                  local messages_text = table.concat(filtered_lines, "\n")
                  vim.fn.setreg('"', messages_text)
                  if vim.fn.has("clipboard") == 1 then
                    vim.fn.setreg("+", messages_text)
                  end

                  -- 安全关闭 Noice 窗口，避免无效窗口导致报错
                  if vim.api.nvim_win_is_valid(target_win) then
                    pcall(vim.api.nvim_win_close, target_win, false)
                  end

                  vim.notify(string.format("已复制 %d 行消息历史到剪贴板", #filtered_lines), vim.log.levels.INFO)
                  return
                end
              end

              -- 如果自动复制失败，提示用户手动操作
              vim.notify("已打开 noice 消息窗口，请按 ggVG 选中全部内容，然后按 y 复制", vim.log.levels.INFO)
            end, 500) -- 等待 500ms 让窗口完全渲染
          end)
        end,
        desc = icons.copy .. " " .. "复制消息历史",
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
