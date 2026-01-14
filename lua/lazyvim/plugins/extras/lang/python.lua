-- Python 语言支持的全局配置
-- 这些配置可以在用户自己的 init.lua 中覆盖
if lazyvim_docs then
  -- Python 语言服务器（LSP）配置
  -- 默认使用 "pyright" 作为 Python 的语言服务器
  -- 可以设置为 "basedpyright" 使用基于 pyright 的增强版本
  vim.g.lazyvim_python_lsp = "pyright"

  -- Ruff LSP 配置（代码格式化和检查）
  -- 使用新版 Ruff LSP 实现（推荐）
  -- 可以设置为 "ruff_lsp" 使用旧版 LSP 实现
  vim.g.lazyvim_python_ruff = "ruff"
end

-- 获取用户选择的 LSP 配置，默认使用 pyright
local lsp = vim.g.lazyvim_python_lsp or "pyright"
-- 获取用户选择的 Ruff 配置，默认使用 ruff（新版）
local ruff = vim.g.lazyvim_python_ruff or "ruff"

return {
  -- Python 语言支持推荐函数
  -- 这个函数决定在什么情况下应该启用 Python 支持
  -- 它会检查：
  -- 1. 文件类型是否为 Python
  -- 2. 项目根目录是否存在 Python 项目文件
  recommended = function()
    return LazyVim.extras.wants({
      -- 文件类型检查：只要打开 Python 文件就启用
      ft = "python",
      -- 项目根目录检查：存在这些文件表明这是有意义的 Python 项目
      root = {
        "pyproject.toml",       -- 现代 Python 项目配置文件（推荐）
        "setup.py",            -- 传统 Python 包配置文件
        "setup.cfg",           -- Python 项目配置文件
        "requirements.txt",    -- Python 依赖包列表
        "Pipfile",             -- Pipenv 依赖管理文件
        "pyrightconfig.json",  -- Pyright 配置文件
      },
    })
  end,
  -- Tree-sitter 语法高亮补充
  -- 为 Python 项目添加额外的语法解析器支持
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ninja", "rst" } },
    -- "ninja": Ninja 构建系统的语法解析器
    -- "rst": reStructuredText 文档格式的语法解析器
  },

  -- Python LSP 配置
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ruff LSP 服务器配置（新版 Ruff LSP）
        ruff = {
          -- 设置环境变量，启用详细的消息跟踪
          cmd_env = { RUFF_TRACE = "messages" },
          -- 初始化选项配置
          init_options = {
            settings = {
              logLevel = "error",  -- 只记录错误级别及以上的日志
            },
          },
          -- 按键映射：使用 LazyVim 的 LSP 动作
          keys = {
            {
              "<leader>co",  -- 整理 Python 导入语句
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports / 整理导入语句",
            },
          },
        },
        -- Ruff LSP 服务器配置（旧版实现）
        ruff_lsp = {
          -- 使用与 Ruff 相同的按键映射
          keys = {
            {
              "<leader>co",
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports / 整理导入语句",
            },
          },
        },
      },
      -- LSP 服务器特定设置
      setup = {
        -- Ruff LSP 的特殊设置
        [ruff] = function()
          Snacks.util.lsp.on({ name = ruff }, function(_, client)
            -- 禁用 Ruff 的 hover 功能，使用 Pyright 的 hover
            -- 这样可以避免两个 LSP 同时提供 hover 导致的冲突
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
  -- Python LSP 服务器动态启用
  -- 根据用户配置动态决定启用哪些 LSP 服务器
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- 需要处理的 LSP 服务器列表
      local servers = { "pyright", "basedpyright", "ruff", "ruff_lsp", ruff, lsp }
      -- 遍历服务器列表，只启用用户选择的服务器
      for _, server in ipairs(servers) do
        opts.servers[server] = opts.servers[server] or {}
        -- 只启用用户选择的 LSP 和 Ruff 服务器
        opts.servers[server].enabled = server == lsp or server == ruff
      end
    end,
  },

  -- Python 测试框架集成
  -- 使用 neotest 进行单元测试，提供：
  -- 1. 可视化测试界面：测试结果以符号和颜色显示
  -- 2. 测试调试：支持断点和单步调试
  -- 3. 测试过滤：可以运行单个测试、测试类或整个测试文件
  -- 4. 多种测试框架支持：pytest、unittest 等
  {
    "nvim-neotest/neotest",
    optional = true,  -- 可选组件，用户可以选择启用或禁用
    dependencies = {
      "nvim-neotest/neotest-python",  -- Python 特定的测试适配器
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- Python 测试适配器配置选项：
          -- runner = "pytest",        -- 使用 pytest 作为测试运行器（默认）
          -- python = ".venv/bin/python", -- 指定 Python 解释器路径
        },
      },
    },
  },
  -- Python 调试支持
  -- 使用 nvim-dap 提供 Python 代码调试功能：
  -- 1. 断点调试：在代码中设置断点，暂停执行
  -- 2. 变量检查：查看和修改变量值
  -- 3. 单步执行：逐行执行代码，跟踪执行流程
  -- 4. 调用栈：查看函数调用层次
  -- 5. 条件断点：只在满足条件时停止
  {
    "mfussenegger/nvim-dap",
    optional = true,  -- 可选组件
    dependencies = {
      "mfussenegger/nvim-dap-python",  -- Python 特定的调试适配器
      -- stylua: ignore
      keys = {
        -- 调试当前测试方法：在光标位置调试测试函数
        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method / 调试方法", ft = "python" },
        -- 调试当前测试类：调试整个测试类中的所有测试
        { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class / 调试类", ft = "python" },
      },
      -- 调试适配器配置
      config = function()
        -- 设置 Python 调试适配器（debugpy）
        require("dap-python").setup("debugpy-adapter")
      end,
    },
  },

  -- Python 虚拟环境选择器
  -- 提供便捷的 Python 虚拟环境管理功能：
  -- 1. 自动检测：扫描项目中的虚拟环境目录
  -- 2. 一键切换：快速切换不同的虚拟环境
  -- 3. 智能激活：在项目切换时自动激活正确的虚拟环境
  -- 4. 环境缓存：记住用户选择的虚拟环境
  -- 5. 通知提醒：在环境激活时显示通知
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",  -- 虚拟环境选择命令
    opts = {
      options = {
        notify_user_on_venv_activation = true,  -- 在激活虚拟环境时通知用户
      },
    },
    -- 在 Python 文件中自动配置并加载缓存的虚拟环境
    ft = "python",
    keys = {
      { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "选择虚拟环境", ft = "python" }
    },
  },

  -- Python 代码补全增强
  -- 为 Python 文件启用括号自动补全功能
  {
    "hrsh7th/nvim-cmp",
    optional = true,  -- 可选组件
    opts = function(_, opts)
      -- 确保 auto_brackets 表存在
      opts.auto_brackets = opts.auto_brackets or {}
      -- 为 Python 文件启用括号自动补全
      -- Python 中通常需要：()、[]、{}、""
      table.insert(opts.auto_brackets, "python")
    end,
  },

  -- DAP 适配器冲突避免
  -- 防止 nvim-dap-python 的调试适配器与 Mason-DAP 发生冲突
  -- 这确保调试功能能正常工作
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,  -- 可选组件
    opts = {
      handlers = {
        -- 对于 Python，不使用 Mason-DAP 的默认处理
        -- 避免与 nvim-dap-python 的调试配置冲突
        python = function() end,
      },
    },
  },
}
