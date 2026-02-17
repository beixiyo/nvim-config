-- 插件列表入口
-- ================================
-- 按文件名排序引入；Snacks 的实际加载顺序由 lazy.nvim 配置控制

return {
  -- Snacks 功能总览（详见 `plugins.snacks`）：
  -- - `dashboard`：欢迎页（无文件启动时）
  -- - `picker`：文件/内容检索（`<leader>ff` / `fg` / `fr` / `fc` / `fb` / `sg` / `sw`）
  -- - `explorer`：文件树（`<leader>e` / `E` / `fe` / `fE`）
  -- - `terminal`：终端（`<C-\>` / `<leader>ft`）
  -- - `notifier`：通知中心（替代 `vim.notify`）
  -- - `bufdelete`：关闭 buffer（供 bufferline 使用）
  -- - `bigfile` / `input` / `quickfile`
  { import = "plugins.snacks" },

  { import = "plugins.code.blink" },
  { import = "plugins.code.lsp" },
  { import = "plugins.code.mini-pairs" },
  { import = "plugins.code.render-markdown" },
  { import = "plugins.code.treesitter" },

  { import = "plugins.tools.flash" },
  { import = "plugins.tools.session" },
  { import = "plugins.tools.which-key" },

  { import = "plugins.ui.bufferline" },
  { import = "plugins.ui.indent" },
  { import = "plugins.ui.lualine" },
  { import = "plugins.ui.noice" },
  { import = "plugins.ui.theme" },
}
