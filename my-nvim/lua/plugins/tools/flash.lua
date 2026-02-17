-- Flash：快速跳转，为搜索结果显示标签
-- 文档：https://github.com/folke/flash.nvim
---@module "flash"

local icons = require("utils").icons

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = icons.jumps .. " " .. "Flash 跳转" },
    { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = icons.scope .. " " .. "Flash Treesitter" },
  },
}
