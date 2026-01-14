--- LazyVim Mini 插件工具函数集合
-- 该模块包含了Mini插件系列的实用工具函数，用于增强编辑体验
--@class lazyvim.util.mini
local M = {}

-- 从 MiniExtra.gen_ai_spec.buffer 移植而来
-- 获取缓冲区的文本对象范围，用于AI文本对象选择
--@param ai_type string AI文本对象类型，支持 'i'(内部)、'a'(周围)等类型
function M.ai_buffer(ai_type)
  -- 设置缓冲区范围：默认为整个缓冲区（从第1行到最后一行）
  local start_line, end_line = 1, vim.fn.line("$")
  
  -- 如果是内部文本对象类型（i），需要跳过首尾的空白行
  if ai_type == "i" then
    -- 跳过头部和尾部的空白行，只保留有效内容
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    
    -- 如果整个缓冲区都是空白行，返回起始位置
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    
    -- 更新选择范围为有效内容的行范围
    start_line, end_line = first_nonblank, last_nonblank
  end

  -- 计算结束位置的列数（确保至少为1）
  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  
  -- 返回文本对象的选择范围
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- 将所有Mini AI文本对象注册到which-key，提供智能键位提示
-- 这使得用户可以通过which-key看到所有可用的文本对象快捷键
--@param opts table 配置选项，包含文本对象映射关系
function M.ai_whichkey(opts)
  -- 定义所有支持的文本对象类型及其描述
  -- 每个文本对象都有特定的用途和选择范围
  local objects = {
    { " ", desc = "空白字符" },           -- 选择空白字符和空格
    { '"', desc = '" 字符串' },         -- 选择双引号字符串
    { "'", desc = "' 字符串" },         -- 选择单引号字符串
    { "(", desc = "() 代码块" },        -- 选择圆括号包围的代码块
    { ")", desc = "() 带空白" },        -- 选择圆括号及其周围的空白
    { "<", desc = "<> 代码块" },        -- 选择尖括号包围的代码块（如泛型）
    { ">", desc = "<> 带空白" },        -- 选择尖括号及其周围的空白
    { "?", desc = "用户提示" },          -- 选择用户输入提示
    { "U", desc = "调用/使用(无点)" },   -- 选择函数调用或模块使用（不包含点操作符）
    { "[", desc = "[] 代码块" },        -- 选择方括号包围的代码块
    { "]", desc = "[] 带空白" },        -- 选择方括号及其周围的空白
    { "_", desc = "下划线" },           -- 选择下划线分隔的单词
    { "`", desc = "` 字符串" },          -- 选择反引号字符串（markdown代码）
    { "a", desc = "参数" },              -- 选择函数参数
    { "b", desc = ")]}" },            -- 选择圆方花括号包围的代码块
    { "c", desc = "类" },                -- 选择类定义
    { "d", desc = "数字" },              -- 选择数字或数字序列
    { "e", desc = "驼峰/蛇形" },         -- 选择驼峰命名或蛇形命名单词
    { "f", desc = "函数" },              -- 选择函数定义或调用
    { "g", desc = "整个文件" },          -- 选择整个缓冲区内容
    { "i", desc = "缩进" },              -- 选择相同缩进级别的代码块
    { "o", desc = "代码块" },            -- 选择代码块（if、for、while等）
    { "q", desc = "引号" },              -- 选择各种引号包围的内容
    { "t", desc = "标签" },              -- 选择HTML/XML标签
    { "u", desc = "调用/使用" },         -- 选择函数调用或模块使用
    { "{", desc = "{} 代码块" },        -- 选择花括号包围的代码块
    { "}", desc = "{} 带空白" },        -- 选择花括号及其周围的空白
  }

  -- 创建which-key配置规范，支持操作符等待模式(o)和可视模式(x)
  ---@type wk.Spec[]
  local ret = { mode = { "o", "x" } }
  
  -- 定义文本对象的映射关系
  ---@type table<string, string>
  local mappings = vim.tbl_extend("force", {}, {
    around = "a",         -- 包围选择模式
    inside = "i",         -- 内部选择模式
    around_next = "an",   -- 下一个包围选择
    inside_next = "in",   -- 下一个内部选择
    around_last = "al",   -- 上一个包围选择
    inside_last = "il",   -- 上一个内部选择
  }, opts.mappings or {})
  
  -- 移除不需要的导航键位映射
  mappings.goto_left = nil
  mappings.goto_right = nil

  -- 为每种文本对象类型生成which-key注册信息
  for name, prefix in pairs(mappings) do
    -- 清理模式名称前缀
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    
    -- 添加文本对象分组到注册列表
    ret[#ret + 1] = { prefix, group = name }
    
    -- 为每个具体的文本对象创建键位映射
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      
      -- 如果是内部选择模式，移除"with ws"描述
      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end
      
      -- 添加文本对象键位到注册列表
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end
  
  -- 将所有文本对象注册到which-key，启用智能提示但不显示通知
  require("which-key").add(ret, { notify = false })
end

-- 配置MiniPairs插件，提供智能括号/引号配对功能
-- 该函数设置插件并增强其智能配对能力，包括跳过特定字符和markdown支持
--@param opts table 配置选项
-- - skip_next: 需要跳过的下一个字符（防止不必要的配对）
-- - skip_ts: 需要跳过的treesitter捕获类型列表
-- - skip_unbalanced: 是否跳过不平衡的括号
-- - markdown: 是否启用markdown特殊支持
function M.pairs(opts)
  -- 创建MiniPairs插件的快速切换键位
  Snacks.toggle({
    name = "Mini Pairs",
    get = function()
      return not vim.g.minipairs_disable
    end,
    set = function(state)
      vim.g.minipairs_disable = not state
    end,
  }):map("<leader>up")

  -- 加载MiniPairs插件并应用配置
  local pairs = require("mini.pairs")
  pairs.setup(opts)
  
  -- 保存原始的open函数以便后续调用
  local open = pairs.open
  
  -- 重写open函数以添加智能配对逻辑
  pairs.open = function(pair, neigh_pattern)
    -- 如果在命令模式下，使用原始的open函数
    if vim.fn.getcmdline() ~= "" then
      return open(pair, neigh_pattern)
    end
    
    -- 提取配对字符：o为开始字符，c为结束字符
    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    
    -- 获取光标后的下一个字符和光标前的内容
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])
    
    -- Markdown特殊支持：在markdown中输入```时自动创建代码块
    if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    end
    
    -- 如果下一个字符需要跳过，只输入开始字符
    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
      return o
    end
    
    -- 基于treesitter语法检查是否需要跳过
    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then
          return o
        end
      end
    end
    
    -- 检查括号是否不平衡，如果是则只输入开始字符
    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then
        return o
      end
    end
    
    -- 使用原始的配对函数
    return open(pair, neigh_pattern)
  end
end

return M
