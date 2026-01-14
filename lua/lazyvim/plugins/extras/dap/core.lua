--- 获取并处理调试器的启动参数
--- 这个函数用于处理不同类型调试器的参数配置，支持动态输入参数
---@param config {type?:string, args?:string[]|fun():string[]?}
---@return table 配置对象，包含处理后的参数函数
local function get_args(config)
  -- 从配置中提取参数，支持两种格式：
  -- 1. 函数类型：在需要时动态生成参数
  -- 2. 数组类型：预设的静态参数列表
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  
  -- 将参数数组转换为字符串，用于显示和编辑
  local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

  -- 深拷贝配置对象，避免修改原始配置
  config = vim.deepcopy(config)
  ---@cast args string[]
  
  -- 重写参数函数，支持运行时动态输入
  config.args = function()
    -- 显示输入提示，默认显示当前参数
    local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
    
    -- Java调试器特殊处理：直接返回字符串，不需要分割
    if config.type and config.type == "java" then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    
    -- 其他语言：按空格分割参数字符串
    return require("dap.utils").splitstr(new_args)
  end
  return config
end

return {
  {
    --- 核心调试适配器协议（DAP）插件
    "mfussenegger/nvim-dap",
    recommended = true,
    desc = "调试功能支持。需要在语言扩展中配置特定语言调试器（参见 lang 扩展）",

    --- 调试功能依赖项
    dependencies = {
      "rcarriga/nvim-dap-ui", -- 调试器的图形化用户界面，提供变量查看、堆栈跟踪等功能
      
      --- 虚拟文本调试插件：在代码行上显示调试信息
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {}, -- 使用默认配置，在代码行显示变量值、类型等调试信息
      },
    },

    --- 调试相关快捷键映射（全部使用 <leader>d 前缀）
    -- stylua: ignore
    keys = {
      -- 设置条件断点：可以在断点时执行条件表达式
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "条件断点" },
      
      -- 切换普通断点：在当前行添加/删除断点
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "切换断点" },
      
      -- 开始调试/继续执行：启动调试会话或从暂停处继续执行
      { "<leader>dc", function() require("dap").continue() end, desc = "运行/继续" },
      
      -- 带参数运行：支持动态输入命令行参数后启动调试
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "带参数运行" },
      
      -- 运行到光标处：在光标位置设置临时断点并继续执行
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "运行到光标" },
      
      -- 跳转到指定行：设置光标到指定行，但不执行中间代码
      { "<leader>dg", function() require("dap").goto_() end, desc = "跳转行（不执行）" },
      
      -- 单步进入：进入函数内部调试（Step Into）
      { "<leader>di", function() require("dap").step_into() end, desc = "单步进入" },
      
      -- 向下移动：向下执行一行代码（Step Down）
      { "<leader>dj", function() require("dap").down() end, desc = "向下执行" },
      
      -- 向上移动：向上执行一行代码（Step Up）
      { "<leader>dk", function() require("dap").up() end, desc = "向上执行" },
      
      -- 重新运行最后一次调试配置：重复之前的调试会话
      { "<leader>dl", function() require("dap").run_last() end, desc = "重新运行" },
      
      -- 单步跳出：从当前函数跳出到调用点（Step Out）
      { "<leader>do", function() require("dap").step_out() end, desc = "单步跳出" },
      
      -- 单步跳过：跳过当前行代码，不进入函数内部（Step Over）
      { "<leader>dO", function() require("dap").step_over() end, desc = "单步跳过" },
      
      -- 暂停执行：暂停当前正在运行的调试会话
      { "<leader>dP", function() require("dap").pause() end, desc = "暂停调试" },
      
      -- 切换调试REPL：打开/关闭调试器的交互式命令行界面
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "切换REPL" },
      
      -- 查看调试会话：显示当前调试会话的详细信息
      { "<leader>ds", function() require("dap").session() end, desc = "会话信息" },
      
      -- 终止调试：结束当前的调试会话
      { "<leader>dt", function() require("dap").terminate() end, desc = "终止调试" },
      
      -- 显示调试窗口：在浮动窗口中显示变量值、堆栈、监视表达式等
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "调试窗口" },
    },

    --- DAP调试器的初始化配置
    config = function()
      --- 延迟加载 mason-nvim-dap：在所有调试适配器设置完成后加载
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      --- 设置调试停止行的高亮样式
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      --- 定义调试相关的视觉符号：断点、执行位置等状态指示符
      for name, sign in pairs(LazyVim.config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      --- 配置 VS Code 格式的 launch.json 文件支持
      -- 这使得 LazyVim 可以直接使用 VS Code 的调试配置文件
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
  },

  --- 调试器的图形化用户界面插件
  -- 提供丰富的调试可视化界面，包括变量窗口、调用堆栈、控制台等
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" }, -- 异步IO支持，UI更新的必要依赖
    
    --- DAP UI界面相关快捷键
    -- stylua: ignore
    keys = {
      -- 切换调试UI界面：打开/关闭调试器专用界面
      { "<leader>du", function() require("dapui").toggle({ }) end, desc = "调试UI" },
      
      -- 表达式求值：在当前位置或选择区域执行代码表达式求值
      { "<leader>de", function() require("dapui").eval() end, desc = "表达式求值", mode = {"n", "x"} },
    },
    opts = {}, -- 使用默认配置：浮动窗口布局、合适的窗口尺寸等
    
    --- DAP UI的初始化配置
    config = function(_, opts)
      local dap = require("dap")      -- 获取DAP核心模块
      local dapui = require("dapui")  -- 获取UI模块
      
      --- 初始化UI组件：使用默认选项配置所有UI面板
      dapui.setup(opts)
      
      --- 自动打开UI：当调试会话初始化完成后自动显示UI界面
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      
      --- 自动关闭UI：当调试会话正常结束时自动关闭UI界面
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      
      --- 自动关闭UI：当调试会话异常退出时自动关闭UI界面
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },

  --- Mason调试器管理器集成
  -- 自动安装和配置各种语言调试器，与mason.nvim插件无缝集成
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim", -- 依赖Mason包管理器来管理调试器
    cmd = { "DapInstall", "DapUninstall" }, -- 手动安装/卸载调试器的命令
    
    --- Mason-DAP配置选项
    opts = {
      --- 自动安装：自动安装和配置所有检测到的调试器适配器
      -- 当检测到项目包含特定语言文件时，自动安装对应调试器
      automatic_installation = true,

      --- 自定义处理程序：为不同调试器提供特定配置
      -- 可以针对特定调试器进行自定义配置，详见mason-nvim-dap README
      handlers = {},

      --- 强制安装列表：确保指定的调试器始终已安装
      -- 根据项目需求添加需要支持的编程语言调试器
      -- 示例：ensure_installed = { "python", "node", "go" }
      ensure_installed = {
        -- 留空表示自动检测，根据项目文件类型安装相应调试器
        -- 用户可以手动添加需要的调试器名称
      },
    },
    
    --- Mason-DAP配置函数
    -- 当nvim-dap加载时会自动加载此配置，无需额外设置
    config = function() end,
  },
}
