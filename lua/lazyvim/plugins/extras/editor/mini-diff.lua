-- Mini-Diff 代码差异查看插件配置
-- nvim-mini 组织开发的轻量级代码差异显示工具
-- 替代 gitsigns.nvim，提供简洁高效的 Git 变更提示

return {
  -- ==================== 禁用 Gitsigns 插件 ====================
  -- disable gitsigns.nvim：禁用原有的 Git 符号插件
  -- 使用 Mini-Diff 作为替代方案，避免功能冲突
  {
    "lewis6991/gitsigns.nvim",
    enabled = false, -- 完全禁用 gitsigns 插件
  },

  -- ==================== Mini-Diff 主插件配置 ====================
  -- setup mini.diff：配置 Mini-Diff 插件
  {
    "nvim-mini/mini.diff",
    -- 延迟加载：在编辑器完全初始化后加载
    event = "VeryLazy",
    -- 快捷键绑定：在 Normal 模式下触发差异显示功能
    keys = {
      {
        -- <leader>go：切换 Mini-Diff 覆盖层显示
        -- 用于显示或隐藏当前文件的 Git 变更提示
        "<leader>go",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay", -- 切换 Mini-Diff 覆盖层
      },
    },
    -- 插件选项配置
    opts = {
      -- 视图相关设置
      view = {
        -- 显示样式：sign 表示使用符号标记而非高亮显示
        style = "sign",
        -- 符号配置：定义不同类型变更的显示符号
        signs = {
          add = "▎",      -- 新增内容的符号：右侧短线
          change = "▎",   -- 修改内容的符号：右侧短线
          delete = "",   -- 删除内容的符号：右侧小三角
        },
      },
    },
  },

  -- ==================== Snacks 插件集成 ====================
  -- 通过 Snacks 插件提供 Mini-Diff 的快速切换功能
  {
    "mini.diff",
    -- Snacks 配置函数：创建切换按钮来快速启用/禁用差异符号
    opts = function()
      Snacks.toggle({
        -- 功能名称
        name = "Mini Diff Signs",
        -- 获取当前状态：检查 Mini-Diff 是否启用
        get = function()
          return vim.g.minidiff_disable ~= true
        end,
        -- 设置状态：根据用户切换操作启用或禁用 Mini-Diff
        set = function(state)
          -- 切换全局禁用标志
          vim.g.minidiff_disable = not state
          if state then
            -- 如果启用状态：启用当前缓冲区的差异显示
            require("mini.diff").enable(0)
          else
            -- 如果禁用状态：禁用当前缓冲区的差异显示
            require("mini.diff").disable(0)
          end
          -- HACK: redraw to update the signs
          -- 强制重绘屏幕以更新符号显示（延迟执行确保状态生效）
          vim.defer_fn(function()
            vim.cmd([[redraw!]])
          end, 200)
        end,
      }):map("<leader>uG") -- 绑定到 <leader>uG 快捷键（用户全局切换）
    end,
  },

  -- ==================== Lualine 状态栏集成 ====================
  -- lualine integration：在状态栏中显示差异统计信息
  {
    "nvim-lualine/lualine.nvim",
    -- Lualine 配置函数：自定义差异组件的数据源
    opts = function(_, opts)
      -- 获取 Lualine X 区域（右侧区域）的组件列表
      local x = opts.sections.lualine_x
      -- 遍历所有组件，查找差异组件
      for _, comp in ipairs(x) do
        if comp[1] == "diff" then
          -- 重写差异组件的数据源函数
          comp.source = function()
            -- 获取当前缓冲区的差异摘要信息
            local summary = vim.b.minidiff_summary
            -- 如果存在摘要信息，返回格式化的差异数据
            return summary
              and {
                added = summary.add,     -- 新增行数
                modified = summary.change, -- 修改行数
                removed = summary.delete, -- 删除行数
              }
          end
          -- 找到并修改后立即退出循环
          break
        end
      end
    end,
  },
}
