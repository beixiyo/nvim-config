-- 插件列表入口
-- ================================
-- 按文件名排序引入；Snacks 的实际加载顺序由 lazy.nvim 配置控制。
-- 可选插件由 plugins/user-picks.lua 控制，可通过 :PluginManager 勾选。

local registry = require("plugins.manager-ui.registry")
local picks = require("plugins.manager-ui.user-picks")

local spec = {
  -- 核心：Snacks（dashboard / picker / terminal / explorer / notifier / bufdelete）
  { import = "plugins.snacks" },
}

for _, entry in ipairs(registry.optional_plugins) do
  if picks[entry.id] ~= false then
    spec[#spec + 1] = { import = entry.import }
  end
end

return spec
