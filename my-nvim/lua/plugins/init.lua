-- ================================
-- 插件列表入口
-- ================================
-- 按分类引入：ui / code / file / tools

return {
  -- UI：主题、欢迎页、状态栏、buffer 标签、消息
  { import = "plugins.ui.theme" },
  { import = "plugins.ui.alpha" },
  { import = "plugins.ui.bufferline" },
  { import = "plugins.ui.lualine" },
  { import = "plugins.ui.noice" },
  -- 代码：语法、自动配对、补全、Markdown 渲染
  { import = "plugins.code.treesitter" },
  { import = "plugins.code.mini-pairs" },
  { import = "plugins.code.blink" },
  { import = "plugins.code.render-markdown" },
  -- 文件：文件树、模糊查找
  { import = "plugins.file.neo-tree" },
  { import = "plugins.file.fzf" },
  -- 工具：键位提示、终端
  { import = "plugins.tools.which-key" },
  { import = "plugins.tools.toggleterm" },
}
