-- LazyVim Java 语言支持完整配置
-- 该配置文件为 Java 语言开发提供了完整的工具链支持，包括 LSP、调试、测试等

-- 与 lspconfig.configs.jdtls 中相同的文件类型定义，避免在模块加载时引入不必要的依赖
local java_filetypes = { "java" }  -- Java 文件类型列表

-- 工具函数：扩展或覆盖配置表，类似于 Plugin.opts 的工作方式
-- 这个函数提供了灵活的配置合并机制，支持函数式配置和表式配置
---@param config table 基础配置表
---@param custom function | table | nil 自定义配置，可以是函数或表
---@param ... any 函数式配置时传入的额外参数
local function extend_or_override(config, custom, ...)
  -- 如果自定义配置是函数，则调用函数处理基础配置
  if type(custom) == "function" then
    config = custom(config, ...) or config
  -- 如果自定义配置是表，则深度合并到基础配置
  elseif custom then
    config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
  end
  return config
end

return {
  -- 推荐检查函数：验证当前项目是否为 Java 项目
  -- 只有满足文件类型或根目录要求的项目才会加载此配置
  recommended = function()
    return LazyVim.extras.wants({
      ft = "java",  -- Java 文件类型

      -- Java 项目根目录的标识文件（存在其中任一文件就认为是有意义的项目）
      root = {
        "build.gradle",        -- Gradle 构建文件
        "build.gradle.kts",    -- Gradle Kotlin DSL 构建文件
        "build.xml",           -- Ant 构建文件
        "pom.xml",             -- Maven 项目描述文件
        "settings.gradle",     -- Gradle 设置文件
        "settings.gradle.kts", -- Gradle Kotlin DSL 设置文件
      },
    })
  end,

  -- 语法高亮和解析器配置
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
    -- 自动安装 Java 语言的 Tree-sitter 语法解析器
    -- 提供精确的 Java 语法高亮和代码结构理解
  },

  -- 确保 Java 调试器和测试包已安装
  {
    "mfussenegger/nvim-dap",
    optional = true,  -- 可选依赖，只在用户手动安装时启用
    opts = function()
      -- 简单配置：附加到远程 Java 调试进程
      -- 配置直接参考：https://github.com/mfussenegger/nvim-dap/wiki/Java
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",                    -- 调试器类型
          request = "attach",               -- 连接类型：附加到现有进程
          name = "Debug (Attach) - Remote", -- 配置名称
          hostName = "127.0.0.1",          -- 调试服务器地址
          port = 5005,                      -- 调试服务器端口（JDWP 默认端口）
        },
      }
    end,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
        -- java-debug-adapter：Java 调试适配器
        -- java-test：Java 测试运行器
      },
    },
  },

  -- 配置 nvim-lspconfig：通过 mason 自动安装服务器，但实际启动延迟到下面的 nvim-jdtls 配置
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 确保 mason 安装 Java 语言服务器
      servers = {
        jdtls = {},  -- JDTLS（Java Development Tools Language Server）配置
      },
      setup = {
        jdtls = function()
          return true -- 避免重复启动服务器，由 nvim-jdtls 管理
        end,
      },
    },
  },

  -- 配置 nvim-jdtls：附加到 Java 文件的完整 LSP 设置
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" },  -- which-key 依赖，用于键位提示
    ft = java_filetypes,  -- 只在 Java 文件类型时加载
    opts = function()
      -- 构建 JDTLS 命令行
      local cmd = { vim.fn.exepath("jdtls") }  -- 获取 JDTLS 可执行文件路径

      -- 如果安装了 mason，添加 Lombok 支持
      if LazyVim.has("mason.nvim") then
        local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
        table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
      end

      return {
        -- 项目根目录检测函数
        root_dir = function(path)
          return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
        end,

        -- 如何为给定的根目录查找项目名称
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,

        -- 项目的配置和 Workspace 目录位置
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
        end,

        -- 如何运行 JDTLS。如果 Python 包装脚本不够用，这里可以覆盖为完整的 Java 命令行
        cmd = cmd,  -- 基础命令
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)

          -- 如果有项目名称，添加项目特定的配置参数
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",     -- 指定配置文件目录
              opts.jdtls_config_dir(project_name),
              "-data",              -- 指定 Workspace 数据目录
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,

        -- 调试相关配置（依赖 nvim-dap，但可以通过设置为 false 来禁用）
        dap = { hotcodereplace = "auto", config_overrides = {} },
        -- 可以设置为 false 来禁用主类扫描，这在大型项目中是性能杀手
        dap_main = {},
        test = true,  -- 启用测试支持

        -- LSP 设置配置
        settings = {
          java = {
            inlayHints = {
              parameterNames = {
                enabled = "all",  -- 启用所有参数名称的提示
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      -- Find the extra bundles that should be passed on the jdtls command-line
      -- if nvim-dap is enabled with java debug/test.
      local bundles = {} ---@type string[]
      if LazyVim.has("mason.nvim") then
        local mason_registry = require("mason-registry")
        if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
          bundles = vim.fn.glob("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*jar", false, true)
          -- java-test also depends on java-debug-adapter.
          if opts.test and mason_registry.is_installed("java-test") then
            vim.list_extend(bundles, vim.fn.glob("$MASON/share/java-test/*.jar", false, true))
          end
        end
      end
      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          settings = opts.settings,
          -- enable CMP capabilities
          capabilities = LazyVim.has("blink.cmp") and require("blink.cmp").get_lsp_capabilities() or LazyVim.has(
            "cmp-nvim-lsp"
          ) and require("cmp_nvim_lsp").default_capabilities() or nil,
        }, opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = java_filetypes,
        callback = attach_jdtls,
      })

      -- Setup keymap and dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      -- https://neovim.io/doc/user/lsp.html#LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require("which-key")
            wk.add({
              {
                mode = "n",
                buffer = args.buf,
                { "<leader>cx", group = "extract" },
                { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
                { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
                { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
                { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
                { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
              },
            })
            wk.add({
              {
                mode = "x",
                buffer = args.buf,
                { "<leader>cx", group = "extract" },
                {
                  "<leader>cxm",
                  [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                  desc = "Extract Method",
                },
                {
                  "<leader>cxv",
                  [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                  desc = "Extract Variable",
                },
                {
                  "<leader>cxc",
                  [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                  desc = "Extract Constant",
                },
              },
            })

            if LazyVim.has("mason.nvim") then
              local mason_registry = require("mason-registry")
              if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
                -- custom init for Java debugger
                require("jdtls").setup_dap(opts.dap)
                if opts.dap_main then
                  require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
                end

                -- Java Test require Java debugger to work
                if opts.test and mason_registry.is_installed("java-test") then
                  -- custom keymaps for Java test runner (not yet compatible with neotest)
                  wk.add({
                    {
                      mode = "n",
                      buffer = args.buf,
                      { "<leader>t", group = "test" },
                      {
                        "<leader>tt",
                        function()
                          require("jdtls.dap").test_class({
                            config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                          })
                        end,
                        desc = "Run All Test",
                      },
                      {
                        "<leader>tr",
                        function()
                          require("jdtls.dap").test_nearest_method({
                            config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                          })
                        end,
                        desc = "Run Nearest Test",
                      },
                      { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
                    },
                  })
                end
              end
            end

            -- User can set additional keymaps in opts.on_attach
            if opts.on_attach then
              opts.on_attach(args)
            end
          end
        end,
      })

      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      attach_jdtls()
    end,
  },
}
