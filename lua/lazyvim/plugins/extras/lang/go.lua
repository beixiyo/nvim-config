-- LazyVim Go 语言支持完整配置
-- 该配置文件为 Go 语言开发提供了完整的工具链支持，包括语法高亮、LSP、代码格式化、调试和测试等

return {
  -- 推荐检查函数：验证当前项目是否为 Go 项目
  -- 只有满足文件类型或根目录要求的项目才会加载此配置
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "go", "gomod", "gowork", "gotmpl" },  -- 支持的 Go 相关文件类型
      root = { "go.work", "go.mod" },              -- Go 项目根目录标识文件
    })
  end,
  -- 语法高亮和解析器配置
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "go", "gomod", "gowork", "gosum" } },
    -- 自动安装 Go 语言相关的 Tree-sitter 语法解析器
    -- 包括 Go 主语言、Go 模块、Go 工作空间和 Go 校验和文件
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- 启用 gofumpt 格式化工具：更严格的 Go 代码格式化
              gofumpt = true,
              
              -- 代码镜头配置：在代码中显示可执行的代码操作
              codelenses = {
                gc_details = false,          -- 不显示垃圾回收详情
                generate = true,             -- 显示 go:generate 命令
                regenerate_cgo = true,       -- 显示重新生成 cgo 的命令
                run_govulncheck = true,      -- 显示运行漏洞检查命令
                test = true,                 -- 显示运行测试命令
                tidy = true,                 -- 显示 go mod tidy 命令
                upgrade_dependency = true,   -- 显示依赖升级命令
                vendor = true,               -- 显示 vendor 命令
              },
              
              -- 代码提示配置：显示更多有用的代码信息
              hints = {
                assignVariableTypes = true,       -- 显示赋值变量类型
                compositeLiteralFields = true,    -- 显示复合字面量字段
                compositeLiteralTypes = true,     -- 显示复合字面量类型
                constantValues = true,            -- 显示常量值
                functionTypeParameters = true,    -- 显示函数类型参数
                parameterNames = true,            -- 显示参数名称
                rangeVariableTypes = true,        -- 显示范围变量类型
              },
              
              -- 代码分析配置：启用各种静态分析检查
              analyses = {
                nilness = true,      -- 检查 nil 值使用
                unusedparams = true, -- 检查未使用参数
                unusedwrite = true,  -- 检查写入但未读取的变量
                useany = true,       -- 建议使用 any 而不是 interface{}
              },
              
              -- 其他 LSP 功能配置
              usePlaceholders = true,           -- 在函数参数中使用占位符
              completeUnimported = true,        -- 补全未导入的包
              staticcheck = true,               -- 启用 Staticcheck 分析
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" }, -- 排除目录
              semanticTokens = true,            -- 启用语义令牌支持
            },
          },
        },
      },
      -- gopls 服务器启动后的特殊处理
      setup = {
        gopls = function(_, opts)
          -- 临时解决方案：gopls 不原生支持 semanticTokensProvider
          -- 详情请参考：https://github.com/golang/go/issues/54531#issuecomment-1464982242
          -- 这个解决方案确保语义令牌功能正常工作
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if not client.server_capabilities.semanticTokensProvider then
              -- 从客户端配置中获取语义令牌配置
              local semantic = client.config.capabilities.textDocument.semanticTokens
              -- 手动设置语义令牌提供者，支持完整和范围模式
              client.server_capabilities.semanticTokensProvider = {
                full = true,                                    -- 支持完整语义令牌
                legend = {
                  tokenTypes = semantic.tokenTypes,             -- 令牌类型映射
                  tokenModifiers = semantic.tokenModifiers,     -- 令牌修饰符映射
                },
                range = true,                                   -- 支持范围语义令牌
              }
            end
          end)
          -- 临时解决方案结束
        end,
      },
    },
  },
  -- 确保 Go 工具已安装：通过 mason 自动安装必要的 Go 开发工具
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "goimports", "gofumpt" } },
    -- goimports：自动导入 Go 包的工具
    -- gofumpt：更严格的 Go 代码格式化工具
  },
  -- 代码质量检查和格式化：集成 null-ls 提供额外的代码分析和格式化功能
  {
    "nvimtools/none-ls.nvim",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "gomodifytags", "impl" } },
        -- gomodifytags：自动管理结构体标签的工具
        -- impl：自动生成接口实现的方法
      },
    },
    opts = function(_, opts)
      local nls = require("null-ls")
      -- 扩展现有的 null-ls 源配置，添加 Go 特定的功能
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- 代码操作功能
        nls.builtins.code_actions.gomodifytags,  -- 结构体标签自动管理
        nls.builtins.code_actions.impl,          -- 接口实现方法自动生成
        
        -- 代码格式化功能
        nls.builtins.formatting.goimports,       -- 包导入整理和格式化
        nls.builtins.formatting.gofumpt,         -- 严格 Go 代码格式化
      })
    end,
  },
  -- 代码质量检查：集成 nvim-lint 提供实时的代码质量检查
  {
    "mfussenegger/nvim-lint",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "golangci-lint" } },
        -- golangci-lint：Go 语言最流行的代码质量检查工具
        -- 集成了多种静态分析工具，提供全面的代码质量检查
      },
    },
    opts = {
      linters_by_ft = {
        go = { "golangcilint" },  -- 为 Go 文件配置 golangci-lint 检查器
      },
    },
  },
  -- 代码格式化配置：集成 conform 提供统一的代码格式化解决方案
  {
    "stevearc/conform.nvim",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },  -- 为 Go 文件配置的格式化工具
        -- goimports：导入包整理 + 基本格式化
        -- gofumpt：更严格的 Go 代码格式化
      },
    },
  },
  -- 调试器配置：集成 nvim-dap 提供 Go 代码调试功能
  {
    "mfussenegger/nvim-dap",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "delve" } },
        -- delve：Go 语言的官方调试器，支持断点、变量检查、调用栈等功能
      },
      {
        "leoluz/nvim-dap-go",
        opts = {},  -- nvim-dap-go：为 Go 项目提供专门的调试配置
      },
    },
  },
  -- 测试框架集成：提供完整的 Go 测试支持
  {
    "nvim-neotest/neotest",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    dependencies = {
      "fredrikaverpil/neotest-golang",  -- Go 测试适配器，集成到 neotest 框架中
    },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          -- Go 测试参数配置示例（可根据需要取消注释和修改）：
          -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
          -- -v: 详细输出
          -- -race: 竞态条件检测
          -- -count=1: 禁用测试缓存
          -- -timeout=60s: 设置测试超时时间
          
          dap_go_enabled = true, -- 启用调试器集成（需要 leoluz/nvim-dap-go）
          -- 这允许直接在调试器中运行测试，提供更好的调试体验
        },
      },
    },
  },

  -- 文件类型图标配置：为 Go 相关文件提供美观的图标显示
  {
    "nvim-mini/mini.icons",
    opts = {
      -- 文件图标配置
      file = {
        [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },  -- Go 版本文件图标
      },
      -- 文件类型图标配置
      filetype = {
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },            -- Go 模板文件图标
      },
    },
  },
}
