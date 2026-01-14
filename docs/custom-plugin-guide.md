# LazyVim Telescope 配置指南

> **📚 LazyVim 官方文档参考：**
> - **Extras 插件说明**：https://www.lazyvim.org/extras
> - **插件配置文档**：https://www.lazyvim.org/configuration/plugins
> - **LazyVim 官网**：https://www.lazyvim.org/

## ⚡ 默认 Picker 说明

### 当前使用的 Picker

LazyVim 支持三种文件搜索工具（picker），根据版本和配置自动选择：

| Picker | LazyVim 版本 | 特点 | 性能 |
|--------|-------------|------|------|
| **Snacks.nvim** | 8.x **默认** | 轻量、现代化、无外部依赖 | ⭐⭐⭐⭐ LuaJIT + 原生 C API |
| **Telescope.nvim** | 7.x 默认 | 功能最丰富、高度可扩展 | ⭐⭐⭐⭐⭐（可选 FZF 扩展） |
| **FZF-Lua** | 可选 | 速度快、传统 FZF 体验 | ⭐⭐⭐⭐⭐ C 实现 |

### 如何判断当前使用的 Picker？

#### 方法 1：查看配置文件

**判断文件位置**：`lua/lazyvim/config/init.lua`（第 482-486 行）

```lua
-- 根据 install_version 判断：
if (LazyVim.config.json.data.install_version or 7) < 8 then
  -- 版本 < 8：使用 telescope（默认）
else
  -- 版本 >= 8：使用 snacks（默认，数组中第一个）
end
```

**查看你的版本**：打开 `lazyvim.json`，查看 `install_version` 字段：
- `install_version: 8` → 默认使用 **Snacks**
- `install_version: 7` → 默认使用 **Telescope**

#### 方法 2：在 Neovim 中检查

```vim
:lua print("当前 Picker:", LazyVim.pick.picker.name)
```

### Picker 区别对比

| 特性 | Snacks.nvim | Telescope.nvim | FZF-Lua |
|------|------------|----------------|---------|
| **实现语言** | Lua + Neovim C API | Lua（可加 C 扩展） | C 核心 |
| **启动速度** | 快（轻量） | 中等 | 快 |
| **功能丰富度** | ⭐⭐⭐ 基础功能 | ⭐⭐⭐⭐⭐ 功能最多 | ⭐⭐⭐⭐ 功能丰富 |
| **扩展生态** | 较少 | ⭐⭐⭐⭐⭐ 数百个扩展 | 中等 |
| **外部依赖** | ❌ 无依赖 | ✅ 可选依赖 | ✅ 需要 fzf 二进制 |
| **推荐场景** | 日常使用、LazyVim 用户 | 需要高级功能 | 追求极致速度 |

**性能说明**：
- **Snacks**：虽然用 Lua 编写，但调用 Neovim 原生 C API（`vim.uv`、`vim.fs`），配合 LuaJIT 性能接近原生 C
- **Telescope**：可安装 `telescope-fzf-native` 扩展，使用 C 实现的 FZF 算法，性能提升 10-20 倍
- **FZF-Lua**：核心算法用 C 实现，处理大型项目时速度最快

### 切换 Picker

如果你当前使用的是 **Snacks**，想切换到 **Telescope**：

1. 执行 `:LazyExtras`
2. 找到 `editor.telescope` 并按 `x` 启用
3. 重启 Neovim

或者设置全局变量（在 `lua/config/options.lua`）：
```lua
vim.g.lazyvim_picker = "telescope"  -- 或 "fzf" 或 "snacks"
```

---

## 一、启用 Telescope Extra

> **📝 注意**：LazyVim 8.x 默认使用 **Snacks.nvim** 作为文件搜索工具。如果你想要使用 **Telescope**，需要手动启用。

Telescope 在 LazyVim 中是一个 **extra**（可选插件），默认不启用。有两种方式启用：

### 方法 1：使用命令（推荐）

1. 在 Neovim 中执行命令：
   ```
   :LazyExtras
   ```

2. 在打开的界面中：
   - 找到 `editor.telescope` 选项
   - 按 `x` 键启用/禁用
   - 按 `q` 退出

### 方法 2：通过全局变量（程序化启用）

在 `lua/config/options.lua` 或 `init.lua` 中添加：

```lua
-- 启用 telescope 作为默认的 picker
vim.g.lazyvim_picker = "telescope"
```

## 二、自定义 Telescope 配置

LazyVim 使用 `opts` 函数来配置插件，这个函数会返回配置表。要自定义配置，你需要在 `lua/plugins/` 目录下创建配置文件。

### ⚠️ 重要：配置行为说明

**LazyVim 的配置加载机制：**

1. **加载顺序**：LazyVim 先加载默认配置（`lua/lazyvim/plugins/extras/editor/telescope.lua`），然后加载用户配置（`lua/plugins/` 目录下的文件）
2. **`opts` 函数参数**：`opts` 函数的第二个参数 `opts` 包含 **LazyVim 的默认配置**
3. **配置行为**：
   - **如果 `opts` 函数不接受 `opts` 参数**：你的配置会**完全覆盖** LazyVim 的默认配置（不推荐）
   - **如果 `opts` 函数接受 `opts` 参数并使用 `vim.tbl_deep_extend`**：你的配置会**深度合并**到默认配置中（推荐）

### 配置方式

在 `lua/plugins/` 目录下创建 `telescope.lua` 文件（或任何你喜欢的文件名），使用以下方式之一：

#### 方式 1：完全覆盖配置（不推荐）❌

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      -- ⚠️ 注意：这里没有接收 opts 参数
      -- 行为：完全覆盖 LazyVim 的默认配置
      -- 结果：会丢失 LazyVim 的所有优化设置和默认映射
      return {
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
        },
      }
    end,
  },
}
```

**行为说明**：这种方式会**完全替换** LazyVim 的默认配置，导致：
- ❌ 丢失所有 LazyVim 的默认映射（如 `<C-t>` 打开 Trouble）
- ❌ 丢失所有 LazyVim 的优化设置
- ❌ 丢失所有 LazyVim 的默认 picker 配置

#### 方式 2：深度合并配置（推荐）✅

这是推荐的方式，可以保留 LazyVim 的默认配置，只修改你需要改的部分：

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      -- ✅ opts 参数包含 LazyVim 的默认配置
      -- ✅ 使用 vim.tbl_deep_extend("force", ...) 进行深度合并
      -- 行为：深度合并配置，保留默认设置，只覆盖指定的部分
      return vim.tbl_deep_extend("force", opts, {
        defaults = {
          -- 只覆盖你想修改的部分
          prompt_prefix = "🔍 ",  -- 覆盖默认的 prompt_prefix
          selection_caret = "➤ ",  -- 覆盖默认的 selection_caret
          -- 添加新的映射（会合并到默认映射中）
          mappings = {
            i = {
              -- 添加新的快捷键：Ctrl+p 打开文件搜索
              ["<C-p>"] = function()
                require("telescope.builtin").find_files()
              end,
              -- 注意：默认映射（如 <C-t>）仍然保留
            },
          },
        },
        pickers = {
          find_files = {
            -- 修改文件查找的默认行为
            hidden = false,  -- 覆盖默认的 hidden 设置
            no_ignore = false,  -- 覆盖默认的 no_ignore 设置
          },
        },
      })
    end,
  },
}
```

**行为说明**：这种方式会**深度合并**配置：
- ✅ 保留所有 LazyVim 的默认映射和设置
- ✅ 只覆盖你明确指定的配置项
- ✅ 对于嵌套表（如 `mappings`），会进行深度合并
- ✅ 对于数组，`"force"` 模式会替换整个数组（如果需要合并数组，需要使用其他方法）

**`vim.tbl_deep_extend("force", ...)` 的行为：**
- `"force"` 模式：后面的配置会覆盖前面的同名配置
- 深度合并：对于嵌套表，会递归合并
- 数组处理：数组会被完全替换，不会合并元素

#### 方式 3：添加扩展插件

如果你想添加 Telescope 的扩展插件（如 `telescope-project.nvim`），在 `lua/plugins/telescope.lua` 文件中添加：

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      -- 添加扩展插件
      { "nvim-telescope/telescope-project.nvim" },
    },
    opts = function(_, opts)
      -- 加载扩展
      require("telescope").load_extension("project")
      
      -- 合并配置
      return vim.tbl_deep_extend("force", opts, {
        -- 你的自定义配置
      })
    end,
  },
  
  -- 扩展插件的配置
  {
    "nvim-telescope/telescope-project.nvim",
    config = function()
      -- 扩展插件的配置
    end,
  },
}
```

## 自定义配置示例

> **📝 说明**：以下配置选项需要添加到 `lua/plugins/telescope.lua` 文件中的 `opts` 函数内，作为自定义配置的一部分。这些选项会通过 `vim.tbl_deep_extend("force", opts, {...})` 合并到 LazyVim 的默认配置中。

### 修改提示符和图标

在 `lua/plugins/telescope.lua` 中使用：

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        defaults = {
          prompt_prefix = "🔍 ",          -- 提示符前缀
          selection_caret = "➤ ",         -- 选中项标记
          entry_prefix = "  ",             -- 条目前缀
          initial_mode = "insert",         -- 初始模式：insert 或 normal
          sorting_strategy = "ascending",  -- 排序策略
        },
      })
    end,
  },
}
```

## 验证配置

### 快速验证步骤（推荐）

配置完成后，按以下步骤验证：

1. **保存文件**：保存 `lua/plugins/telescope.lua`

2. **重新加载配置**：
   - 方法 1：在 Neovim 中执行 `:Lazy reload telescope.nvim`（只重新加载 Telescope 插件）
   - 方法 2：执行 `:Lazy reload`（重新加载所有配置）
   - 方法 3：重启 Neovim（完全重新加载）

3. **打开 Telescope 测试**：
   - 执行命令 `:Telescope find_files`

4. **验证图标是否生效**：
   - 查看提示符前缀：应该显示 `🔍`（你设置的自定义图标）
   - 查看选中项标记：用上下箭头选择文件时，应该显示 `➤`（你设置的自定义图标）
   - **如果看到这些自定义图标，说明配置生效了！**

### 调试配置（可选）

如果配置没有生效，可以使用以下方法调试：

```lua
opts = function(_, opts)
  -- 打印默认配置（调试用），在 nvim 中执行 :messages 查看
  print(vim.inspect(opts))
  
  -- 打印你的自定义配置，确认配置结构正确
  -- local custom_opts = {
  --   defaults = {
  --     prompt_prefix = "🔍 ",
  --   },
  -- }
  -- print("自定义配置:", vim.inspect(custom_opts))
  
  -- 确保使用深度合并
  return vim.tbl_deep_extend("force", opts, {
    -- 你的自定义配置
  })
end,
```
