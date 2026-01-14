-- SuperMaven AI - 高性能AI代码补全工具
-- 核心功能：
-- 1. 快速智能的代码补全和建议
-- 2. 支持多种编程语言和框架
-- 3. 集成传统补全框架（nvim-cmp、blink.cmp）
-- 4. 内联补全和建议预览功能

return {
  -- 主插件：SuperMaven AI补全
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",  -- 进入插入模式时加载
    cmd = {
      "SupermavenUseFree", -- 切换到免费版本
      "SupermavenUsePro",  -- 切换到专业版本
    },

    -- 基础配置
    opts = {
      -- 键位映射：接受建议由补全框架处理
      keymaps = {
        accept_suggestion = nil, -- 由 nvim-cmp / blink.cmp 处理
      },
      
      -- 禁用内联补全：如果启用AI补全则禁用
      disable_inline_completion = vim.g.ai_cmp,
      
      -- 忽略文件类型：大文件、输入框、通知等不启用补全
      ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
    },
  },

  -- AI接受动作集成：提供统一的AI接受API
  {
    "supermaven-inc/supermaven-nvim",
    opts = function()
      -- 建议预览设置：配置建议组和接受逻辑
      require("supermaven-nvim.completion_preview").suggestion_group = "SupermavenSuggestion"
      
      -- 全局AI接受动作：统一处理所有AI助手的接受逻辑
      LazyVim.cmp.actions.ai_accept = function()
        local suggestion = require("supermaven-nvim.completion_preview")
        if suggestion.has_suggestion() then
          -- 创建撤销点，允许用户撤销AI建议
          LazyVim.create_undo()
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end
      end
    end,
  },

  -- nvim-cmp集成：传统补全框架支持
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "supermaven-nvim" },
    opts = function(_, opts)
      if vim.g.ai_cmp then
        -- 在补全源列表中插入SuperMaven，优先级最高
        table.insert(opts.sources, 1, {
          name = "supermaven",
          group_index = 1,      -- 第一组
          priority = 100,       -- 最高优先级
        })
      end
    end,
  },

  -- blink.cmp集成：现代补全框架支持
  vim.g.ai_cmp and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "supermaven-nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "supermaven" }, -- 兼容性支持
        providers = {
          supermaven = {
            kind = "Supermaven",
            score_offset = 100,   -- 提高排序得分
            async = true,         -- 异步补全
          },
        },
      },
    },
  } or nil,

  -- 状态栏集成：在Lualine中显示SuperMaven状态
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("supermaven"))
    end,
  },

  -- 通知过滤：减少不必要的启动消息
  {
    "folke/noice.nvim",
    optional = true,
    opts = function(_, opts)
      vim.list_extend(opts.routes, {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "Starting Supermaven" },      -- 跳过启动消息
              { find = "Supermaven Free Tier" },     -- 跳过免费版提示
            },
          },
          skip = true, -- 跳过显示这些消息
        },
      })
    end,
  },
}
