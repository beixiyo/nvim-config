-- ================================
-- 插件列表入口
-- ================================
-- 在此返回插件 spec，或通过 { import = "plugins.xxx" } 引入子模块

return {
  { import = "plugins.theme" },
  { import = "plugins.which-key" },
  { import = "plugins.fzf" },
  { import = "plugins.alpha" },
  { import = "plugins.neo-tree" },
  { import = "plugins.bufferline" },
  { import = "plugins.lualine" },
  { import = "plugins.noice" },
  { import = "plugins.blink" },
  { import = "plugins.render-markdown" },
  { import = "plugins.toggleterm" },
  { import = "plugins.treesitter" },
}
