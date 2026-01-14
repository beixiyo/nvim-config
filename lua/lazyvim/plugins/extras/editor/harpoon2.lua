-- Harpoon2 快速文件切换插件配置
-- ThePrimeagen 开发的快速文件导航和书签管理工具
-- 允许用户快速切换到经常访问的文件，提高开发效率

return {
  -- 插件仓库：使用 harpoon2 分支
  "ThePrimeagen/harpoon",
  branch = "harpoon2",

  -- 插件选项配置
  opts = {
    -- 菜单相关设置
    menu = {
      -- 快速菜单宽度：当前窗口宽度减去4列，确保与窗口边缘有适当间距
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    -- 全局设置
    settings = {
      -- 每次切换书签时自动保存列表状态
      -- 确保重新启动 Neovim 后，之前添加的书签不会丢失
      save_on_toggle = true,
    },
  },

  -- 快捷键绑定函数：根据索引动态生成快捷键
  keys = function()
    -- 基础快捷键配置
    local keys = {
      {
        -- <leader>H：将当前文件添加到 harpoon 书签列表
        -- 用于标记重要或常用的文件
        "<leader>H",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      {
        -- <leader>h：打开 harpoon 快速菜单
        -- 显示所有已标记的文件列表，支持快速搜索和切换
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
    }

    -- 为每个书签位置（1-9）创建直接切换快捷键
    for i = 1, 9 do
      table.insert(keys, {
        -- <leader>1 到 <leader>9：直接跳转到对应的书签
        -- 例如：<leader>1 跳转到第1个书签，<leader>2 跳转到第2个书签
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
    end
    return keys
  end,
}
