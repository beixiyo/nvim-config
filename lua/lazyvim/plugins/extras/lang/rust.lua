-- LazyVim Rust 语言支持配置
-- 该配置文件为 Rust 语言开发提供了完整的工具链支持，包括 LSP、调试、测试等

-- 文档模式下的配置：设置 Rust 语言的诊断服务器
if lazyvim_docs then
  -- Rust 语言服务器选择配置
  -- 默认使用 rust-analyzer（推荐）
  -- 可设置为 "bacon-ls" 使用 bacon-ls 替代 rust-analyzer 进行诊断
  -- 注意：bacon-ls 只提供诊断功能，其他 LSP 功能仍由 rust-analyzer 提供
  vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
end

-- 获取当前配置的诊断服务器（默认为 rust-analyzer）
local diagnostics = vim.g.lazyvim_rust_diagnostics or "rust-analyzer"

return {
  -- 推荐检查函数：验证当前项目是否为 Rust 项目
  -- 只有满足文件类型或根目录要求的项目才会加载此配置
  recommended = function()
    return LazyVim.extras.wants({
      ft = "rust",                           -- Rust 文件类型
      root = { "Cargo.toml", "rust-project.json" },  -- Rust 项目根目录标识文件
    })
  end,

  -- Cargo.toml LSP 支持：为 Rust 依赖管理提供智能补全和功能
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },  -- 在读取 Cargo.toml 文件时加载
    opts = {
      -- 补全功能配置
      completion = {
        crates = {
          enabled = true,  -- 启用 crate 补全，显示可用的 crates.io 包
        },
      },
      -- LSP 功能配置
      lsp = {
        enabled = true,     -- 启用 LSP 支持
        actions = true,     -- 启用代码操作（更新依赖版本等）
        completion = true,  -- 启用补全功能
        hover = true,       -- 启用悬停提示（显示 crate 信息）
      },
    },
  },

  -- 语法高亮和解析器配置
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "rust", "ron" } },
    -- 自动安装 Rust 语言相关的 Tree-sitter 语法解析器
    -- rust：Rust 主语言语法解析器
    -- ron：Rust Object Notation 格式解析器（用于配置文件）
  },

  -- 确保 Rust 调试器已安装：通过 mason 自动安装必要的 Rust 开发工具
  {
    "mason-org/mason.nvim",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    opts = function(_, opts)
      -- 扩展现有的安装列表，添加 Rust 相关工具
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb" })  -- LLDB 调试器适配器
      
      -- 如果使用 bacon-ls 作为诊断服务器，也安装 bacon
      if diagnostics == "bacon-ls" then
        vim.list_extend(opts.ensure_installed, { "bacon" })  -- Bacon 诊断工具
      end
    end,
  },

  -- Rust LSP 和调试配置：rustaceanvim 提供完整的 Rust 开发支持
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },  -- 只在 Rust 文件类型时加载
    opts = {
      -- LSP 服务器配置
      server = {
        -- LSP 客户端附加时的回调函数，设置自定义键位映射
        on_attach = function(_, bufnr)
          -- Rust 代码操作快捷键（<leader>cR）
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          
          -- Rust 可调试项目快捷键（<leader>dr）
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        
        -- 默认 LSP 设置配置
        default_settings = {
          -- rust-analyzer 语言服务器配置
          ["rust-analyzer"] = {
            -- Cargo 项目配置
            cargo = {
              allFeatures = true,                    -- 启用所有 features（功能特性）
              loadOutDirsFromCheck = true,           -- 从 cargo check 加载外部文档
              buildScripts = { enable = true },      -- 启用构建脚本支持
            },
            
            -- 静态检查配置
            checkOnSave = diagnostics == "rust-analyzer",  -- 保存时运行检查
            
            -- 诊断配置
            diagnostics = {
              enable = diagnostics == "rust-analyzer",     -- 启用诊断功能
            },
            
            -- 过程宏配置
            procMacro = { enable = true },                  -- 启用过程宏支持
            
            -- 文件系统配置
            files = {
              -- 排除的目录列表，避免不必要的扫描
              exclude = {
                ".direnv", ".git", ".jj",          -- 版本控制系统目录
                ".github", ".gitlab",              -- 代码托管平台目录
                "bin",                              -- 二进制文件目录
                "node_modules",                     -- Node.js 依赖目录
                "target",                           -- Rust 构建输出目录
                "venv", ".venv",                    -- Python 虚拟环境
              },
              
              -- 使用客户端文件观察器，避免根目录扫描卡顿
              -- 详情请参考：https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
              watcher = "client",
            },
          },
        },
      },
    },
    -- 配置函数：设置调试器和全局配置
    config = function(_, opts)
      -- 如果安装了 mason，设置调试器适配器
      if LazyVim.has("mason.nvim") then
        -- 获取 codelldb 可执行文件路径
        local codelldb = vim.fn.exepath("codelldb")
        
        -- 根据操作系统选择动态库扩展名
        local codelldb_lib_ext = io.popen("uname"):read("*l") == "Linux" and ".so" or ".dylib"
        
        -- 构建 LLDB 库路径（Linux 使用 .so，macOS 使用 .dylib）
        local library_path = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. codelldb_lib_ext)
        
        -- 配置调试适配器
        opts.dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
        }
      end
      
      -- 合并配置到全局变量，保留现有配置
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      
      -- 检查 rust-analyzer 是否已安装，如果没有则显示错误信息
      if vim.fn.executable("rust-analyzer") == 0 then
        LazyVim.error(
          "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
          { title = "rustaceanvim" }
        )
      end
    end,
  },

  -- LSP 配置：正确设置 Rust 语言的 LSP 服务器 🚀
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Bacon 语言服务器（仅用于诊断）
        bacon_ls = {
          enabled = diagnostics == "bacon-ls",  -- 根据配置决定是否启用
        },
        -- Rust Analyzer（主 LSP 服务器）
        rust_analyzer = { 
          enabled = false,  -- 由 rustaceanvim 插件管理，不通过 lspconfig 启用
        },
      },
    },
  },

  -- 测试框架集成：提供 Rust 测试支持
  {
    "nvim-neotest/neotest",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},  -- Rustaceanvim 的测试适配器，集成到 neotest 框架中
      },
    },
  },
}
