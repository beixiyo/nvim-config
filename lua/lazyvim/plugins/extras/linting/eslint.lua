-- LazyVim ESLint 配置文件
-- 功能：为 Neovim 配置 ESLint 语言服务器，提供 JavaScript/TypeScript 代码的实时 linting 和格式化功能
-- 说明：集成到 LazyVim 的 LSP 系统中，支持自动格式化和代码质量检查

-- ========================================
-- 1. ESLint 自动格式化配置
-- ========================================

-- 文档生成模式下设置全局变量，用于控制 ESLint 的自动格式化功能
-- 当设置为 false 时，将禁用 ESLint 的自动格式化功能
if lazyvim_docs then
  -- 设置为 false 可禁用自动格式功能（默认 true）
  vim.g.lazyvim_eslint_auto_format = true
end

-- 获取 ESLint 自动格式化的配置状态
-- 默认值为 true（启用），除非用户显式设置为 false
local auto_format = vim.g.lazyvim_eslint_auto_format == nil or vim.g.lazyvim_eslint_auto_format

-- ========================================
-- 2. ESLint LSP 服务器配置
-- ========================================

return {
  {
    -- 使用 Neovim 内建的 LSP 配置插件
    "neovim/nvim-lspconfig",
    -- 其他设置在此处省略以保持简洁性

    -- LSP 配置选项
    opts = {
      -- 定义语言服务器的配置表
      ---@type table<string, vim.lsp.Config>
      servers = {
        eslint = {
          -- ESLint 服务器的特定配置设置
          settings = {
            -- 帮助 ESLint 在项目结构中找到正确的 .eslintrc 配置文件
            -- 当 .eslintrc 位于子目录而非当前工作目录根时，此设置尤为有用
            -- 设置为 "auto" 模式可自动检测项目结构
            workingDirectories = { mode = "auto" },

            -- 控制是否启用 ESLint 的自动格式化功能
            -- 基于上述获取的 auto_format 变量值
            format = auto_format,
          },
        },
      },

      -- LSP 服务器的设置函数，在服务器启动时执行
      setup = {
        eslint = function()
          -- 如果未启用自动格式化，则直接返回，不进行后续配置
          if not auto_format then
            return
          end

          -- 创建 ESLint 格式化器实例
          local formatter = LazyVim.lsp.formatter({
            -- 格式化器的名称标识
            name = "eslint: lsp",
            -- 设置为主要格式化器（false 表示非主要，与其他格式化器协作）
            primary = false,
            -- 格式化优先级，数值越高优先级越高（200 高于内置格式化器）
            priority = 200,
            -- 过滤条件，只处理 ESLint 相关文件
            filter = "eslint",
          })

          -- 将格式化器注册到 LazyVim 的格式化系统中
          -- 这样 LazyVim 就可以使用 ESLint 进行代码格式化
          LazyVim.format.register(formatter)
        end,
      },
    },
  },
}
