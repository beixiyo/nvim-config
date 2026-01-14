--- Prettier 代码格式化插件配置
-- 集成 Prettier 代码格式化工具，支持多种前端和配置文件格式的自动格式化

---@diagnostic disable: inject-field

-- LazyVim 文档模式配置：启用/禁用 Prettier 配置文件要求
if lazyvim_docs then
  --- 配置文件要求选项：如果找不到 prettier 配置文件，则不使用格式化器
  -- false = 允许在无配置文件时使用默认设置，true = 强制要求配置文件
  vim.g.lazyvim_prettier_needs_config = false
end

--- Conform 上下文类型定义
---@alias ConformCtx {buf: number, filename: string, dirname: string}

--- Prettier 模块主对象
local M = {}

--- Prettier 支持的文件类型列表
-- 包括前端开发中常用的所有配置文件格式和脚本语言
local supported = {
  "css",              -- CSS 样式表
  "graphql",          -- GraphQL 查询语言
  "handlebars",       -- Handlebars 模板引擎
  "html",             -- HTML 文档
  "javascript",       -- JavaScript 脚本
  "javascriptreact",  -- JavaScript React 组件
  "json",             -- JSON 数据格式
  "jsonc",            -- JSON with Comments
  "less",             -- LESS 预处理器
  "markdown",         -- Markdown 文档
  "markdown.mdx",     -- MDX (Markdown + JSX)
  "scss",             -- SCSS 预处理器
  "typescript",       -- TypeScript
  "typescriptreact",  -- TypeScript React 组件
  "vue",              -- Vue.js 组件
  "yaml",             -- YAML 配置文件
}

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
function M.has_config(ctx)
  vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true
--- * Otherwise, check if a parser can be inferred
---@param ctx ConformCtx
function M.has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- default filetypes are always supported
  if vim.tbl_contains(supported, ft) then
    return true
  end
  -- otherwise, check if a parser can be inferred
  local ret = vim.fn.system({ "prettier", "--file-info", ctx.filename })
  ---@type boolean, string?
  local ok, parser = pcall(function()
    return vim.fn.json_decode(ret).inferredParser
  end)
  return ok and parser and parser ~= vim.NIL
end

M.has_config = LazyVim.memoize(M.has_config)
M.has_parser = LazyVim.memoize(M.has_parser)

return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettier" } },
  },

  -- conform
  {
    "stevearc/conform.nvim",
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "prettier")
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        condition = function(_, ctx)
          return M.has_parser(ctx) and (vim.g.lazyvim_prettier_needs_config ~= true or M.has_config(ctx))
        end,
      }
    end,
  },

  -- none-ls support
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.prettier)
    end,
  },
}
