-- 用户自定义插件配置
-- 这个文件会被 lazy.nvim 自动加载
-- 你可以在 lua/plugins/ 目录下创建其他 .lua 文件来添加自己的插件
-- 例如：lua/plugins/my-plugins.lua
--
-- 注意：LazyVim 的插件配置已经在 lua/config/lazy.lua 中加载了
-- 这里只需要返回你的自定义插件

return {
  -- 本地 pretty_dark 主题插件
  -- {
  --   "pretty_dark",
  --   dir = vim.fn.stdpath("config") .. "/pretty_dark",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- 这里可以配置 pretty_dark 主题
  --     -- 但因为我们主要在 theme.lua 中使用它的颜色，所以不需要额外配置
  --   end,
  -- },
}
