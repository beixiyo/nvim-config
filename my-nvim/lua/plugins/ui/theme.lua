-- ================================
-- 主题（本地 tokyonight.nvim）
-- ================================
-- 使用配置根目录下的 tokyonight.nvim，不从 GitHub 安装
---@module "tokyonight"
return {
  {
    dir = vim.fn.stdpath("config") .. "/tokyonight.nvim",
    lazy = false,
    config = function()
      require("tokyonight").load({ style = "night" })
    end,
  },
}
