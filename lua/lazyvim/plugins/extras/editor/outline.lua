-- Outline 代码大纲插件配置
-- 在侧边栏中显示代码的层次结构树
-- 支持函数、类、变量等代码符号的快速导航和浏览

return {
  -- ==================== Trouble 插件冲突处理 ====================
  -- Disable `<leader>cs` keymap so it doesn't conflict with `outline.nvim`
  -- 禁用 Trouble 插件的 <leader>cs 快捷键，避免与 Outline 插件冲突
  {
    "folke/trouble.nvim",
    -- 可选插件：仅在安装了 trouble 时启用
    optional = true,
    -- 快捷键设置：禁用 <leader>cs 快捷键
    keys = {
      { "<leader>cs", false }, -- 禁用该快捷键，保留给 Outline 插件使用
    },
  },

  -- ==================== Outline 主插件配置 ====================
  {
    "hedyhli/outline.nvim",
    -- 快捷键绑定：切换代码大纲显示
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    -- 命令：Outline 命令用于打开/关闭代码大纲
    cmd = "Outline",
    -- 插件选项配置函数
    opts = function()
      -- 获取 Outline 插件的默认配置
      local defaults = require("outline.config").defaults
      -- 自定义配置选项
      local opts = {
        -- 符号图标配置
        symbols = {
          icons = {}, -- 存储各种代码符号的图标
          -- 过滤设置：使用 LazyVim 的符号过滤器配置
          filter = vim.deepcopy(LazyVim.config.kind_filter),
        },
        -- 快捷键配置：定义导航相关的快捷键
        keymaps = {
          up_and_jump = "<up>",    -- 向上移动并跳转到选中的符号
          down_and_jump = "<down>", -- 向下移动并跳转到选中的符号
        },
      }

      -- 合并图标配置：使用 LazyVim 的图标配置，fallback 到默认值
      for kind, symbol in pairs(defaults.symbols.icons) do
        opts.symbols.icons[kind] = {
          -- 图标：优先使用 LazyVim 配置的图标，否则使用默认图标
          icon = LazyVim.config.icons.kinds[kind] or symbol.icon,
          -- 高亮组：保留原配置的高亮信息
          hl = symbol.hl,
        }
      end
      return opts
    end,
  },

  -- ==================== Edgy 插件集成 ====================
  -- edgy integration：将 Outline 集成到 Edgy 侧边栏中
  {
    "folke/edgy.nvim",
    -- 可选插件：仅在安装了 edgy 时启用
    optional = true,
    -- Edgy 配置函数：在右侧边栏中添加 Outline 面板
    opts = function(_, opts)
      -- 获取插件加载顺序索引
      local edgy_idx = LazyVim.plugin.extra_idx("ui.edgy")
      local symbols_idx = LazyVim.plugin.extra_idx("editor.outline")

      -- 警告：如果 edgy 插件在 outline 之后加载，显示警告信息
      if edgy_idx and edgy_idx > symbols_idx then
        LazyVim.warn(
          "The `edgy.nvim` extra must be **imported** before the `outline.nvim` extra to work properly.",
          { title = "LazyVim" }
        )
      end

      -- 初始化右侧边栏配置
      opts.right = opts.right or {}
      -- 插入 Outline 面板配置
      table.insert(opts.right, {
        -- 面板标题
        title = "Outline",
        -- 文件类型：Outline 专用的文件类型
        ft = "Outline",
        -- 固定显示：始终显示在侧边栏中
        pinned = true,
        -- 打开命令：启动时自动打开 Outline
        open = "Outline",
      })
    end,
  },
}
