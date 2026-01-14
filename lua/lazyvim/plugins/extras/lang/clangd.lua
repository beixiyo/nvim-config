-- LazyVim C/C++ 语言支持完整配置
-- 该配置文件为 C/C++ 语言开发提供了完整的工具链支持，包括 LSP、代码分析、调试等

return {
  -- 推荐检查函数：验证当前项目是否为 C/C++ 项目
  -- 只有满足文件类型或根目录要求的项目才会加载此配置
  recommended = function()
    return LazyVim.extras.wants({
      -- 支持的 C/C++ 相关文件类型
      ft = {
        "c",        -- C 源文件
        "cpp",      -- C++ 源文件
        "objc",     -- Objective-C 源文件
        "objcpp",   -- Objective-C++ 源文件
        "cuda",     -- CUDA 源文件
        "proto",    -- Protocol Buffers 文件
      },

      -- C/C++ 项目根目录的标识文件（存在其中任一文件就认为是有意义的项目）
      root = {
        ".clangd",              -- Clangd 配置文件
        ".clang-tidy",          -- Clang-Tidy 检查配置文件
        ".clang-format",        -- Clang-Format 格式化配置文件
        "compile_commands.json", -- 编译数据库文件
        "compile_flags.txt",    -- 编译标志文件
        "configure.ac",         -- AutoTools 配置脚本
        "meson.build",          -- Meson 构建系统文件
        "build.ninja",          -- Ninja 构建系统文件
      },
    })
  end,

  -- 语法高亮和解析器配置
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "cpp" } },
    -- 自动安装 C++ 语言的 Tree-sitter 语法解析器
    -- cpp 解析器支持 C、C++、Objective-C 等语言
  },

  -- Clangd 扩展插件：提供增强的 C/C++ 开发功能
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,  -- 延迟加载，只在需要时加载
    config = function() end,  -- 空配置函数，扩展功能通过 opts 配置
    opts = {
      -- 内联提示配置
      inlay_hints = {
        inline = false,  -- 禁用内联提示，使用边框提示
      },

      -- 抽象语法树（AST）显示配置
      ast = {
        -- 角色图标配置（需要 codicons 字体：https://github.com/microsoft/vscode-codicons）
        role_icons = {
          type = "",                -- 类型声明图标
          declaration = "",         -- 声明图标
          expression = "",          -- 表达式图标
          specifier = "",           -- 说明符图标
          statement = "",           -- 语句图标
          ["template argument"] = "", -- 模板参数图标
        },

        -- 种类图标配置
        kind_icons = {
          Compound = "",             -- 复合类型
          Recovery = "",             -- 恢复节点
          TranslationUnit = "",      -- 翻译单元
          PackExpansion = "",        -- 包扩展
          TemplateTypeParm = "",     -- 模板类型参数
          TemplateTemplateParm = "", -- 模板模板参数
          TemplateParamObject = "",  -- 模板参数对象
        },
      },
    },
  },

  -- LSP 配置：正确设置 clangd 语言服务器 🚀
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- 确保 mason 安装 Clangd 服务器
        clangd = {
          -- 自定义键位映射
          keys = {
            { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "切换源文件/头文件 (C/C++)" },
          },

          -- 项目根目录标记（Clangd 用来查找项目根目录）
          root_markers = {
            "compile_commands.json",  -- 编译数据库文件
            "compile_flags.txt",      -- 编译标志文件
            "configure.ac",           -- AutoTools 配置脚本
            "Makefile",               -- Make 构建文件
            "configure.ac",           -- AutoTools 配置脚本
            "configure.in",           -- AutoTools 旧版配置脚本
            "config.h.in",            -- 配置头文件模板
            "meson.build",            -- Meson 构建文件
            "meson_options.txt",      -- Meson 选项文件
            "build.ninja",            -- Ninja 构建文件
            ".git",                   -- Git 版本控制目录
          },

          -- 服务器能力配置
          capabilities = {
            offsetEncoding = { "utf-16" },  -- 支持 UTF-16 偏移编码（处理大文件）
          },

          -- Clangd 命令行参数配置
          cmd = {
            "clangd",                               -- 启动 clangd
            "--background-index",                   -- 后台索引，提升性能
            "--clang-tidy",                         -- 启用 Clang-Tidy 检查
            "--header-insertion=iwyu",             -- 头文件插入使用 Include-What-You-Use
            "--completion-style=detailed",         -- 详细的补全风格
            "--function-arg-placeholders",         -- 函数参数占位符
            "--fallback-style=llvm",               -- 回退代码风格使用 LLVM
          },

          -- 初始化选项配置
          init_options = {
            usePlaceholders = true,                -- 使用函数参数占位符
            completeUnimported = true,             -- 补全未导入的符号
            clangdFileStatus = true,               -- 启用文件状态跟踪
          },
        },
      },
      -- Clangd 服务器启动后的特殊处理
      setup = {
        clangd = function(_, opts)
          -- 获取 clangd_extensions 插件的配置选项
          local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")

          -- 合并扩展插件和 LSP 服务器配置
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))

          return false  -- 返回 false 让其他设置函数继续执行
        end,
      },
    },
  },

  -- 代码补全配置：集成 clangd 扩展的补全评分器
  {
    "hrsh7th/nvim-cmp",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    opts = function(_, opts)
      -- 配置补全排序器
      opts.sorting = opts.sorting or {}
      opts.sorting.comparators = opts.sorting.comparators or {}

      -- 添加 clangd 扩展的补全评分比较器（优先显示）
      table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
    end,
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      -- Ensure C/C++ debugger is installed
      "mason-org/mason.nvim",
      optional = true,
      opts = { ensure_installed = { "codelldb" } },
    },
    opts = function()
      local dap = require("dap")
      if not dap.adapters["codelldb"] then
        require("dap").adapters["codelldb"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "codelldb",
            args = {
              "--port",
              "${port}",
            },
          },
        }
      end
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch file",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
          {
            type = "codelldb",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
