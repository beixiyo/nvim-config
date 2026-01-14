return {
  recommended = true,
  desc = "Neotest测试框架支持。需要在语言扩展中配置特定语言测试适配器（参见 lang 扩展）",
  
  --- 核心Neotest测试框架插件
  -- 提供统一的测试运行接口，支持多种编程语言和测试框架
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/nvim-nio" }, -- 异步IO支持，测试输出的必要依赖
    
    --- Neotest配置选项
    opts = {
      --- 测试适配器配置：支持多种配置格式
      -- 1. 适配器列表：直接提供适配器实例
      -- 2. 适配器名称列表：按名称自动加载适配器
      -- 3. 名称配置映射：按名称加载并配置适配器
      adapters = {},
      
      --- Go语言测试适配器配置示例：
      -- 演示如何为特定语言配置测试适配器，包含详细参数
      -- adapters = {
      --   ["neotest-golang"] = {
      --     go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" }, -- Go测试参数
      --     dap_go_enabled = true, -- 启用Go语言调试集成
      --   },
      -- },
      
      --- 测试状态显示：在代码行显示虚拟文本（测试通过/失败状态）
      status = { virtual_text = true },
      
      --- 测试输出：运行测试时自动打开输出窗口
      output = { open_on_run = true },
      
      --- 快速修复窗口：测试失败时显示错误列表的窗口
      quickfix = {
        --- 打开快速修复窗口的逻辑
        open = function()
          if LazyVim.has("trouble.nvim") then
            -- 如果安装了trouble插件，使用trouble窗口显示测试结果
            require("trouble").open({ mode = "quickfix", focus = false })
          else
            -- 否则使用Neovim内置的快速修复窗口
            vim.cmd("copen")
          end
        end,
      },
    },
    
    --- Neotest初始化配置
    config = function(_, opts)
      --- 创建Neotest专用命名空间，用于隔离测试相关的诊断信息
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      
      --- 配置虚拟文本格式：优化测试诊断信息的显示格式
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- 压缩诊断信息：将换行符和制表符替换为空格，合并多个空格
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      --- 配置Trouble集成：测试完成后自动刷新和关闭结果窗口
      if LazyVim.has("trouble.nvim") then
        opts.consumers = opts.consumers or {}
        
        --- Trouble消费者：处理测试结果并自动管理Trouble窗口
        ---@type neotest.Consumer
        opts.consumers.trouble = function(client)
          client.listeners.results = function(adapter_id, results, partial)
            -- 如果是部分结果则跳过
            if partial then
              return
            end
            
            -- 获取测试结果树结构
            local tree = assert(client:get_position(nil, { adapter = adapter_id }))

            -- 统计失败的测试数量
            local failed = 0
            for pos_id, result in pairs(results) do
              if result.status == "failed" and tree:get_key(pos_id) then
                failed = failed + 1
              end
            end
            
            --- 异步更新Trouble窗口
            vim.schedule(function()
              local trouble = require("trouble")
              if trouble.is_open() then
                trouble.refresh()
                -- 如果所有测试都通过，自动关闭Trouble窗口
                if failed == 0 then
                  trouble.close()
                end
              end
            end)
            return {}
          end
        end
      end

      --- 适配器加载和配置逻辑
      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            -- 数字索引：直接使用配置作为适配器
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            -- 名称索引：按名称加载适配器
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              
              -- 根据适配器类型选择配置方法
              if adapter.setup then
                adapter.setup(config)
              elseif adapter.adapter then
                adapter.adapter(config)
                adapter = adapter.adapter
              elseif meta and meta.__call then
                adapter = adapter(config)
              else
                error("适配器 " .. name .. " 不支持配置")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      --- 最终设置Neotest：使用处理后的选项初始化
      require("neotest").setup(opts)
    end,
    
    --- 测试相关快捷键映射（全部使用 <leader>t 前缀）
    -- stylua: ignore
    keys = {
      { "<leader>t", "", desc = "+测试" }, -- 测试主前缀
      
      -- 附加到测试：连接到正在运行的测试进程
      { "<leader>ta", function() require("neotest").run.attach() end, desc = "附加到测试 (Neotest)" },
      
      -- 运行文件测试：运行当前文件的所有测试
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "运行文件测试 (Neotest)" },
      
      -- 运行所有测试文件：运行当前工作目录下的所有测试文件
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "运行所有测试文件 (Neotest)" },
      
      -- 运行最近测试：在光标位置的测试（函数/测试用例级别）
      { "<leader>tr", function() require("neotest").run.run() end, desc = "运行最近测试 (Neotest)" },
      
      -- 重新运行最后一次测试：重复之前的测试运行
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "重新运行测试 (Neotest)" },
      
      -- 切换测试摘要：显示/隐藏测试运行结果摘要窗口
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "切换测试摘要 (Neotest)" },
      
      -- 显示测试输出：打开测试运行输出的详细窗口
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "显示测试输出 (Neotest)" },
      
      -- 切换输出面板：打开/关闭测试输出面板（底部固定窗口）
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "切换输出面板 (Neotest)" },
      
      -- 停止测试：停止当前正在运行的测试进程
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "停止测试 (Neotest)" },
      
      -- 切换测试监视：在文件变化时自动重新运行相关测试
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "切换测试监视 (Neotest)" },
    },
  },

  --- 测试调试集成
  -- 提供测试框架与调试器的集成支持，可选依赖
  {
    "mfussenegger/nvim-dap",
    optional = true, -- 可选依赖：如果未安装DAP则不会加载此配置
    
    --- 测试调试快捷键
    -- stylua: ignore
    keys = {
      -- 调试最近测试：使用调试模式运行当前光标位置的测试
      { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, desc = "调试最近测试" },
    },
  },
}
