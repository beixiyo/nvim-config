-- ================================
-- 插件列表入口
-- ================================
-- 在此返回插件 spec，或通过 { import = "plugins.xxx" } 引入子模块

return {
  { import = "plugins.theme" },
  { import = "plugins.which-key" },
  { import = "plugins.telescope" },
  { import = "plugins.fzf" },
  { import = "plugins.alpha" },
  { import = "plugins.noice" },
}
