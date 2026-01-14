-- Navic 代码结构导航插件配置
-- 在状态栏中显示当前代码结构位置（函数、类等）
-- 帮助开发者了解在代码层次结构中的当前位置

return {
  -- ==================== Navic 主插件配置 ====================
  -- lsp symbol navigation for lualine. This shows where
  -- in the code structure you are - within functions, classes,
  -- etc - in the statusline.
  {
    "SmiteshP/nvim-navic",
    -- 延迟加载：提高启动性能
    lazy = true,
    -- 初始化函数：设置插件的全局配置
    init = function()
      -- 启用静默模式：减少不必要的提示信息
      vim.g.navic_silence = true
    end,
    -- 插件选项配置函数
    opts = function()
      -- 注册 LSP 文档符号事件处理器
      Snacks.util.lsp.on({ method = "textDocument/documentSymbol" }, function(buffer, client)
        -- 将 Navic 附加到 LSP 客户端和缓冲区
        -- 启用实时代码结构跟踪功能
        require("nvim-navic").attach(client, buffer)
      end)

      -- 返回 Navic 配置选项
      return {
        -- 导航路径的分隔符：用于分隔不同层级的代码结构
        separator = " ",
        -- 启用语法高亮：使用不同颜色区分不同的代码结构类型
        highlight = true,
        -- 限制显示层级：最多显示5层嵌套的代码结构，避免显示过于详细
        depth_limit = 5,
        -- 图标配置：使用 LazyVim 配置的图标集合
        icons = LazyVim.config.icons.kinds,
        -- 延迟更新上下文：提高性能，仅在必要时更新导航信息
        lazy_update_context = true,
      }
    end,
  },

  -- ==================== Lualine 状态栏集成 ====================
  -- lualine integration：在状态栏中显示代码导航信息
  {
    "nvim-lualine/lualine.nvim",
    -- 可选插件：仅在安装了 lualine 时启用
    optional = true,
    -- Lualine 配置函数：在状态栏中添加 Navic 组件
    opts = function(_, opts)
      -- 如果没有启用 Trouble 插件的 Lualine 集成
      if not vim.g.trouble_lualine then
        -- 在 Lualine 的 C 区域（左侧）插入 Navic 组件
        table.insert(opts.sections.lualine_c, {
          "navic",
          -- 动态颜色校正：根据当前主题自动调整颜色
          color_correction = "dynamic"
        })
      end
    end,
  },
}
