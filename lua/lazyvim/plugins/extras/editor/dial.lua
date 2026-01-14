--- Dial 智能增量/减量模块
-- 提供基于上下文的智能增量/减量功能，支持数字、日期、布尔值等多种类型
local M = {}

--- 核心 Dial 函数：根据当前模式和数据类型执行增量/减量操作
---@param increment boolean true=增量操作，false=减量操作
---@param g? boolean true=全局操作（影响整个缓冲区），false=当前操作
---@return string 执行的操作序列（用于 expr 模式）
function M.dial(increment, g)
  --- 获取当前编辑模式
  local mode = vim.fn.mode(true)
  
  --- 判断是否为可视化模式：包括字符选择、行选择、块选择
  -- 可视化模式需要使用特殊命令来处理选中的文本
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  
  --- 构建Dial函数名：基于操作类型、范围和模式确定调用的函数
  -- 格式：[inc|dec] + [_g] + [visual|normal]
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  
  --- 根据文件类型确定Dial组：每种语言有不同的增量/减量规则
  local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
  
  --- 执行Dial操作：调用 Dial 映射表中的对应函数
  return require("dial.map")[func](group)
end

return {
  --- Dial 智能增量/减量插件
  -- 提供基于上下文的智能编辑功能，支持数字、日期、布尔值等多种数据类型的增量/减量操作
  "monaqa/dial.nvim",
  recommended = true,
  desc = "智能增量/减量插件 - 支持数字、日期、布尔值等多种类型的智能编辑",

  --- Dial 核心快捷键配置
  -- stylua: ignore
  keys = {
    -- Ctrl+A 增量：增加当前值（数字、字母、日期等）
    { "<C-a>", function() return M.dial(true) end, expr = true, desc = "增量操作", mode = {"n", "v"} },
    
    -- Ctrl+X 减量：减少当前值（数字、字母、日期等）  
    { "<C-x>", function() return M.dial(false) end, expr = true, desc = "减量操作", mode = {"n", "v"} },
    
    -- g+Ctrl+A 全局增量：影响整个缓冲区的同类值
    { "g<C-a>", function() return M.dial(true, true) end, expr = true, desc = "全局增量", mode = {"n", "x"} },
    
    -- g+Ctrl+X 全局减量：影响整个缓冲区的同类值
    { "g<C-x>", function() return M.dial(false, true) end, expr = true, desc = "全局减量", mode = {"n", "x"} },
  },
  --- Dial 配置选项函数
  -- 定义各种增量/减量的规则和分组
  opts = function()
    --- 获取Dial的增量子模块：包含各种内置的增量/减量规则
    local augend = require("dial.augend")

    --- 逻辑运算符别名：将 && 和 || 在增量/减量时循环切换
    local logical_alias = augend.constant.new({
      elements = { "&&", "||" },  -- 增量为 &&->||，减量为 ||->&&
      word = false,              -- 不要求完整的单词边界
      cyclic = true,             -- 循环切换：第一个和最后一个互转
    })

    --- 序数词：first 到 tenth 的循环切换
    local ordinal_numbers = augend.constant.new({
      -- 循环的元素列表：增量时顺序递减，减量时顺序递增
      elements = {
        "first",
        "second", 
        "third",
        "fourth",
        "fifth",
        "sixth",
        "seventh",
        "eighth", 
        "ninth",
        "tenth",
      },
      -- 如果为 true，只匹配完整的单词边界，例如 firstDate 不匹配
      word = false,
      -- 是否循环：tenth 增量回到 first，first 减量回到 tenth
      cyclic = true,
    })

    --- 星期名称：英文星期一到星期日的循环
    local weekdays = augend.constant.new({
      elements = {
        "Monday", "Tuesday", "Wednesday", "Thursday", 
        "Friday", "Saturday", "Sunday"
      },
      word = true,    -- 要求完整单词边界
      cyclic = true,  -- 循环切换
    })

    --- 月份名称：英文月份名称的循环
    local months = augend.constant.new({
      elements = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      },
      word = true,    -- 要求完整单词边界  
      cyclic = true,  -- 循环切换
    })

    --- 首字母大写的布尔值：True 和 False 的切换
    local capitalized_boolean = augend.constant.new({
      elements = {
        "True",  -- 首字母大写的布尔值
        "False",
      },
      word = true,    -- 要求完整单词边界
      cyclic = true,  -- 循环切换
    })

    --- 返回完整的Dial配置
    return {
      --- 文件类型到Dial组的映射：每种文件类型使用特定的Dial组
      dials_by_ft = {
        css = "css",              -- CSS 文件使用 CSS 规则
        vue = "vue",              -- Vue 文件使用 Vue 规则
        javascript = "typescript", -- JavaScript 使用 TypeScript 规则
        typescript = "typescript", -- TypeScript 使用 TypeScript 规则
        typescriptreact = "typescript", -- TypeScript React 使用 TypeScript 规则
        javascriptreact = "typescript", -- JavaScript React 使用 TypeScript 规则
        json = "json",            -- JSON 文件使用 JSON 规则
        lua = "lua",              -- Lua 文件使用 Lua 规则
        markdown = "markdown",    -- Markdown 文件使用 Markdown 规则
        sass = "css",             -- Sass 使用 CSS 规则
        scss = "css",             -- SCSS 使用 CSS 规则
        python = "python",        -- Python 文件使用 Python 规则
      },
      --- Dial 组配置：定义各种文件类型和场景的增量/减量规则
      groups = {
        --- 默认组：所有文件类型都包含的基础规则
        default = {
          augend.integer.alias.decimal,        -- 非负十进制整数 (0, 1, 2, 3, ...)
          augend.integer.alias.decimal_int,    -- 十进制整数（正数和负数）
          augend.integer.alias.hex,            -- 十六进制数 (0x01, 0x1a1f, 等等)
          augend.date.alias["%Y/%m/%d"],       -- 日期格式 (2022/02/19, 等等)
          ordinal_numbers,                     -- 序数词：first -> second -> third
          weekdays,                            -- 星期：Monday -> Tuesday -> Wednesday
          months,                              -- 月份：January -> February -> March
          capitalized_boolean,                 -- 首字母大写布尔值：True -> False
          augend.constant.alias.bool,          -- 小写布尔值：true -> false
          logical_alias,                       -- 逻辑运算符：&& -> ||
        },
        
        --- Vue 组：Vue.js 特定规则
        vue = {
          -- Vue 变量声明：let 和 const 循环切换
          augend.constant.new({ elements = { "let", "const" } }),
          -- 十六进制颜色：小写
          augend.hexcolor.new({ case = "lower" }),
          -- 十六进制颜色：大写
          augend.hexcolor.new({ case = "upper" }),
        },
        
        --- TypeScript 组：TypeScript/JavaScript 特定规则
        typescript = {
          -- JavaScript 变量声明：let 和 const 循环切换
          augend.constant.new({ elements = { "let", "const" } }),
        },
        
        --- CSS 组：CSS 样式表规则
        css = {
          -- 十六进制颜色：小写表示
          augend.hexcolor.new({
            case = "lower",
          }),
          -- 十六进制颜色：大写表示
          augend.hexcolor.new({
            case = "upper",
          }),
        },
        
        --- Markdown 组：Markdown 文档规则
        markdown = {
          -- Markdown 复选框：未选中 -> 已选中
          augend.constant.new({
            elements = { "[ ]", "[x]" },
            word = false,    -- 不要求单词边界，[x] 匹配
            cyclic = true,   -- 循环切换
          }),
          -- Markdown 标题：# 到 ######
          augend.misc.alias.markdown_header,
        },
        
        --- JSON 组：JSON 格式规则
        json = {
          -- 语义化版本号：v1.0.0 -> v1.0.1 -> v1.1.0
          augend.semver.alias.semver,
        },
        
        --- Lua 组：Lua 语言特定规则
        lua = {
          -- Lua 逻辑运算符：小写版本
          augend.constant.new({
            elements = { "and", "or" },
            word = true,   -- 要求完整单词边界：避免 "sand" 变成 "sor"
            cyclic = true, -- "or" 增量变为 "and"
          }),
        },
        
        --- Python 组：Python 语言特定规则
        python = {
          -- Python 逻辑运算符
          augend.constant.new({
            elements = { "and", "or" },
          }),
        },
      },
    }
  end,
  --- Dial 插件配置函数
  -- 设置 Dial 组的继承关系和全局变量
  config = function(_, opts)
    --- 将默认组的规则复制到其他组
    -- 确保每个特定组都包含基础规则，避免重复定义
    for name, group in pairs(opts.groups) do
      if name ~= "default" then
        vim.list_extend(group, opts.groups.default)
      end
    end
    
    --- 注册所有 Dial 组到 Dial 配置系统
    -- 这使得 Dial 插件能够根据文件类型选择合适的增量/减量规则
    require("dial.config").augends:register_group(opts.groups)
    
    --- 设置全局文件类型映射变量
    -- 用于 Dial 核心函数根据当前文件类型确定使用的规则组
    vim.g.dials_by_ft = opts.dials_by_ft
  end,
}
