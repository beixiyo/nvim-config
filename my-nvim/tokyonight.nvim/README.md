# TokyoNight.nvim 自定义主题指南

本项目已根据 pretty_dark 颜色方案进行了自定义修改，以提供更好的性能和视觉体验

## 颜色方案概述

当前配置基于 pretty_dark 颜色方案，主要颜色包括：

- **函数**: 蓝色 (`#4aa5f0`)
- **关键字**: 紫色 (`#c678dd`)
- **字符串**: 绿色 (`#98c379`)
- **常量/数字**: 橙色 (`#d19a66`)
- **变量**: 红色系 (`#e06c75`)
- **类型**: 青色 (`#4ec9b0`)
- **属性**: 红色系 (`#e06c75`)

## 如何自定义颜色

### 方法一：直接修改源码（推荐）

为了获得最佳性能，建议直接修改源码文件：

1. **修改基础颜色**：
   编辑 `lua/tokyonight/colors/storm.lua`
   ```lua
   -- 修改颜色值
   bg = "#你的背景色",
   blue = "#你的函数颜色",
   magenta = "#你的关键字颜色",
   green = "#你的字符串颜色",
   orange = "#你的常量颜色",
   -- 添加自定义颜色
   type = "#你的类型颜色",
   property = "#你的属性颜色",
   variable = "#你的变量颜色",
   ```

2. **修改语法高亮**：
   编辑 `lua/tokyonight/groups/treesitter.lua`
   ```lua
   ["@function"] = "Function",
   ["@keyword"] = { fg = c.magenta, style = opts.styles.keywords },
   ["@string"] = "String",
   ["@variable"] = { fg = c.variable, style = opts.styles.variables },
   ["@type"] = { fg = c.type },
   ```

3. **修改基础高亮**：
   编辑 `lua/tokyonight/groups/base.lua`
   ```lua
   Function = { fg = c.blue, style = opts.styles.functions },
   Keyword = { fg = c.magenta, style = opts.styles.keywords },
   String = { fg = c.green },
   Type = { fg = c.type },
   ```

### 方法二：使用配置覆盖（不推荐）

**注意**：此方法会导致代码二次着色，首次渲染很慢，仅建议用于临时测试

参考 `override-example.lua` 文件，使用 `on_colors` 和 `on_highlights` 函数：

```lua
{
  'folke/tokyonight.nvim',
  opts = {
    on_colors = function(colors)
      -- 修改颜色
      colors.bg = "#你的背景色"
      colors.blue = "#你的函数颜色"
    end,
    on_highlights = function(hl, colors)
      -- 修改高亮组
      hl["@function"] = { fg = "#你的函数颜色" }
      hl["@keyword"] = { fg = "#你的关键字颜色", italic = true }
    end,
  },
}
```

## 性能优化建议

1. **避免使用 `on_colors` 和 `on_highlights`**：这些函数会在运行时重新计算颜色，导致性能下降
2. **直接修改源码**：可以获得与原生主题相同的渲染速度
3. **减少颜色覆盖**：只修改必要的颜色，保持整体一致性

## 常见语法元素对应关系

| 语法元素 | 颜色变量 | 示例颜色 |
|---------|---------|---------|
| 函数 | `c.blue` | `#4aa5f0` |
| 关键字 | `c.magenta` | `#c678dd` |
| 字符串 | `c.green` | `#98c379` |
| 常量/数字 | `c.orange` | `#d19a66` |
| 变量 | `c.variable` | `#e06c75` |
| 类型 | `c.type` | `#4ec9b0` |
| 属性 | `c.property` | `#e06c75` |
| 注释 | `c.comment` | `#7f848e` |

## 重启应用

修改源码后，需要重启 Neovim 才能看到效果。修改配置文件后，可以使用 `:colorscheme tokyonight` 命令重新加载主题

## 备份原配置

在进行重大修改前，建议备份原始文件：

```bash
cp lua/tokyonight/colors/storm.lua lua/tokyonight/colors/storm.lua.backup
cp lua/tokyonight/groups/treesitter.lua lua/tokyonight/groups/treesitter.lua.backup
cp lua/tokyonight/groups/base.lua lua/tokyonight/groups/base.lua.backup
```
