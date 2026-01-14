-- Tabnine AI - 智能AI代码补全和预测工具
-- 核心功能：
-- 1. 基于机器学习的智能代码补全
-- 2. 支持多种编程语言的代码预测
-- 3. 集成传统补全框架（nvim-cmp、blink.cmp）
-- 4. 提供可靠的代码建议和自动完成

return {
  -- Tabnine补全源：通过cmp框架提供Tabnine补全
  {
    "tzachar/cmp-tabnine",
    -- 构建脚本：根据操作系统选择不同的安装方式
    build = LazyVim.is_win() and "pwsh -noni .\\install.ps1" or "./install.sh",

    -- 配置选项：控制补全行为和性能
    opts = {
      max_lines = 1000,      -- 最大分析行数：限制扫描代码行数以提升性能
      max_num_results = 3,   -- 最大结果数量：显示3个补全选项
      sort = true,           -- 启用排序：按相关度对结果排序
    },

    config = function(_, opts)
      require("cmp_tabnine.config"):setup(opts)
    end,
  },

  -- nvim-cmp集成：传统补全框架支持
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "tzachar/cmp-tabnine" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      -- 在补全源列表中插入Tabnine，优先级最高
      table.insert(opts.sources, 1, {
        name = "cmp_tabnine",
        group_index = 1,      -- 第一组
        priority = 100,       -- 最高优先级
      })

      -- 格式化处理：隐藏百分比显示
      opts.formatting.format = LazyVim.inject.args(opts.formatting.format, function(entry, item)
        -- 在菜单中隐藏百分比
        if entry.source.name == "cmp_tabnine" then
          item.menu = "" -- 清空菜单显示，减少界面干扰
        end
      end)
    end,
  },

  -- blink.cmp集成：现代补全框架支持
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "tzachar/cmp-tabnine", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "cmp_tabnine" }, -- 兼容性支持
        providers = {
          cmp_tabnine = {
            kind = "TabNine",
            score_offset = 100,      -- 提高排序得分
            async = true,            -- 异步补全
          },
        },
      },
    },
  },

  -- 状态栏集成：在Lualine中显示Tabnine状态
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local icon = LazyVim.config.icons.kinds.TabNine
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("cmp_tabnine", icon))
    end,
  },
}
