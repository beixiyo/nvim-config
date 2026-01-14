-- Overseer 任务管理和构建工具配置
-- SteveArc 开发的强大任务管理插件
-- 支持任务定义、运行、监控和管理，适合开发、构建、测试等场景

return {
  -- ==================== Catppuccin 主题集成 ====================
  {
    "catppuccin",
    -- 可选插件：仅在安装了 catppuccin 主题时启用
    optional = true,
    -- 主题集成配置：启用 Overseer 的 Catppuccin 主题支持
    opts = {
      integrations = { overseer = true },
    },
  },

  -- ==================== Overseer 主插件配置 ====================
  {
    "stevearc/overseer.nvim",
    -- 注册所有 Overseer 相关命令：延迟加载提高性能
    cmd = {
      "OverseerOpen",           -- 打开任务列表
      "OverseerClose",          -- 关闭任务列表
      "OverseerToggle",         -- 切换任务列表显示
      "OverseerSaveBundle",     -- 保存任务包
      "OverseerLoadBundle",     -- 加载任务包
      "OverseerDeleteBundle",   -- 删除任务包
      "OverseerRunCmd",         -- 运行命令
      "OverseerRun",            -- 运行任务
      "OverseerInfo",           -- 显示任务信息
      "OverseerBuild",          -- 任务构建器
      "OverseerQuickAction",    -- 快速操作
      "OverseerTaskAction",     -- 任务操作
      "OverseerClearCache",     -- 清除缓存
    },
    -- 插件选项配置
    opts = {
      -- 禁用 DAP（调试适配器协议）集成
      dap = false,
      -- 任务列表界面配置
      task_list = {
        -- 快捷键绑定配置
        bindings = {
          -- 禁用 Ctrl+H/J/K/L 快捷键，避免与 Neovim 内置快捷键冲突
          ["<C-h>"] = false,
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["<C-l>"] = false,
        },
      },
      -- 任务表单窗口配置
      form = {
        win_opts = {
          -- 窗口透明度：0 表示完全不透明（无透明度）
          winblend = 0,
        },
      },
      -- 确认对话框配置
      confirm = {
        win_opts = {
          winblend = 0,
        },
      },
      -- 任务窗口配置
      task_win = {
        win_opts = {
          winblend = 0,
        },
      },
    },
    -- stylua: ignore
    -- 快捷键绑定：定义所有任务管理相关的快捷键
    keys = {
      { "<leader>ow", "<cmd>OverseerToggle<cr>",      desc = "Task list" },       -- 切换任务列表
      { "<leader>oo", "<cmd>OverseerRun<cr>",         desc = "Run task" },        -- 运行任务
      { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" }, -- 对最近任务执行快速操作
      { "<leader>oi", "<cmd>OverseerInfo<cr>",        desc = "Overseer Info" },   -- 显示 Overseer 信息
      { "<leader>ob", "<cmd>OverseerBuild<cr>",       desc = "Task builder" },    -- 打开任务构建器
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },     -- 对选中的任务执行操作
      { "<leader>oc", "<cmd>OverseerClearCache<cr>",  desc = "Clear cache" },     -- 清除任务缓存
    },
  },

  -- ==================== Which-Key 集成 ====================
  -- 为 overseer 快捷键提供可视化的快捷键提示
  {
    "folke/which-key.nvim",
    -- 可选插件：仅在安装了 which-key 时启用
    optional = true,
    -- Which-Key 配置：定义快捷键组
    opts = {
      spec = {
        { "<leader>o", group = "overseer" }, -- 定义 <leader>o 作为 overseer 组的触发键
      },
    },
  },

  -- ==================== Edgy 侧边栏集成 ====================
  -- 将 Overseer 集成到 Edgy 侧边栏中
  {
    "folke/edgy.nvim",
    -- 可选插件：仅在安装了 edgy 时启用
    optional = true,
    -- Edgy 配置函数：在右侧边栏中添加 Overseer 面板
    opts = function(_, opts)
      -- 初始化右侧边栏配置
      opts.right = opts.right or {}
      -- 插入 Overseer 面板配置
      table.insert(opts.right, {
        -- 面板标题
        title = "Overseer",
        -- 文件类型：Overseer 专用的文件类型
        ft = "OverseerList",
        -- 打开函数：面板显示时自动打开 Overseer
        open = function()
          require("overseer").open()
        end,
      })
    end,
  },

  -- ==================== Neotest 集成 ====================
  -- 与测试框架集成，将测试结果集成到任务管理中
  {
    "nvim-neotest/neotest",
    -- 可选插件：仅在安装了 neotest 时启用
    optional = true,
    -- Neotest 配置函数：添加 Overseer 消费者
    opts = function(_, opts)
      opts = opts or {}
      -- 初始化消费者列表
      opts.consumers = opts.consumers or {}
      -- 注册 Overseer 消费者：支持在 Overseer 中运行和管理测试任务
      opts.consumers.overseer = require("neotest.consumers.overseer")
    end,
  },

  -- ==================== DAP 调试集成 ====================
  -- 启用与调试适配器的集成，支持调试任务
  {
    "mfussenegger/nvim-dap",
    -- 可选插件：仅在安装了 nvim-dap 时启用
    optional = true,
    -- DAP 配置函数：启用 Overseer 的 DAP 功能
    opts = function()
      require("overseer").enable_dap()
    end,
  },
}
