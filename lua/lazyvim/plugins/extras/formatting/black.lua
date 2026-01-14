-- Black Python 代码格式化工具配置
-- Black 是 Python 社区广泛使用的代码格式化工具
-- 支持自动格式化 Python 代码，保持一致的代码风格

return {
  -- ==================== Mason 包管理器集成 ====================
  -- 确保 Black 通过 mason 包管理器安装
  {
    "mason-org/mason.nvim",
    -- 自定义选项函数：在 Mason 中添加 Black 格式化工具
    opts = function(_, opts)
      -- 将 "black" 添加到确保安装的工具列表中
      table.insert(opts.ensure_installed, "black")
    end,
  },

  -- ==================== None-LS 集成 ====================
  -- 通过 None-LS 插件集成 Black 格式化功能
  {
    "nvimtools/none-ls.nvim",
    -- 可选插件：仅在安装了 none-ls 时启用
    optional = true,
    opts = function(_, opts)
      -- 引入 null-ls 模块
      local nls = require("null-ls")
      -- 初始化格式化工具源列表
      opts.sources = opts.sources or {}
      -- 添加 Black 作为格式化工具
      table.insert(opts.sources, nls.builtins.formatting.black)
    end,
  },

  -- ==================== Conform 格式化工具集成 ====================
  -- 通过 Conform 插件集成 Black 格式化功能
  {
    "stevearc/conform.nvim",
    -- 可选插件：仅在安装了 conform 时启用
    optional = true,
    -- Conform 插件配置
    opts = {
      -- 按文件类型配置格式化工具
      formatters_by_ft = {
        -- Python 文件使用 Black 进行格式化
        ["python"] = { "black" },
      },
    },
  },
}
