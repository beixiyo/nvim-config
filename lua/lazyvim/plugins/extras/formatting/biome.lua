-- Biome 现代化前端代码格式化工具配置
-- Biome 是由 Rome 团队开发的新一代前端工具链
-- 支持 TypeScript、JavaScript、CSS、JSON 等多种前端语言的格式化

---@diagnostic disable: inject-field
if lazyvim_docs then
  -- 启用此选项以避免与 Prettier 冲突
  -- 当用户同时使用 Biome 和 Prettier 时，需要明确配置
  vim.g.lazyvim_prettier_needs_config = true
end

-- Biome 支持的文件类型列表
-- 参考：https://biomejs.dev/internals/language-support/
local supported = {
  "astro",          -- Astro 框架文件
  "css",            -- CSS 样式文件
  "graphql",        -- GraphQL 查询文件
  -- "html",        -- HTML 文件（目前不推荐使用，因为与 Prettier 冲突）
  "javascript",     -- JavaScript 文件
  "javascriptreact",-- React JSX 语法
  "json",           -- JSON 数据文件
  "jsonc",          -- JSON with Comments（支持注释的 JSON）
  -- "markdown",    -- Markdown 文件（目前不推荐使用）
  "svelte",         -- Svelte 框架文件
  "typescript",     -- TypeScript 文件
  "typescriptreact",-- React TSX 语法
  "vue",            -- Vue.js 模板文件
  -- "yaml",        -- YAML 配置文件（目前不推荐使用）
}

return {
  -- ==================== Mason 包管理器集成 ====================
  -- 确保 Biome 通过 mason 包管理器安装
  {
    "mason-org/mason.nvim",
    -- 确保安装列表：包含 "biome" 格式化工具
    opts = { ensure_installed = { "biome" } },
  },

  -- ==================== Conform 格式化工具集成 ====================
  {
    "stevearc/conform.nvim",
    -- 可选插件：仅在安装了 conform 时启用
    optional = true,
    ---@param opts ConformOpts
    -- Conform 插件配置函数
    opts = function(_, opts)
      -- 初始化文件类型到格式化工具的映射表
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- 为每个支持的文件类型添加 Biome 作为格式化选项
      for _, ft in ipairs(supported) do
        -- 如果该文件类型已有格式化工具，保留原有工具
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        -- 将 Biome 添加到该文件类型的格式化工具列表中
        table.insert(opts.formatters_by_ft[ft], "biome")
      end

      -- Biome 格式化工具的特定配置
      opts.formatters = opts.formatters or {}
      opts.formatters.biome = {
        -- require_cwd = true：要求 Biome 在工作目录中运行
        -- 确保配置文件解析和相对路径处理的一致性
        require_cwd = true,
      }
    end,
  },

  -- ==================== None-LS 支持 ====================
  -- 通过 None-LS 插件集成 Biome 格式化功能
  {
    "nvimtools/none-ls.nvim",
    -- 可选插件：仅在安装了 none-ls 时启用
    optional = true,
    -- None-LS 配置函数
    opts = function(_, opts)
      -- 引入 null-ls 模块
      local nls = require("null-ls")
      -- 初始化格式化工具源列表
      opts.sources = opts.sources or {}
      -- 添加 Biome 作为格式化工具源
      table.insert(opts.sources, nls.builtins.formatting.biome)
    end,
  },
}
