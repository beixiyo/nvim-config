# Neovim 配置文档

这是一个基于 Lazy.nvim 的 Neovim 配置，专门为 Linux 系统配置文件编辑而优化，目标是打造一个轻量级、类似 VSCode 的基础款编辑器

## 安装

```bash
git clone --depth=1 https://github.com/beixiyo/nvim-config ~/.config/nvim && \
rm -rf ~/.config/nvim/.git
```

## 🎯 配置目标

- 像 Windows 一样具有鼠标点击、选区功能
- 支持 `Ctrl + V` 粘贴、`Ctrl + C` 复制、`Ctrl + S` 保存
- 支持 `Ctrl + F` 搜索、`Ctrl + Shift + F` 工作区搜索（不分大小写）
- 有左侧文件树，可以点击打开文件夹、文件
- 专门用于编辑 Linux 配置文件（bash、json、yaml、toml、ini 等）
- 轻量级设计，不包含编程相关功能

## 🚫 已禁用的功能

为了保持轻量级和专注配置文件编辑，以下功能已被禁用：

| 功能类别 | 禁用的功能 | 原因 |
|----------|------------|------|
| **LSP 支持** | 代码补全、语法检查、跳转定义 | 不需要编程功能 |
| **自动补全** | nvim-cmp、代码片段 | 配置文件编辑不需要 |
| **Git 集成** | Git 状态显示、Git 操作 | 简化界面 |
| **状态栏** | lualine 状态栏 | 减少视觉干扰 |
| **语法高亮** | Treesitter 语法高亮 | 使用 Neovim 原生高亮 |
| **代码片段** | LuaSnip、friendly-snippets | 配置文件不需要 |

## 📁 配置文件结构

```
nvim/
├── init.lua                    # 主配置文件，加载所有模块
└── lua/
    ├── core/                   # 核心配置
    │   ├── keymaps.lua         # 快捷键配置
    │   └── options.lua         # 基础选项配置
    └── plugins/                # 插件配置
        ├── plugins-setup.lua   # 插件管理器配置
        ├── autopairs.lua       # 自动配对括号
        ├── bufferline.lua      # 标签页显示
        ├── cmp.lua             # 代码补全
        ├── comment.lua         # 注释功能
        ├── gitsigns.lua        # Git 状态显示
        ├── lsp.lua             # LSP 配置（已禁用）
        ├── lualine.lua         # 状态栏
        ├── nvim-tree.lua       # 文件树
        ├── telescope.lua       # 文件搜索
        └── treesitter.lua      # 语法高亮
```

## 🔧 核心配置文件详解

### `init.lua` - 主配置文件
- 加载插件管理器
- 加载核心配置（选项、快捷键）
- 加载所有插件配置

### `core/options.lua` - 基础选项配置
| 配置项 | 作用 | 值 |
|--------|------|-----|
| `relativenumber` | 相对行号 | `true` |
| `number` | 绝对行号 | `true` |
| `tabstop` | Tab 宽度 | `2` |
| `shiftwidth` | 缩进宽度 | `2` |
| `expandtab` | Tab 转空格 | `true` |
| `autoindent` | 自动缩进 | `true` |
| `wrap` | 自动换行 | `false` |
| `cursorline` | 高亮当前行 | `true` |
| `mouse` | 启用鼠标 | `"a"` |
| `clipboard` | 系统剪贴板 | `"unnamedplus"` |
| `splitright` | 新窗口在右侧 | `true` |
| `splitbelow` | 新窗口在下方 | `true` |
| `ignorecase` | 搜索忽略大小写 | `true` |
| `smartcase` | 智能大小写 | `true` |
| `termguicolors` | 真彩色支持 | `true` |
| `signcolumn` | 显示符号列 | `"yes"` |

### `core/keymaps.lua` - 快捷键配置

#### 基础快捷键
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `ESC` | 插入模式 | 退出到正常模式 |
| `Ctrl + Enter` | 插入模式 | 在下方新增一行并移动光标 |
| `Ctrl + Shift + Enter` | 插入模式 | 在上方新增一行并移动光标 |
| `Alt + ↑` | 插入模式 | 向上移动当前行 |
| `Alt + ↓` | 插入模式 | 向下移动当前行 |
| `Alt + Shift + ↑` | 插入模式 | 向上复制当前行 |
| `Alt + Shift + ↓` | 插入模式 | 向下复制当前行 |
| `<leader>nh` | 正常模式 | 取消搜索高亮 |
| `Ctrl + Tab` | 正常模式 | 下一个缓冲区 |
| `Ctrl + 1-9` | 正常模式 | 切换到指定缓冲区 |
| `<leader>e` | 正常模式 | 切换文件树 |

#### VSCode 风格快捷键
| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl + C` | 复制到系统剪贴板 | **覆盖原生功能** |
| `Ctrl + V` | 从系统剪贴板粘贴 | **覆盖原生功能** |
| `Ctrl + S` | 保存文件 | 支持插入模式和正常模式 |
| `Ctrl + F` | 搜索 | 在当前文件中搜索 |
| `Ctrl + Shift + F` | 工作区搜索 | 使用 Telescope 搜索所有文件 |
| `Ctrl + /` | 注释/取消注释 | 支持当前行和选中区域 |
| `Ctrl + Z` | 撤回 | 支持所有模式 |
| `Ctrl + Y` | 回溯（重做） | 支持所有模式 |
| `Ctrl + Shift + Z` | 回溯（重做） | 备用方案 |

## 🔌 插件配置详解

### 插件管理器
- **`plugins-setup.lua`**: 使用 Lazy.nvim 管理插件，自动安装和更新

### 界面美化
- **`bufferline.lua`**: 标签页显示，类似 VSCode 的标签页
- **`treesitter.lua`**: 语法高亮（已禁用，使用 Neovim 原生高亮）

### 文件管理
- **`nvim-tree.lua`**: 文件树，类似 VSCode 的资源管理器
- **`telescope.lua`**: 文件搜索，支持模糊搜索和实时搜索

### 编辑功能
- **`autopairs.lua`**: 自动配对括号、引号等

### 已禁用的功能
- **`comment.lua`**: 注释功能，支持多种注释风格
- **`lualine.lua`**: 状态栏（已禁用）
- **`lsp.lua`**: LSP 配置（已禁用）
- **`cmp.lua`**: 代码补全（已禁用）
- **`gitsigns.lua`**: Git 状态显示（已禁用）

## 🎨 主题

使用 Tokyo Night 主题，支持深色模式：
- 主题文件：`tokyonight-moon`
- 简洁的界面设计，专注于内容编辑

## 📝 常用操作
TODO

## 🔧 自定义配置

如需修改配置，可以编辑对应的配置文件：
- 修改快捷键：编辑 `lua/core/keymaps.lua`
- 修改基础选项：编辑 `lua/core/options.lua`
- 添加插件：编辑 `lua/plugins/plugins-setup.lua`
- 配置插件：编辑 `lua/plugins/` 下对应的文件

## 📚 更多信息

- [Neovim 官方文档](https://neovim.io/doc/)
- [Lazy.nvim 文档](https://github.com/folke/lazy.nvim)
- [Telescope 文档](https://github.com/nvim-telescope/telescope.nvim)
