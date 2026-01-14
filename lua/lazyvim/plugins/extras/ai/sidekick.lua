-- Sidekick AI 编程助手 - 下一代编辑建议和AI集成
-- 核心功能：
-- 1. NES (Next Edit Suggestions) - 下一个编辑建议
-- 2. CLI集成 - 命令行界面与AI工具交互
-- 3. 多种AI模型和工具的统一管理
-- 4. 智能代码补全和建议系统

return {
  desc = "使用Copilot LSP服务器的下一个编辑建议",

  -- LSP配置：为Sidekick的NES功能启用Copilot服务器
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local sk = LazyVim.opts("sidekick.nvim") ---@type sidekick.Config|{}
      
      -- 如果Sidekick NES功能启用，配置Copilot服务器
      if vim.tbl_get(sk, "nes", "enabled") ~= false then
        opts.servers = opts.servers or {}
        opts.servers.copilot = opts.servers.copilot or {}
      end
    end,
  },

  -- 状态栏集成：在Lualine中显示Sidekick状态和CLI会话数量
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      -- 状态图标配置：不同状态使用不同图标和颜色
      local icons = {
        Error = { " ", "DiagnosticError" },    -- 错误状态
        Inactive = { " ", "MsgArea" },          -- 非活跃状态  
        Warning = { " ", "DiagnosticWarn" },    -- 警告状态
        Normal = { LazyVim.config.icons.kinds.Copilot, "Special" }, -- 正常状态
      }

      -- Sidekick状态指示器：显示NES连接状态
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local status = require("sidekick.status").get()
          return status and vim.tbl_get(icons, status.kind, 1)
        end,
        cond = function()
          return require("sidekick.status").get() ~= nil
        end,
        color = function()
          local status = require("sidekick.status").get()
          -- 忙碌时使用警告色，否则使用状态对应的颜色
          local hl = status and (status.busy and "DiagnosticWarn" or vim.tbl_get(icons, status.kind, 2))
          return { fg = Snacks.util.color(hl) }
        end,
      })

      -- CLI会话数量指示器：显示活跃的CLI会话数
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local status = require("sidekick.status").cli()
          -- 如果多个会话，显示数量；否则只显示图标
          return " " .. (#status > 1 and #status or "")
        end,
        cond = function()
          return #require("sidekick.status").cli() > 0
        end,
        color = function()
          return { fg = Snacks.util.color("Special") }
        end,
      })
    end,
  },

  -- Sidekick主插件：提供NES和CLI功能
  {
    "folke/sidekick.nvim",
    opts = function()
      -- NES动作映射：将AI补全动作映射到Sidekick NES
      LazyVim.cmp.actions.ai_nes = function()
        local Nes = require("sidekick.nes")
        -- 如果有下一个建议，尝试跳转或应用
        if Nes.have() and (Nes.jump() or Nes.apply()) then
          return true
        end
      end

      -- NES切换开关：提供开关控制
      Snacks.toggle({
        name = "Sidekick NES",
        get = function()
          return require("sidekick.nes").enabled
        end,
        set = function(state)
          require("sidekick.nes").enable(state)
        end,
      }):map("<leader>uN")
    end,

    -- 键盘快捷键：提供完整的Sidekick访问方式
    -- stylua: ignore
    keys = {
      -- NES在普通模式下也很有用
      { "<tab>", LazyVim.cmp.map({ "ai_nes" }, "<tab>"), mode = { "n" }, expr = true },
      
      -- AI前缀键：所有AI操作以<leader>a开头
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },

      -- CLI控制
      {
        "<c-.>",
        function() require("sidekick.cli").toggle() end,
        desc = "切换Sidekick显示",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick CLI切换",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        -- 或者只选择已安装的工具：
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "选择CLI工具",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "关闭CLI会话",
      },

      -- 内容发送
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "发送当前内容",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "发送整个文件",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "发送选中文本",
      },

      -- 提示输入
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick选择提示",
      },
    },
  },

  -- Snacks集成：为Snacks选择器添加Sidekick支持
  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        actions = {
          -- Sidekick发送动作：在选择器中集成Sidekick发送功能
          sidekick_send = function(...)
            return require("sidekick.cli.picker.snacks").send(...)
          end,
        },
        win = {
          input = {
            keys = {
              -- Alt+A快捷键在选择器中发送内容到Sidekick
              ["<a-a>"] = {
                "sidekick_send",
                mode = { "n", "i" },
              },
            },
          },
        },
      },
    },
  },
}
