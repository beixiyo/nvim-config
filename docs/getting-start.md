# LazyVim 使用技巧指南（初学者版）

> 本文档面向初学者，介绍 LazyVim 配置的常用技巧和快速学习方法。每个技巧都标注了对应的文件路径，方便你深入学习

## 基础概念

### 什么是 LazyVim？

LazyVim 是基于 Neovim 的 IDE 配置框架，它：
- 自动管理插件（使用 lazy.nvim）
- 提供开箱即用的功能（LSP、代码补全、格式化等）
- 支持高度自定义

**相关文件：**
- [`init.lua`](init.lua) - 入口文件，Neovim 启动时首先执行
- [lazy.lua](../lua/config/lazy.lua) - 插件管理器配置

### Leader 键是什么？

Leader 键是快捷键的前缀键，默认是**空格键**

**示例：**
- `<leader>f` = 按空格键，然后按 `f`
- `<leader>w` = 按空格键，然后按 `w`

**相关文件：**
- [options.lua](../lua/lazyvim/config/options.lua#L9) (第 9 行) - 定义 Leader 键

---

## 常用快捷键速查

> **快捷键类型说明：**
> - **内置快捷键**：LazyVim 框架提供的默认快捷键，定义在 `lua/lazyvim/config/keymaps.lua`
> - **自定义快捷键**：用户自定义的快捷键，定义在 `lua/config/keymaps.lua`（会覆盖同名的内置快捷键）
> 
> **如何区分：**
> - 查看表格中的"类型"列
> - 自定义快捷键的文件路径指向 `lua/config/keymaps.lua`
> - 内置快捷键的文件路径指向 `lua/lazyvim/config/keymaps.lua` 或其他 LazyVim 插件文件

### 🎯 最常用的快捷键

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>f` | 文件查找 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua) |
| `<leader>s` | 搜索 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua) |
| `<leader>sr` | 搜索替换 | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua) |
| `<leader>l` | 插件管理 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L159) |
| `<C-s>` | 保存文件 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L145) |
| `<leader>?` | 查看快捷键 | 内置 | which-key 插件 |
| `<leader>fp` | 切换项目 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |

**相关文件：**
- [keymaps.lua](../lua/lazyvim/config/keymaps.lua) - LazyVim 内置快捷键定义
- [keymaps.lua](../lua/config/keymaps.lua) - 用户自定义快捷键定义
- [editor.lua](../lua/lazyvim/plugins/editor.lua) - 编辑器相关快捷键

### 📁 文件操作

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>fn` | 新建文件 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L162) |
| `<leader>ff` | 查找文件（根目录） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fF` | 查找文件（当前目录） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fg` | Git 文件 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fr` | 最近文件 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fe` | 文件树（根目录） | 内置 | [snacks_explorer.lua](../lua/lazyvim/plugins/extras/editor/snacks_explorer.lua) |
| `<leader>fE` | 文件树（当前目录） | 内置 | [snacks_explorer.lua](../lua/lazyvim/plugins/extras/editor/snacks_explorer.lua) |
| `<leader>fp` | 切换项目 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fb` | 缓冲区列表（同 `<leader>,`） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fc` | 查找配置文件 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>fm` | mini.files 文件浏览 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L32) |

### 🔍 搜索功能

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>/` | 文本搜索（根目录） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>sg` | 文本搜索（根目录，同 `<leader>/`） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>sG` | 文本搜索（当前目录） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>sw` | 搜索光标下的词（根目录） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>sW` | 搜索光标下的词（当前目录） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>sb` | 搜索当前缓冲区 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>sr` | 搜索替换 | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua#L17) |
| `s` | Flash 跳转 | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua#L46) |
| `S` | Flash Treesitter | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua#L47) |

**说明：** Flash 是一个智能跳转工具，按 `s` 后输入两个字符，会高亮显示匹配位置，再按对应字母即可跳转

### 🪟 窗口管理

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<C-h/j/k/l>` | 切换窗口 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L61) |
| ``<C-`>`` | 切换终端显示 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L61) |
| `<C-Up/Down>` | 调整窗口高度 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L88) |
| `<C-Left/Right>` | 调整窗口宽度 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L90) |

**说明：** 
- 使用 `<C-h/j/k/l>` 可以快速在分割窗口间切换，比原生的 `<C-w>h` 更方便
- ``<C-`>`` 用于切换终端窗口的显示/隐藏（类似 VSCode 的终端切换快捷键，**自定义快捷键**）

### 📝 代码编辑

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<C-a>` | 智能增量（数字、日期、布尔值等） | 内置 | [dial.lua](../lua/lazyvim/plugins/extras/editor/dial.lua#L39) |
| `<C-c>` | 复制（可视/插入模式） | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L39) |
| `<C-v>` | 粘贴（普通/插入/可视模式） | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L43) |
| `<C-x>` | 智能减量（数字、日期、布尔值等） | 内置 | [dial.lua](../lua/lazyvim/plugins/extras/editor/dial.lua#L42) |
| `<C-z>` | 撤销 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L79) |
| `<C-S-z>` | 重做 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L84) |
| `<A-Left>` | 跳转到上一个光标位置 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L91) |
| `<A-Right>` | 跳转到下一个光标位置 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L93) |
| `<A-j/k>` | 移动行 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L94) |
| `<A-S-j/k>` | 复制行 | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L51) |
| `<C-/>` | 切换注释（单行/选中） | **自定义** | [keymaps.lua](../lua/config/keymaps.lua#L65) |
| `gcc` | 注释/取消注释（原映射） | 内置 | [coding.lua](../lua/lazyvim/plugins/coding.lua) |
| `gc` | 注释选中内容（原映射） | 内置 | [coding.lua](../lua/lazyvim/plugins/coding.lua) |

**说明：** 
- `<C-z>` 表示 Ctrl+Z，用于撤销（类似 VSCode 的撤销快捷键，**自定义快捷键**）
- `<C-S-z>` 表示 Ctrl+Shift+Z，用于重做（类似 VSCode 的重做快捷键，**自定义快捷键**）
- `<A-Left>` 表示 Alt+Left，用于跳转到上一个光标位置（类似 VSCode 的导航历史，**自定义快捷键**，对应原生的 `<C-o>`）
- `<A-Right>` 表示 Alt+Right，用于跳转到下一个光标位置（类似 VSCode 的导航历史，**自定义快捷键**，对应原生的 `<C-i>`）
- `<A-j>` 表示 Alt+j，用于向下移动当前行（**内置快捷键**）
- `<A-S-j>` 表示 Alt+Shift+j，用于向下复制当前行（类似 VSCode 的 Alt+Shift+DownArrow，**自定义快捷键**）
- `<C-/>` 表示 Ctrl+/，用于切换注释（类似 VSCode 的注释快捷键，**自定义快捷键**，覆盖了内置的打开终端功能）

### 📜 滚动和翻页

| 快捷键 | 功能 | 速记法 | 单词关联 |
|--------|------|--------|----------|
| `<C-f>` | 向下滚动一屏（向前翻页） | **F** = **Forward** | Forward（向前） |
| `<C-b>` | 向上滚动一屏（向后翻页） | **B** = **Backward** | Backward（向后） |
| `<C-d>` | 向下滚动半屏 | **D** = **Down** | Down（向下） |
| `<C-u>` | 向上滚动半屏 | **U** = **Up** | Up（向上） |
| `<C-e>` | 向下滚动一行 | **E** = **Easy** | Easy（简单，一行一行） |
| `<C-y>` | 向上滚动一行 | **Y** = **Yield** | Yield（让步，向上） |
| `zz` | 将当前行居中 | **z** = **center** | center（居中） |
| `zt` | 将当前行置顶 | **t** = **top** | top（顶部） |
| `zb` | 将当前行置底 | **b** = **bottom** | bottom（底部） |

**相关配置：**
- `scrolloff = 4`：光标上下保留 4 行视野（见 [options.lua](../lua/lazyvim/config/options.lua#L112)）
- `smoothscroll = true`：启用平滑滚动（见 [options.lua](../lua/lazyvim/config/options.lua#L121)）

### 💡 代码补全

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<C-Space>` | 手动触发代码补全 | 内置 | [nvim-cmp.lua](../lua/lazyvim/plugins/extras/coding/nvim-cmp.lua#L53) |
| `<C-n>` | 向下选择补全项 | 内置 | [nvim-cmp.lua](../lua/lazyvim/plugins/extras/coding/nvim-cmp.lua#L51) |
| `<C-p>` | 向上选择补全项 | 内置 | [nvim-cmp.lua](../lua/lazyvim/plugins/extras/coding/nvim-cmp.lua#L52) |

**测试方法：** 如果想验证某个快捷键的来源

直接查看映射来源：
```vim
:verbose imap <C-e>    " 查看插入模式下的 Ctrl+E 映射
```
如果显示来自 `nvim-cmp`，说明是内置功能

> **💡 提示：** 更多实用命令请查看 [commands.md](commands.md) - 命令速查表

### 🔄 缓冲区切换

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<S-h>` | 上一个缓冲区 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L102) |
| `<S-l>` | 下一个缓冲区 | 内置 | [keymaps.lua](../lua/lazyvim/config/keymaps.lua#L103) |
| `<leader>,` | 缓冲区列表（同 `<leader>fb`） | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |

### 🔧 LSP 功能

LSP（Language Server Protocol）提供了强大的代码导航、重构和智能提示功能。

#### 📍 代码导航

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `gd` | 跳转到定义 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L83) |
| `gr` | 查找引用（查看所有使用位置） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L84) |
| `gI` | 跳转到实现 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L85) |
| `gy` | 跳转到类型定义 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L86) |
| `gD` | 跳转到声明 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L87) |

#### 🔍 符号查找

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>ss` | 查找当前文件中的符号 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L170) |
| `<leader>sS` | 查找工作区中的符号 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua#L171) |

**使用场景：**
- `<leader>ss`：快速查找当前文件中的函数、类、变量等
- `<leader>sS`：在整个项目中搜索符号（跨文件）

#### 📝 重命名操作

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>cr` | 重命名符号（智能重构） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L95) |
| `<leader>cR` | 重命名文件 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L94) |

#### 💡 信息查看

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `K` | 显示悬停信息（函数文档、类型等） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L88) |
| `gK` | 显示签名帮助（函数参数提示） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L89) |
| `<C-k>` | 插入模式下显示签名帮助 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L90) |

#### ⚡ 代码操作

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>ca` | 代码操作（快速修复、重构等） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L91) |
| `<leader>cA` | 源操作（Source Action） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L96) |
| `<leader>cc` | 运行 Codelens | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L92) |
| `<leader>cC` | 刷新并显示 Codelens | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L93) |

**使用场景：**
- `<leader>ca`：快速修复错误、自动导入、生成代码等（根据上下文显示可用操作）
- `<leader>cA`：执行源操作（如自动生成 getter/setter）
- `<leader>cc`：运行代码镜头（Codelens）中的操作（如运行测试、查看引用数等）

#### 🔄 引用导航（文档高亮模式）

当启用文档高亮时（将光标放在符号上会自动高亮所有引用），可以使用以下快捷键：

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `]]` | 跳转到下一个引用 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L97) |
| `[[` | 跳转到上一个引用 | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L99) |
| `<A-n>` | 跳转到下一个引用（跨窗口） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L101) |
| `<A-p>` | 跳转到上一个引用（跨窗口） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L103) |

#### 🛠️ 其他 LSP 功能

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>cl` | 查看 LSP 信息（服务器状态、配置等） | 内置 | [init.lua](../lua/lazyvim/plugins/lsp/init.lua#L82) |
| `<leader>cS` | 打开 LSP 引用/定义列表（Trouble） | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua#L228) |

**相关文件：**
- [init.lua](../lua/lazyvim/plugins/lsp/init.lua) - LSP 核心配置和所有快捷键定义

### 🔀 Git 功能

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `]h` | 下一个 Git hunk | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua) |
| `[h` | 上一个 Git hunk | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua) |
| `<leader>ghs` | Stage hunk | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua) |
| `<leader>ghr` | Reset hunk | 内置 | [editor.lua](../lua/lazyvim/plugins/editor.lua) |
| `<leader>gs` | Git 状态 | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |
| `<leader>gd` | Git Diff | 内置 | [snacks_picker.lua](../lua/lazyvim/plugins/extras/editor/snacks_picker.lua) |

### 💾 会话管理

| 快捷键 | 功能 | 类型 | 文件位置 |
|--------|------|------|----------|
| `<leader>qs` | 恢复会话 | 内置 | [util.lua](../lua/lazyvim/plugins/util.lua) |
| `<leader>qS` | 选择会话 | 内置 | [util.lua](../lua/lazyvim/plugins/util.lua) |
| `<leader>ql` | 恢复最近会话 | 内置 | [util.lua](../lua/lazyvim/plugins/util.lua) |

---

## 自定义配置技巧

### 1. 添加自定义快捷键

**文件位置：** [keymaps.lua](../lua/config/keymaps.lua)

**当前已有的自定义快捷键：**
- `<C-z>` - 撤销（VSCode 风格）
- `<C-S-z>` - 重做（VSCode 风格）
- `<A-Left>` - 跳转到上一个光标位置（VSCode 风格）
- `<A-Right>` - 跳转到下一个光标位置（VSCode 风格）
- `<leader>fm` - mini.files 文件浏览
- `<A-S-j/k>` - 复制行（VSCode 风格）
- `<C-/>` - 切换注释（覆盖内置的打开终端功能）
- ``<C-`>`` - 切换终端显示（VSCode 风格）

**示例：**
```lua
-- 添加保存快捷键
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "保存文件" })

-- 添加退出快捷键
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "退出" })
```

**学习路径：**
1. 先看 [keymaps.lua](../lua/lazyvim/config/keymaps.lua) 了解内置快捷键
2. 查看 [keymaps.lua](../lua/config/keymaps.lua) 了解已有的自定义快捷键
3. 在 [keymaps.lua](../lua/config/keymaps.lua) 中添加自己的快捷键
4. 使用 `:Lazy reload` 重新加载配置

**注意：** 自定义快捷键会覆盖同名的内置快捷键，例如 `<C-/>` 覆盖了内置的打开终端功能

### 2. 修改编辑器选项

**文件位置：** [options.lua](../lua/config/options.lua)

**常用选项：**
```lua
-- 显示行号
vim.opt.number = true

-- 显示相对行号
vim.opt.relativenumber = true

-- Tab 键宽度
vim.opt.tabstop = 4

-- 自动缩进宽度
vim.opt.shiftwidth = 4

-- 使用空格代替 Tab
vim.opt.expandtab = true
```

**学习路径：**
1. 查看 [options.lua](../lua/lazyvim/config/options.lua) 了解默认选项
2. 在 [options.lua](../lua/config/options.lua) 中覆盖或添加选项
3. 重启 Neovim 或使用 `:source %` 重新加载

### 3. 添加自定义插件

**文件位置：** `lua/plugins/` 目录

**步骤：**
1. 在 `lua/plugins/` 目录下创建新文件（如 `my-plugin.lua`）
2. 使用以下格式：

```lua
return {
  {
    "作者名/插件名",
    opts = {
      -- 插件配置选项
    },
    keys = {
      { "<leader>xx", function() ... end, desc = "描述" }
    },
  },
}
```

**示例：** 查看 [init.lua](../lua/plugins/init.lua) 了解现有插件配置格式

**学习路径：**
1. 查看 `lua/lazyvim/plugins/` 目录下的插件配置示例
2. 在 `lua/plugins/` 中添加自己的插件
3. 运行 `:Lazy` 查看插件是否加载成功

### 4. 启用/禁用 Extras（可选插件）

**命令：** `:LazyExtras`

**说明：**
- Extras 是可选的插件模块（如语言支持、AI 工具等）
- 不会自动加载，需要手动启用
- 使用 `:LazyExtras` 打开界面，按 `x` 键启用/禁用

**相关文件：**
- [xtras.lua](../lua/lazyvim/plugins/xtras.lua) - Extras 加载逻辑
- [extras.lua](../lua/lazyvim/util/extras.lua) - Extras 管理工具

**常见 Extras：**
- `lang.python` - Python 语言支持
- `lang.typescript` - TypeScript 语言支持
- `ai.copilot` - GitHub Copilot 集成
- `editor.neo-tree` - 文件树

---

## 插件管理技巧

### 查看所有插件

**命令：** `:Lazy`

**功能：**
- 查看已安装的插件
- 查看插件状态（已加载/未加载/有更新）
- 启用/禁用插件
- 更新插件

### 安装新插件

1. 在 `lua/plugins/` 目录下创建配置文件
2. 运行 `:Lazy` 查看插件列表
3. 使用 `:Lazy install` 安装缺失的插件

### 更新插件

**命令：** `:Lazy update`

**说明：** 更新所有插件到最新版本

### 重新加载配置

**命令：** `:Lazy reload`

**使用场景：** 修改插件配置后，不需要重启 Neovim，使用此命令重新加载

**相关文件：**
- [lazy.lua](../lua/config/lazy.lua) - lazy.nvim 配置

---

## 文件结构说明

### 核心配置文件

```
nvim/
├── init.lua                    # 入口文件（Neovim 启动时执行）
│
├── lua/
│   ├── config/                 # 用户自定义配置
│   │   ├── autocmds.lua        # 自动命令（文件打开时执行的操作）
│   │   ├── keymaps.lua         # 自定义快捷键
│   │   ├── lazy.lua            # 插件管理器配置
│   │   └── options.lua          # 编辑器选项（行号、Tab 等）
│   │
│   ├── plugins/                # 用户自定义插件
│   │   └── init.lua            # 插件配置示例
│   │
│   └── lazyvim/                # LazyVim 框架代码（可修改学习）
│       ├── config/             # LazyVim 默认配置
│       │   ├── keymaps.lua     # 默认快捷键定义
│       │   ├── options.lua     # 默认选项配置
│       │   └── autocmds.lua    # 默认自动命令
│       │
│       └── plugins/            # LazyVim 插件配置
│           ├── coding.lua      # 代码补全、注释等
│           ├── editor.lua      # 编辑器增强功能
│           ├── ui.lua          # 界面相关插件
│           └── extras/         # 可选插件模块
│               ├── lang/       # 语言支持
│               ├── ai/         # AI 工具
│               └── editor/     # 编辑器工具
```

### 配置文件加载顺序

1. [`init.lua`](init.lua) - 首先执行，设置 runtimepath
2. [lazy.lua](../lua/config/lazy.lua) - 初始化插件管理器
3. `lua/lazyvim/config/*.lua` - 加载 LazyVim 默认配置
4. `lua/config/*.lua` - 加载用户自定义配置（会覆盖默认配置）
5. `lua/lazyvim/plugins/*.lua` - 加载 LazyVim 插件
6. `lua/plugins/*.lua` - 加载用户自定义插件

---

## 实用技巧

### 替换文本
1. 按 `:` 进入命令模式
2. 输入 `:%s/old/new/g`（替换所有匹配）
   - `%` = 整个文件
   - `s` = 替换（substitute）
   - `/old/new/` = 将 "old" 替换为 "new"
   - `g` = 全局（每行的所有匹配都替换）

**高级用法：**
```
:%s/old/new/gc    - 替换前确认（c = confirm）
:%s/old/new/g     - 替换所有（不确认）
:%s//new/g        - 使用上次搜索的内容，替换为 "new"
:5,10s/old/new/g - 只替换第 5-10 行
:'<,'>s/old/new/g - 替换可视模式下选中的内容
```

### 查看快捷键定义

**方法 1：** 使用 which-key
- 按 `<leader>?` 查看当前缓冲区的快捷键
- 按任意 `<leader>` 开头的组合键，会显示提示

**方法 2：** 直接查看文件
- [keymaps.lua](../lua/lazyvim/config/keymaps.lua) - LazyVim 内置快捷键（所有默认快捷键）
- [keymaps.lua](../lua/config/keymaps.lua) - 用户自定义快捷键（会覆盖内置快捷键）

### 调试配置问题

**命令：**
- `:checkhealth` - 检查 Neovim 健康状态
- `:messages` - 查看错误消息
- `:Lazy health` - 检查插件健康状态

### 快速查找配置

**技巧：** 使用 `<leader>f` 打开文件查找，然后输入配置文件名

**示例：**
- 输入 `keymaps` 找到 [keymaps.lua](../lua/config/keymaps.lua)
- 输入 `options` 找到 [options.lua](../lua/config/options.lua)

### 学习插件配置

**方法：** 查看 `lua/lazyvim/plugins/` 目录下的文件，每个文件都有详细的中文注释

**推荐阅读顺序：**
1. [coding.lua](../lua/lazyvim/plugins/coding.lua) - 代码补全、注释
2. [editor.lua](../lua/lazyvim/plugins/editor.lua) - 编辑器功能
3. [ui.lua](../lua/lazyvim/plugins/ui.lua) - 界面相关

---

## 常见问题

### Q: 如何知道某个功能对应的快捷键？

**A:** 
1. 按 `<leader>?` 查看当前可用的快捷键
2. 查看 [keymaps.lua](../lua/lazyvim/config/keymaps.lua) 文件
3. 使用 `:Telescope keymaps` 搜索快捷键

### Q: 修改配置后不生效？

**A:**
1. 检查文件语法是否正确（`:checkhealth`）
2. 使用 `:Lazy reload` 重新加载插件配置
3. 重启 Neovim（某些配置需要重启）

### Q: 如何添加新的插件？

**A:**
1. 在 `lua/plugins/` 目录下创建 `.lua` 文件
2. 参考 `lua/lazyvim/plugins/` 目录下的配置格式
3. 运行 `:Lazy` 查看插件是否加载

### Q: 如何禁用某个插件？

**A:**
1. 运行 `:Lazy`
2. 找到要禁用的插件
3. 按 `x` 键禁用（或删除对应的配置文件）

---

## 总结

- **配置文件位置：** `lua/config/` 目录
- **插件配置位置：** `lua/plugins/` 目录
- **默认配置参考：** `lua/lazyvim/config/` 目录
- **插件示例参考：** `lua/lazyvim/plugins/` 目录
