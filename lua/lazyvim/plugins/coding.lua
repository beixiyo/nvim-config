return {
  -- Mini Pairs 自动配对插件
  -- 这是一个轻量级的自动配对插件，提供：
  -- 1. 智能括号配对：输入 ( 时自动补全 )
  -- 2. 引号自动配对：输入 " 时自动补全 "
  -- 3. 跳过逻辑：如果下一个字符已经有配对字符，跳过自动补全
  -- 4. 多模式支持：在插入模式、命令模式下启用，在终端模式禁用
  -- 5. 智能处理：避免在字符串、注释中的错误配对
  -- 相比传统方案，Mini Pairs 更轻量、更智能
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",  -- 所有插件加载完成后启用
    opts = {
      -- 启用自动配对的模式
      modes = {
        insert = true,      -- 插入模式：正常情况下都需要
        command = true,     -- 命令模式：在命令行输入时也可用
        terminal = false,   -- 终端模式：在终端中禁用（容易与终端程序冲突）
      },
      -- 跳过补全的字符集合：匹配这些字符时不自动补全
      -- %w 字母数字, %' 单引号, %" 双引号, %. 句号, %` 反引号, %$ 美元符
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- 跳过补全的 Tree-sitter 节点：在字符串节点中不进行配对
      skip_ts = { "string" },
      -- 避免不平衡配对：防止在未闭合的情况下重复插入
      skip_unbalanced = true,
      -- 特别处理 Markdown：支持 Markdown 代码块的配对
      markdown = true,
    },
    config = function(_, opts)
      -- 使用 LazyVim 的 mini.pairs 配置函数
      -- 这样可以确保与其他 LazyVim 功能兼容
      LazyVim.mini.pairs(opts)
    end,
  },

  -- Tree-sitter Comments 注释增强插件
  -- 基于语法树的智能注释插件，提供：
  -- 1. 精确注释识别：基于语言语法正确识别注释范围
  -- 2. 多语言支持：支持各种编程语言的注释语法
  -- 3. 智能取消注释：正确处理嵌套注释和块注释
  -- 4. 注释重排：支持注释行的重新格式化
  -- 5. 注释跳转：在注释和代码之间快速切换
  -- 相比传统基于正则表达式的注释插件，ts-comments 更准确
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},  -- 使用默认配置，大多数情况无需额外设置
  },

  -- Mini AI 智能文本对象插件
  -- 扩展 Neovim 的内置文本对象系统，提供：
  -- 1. 语法感知选择：基于语言语法选择代码块、函数、类等
  -- 2. 高级选择对象：数字、单词、缓冲区等更多文本对象
  -- 3. 重复操作支持：支持 . 命令重复操作
  -- 4. 自定义配置：可以定义特定语言的文本对象
  -- 5. 与 Tree-sitter 集成：深度集成语法树分析
  -- 传统的 a/i 操作符功能有限，Mini AI 大大扩展了选择能力
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        -- 最大处理行数：超过此行数的缓冲区将跳过处理（提升性能）
        n_lines = 500,

        -- 自定义文本对象定义：扩展默认的 a/i 操作符功能
        custom_textobjects = {
          -- o 对象：代码块（包含条件语句、循环语句等）
          o = ai.gen_spec.treesitter({
            -- outer 选择：包含整个代码块的完整结构
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            -- inner 选择：仅选择代码块内部内容
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),

          -- f 对象：函数相关
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),

          -- c 对象：类相关
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),

          -- t 对象：HTML-like 标签
          t = {
            -- 匹配开始标签：<tag> 或 <tag-name> 格式
            "<([%p%w]-)%f[^<%w][^<>]->.-</%1>",
            -- 匹配结束标签和内容：标签内的所有内容
            "^<.->().*()</[^/]->$"
          },

          -- d 对象：连续数字序列
          d = { "%f[%d]%d+" },

          -- e 对象：带大小写的单词
          e = {
            -- 匹配模式：识别不同格式的大小写字母组合
            {
              "%u[%l%d]+%f[^%l%d]",     -- 首字母大写，后面跟小写字母数字
              "%f[%S][%l%d]+%f[^%l%d]", -- 非空白字符开头，后跟小写字母数字
              "%f[%P][%l%d]+%f[^%l%d]", -- 标点符号开头，后跟小写字母数字
              "^[%l%d]+%f[^%l%d]"       -- 数字开头，后跟非小写字符
            },
            "^().*()$",  -- 通用匹配模式
          },

          -- g 对象：整个缓冲区
          g = LazyVim.mini.ai_buffer,

          -- u 对象：通用函数调用
          u = ai.gen_spec.function_call(),
          -- U 对象：严格的函数调用（禁止函数名包含点）
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,

    config = function(_, opts)
      -- 设置 Mini AI 插件
      require("mini.ai").setup(opts)

      -- 与 which-key 集成：在 which-key 中显示文本对象映射
      LazyVim.on_load("which-key.nvim", function()
        vim.schedule(function()
          LazyVim.mini.ai_whichkey(opts)
        end)
      end)
    end,
  },

  -- LazyDev Lua 开发增强插件
  -- 为 Neovim 的 Lua 语言服务器（LuaLS）提供：
  -- 1. 类型定义补充：为 Neovim API、LazyVim、luv、snacks 等提供类型定义
  -- 2. 智能补全增强：更准确的 API 自动完成
  -- 3. 错误检查改进：更好的语法和类型错误检测
  -- 4. 项目感知：自动检测项目中使用的库并提供相应的类型支持
  -- 5. 实时更新：类型定义与库版本同步更新
  -- 这使得用 Lua 开发 Neovim 配置变得更加便捷和可靠
  {
    "folke/lazydev.nvim",
    ft = "lua",  -- 仅在 Lua 文件中启用
    cmd = "LazyDev",  -- 调试和配置命令
    opts = {
      -- 类型库配置：指定需要提供类型定义的项目/库
      library = {
        {
          path = "${3rd}/luv/library",  -- luv 库的类型定义路径（Windows/Linux/macOS 兼容）
          words = { "vim%.uv" }         -- 识别 vim.uv API
        },
        { path = "LazyVim", words = { "LazyVim" } },  -- LazyVim 框架类型定义
        { path = "snacks.nvim", words = { "Snacks" } },  -- Snacks 插件类型定义
        { path = "lazy.nvim", words = { "LazyVim" } },  -- lazy.nvim 类型定义
      },
    },
  },
}
