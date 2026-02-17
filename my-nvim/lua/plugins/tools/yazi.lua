-- ================================
-- 终端文件管理器：yazi.nvim
-- ================================

-- s：按文件名搜索（用 fd 递归搜当前目录下的子目录），输入关键字后会给你候选结果，选中即可跳转/进入
-- S：按文件内容搜索（用 ripgrep），适合“在项目里搜字符串”
-- f：过滤当前列表（更像“当前目录列表筛选”，不一定递归）
-- /：在当前列表里“查找并高亮匹配项”，然后用 n / N 在命中项间跳转

local icons = require("utils").icons

---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  version = "*", -- 使用最新稳定版本
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },

  ---@type YaziConfig | {}
  opts = {
    -- 默认就会在浮动窗口里打开 yazi，这里先保持最小配置
    open_for_directories = false,
  },

  keys = {
    -- 在当前文件所在目录打开 yazi
    {
      "<leader>fy",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = icons.duck .. " " .. "Yazi（当前文件目录）",
    },
    -- 在 Neovim 当前工作目录打开 yazi
    {
      "<leader>fY",
      "<cmd>Yazi cwd<cr>",
      desc = icons.duck .. " " .. "Yazi（工作目录）",
    },
  },
}

