-- Snacks 现代化文件资源管理器配置
-- folke 开发的 Snacks 工具集中的文件管理器
-- 提供现代化、简洁的文件浏览和管理体验

return {
  -- 插件描述：说明这是 Snacks 的文件资源管理器
  desc = "Snacks File Explorer",
  -- 推荐启用：这是 LazyVim 推荐的插件
  recommended = true,

  -- ==================== Snacks 主插件 ====================
  -- 插件仓库：folke/snacks.nvim 提供了多个实用工具
  "folke/snacks.nvim",
  -- 插件选项：仅启用文件管理器功能
  opts = { explorer = {} },

  -- 快捷键绑定：提供多种方式打开文件管理器
  keys = {
    {
      -- <leader>fe：在项目根目录打开文件资源管理器
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (root dir)", -- 在根目录中浏览
    },
    {
      -- <leader>fE：在当前工作目录打开文件资源管理器
      "<leader>fE",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)", -- 在当前目录中浏览
    },
    -- 重映射快捷键：提供更简洁的访问方式
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },   -- 重映射到根目录浏览
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },      -- 重映射到当前目录浏览
  },
}
