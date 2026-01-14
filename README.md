## Version 
基于 LazyVim v15.13.0: https://github.com/LazyVim/LazyVim/releases/tag/v15.13.0

## 自定义配置

### 文件树
- **[mini.files](lua/plugins/mini.file.lua)** - 轻量级文件浏览器（替代默认的 Snacks Explorer）

### 性能优化
- **[bigfile.nvim](lua/plugins/bigfile.lua)** - 自动检测大文件并优化性能

### 颜色增强
- **[nvim-colorizer.lua](lua/plugins/colorizer.lua)** - 颜色代码高亮
- **[color-picker.nvim](lua/plugins/colorizer.lua)** - 颜色选择器

### 主题
- **[tokyonight.nvim](lua/plugins/theme.lua)** - 使用本地版本，配置为 `night` 风格

## LazyVim 默认插件

### 核心功能
- **文件树**: [Snacks Explorer](lua/lazyvim/plugins/extras/editor/snacks_explorer.lua)（8.x 默认）或 [Neo-tree](lua/lazyvim/plugins/extras/editor/neo-tree.lua)（可选）
- **文件搜索**: [Snacks Picker](lua/lazyvim/plugins/extras/editor/snacks_picker.lua)（8.x 默认）或 [Telescope](lua/lazyvim/plugins/extras/editor/telescope.lua)（可选）
- **LSP**: [nvim-lspconfig](lua/lazyvim/plugins/lsp/init.lua) + [Mason](lua/lazyvim/plugins/lsp/init.lua)
- **文本搜索**: [Snacks Picker live_grep](lua/lazyvim/plugins/extras/editor/snacks_picker.lua)
- **项目切换**: [Snacks Picker projects](lua/lazyvim/plugins/extras/editor/snacks_picker.lua)
- **Git**: [gitsigns.nvim](lua/lazyvim/plugins/editor.lua)

### 编辑器增强
- **[Flash.nvim](lua/lazyvim/plugins/editor.lua)** - 智能跳转
- **[Grug Far](lua/lazyvim/plugins/editor.lua)** - 项目级搜索替换
- **[Which-key](lua/lazyvim/plugins/editor.lua)** - 快捷键提示
- **[Trouble.nvim](lua/lazyvim/plugins/editor.lua)** - 诊断/引用面板
- **[Todo-comments](lua/lazyvim/plugins/editor.lua)** - TODO 注释管理

### UI 组件
- **[Bufferline](lua/lazyvim/plugins/ui.lua)** - 标签栏
- **[Lualine](lua/lazyvim/plugins/ui.lua)** - 状态栏
- **[Noice](lua/lazyvim/plugins/ui.lua)** - 现代化消息/命令行 UI
- **[Snacks.nvim](lua/lazyvim/plugins/ui.lua)** - 工具集（通知、输入、滚动等）

### 代码编辑
- **[Treesitter](lua/lazyvim/plugins/treesitter.lua)** - 语法高亮
- **[Mini 系列](lua/lazyvim/plugins/coding.lua)** - 轻量级工具（comment、pairs、surround 等）
- **[Yanky](lua/lazyvim/plugins/extras/coding/yanky.lua)** - 增强的复制粘贴

### 工具库
- **[Plenary.nvim](lua/lazyvim/plugins/util.lua)** - Lua 工具库
- **[Persistence.nvim](lua/lazyvim/plugins/util.lua)** - 会话管理
