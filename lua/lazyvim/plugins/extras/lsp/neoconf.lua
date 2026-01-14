-- LazyVim Neoconf 配置文件
-- 功能：配置 Neoconf 插件，提供强大的 LSP 配置管理和项目特定设置功能
-- 说明：集成到 LazyVim 的 LSP 系统中，支持多种配置文件格式和项目级别的语言服务器配置

-- ========================================
-- Neoconf 插件配置
-- ========================================

return {
  {
    -- 使用 Neovim 内建的 LSP 配置插件作为基础
    "neovim/nvim-lspconfig",

    -- 定义插件依赖项
    dependencies = {
      {
        -- Neoconf 插件：强大的 LSP 配置管理工具
        -- 功能：
        -- 1. 支持多种配置文件格式（.neoconf.json, .nvimrc.lua, init.lua 等）
        -- 2. 项目级别的 LSP 配置管理
        -- 3. 用户友好的 LSP 服务器配置界面
        -- 4. 与 LazyVim 的配置系统无缝集成
        "folke/neoconf.nvim",

        -- 定义 Neoconf 的命令
        -- 执行 ":Neoconf" 命令打开配置管理界面
        cmd = "Neoconf",

        -- 插件选项配置（使用默认设置）
        -- Neoconf 的选项可以通过以下方式配置：
        -- - 全局变量（vim.g.neoconf_*）
        -- - 插件选项（opts）
        -- - 项目配置文件（.neoconf.json 等）
        opts = {},
      },
    },
  },
}
