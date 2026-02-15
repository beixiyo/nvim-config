# Lua 配置和包管理说明

## 1. Lua 模块系统基础

### 1.1 什么是 Lua 模块？
在 Neovim 中，Lua 模块是通过 `require()` 函数加载的代码文件。

**基本语法：**
```lua
local module = require("模块名")
```

### 1.2 模块路径解析规则

Neovim 会在 `runtimepath` (rtp) 中查找 Lua 模块。路径规则如下：

```lua
-- 查找 lua/config/options.lua
require("config.options")
```

**关键点：**
- 点号 (`.`) 表示目录分隔符
- `lua/` 目录是自动添加的前缀
- 不需要写 `.lua` 扩展名

## 2. Neovim 的 runtimepath (rtp)

### 2.1 什么是 runtimepath？
`runtimepath` 是 Neovim 查找配置文件的路径列表。你的配置目录会自动添加到 rtp 中

**查看当前 runtimepath：**
```lua
:lua print(vim.inspect(vim.opt.rtp:get()))
```

### 2.2 你的配置目录结构

```
lazy-vim/
├── init.lua                   # 入口文件
└── lua/                       # Lua 模块目录
    ├── config/                # 用户配置模块
    │   ├── autocmds.lua       # require("config.autocmds")
    │   ├── keymaps.lua        # require("config.keymaps")
    │   └── options.lua        # require("config.options")
    ├── plugins/               # 用户插件模块
    │   ├── init.lua           # require("plugins")
    │   └── example.lua        # require("plugins.example")
    └── lazyvim/               # LazyVim 框架模块
        ├── init.lua           # require("lazyvim")
        └── config/
            └── init.lua       # require("lazyvim.config")
```

## 3. 路径解析示例

### 3.1 正确的路径写法

| require() 调用 | 实际查找的文件路径 |
|--------------|------------------|
| `require("config.options")` | `lua/config/options.lua` ✅ |
| `require("config.keymaps")` | `lua/config/keymaps.lua` ✅ |
| `require("config.autocmds")` | `lua/config/autocmds.lua` ✅ |
| `require("plugins")` | `lua/plugins/init.lua` ✅ |
| `require("plugins.example")` | `lua/plugins/example.lua` ✅ |
| `require("lazyvim")` | `lua/lazyvim/init.lua` ✅ |
| `require("lazyvim.config")` | `lua/lazyvim/config/init.lua` ✅ |

### 3.2 错误的路径写法

```lua
-- ❌ 错误：不要包含 .lua 扩展名
require("config.options.lua")

-- ❌ 错误：不要包含 lua/ 前缀
require("lua.config.options")

-- ❌ 错误：不要使用反斜杠或斜杠
require("config/options")
require("config\\options")

-- ✅ 正确：使用点号分隔
require("config.options")
```

## 4. 你的配置检查

### 4.1 当前配置结构 ✅

```
lua/
├── config/
│   ├── autocmds.lua    ✅ 正确位置
│   ├── keymaps.lua     ✅ 正确位置
│   └── options.lua     ✅ 正确位置
└── plugins/
    ├── init.lua        ✅ 正确位置
    └── example.lua     ✅ 正确位置
```

### 4.2 init.lua 中的路径设置 ✅

`init.lua` 第 19 行：
```lua
vim.opt.rtp:prepend(vim.fn.stdpath("config"))
```

这行代码将你的配置目录添加到 runtimepath 的最前面，这样 Neovim 就能找到：
- `lua/config/` 目录下的文件
- `lua/plugins/` 目录下的文件
- `lua/lazyvim/` 目录下的文件

**这是正确的！** ✅

## 5. 插件管理 (lazy.nvim)

### 5.1 插件配置路径

在 `init.lua` 第 70 行：
```lua
{ import = "plugins" }
```

这会让 lazy.nvim 自动加载 `lua/plugins/` 目录下的所有 `.lua` 文件。

**加载规则：**
- `lua/plugins/init.lua` → 自动加载
- `lua/plugins/example.lua` → 自动加载
- `lua/plugins/任何名字.lua` → 自动加载

### 5.2 插件配置格式

每个插件文件应该返回一个表（table）：

```lua
-- lua/plugins/example.lua
return {
  {
    "插件作者/插件名",
    opts = {
      -- 插件配置选项
    },
  },
}
```

## 6. 常见问题

### Q1: 为什么我的配置不生效？

**检查清单：**
1. ✅ 文件是否在正确的目录？(`lua/config/` 或 `lua/plugins/`)
2. ✅ 文件名是否正确？(例如：`options.lua` 不是 `option.lua`)
3. ✅ 文件是否有语法错误？(运行 `:checkhealth` 检查)
4. ✅ runtimepath 是否正确？(你的 init.lua 已经设置了)

### Q2: 如何测试模块是否能被找到？

在 Neovim 中运行：
```lua
:lua print(package.searchpath("config.options", package.path))
```

如果返回路径，说明模块可以被找到。

### Q3: 如何查看已加载的模块？

```lua
:lua print(vim.inspect(package.loaded))
```
