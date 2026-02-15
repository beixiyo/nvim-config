---@class Palette
local ret = {
  -- 基础颜色 (使用 pretty_dark 的颜色)
  bg = "#191815",
  bg_dark = "#181818",
  bg_dark1 = "#191815",
  bg_highlight = "#23262c",
  blue = "#4aa5f0",           -- 函数颜色
  blue0 = "#4aa5f0",
  blue1 = "#4dc4ff",          -- 亮蓝色
  blue2 = "#4aa5f0",
  blue5 = "#4dc4ff",
  blue6 = "#4dc4ff",
  blue7 = "#4aa5f0",
  comment = "#7f848e",         -- 注释颜色
  cyan = "#42b3c2",           -- 青色
  dark3 = "#3f4451",          -- 深灰色
  dark5 = "#7f848e",          -- 灰色
  fg = "#c2c2c2",             -- 前景色
  fg_dark = "#c2c2c2",
  fg_gutter = "#495162",      -- 行号颜色
  green = "#98c379",          -- 字符串颜色
  green1 = "#8cc265",         -- 绿色
  green2 = "#a5e075",         -- 亮绿色
  magenta = "#c678dd",        -- 关键字颜色 (emphasis)
  magenta2 = "#de73ff",       -- 亮紫色
  orange = "#d19a66",         -- 常量/数字颜色
  purple = "#c678dd",         -- 紫色 (同 magenta)
  red = "#e05561",            -- 红色
  red1 = "#c24038",           -- 深红色
  teal = "#42b3c2",           -- 青色 (同 cyan)
  terminal_black = "#191815",
  yellow = "#d18f52",         -- 黄色
  git = {
    add = "#a5e075",          -- Git 添加
    change = "#e5c07b",       -- Git 更改
    delete = "#ff616e",       -- Git 删除
  },
  -- pretty_dark 特有的颜色映射
  type = "#4ec9b0",           -- 类型颜色
  property = "#e06c75",       -- 属性颜色
  variable = "#e06c75",       -- 变量颜色
  constant = "#d19a66",       -- 常量颜色
  string_escape = "#56b6c2",  -- 字符串转义
  operator = "#c2c2c2",       -- 操作符
  punctuation = "#c2c2c2",    -- 标点符号
}
return ret
