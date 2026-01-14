-- Inc-Rename 增量重命名插件配置
-- 基于 Neovim 命令预览功能的增量 LSP 重命名工具
-- 允许实时预览重命名结果，提高代码重构的准确性和效率

return {

  -- ==================== 增量重命名主插件 ====================
  -- Rename with cmdpreview：使用命令预览功能进行重命名
  -- 推荐启用：这个功能在日常开发中非常实用
  recommended = true,
  desc = "Incremental LSP renaming based on Neovim's command-preview feature",
  {
    -- 插件仓库：inc-rename.nvim 提供了智能的代码重命名功能
    "smjonas/inc-rename.nvim",
    -- 延迟加载：只有在运行 IncRename 命令时才加载插件
    cmd = "IncRename",
    -- 使用默认选项配置
    opts = {},
  },

  -- ==================== LSP 快捷键映射 ====================
  -- 为所有 LSP 服务器配置重命名快捷键
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = { -- 匹配所有 LSP 服务器
          keys = {
            {
              -- <leader>cr：增量重命名当前光标下的标识符
              "<leader>cr",
              -- 函数：生成重命名命令
              function()
                local inc_rename = require("inc_rename")
                -- 动态生成 IncRename 命令，包含当前单词
                return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
              end,
              -- 表达式快捷键：返回字符串作为实际执行的命令
              expr = true,
              desc = "Rename (inc-rename.nvim)",
              -- 只有当 LSP 服务器支持 rename 功能时才绑定快捷键
              has = "rename",
            },
          },
        },
      },
    },
  },

  -- ==================== Noice 插件集成 ====================
  -- 为 Noice 通知插件提供增量重命名的预设配置
  --- Noice integration：集成 Noice 插件以获得更好的重命名体验
  {
    "folke/noice.nvim",
    -- 可选插件：仅在安装了 noice.nvim 时启用
    optional = true,
    opts = {
      -- 启用增量重命名的 Noice 预设
      presets = { inc_rename = true },
    },
  },
}
