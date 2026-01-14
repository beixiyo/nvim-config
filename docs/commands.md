# LazyVim 实用命令速查

> 本文档整理了 LazyVim 配置中常用的命令，方便快速查找和使用。

## 🔌 插件管理命令

### Lazy 插件管理器

| 命令 | 功能 | 说明 |
|------|------|------|
| `:Lazy` | 打开插件管理界面 | 查看已安装的插件、状态、启用/禁用插件 |
| `:Lazy install` | 安装缺失的插件 | 安装配置文件中定义但未安装的插件 |
| `:Lazy update` | 更新所有插件 | 将所有插件更新到最新版本 |
| `:Lazy reload` | 重新加载配置 | 修改插件配置后，无需重启 Neovim |
| `:Lazy reload {plugin}` | 重新加载特定插件 | 例如：`:Lazy reload telescope.nvim` |
| `:Lazy health` | 检查插件健康状态 | 检查插件是否有问题 |
| `:LazyExtras` | 打开 Extras 界面 | 启用/禁用可选插件模块（按 `x` 键切换） |

**使用场景：**
- 修改插件配置后：使用 `:Lazy reload` 或 `:Lazy reload {plugin}` 重新加载
- 添加新插件后：使用 `:Lazy install` 安装
- 更新插件：使用 `:Lazy update` 更新所有插件

---

## 🐛 调试和检查命令

### 健康检查

| 命令 | 功能 | 说明 |
|------|------|------|
| `:checkhealth` | 检查 Neovim 健康状态 | 检查 Neovim 和插件的健康状态 |
| `:messages` | 查看错误消息 | 查看最近的错误和警告消息 |
| `:Lazy health` | 检查插件健康状态 | 检查 Lazy 管理的插件状态 |

### 查看映射来源

| 命令 | 功能 | 说明 |
|------|------|------|
| `:verbose imap <C-e>` | 查看插入模式映射来源 | 查看 `<C-e>` 在插入模式下的映射来源 |
| `:verbose map {lhs}` | 查看映射来源 | 查看任意按键的映射来源，例如：`:verbose map <leader>f` |
| `:map {lhs}` | 查看映射 | 查看按键映射（不显示来源） |

**示例：**
```vim
" 查看 <C-e> 的映射来源
:verbose imap <C-e>

" 查看 <leader>f 的映射来源
:verbose map <leader>f

" 查看所有 Normal 模式的映射
:map
```

---

## ⚙️ 配置相关命令

### 重新加载配置

| 命令 | 功能 | 说明 |
|------|------|------|
| `:source %` | 重新加载当前文件 | 重新执行当前打开的配置文件 |
| `:Lazy reload` | 重新加载所有插件配置 | 修改插件配置后使用 |
| `:Lazy reload {plugin}` | 重新加载特定插件 | 只重新加载指定的插件 |

**使用场景：**
- 修改 `lua/config/options.lua` 后：使用 `:source %` 或重启 Neovim
- 修改插件配置后：使用 `:Lazy reload` 或 `:Lazy reload {plugin}`

---

## ⌨️ 快捷键相关命令

### 查看快捷键

| 命令 | 功能 | 说明 |
|------|------|------|
| `<leader>?` | 查看当前快捷键 | 使用 which-key 显示当前可用的快捷键 |
| `:Telescope keymaps` | 搜索快捷键 | 使用 Telescope 搜索所有快捷键（需要启用 Telescope） |

**说明：**
- `<leader>?` 是 which-key 插件提供的功能，会显示当前上下文中可用的快捷键
- `:Telescope keymaps` 可以搜索所有已定义的快捷键

---

## 🔍 文件搜索命令

### Telescope 命令

| 命令 | 功能 | 说明 |
|------|------|------|
| `:Telescope find_files` | 查找文件 | 打开文件搜索界面 |
| `:Telescope keymaps` | 搜索快捷键 | 搜索所有快捷键定义 |

**注意：** 这些命令需要启用 Telescope extra（`:LazyExtras` 中启用 `editor.telescope`）

---

## 💻 Lua 调试命令

### 查看配置信息

| 命令 | 功能 | 说明 |
|------|------|------|
| `:lua print(vim.inspect(vim.opt.rtp:get()))` | 查看 runtimepath | 查看 Neovim 的运行时路径列表 |
| `:lua print(package.searchpath("config.options", package.path))` | 测试模块路径 | 检查模块是否能被找到 |
| `:lua print(vim.inspect(package.loaded))` | 查看已加载的模块 | 查看所有已加载的 Lua 模块 |
| `:lua print("当前 Picker:", LazyVim.pick.picker.name)` | 查看当前 Picker | 查看当前使用的文件搜索工具（Snacks/Telescope/FZF） |

### 调试配置

在配置文件中使用 `print()` 或 `vim.notify()` 输出调试信息，然后使用 `:messages` 查看：

```lua
-- 在 opts 函数中添加调试输出
opts = function(_, opts)
  -- 打印默认配置（调试用）
  print(vim.inspect(opts))
  
  -- 或者使用 vim.notify
  vim.notify("配置已加载", vim.log.levels.INFO)
  
  return vim.tbl_deep_extend("force", opts, {
    -- 你的配置
  })
end
```

然后执行 `:messages` 查看输出。

---

## 📚 相关文档

- [getting-start.md](getting-start.md) - 初学者指南
- [keymap-guide.md](keymap-guide.md) - 快捷键配置指南
- [lua-config.md](lua-config.md) - Lua 配置说明
- [custom-plugin-guide.md](custom-plugin-guide.md) - 插件配置指南
