-- ============================================================================
-- VSCode 环境下的插件配置
-- ============================================================================
-- 这个文件只在 VSCode 中使用 Neovim 插件时加载
-- 为了避免加载多余的插件，只在这里配置必要的插件
--
-- 文件位置：lua/plugins/vscode/init.lua
-- 为什么放在 plugins/vscode 而不是直接放在 vscode？
--   VSCode Neovim 插件本身已经注册了 "vscode" 模块名，使用 import = "vscode" 会冲突
--   所以使用 import = "plugins.vscode" 来避免命名冲突
--
-- 如何添加新插件？
--   在这个文件中添加插件配置，格式如下：
--   {
--     "作者/插件名",
--     vscode = true,  -- 标记为 VSCode 专用插件（可选）
--     opts = {},      -- 插件配置选项
--     keys = { ... }, -- 快捷键配置（可选）
--   }
-- ============================================================================

return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      -- Simulate nvim-treesitter incremental selection
      { "<c-space>", mode = { "n", "o", "x" },
        function()
          require("flash").treesitter({
            actions = {
              ["<c-space>"] = "next",
              ["<BS>"] = "prev"
            }
          })
        end, desc = "Treesitter Incremental Selection" },
    },
  },
  -- 在这里添加更多 VSCode 专用的插件配置
  -- 例如：
  -- {
  --   "其他插件",
  --   vscode = true,
  --   opts = {},
  -- },
}

