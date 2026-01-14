-- Extras 加载优先级管理
-- 某些 extras 需要按照特定顺序加载，否则可能因为依赖关系导致错误
-- 这个表定义了各种 extras 的加载优先级，数值越小优先级越高
-- 优先级 1: 最高优先级，必须最先加载
-- 优先级 20: 默认核心 extras 的优先级
-- 优先级 50: 普通 extras 的默认优先级
-- 优先级 100+: 低优先级，可以最后加载

local prios = {
  -- 最高优先级：核心测试和调试框架，必须先于其他所有模块加载
  ["lazyvim.plugins.extras.test.core"] = 1,       -- 测试框架核心
  ["lazyvim.plugins.extras.dap.core"] = 1,        -- 调试适配器协议核心
  
  -- 高优先级：基础编辑工具
  ["lazyvim.plugins.extras.coding.nvim-cmp"] = 2, -- 代码补全基础
  ["lazyvim.plugins.extras.editor.neo-tree"] = 2, -- 文件树基础
  
  -- 中高优先级：布局和UI组件
  ["lazyvim.plugins.extras.ui.edgy"] = 3,         -- 侧边栏布局系统
  
  -- AI 工具：需要基础组件就绪后加载
  ["lazyvim.plugins.extras.ai.copilot-native"] = 4, -- 原生 Copilot 集成
  
  -- 编程相关：需要基础环境就绪
  ["lazyvim.plugins.extras.coding.blink"] = 5,    -- 新的补全引擎
  ["lazyvim.plugins.extras.lang.typescript"] = 5, -- TypeScript 语言支持
  
  -- 格式化工具：优先级相对较低
  ["lazyvim.plugins.extras.formatting.prettier"] = 10, -- 代码格式化器
  
  -- 默认核心 extras 优先级为 20
  -- 普通 extras 优先级为 50
  
  -- 低优先级 UI 组件
  ["lazyvim.plugins.extras.editor.aerial"] = 100,   -- 代码大纲视图
  ["lazyvim.plugins.extras.editor.outline"] = 100,  -- 大纲视图替代方案
  
  -- 启动界面相关：优先级 19（比默认值 20 稍高）
  ["lazyvim.plugins.extras.ui.alpha"] = 19,              -- Alpha 启动界面
  ["lazyvim.plugins.extras.ui.dashboard-nvim"] = 19,     -- Dashboard 替代方案
  ["lazyvim.plugins.extras.ui.mini-starter"] = 19,       -- Mini Starter 启动界面
}

-- 用户自定义优先级配置
-- 如果用户通过全局变量设置了优先级，覆盖默认配置
if vim.g.xtras_prios then
  -- 使用深度合并，允许用户部分覆盖特定模块的优先级
  -- vim.g.xtras_prios 的格式应与 prios 表相同
  prios = vim.tbl_deep_extend("force", prios, vim.g.xtras_prios or {})
end

-- 初始化变量
local extras = {} ---@type string[]  -- 最终要加载的 extras 列表
local defaults = LazyVim.config.get_defaults()  -- 获取默认推荐的 extras 配置

local changed = false  -- 标记配置是否发生改变
local updated = {} ---@type string[]  -- 更新后的 extras 列表

-- 处理用户通过 :LazyExtras 命令选择的 extras
-- 这个过程会：
-- 1. 检查模块是否有重命名或弃用
-- 2. 过滤掉已禁用的模块
-- 3. 更新配置文件中的 extras 列表
for _, extra in ipairs(LazyVim.config.json.data.extras) do
  -- 检查模块是否被重命名：如果被重命名，使用新名称
  if LazyVim.plugin.renamed_extras[extra] then
    extra = LazyVim.plugin.renamed_extras[extra]
    changed = true  -- 标记配置改变
  end
  
  -- 检查模块是否已弃用：如果已弃用，标记改变但不下加载
  if LazyVim.plugin.deprecated_extras[extra] then
    changed = true
  else
    -- 将有效模块加入更新列表
    updated[#updated + 1] = extra
    local def = defaults[extra]
    -- 如果该模块在默认配置中没有被明确禁用，则添加到加载列表
    if not (def and def.enabled == false) then
      extras[#extras + 1] = extra
    end
  end
end

-- 如果配置发生改变，保存更新后的配置
if changed then
  -- 更新 JSON 配置中的 extras 列表（移除已弃用的）
  LazyVim.config.json.data.extras = updated
  -- 保存配置到磁盘
  LazyVim.json.save()
end

-- 添加默认推荐的 extras
-- 根据 LazyVim 的默认配置，自动启用用户没有明确禁用的推荐模块
-- 这个过程确保用户能获得 LazyVim 认为的核心功能
for name, extra in pairs(defaults) do
  -- 如果该模块在默认配置中被标记为启用
  if extra.enabled then
    -- 为该模块设置默认优先级（如果没有自定义优先级）
    prios[name] = prios[name] or 20  -- 20 是默认核心 extras 的优先级
    -- 将该模块添加到要加载的 extras 列表
    extras[#extras + 1] = name
  end
end

---@type string[]
-- 去除重复的 extras：可能有多个地方添加了相同的模块
extras = LazyVim.dedup(extras)

-- 保存核心插件配置到缓存
LazyVim.plugin.save_core()

-- 如果用户正在使用 VSCode 模式，添加 VSCode 特定的配置
if vim.g.vscode then
  -- 将 VSCode 配置插入到 extras 列表的最前面，确保最高优先级
  table.insert(extras, 1, "lazyvim.plugins.extras.vscode")
end

-- 根据优先级对 extras 进行排序
-- 这个排序确保：
-- 1. 优先级高的模块先加载
-- 2. 同优先级的模块按字母顺序排序（保证加载顺序稳定）
table.sort(extras, function(a, b)
  local pa = prios[a] or 50  -- 模块 a 的优先级（默认 50）
  local pb = prios[b] or 50  -- 模块 b 的优先级（默认 50）
  
  -- 如果优先级相同，按模块名称字母顺序排序
  if pa == pb then
    return a < b
  end
  
  -- 否则按优先级数值排序（小的先加载）
  return pa < pb
end)

-- 将 extras 列表转换为 LazyVim 可理解的导入格式
---@param extra string
return vim.tbl_map(function(extra)
  return { import = extra }
end, extras)
-- 返回值格式：[ { import = "lazyvim.plugins.extras.xxx" }, ... ]
-- 这个格式会被 LazyVim 的插件管理器识别并加载
