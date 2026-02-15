local M = {}

-- 默认配置
M.defaults = {
  -- 主题样式
  style = "dark",
  
  -- 透明背景
  transparent = false,
  
  -- 终端颜色
  terminal_colors = true,
  
  -- 样式配置
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
  },
  
  -- 背景样式
  sidebars = "dark",
  floats = "dark",
  
  -- 调整不活跃窗口
  dim_inactive = false,
  
  -- 自定义颜色函数
  on_colors = nil,
  
  -- 自定义高亮函数
  on_highlights = nil,
  
  -- 缓存
  cache = true,
  
  -- 插件配置
  plugins = {
    all = true,
    auto = true,
  },
}

-- 加载主题
function M.load(opts)
  opts = vim.tbl_deep_extend("force", M.defaults, opts or {})
  
  -- 设置背景
  if opts.style == "light" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  
  -- 加载高亮
  require("pretty_dark.highlights").setup(opts)
  
  -- 设置主题名称
  vim.g.colors_name = "pretty_dark"
end

-- 设置函数
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", M.defaults, opts or {})
  
  -- 如果是 lazy.nvim，延迟加载
  if package.loaded.lazy then
    require("lazy").load({ plugins = { "pretty_dark" } })
  end
  
  -- 应用主题
  M.load(opts)
end

return M