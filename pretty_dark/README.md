# Pretty Dark

## 颜色

- 背景：`#191815`
- 前景：`#c2c2c2`
- 注释：`#7f848e`
- 关键字：`#c678dd` (斜体)
- 字符串：`#98c379`
- 数字：`#d19a66`
- 函数：`#4aa5f0`
- 类型：`#4ec9b0`
- 变量：`#e06c75`

## 安装

在你的 `lua/plugins/theme.lua` 中添加：

```lua
{
  dir = vim.fn.stdpath('config') .. '/pretty_dark',
  config = function()
    require('pretty_dark').setup()
  end,
}
```

## 本地导入使用

```lua
return {
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'pretty_dark',
    },
  },
  {
    dir = vim.fn.stdpath('config') .. '/pretty_dark',
    config = function()
      require('pretty_dark').setup({})
    end,
  },
}
```

## 目录结构

```
pretty_dark/
├── colors/
│   └── pretty_dark.lua      # Lua 颜色方案入口（Neovim 通过 colorscheme 命令加载）
├── lua/
│   └── pretty_dark/
│       ├── colors.lua       # 颜色调色板定义
│       ├── highlights.lua   # 高亮组定义
│       └── init.lua         # 主题初始化和主入口
```
