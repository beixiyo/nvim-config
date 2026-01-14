-- GitHub Copilot Chat - 聊天式AI代码助手
-- 核心功能：
-- 1. 与GitHub Copilot进行自然语言对话
-- 2. 代码生成、修改和优化建议
-- 3. 问题解答和技术咨询
-- 4. 支持选中文本和代码块操作

return {
  -- 主插件：CopilotChat 聊天界面
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",           -- 使用主分支版本
    cmd = "CopilotChat",       -- 命令名称

    -- 配置选项：动态配置，包含用户信息和界面设置
    opts = function()
      -- 获取当前用户名并格式化显示
      local user = vim.env.USER or "User"
      user = user:sub(1, 1):upper() .. user:sub(2) -- 首字母大写

      return {
        auto_insert_mode = true, -- 自动插入模式

        -- 聊天界面头部配置：使用图标和用户名显示身份
        headers = {
          user = "  " .. user .. " ",      -- 用户消息显示（用户图标 + 用户名）
          assistant = "  Copilot ",       -- AI助手回复（Copilot图标）
          tool = "󰊳  Tool ",               -- 工具调用消息（工具图标）
        },

        -- 聊天窗口配置
        window = {
          width = 0.4, -- 窗口宽度占屏幕的40%
        },
      }
    end,

    -- 键盘快捷键配置：提供完整的CopilotChat访问方式
    keys = {
      -- 提交提示：在聊天文件中使用Ctrl+S提交问题
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "提交提示", remap = true },
      
      -- AI前缀键：所有AI操作以<leader>a开头
      { "<leader>a", "", desc = "+ai", mode = { "n", "x" } },

      -- 聊天控制
      {
        "<leader>aa",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "切换CopilotChat显示",
        mode = { "n", "x" },
      },
      {
        "<leader>ax",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "清空CopilotChat对话",
        mode = { "n", "x" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({
            prompt = "快速聊天: ",
          }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "CopilotChat快速聊天",
        mode = { "n", "x" },
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "CopilotChat提示操作",
        mode = { "n", "x" },
      },
    },

    -- 插件配置：设置自动命令和初始化
    config = function(_, opts)
      local chat = require("CopilotChat")

      -- 自动命令：进入聊天缓冲区时禁用行号显示
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      -- 初始化CopilotChat
      chat.setup(opts)
    end,
  },

  -- Edgy集成：在侧边栏中显示CopilotChat
  -- 功能：将聊天窗口集成到Edgy侧边栏布局中
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = "copilot-chat",
        title = "Copilot Chat",
        size = { width = 50 }, -- 50列宽度
      })
    end,
  },

  -- Blink.cmp集成：提供代码补全支持
  -- 功能：在非聊天文件中提供路径补全，聊天文件中禁用以避免冲突
  {
    "saghen/blink.cmp",
    optional = true,
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        providers = {
          path = {
            -- 路径补全在"/"触发时与CopilotChat命令冲突
            -- 在copilot-chat文件中禁用路径补全
            enabled = function()
              return vim.bo.filetype ~= "copilot-chat"
            end,
          },
        },
      },
    },
  },
}
