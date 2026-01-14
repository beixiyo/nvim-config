-- LazyVim None-ls 配置文件
-- 功能：配置 None-ls (null-ls) 插件，将外部工具（格式化器、lint器、诊断工具）集成到 Neovim LSP 系统
-- 说明：None-ls 允许使用各种外部代码质量工具作为 LSP 服务器，实现统一的代码检查和格式化体验

-- ========================================
-- None-ls 插件配置
-- ========================================

return {
  -- none-ls (null-ls) 核心配置
  {
    -- None-ls 插件：强大的 LSP 服务器集成工具
    -- 功能：
    -- 1. 将外部工具（prettier、eslint、black 等）转换为 LSP 服务器
    -- 2. 支持代码格式化、linting、诊断等多种功能
    -- 3. 与 LazyVim 的格式化系统深度集成
    -- 4. 项目级别的工具配置管理
    "nvimtools/none-ls.nvim",

    -- 事件触发：仅在文件加载时启用，提高性能
    event = "LazyFile",

    -- 依赖插件
    dependencies = { "mason.nvim" },

    -- 插件初始化函数，在插件加载后执行
    init = function()
      -- 在 Neovim 非常懒惰时（启动完成后）执行
      LazyVim.on_very_lazy(function()
        -- ========================================
        -- 向 LazyVim 注册 None-ls 格式化器
        -- ========================================

        -- 注册 None-ls 格式化器到 LazyVim 的格式化系统
        LazyVim.format.register({
          -- 格式化器的唯一标识名称
          name = "none-ls.nvim",

          -- 设置为高优先级（200），高于内置的 conform 格式化器
          -- 这确保 None-ls 格式化工具有机会优先处理格式化请求
          priority = 200,

          -- 设置为主要格式化器
          -- 当有多个格式化器时，primary = true 的格式化器会被优先选择
          primary = true,

          -- 格式化函数，实现实际的格式化操作
          format = function(buf)
            -- 调用 LazyVim 的 LSP 格式化功能
            return LazyVim.lsp.format({
              bufnr = buf,  -- 指定缓冲区编号
              -- 过滤条件：只处理名称为 "null-ls" 的 LSP 客户端
              -- 这确保格式化只由 None-ls 处理
              filter = function(client)
                return client.name == "null-ls"
              end,
            })
          end,

          -- 获取可用的格式化源列表
          -- 根据文件类型动态返回可用的 None-ls 格式化工具
          sources = function(buf)
            -- 获取当前缓冲区文件类型对应的可用格式化源
            local ret = require("null-ls.sources").get_available(
              vim.bo[buf].filetype,  -- 当前文件的语言类型（如 "javascript", "lua" 等）
              "NULL_LS_FORMATTING"   -- 只获取格式化相关的源
            ) or {}  -- 如果没有可用源，返回空表

            -- 提取源名称列表
            -- 将源对象数组转换为名称字符串数组
            return vim.tbl_map(function(source)
              return source.name
            end, ret)
          end,
        })
      end)
    end,

    -- 插件选项配置函数
    -- 参数：
    -- _ : 插件配置（未使用）
    -- opts : 用户自定义选项（可能为空）
    opts = function(_, opts)
      -- 引入 None-ls 库
      local nls = require("null-ls")

      -- ========================================
      -- 1. 设置项目根目录检测规则
      -- ========================================

      -- 设置 None-ls 搜索项目根目录的模式
      -- 优先级从高到低：
      -- 1. .null-ls-root      - None-ls 专用标识文件
      -- 2. .neoconf.json     - Neoconf 配置文件
      -- 3. Makefile          - 项目构建文件
      -- 4. .git              - Git 仓库标识
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(
          ".null-ls-root",
          ".neoconf.json",
          "Makefile",
          ".git"
        )

      -- ========================================
      -- 2. 配置默认的代码格式化和诊断工具源
      -- ========================================

      -- 扩展用户自定义的源列表（如果存在），或创建新的源列表
      -- 这里预配置了一些常用的格式化和诊断工具
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- Fish Shell 代码格式化器
        -- 用于格式化 Fish shell 脚本文件
        nls.builtins.formatting.fish_indent,

        -- Fish Shell 诊断工具
        -- 用于检查 Fish shell 脚本的语法错误和潜在问题
        nls.builtins.diagnostics.fish,

        -- Stylua Lua 代码格式化器
        -- 专门用于格式化 Lua 代码，支持现代 Lua 语法
        nls.builtins.formatting.stylua,

        -- shfmt Shell 脚本格式化器
        -- 用于格式化 Bash、Shell 等脚本文件
        -- 支持多种 shell 语法风格（POSIX、GNU、Bash 等）
        nls.builtins.formatting.shfmt,
      })
    end,
  },
}
