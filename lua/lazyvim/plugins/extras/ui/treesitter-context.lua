-- Tree-sitter Context: 显示当前代码上下文信息
-- 功能说明：
-- 1. 自动检测并显示当前光标位置所属的函数、类、方法等代码块
-- 2. 在窗口顶部显示当前代码的结构层次，帮助理解代码上下文
-- 3. 支持多种编程语言的语法解析和上下文识别
-- 4. 提供快捷键快速启用/禁用上下文显示功能
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "LazyFile",

  -- 插件配置选项
  opts = function()
    local tsc = require("treesitter-context")

    -- 创建Snacks切换开关：Tree-sitter Context
    Snacks.toggle({
      name = "Treesitter Context",        -- 切换开关名称
      get = tsc.enabled,                  -- 获取当前启用状态
      set = function(state)               -- 设置启用/禁用状态
        if state then
          tsc.enable()                    -- 启用Tree-sitter Context
        else
          tsc.disable()                   -- 禁用Tree-sitter Context
        end
      end,
    }):map("<leader>ut")                  -- 映射快捷键：<leader>ut

    -- 返回Tree-sitter Context配置
    return {
      mode = "cursor",                    -- 模式：光标模式，跟随光标移动
      max_lines = 3,                      -- 最大显示行数：最多显示3行上下文
    }
  end,
}
