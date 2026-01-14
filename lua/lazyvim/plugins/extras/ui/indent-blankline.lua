-- LazyVim 缩进辅助线配置文件
-- 功能：配置 indent-blankline 插件，在代码中显示清晰的缩进辅助线
-- 说明：提供可视化的缩进引导线，帮助理解代码层次结构，提高代码可读性

-- ========================================
-- Indent-blankline 缩进线配置
-- ========================================

return {
  -- disable snacks indent when indent-blankline is enabled
  -- 注释：当启用 indent-blankline 时禁用 snacks 的缩进功能
  -- 说明：避免两个插件的缩进功能冲突，优先使用更专业的 indent-blankline
  {
    "snacks.nvim",
    opts = {
      indent = { enabled = false },  -- 禁用 Snacks 的缩进功能
    },
  },

  -- Indent-blankline 主要配置
  {
    "lukas-reineke/indent-blankline.nvim",

    -- 触发事件：LazyFile - 在文件加载后启用
    event = "LazyFile",

    -- 插件选项配置函数
    opts = function()
      -- ========================================
      -- 1. 配置切换键绑定
      -- ========================================

      -- 使用 Snacks.toggle 创建缩进辅助线的切换开关
      Snacks.toggle({
        name = "Indention Guides",  -- 开关名称：缩进引导线

        -- 获取函数：返回当前缩进辅助线的启用状态
        get = function()
          return require("ibl.config").get_config(0).enabled
        end,

        -- 设置函数：切换缩进辅助线的启用状态
        set = function(state)
          require("ibl").setup_buffer(0, { enabled = state })
        end,
      }):map("<leader>ug")  -- 映射到 <leader> + u + g (utilities + guides)

      -- ========================================
      -- 2. 主要缩进线配置
      -- ========================================

      return {
        -- 缩进线字符配置
        indent = {
          -- 普通缩进字符：使用竖线 "│"（更清晰的视觉区分）
          char = "│",

          -- Tab 缩进字符：同样使用竖线 "│"（保持一致性）
          tab_char = "│",
        },

        -- 作用域高亮配置
        scope = {
          -- 不显示作用域开始标记（减少视觉干扰）
          show_start = false,

          -- 不显示作用域结束标记（减少视觉干扰）
          show_end = false,
        },

        -- ========================================
        -- 3. 文件类型排除配置
        -- ========================================

        -- 排除特定文件类型的缩进线显示
        exclude = {
          filetypes = {
            "Trouble",        -- 代码诊断工具
            "alpha",          -- Alpha 欢迎页面
            "dashboard",      -- Dashboard 欢迎页面
            "help",           -- 帮助文档
            "lazy",           -- Lazy 插件管理器
            "mason",          -- Mason LSP 管理器
            "neo-tree",       -- Neo-tree 文件树
            "notify",         -- 通知弹窗
            "snacks_dashboard", -- Snacks 仪表盘
            "snacks_notif",   -- Snacks 通知
            "snacks_terminal", -- Snacks 终端
            "snacks_win",     -- Snacks 窗口
            "toggleterm",     -- 浮动终端
            "trouble",        -- Trouble 诊断工具
          },
        },
      }
    end,

    -- 插件的主模块名称
    main = "ibl",  -- 使用 "ibl" 作为主模块名（indent-blankline 的缩写）
  },
}
