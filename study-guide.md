# LazyVim 配置学习路径指南

## 🚀 快速参考

### 常用命令

| 命令 | 作用 |
|------|------|
| `:so` | 重新加载当前文件 |
| `:Lazy` | 打开插件管理器界面 |
| `:LazyExtras` | 管理可选功能模块 |
| `:checkhealth` | 检查配置健康状态 |
| `:Lazy reload <插件名>` | 重新加载特定插件 |
| `:Lazy sync` | 同步所有插件 |

### 常用配置位置

| 配置项 | 文件位置 |
|--------|---------|
| 行号、缩进等选项 | [lua/config/options.lua](lua/config/options.lua) |
| 快捷键 | [lua/config/keymaps.lua](lua/config/keymaps.lua) |
| 自动命令 | [lua/config/autocmds.lua](lua/config/autocmds.lua) |
| 自定义插件 | [lua/plugins/init.lua](lua/plugins/init.lua) 或 [lua/plugins/*.lua](lua/plugins/) |
| 查看默认快捷键 | [lua/lazyvim/config/keymaps.lua](lua/lazyvim/config/keymaps.lua) |
| 查看默认选项 | [lua/lazyvim/config/options.lua](lua/lazyvim/config/options.lua) |

### 学习顺序建议

1. ✅ **第一步**：修改 [lua/config/options.lua](lua/config/options.lua)，添加行号、缩进等基础选项
2. ✅ **第二步**：修改 [lua/config/keymaps.lua](lua/config/keymaps.lua)，添加几个常用的快捷键
3. ✅ **第三步**：查看 [lua/lazyvim/config/keymaps.lua](lua/lazyvim/config/keymaps.lua)，了解所有默认快捷键
4. ✅ **第四步**：在 [lua/plugins/init.lua](lua/plugins/init.lua) 中添加一个简单的插件
5. ✅ **第五步**：深入学习 LazyVim 的插件配置结构

---

## 💡 实用技巧

### 技巧 1：如何查看某个快捷键的定义？
```vim
:verbose map <leader>f    " 查看 <leader>f 的定义和来源
```

### 技巧 2：如何查看某个选项的值？
```vim
:set number?              " 查看 number 选项的值
:lua print(vim.opt.tabstop:get())  " 查看 tabstop 的值
```

### 技巧 3：如何测试插件配置？
在 [lua/plugins/init.lua](lua/plugins/init.lua) 中添加插件后：
1. 保存文件
2. 执行 `:Lazy sync` 安装插件
3. 重启 Neovim 或执行 `:Lazy reload <插件名>`

### 技巧 4：如何查看已加载的模块？
```vim
:lua print(vim.inspect(package.loaded))  " 查看所有已加载的模块
```

### 技巧 5：如何调试配置错误？
```vim
:checkhealth              " 检查配置健康状态
:messages                 " 查看错误消息
```

---

## 📝 需要修改的文件

### ✅ 你可以安全修改的文件（推荐）

| 文件路径 | 用途 | 优先级 |
|---------|------|--------|
| [lua/config/options.lua](lua/config/options.lua) | 自定义选项（行号、缩进等） | ⭐⭐⭐ 高 |
| [lua/config/keymaps.lua](lua/config/keymaps.lua) | 自定义快捷键 | ⭐⭐⭐ 高 |
| [lua/config/autocmds.lua](lua/config/autocmds.lua) | 自定义自动命令 | ⭐⭐ 中 |
| [lua/plugins/init.lua](lua/plugins/init.lua) | 添加自定义插件 | ⭐⭐ 中 |
| [lua/plugins/*.lua](lua/plugins/) | 创建新的插件配置文件 | ⭐⭐ 中 |

---

## 🔧 常用配置

### 选项配置 [lua/config/options.lua](lua/config/options.lua)
```lua
-- 显示行号
vim.opt.number = true

-- 显示相对行号
vim.opt.relativenumber = true

-- Tab 键宽度
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- 自动换行
vim.opt.wrap = false

-- 搜索高亮
vim.opt.hlsearch = true
```

### 快捷键配置 [lua/config/keymaps.lua](lua/config/keymaps.lua)
```lua
-- 添加保存文件的快捷键
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "保存文件" })

-- 添加退出快捷键
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "退出" })

-- 覆盖默认快捷键（例如：将文件查找改为 Ctrl+P）
vim.keymap.set("n", "<C-p>", function()
  require("snacks").pick("files")
end, { desc = "查找文件" })
```

### 自动命令配置 [lua/config/autocmds.lua](lua/config/autocmds.lua)
```lua
-- 打开文件时自动执行某些操作
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("MyAutoCmds", { clear = true }),
  callback = function()
    -- 例如：自动跳转到上次编辑的位置
    if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})
```

### 插件配置 [lua/plugins/init.lua](lua/plugins/init.lua)
```lua
return {
  -- 添加一个插件示例
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      -- 插件配置选项
    },
  },
}
```

---

## 🔄 如何立即看到效果

### 方法 1：重新加载配置文件（推荐）⭐

修改配置后，在 Neovim 中执行：
```vim
:so          " 重新加载当前文件（如果正在编辑配置文件）
```

或者：
```vim
:lua require("config.options")   " 重新加载 [options.lua](lua/config/options.lua)
:lua require("config.keymaps")   " 重新加载 [keymaps.lua](lua/config/keymaps.lua)
```

**注意**：某些配置（如插件配置）需要重启 Neovim 才能生效。

### 方法 2：重启 Neovim（最可靠）

1. 保存文件（`:w`）
2. 退出 Neovim（`:q` 或 `:qa`）
3. 重新打开 Neovim

**适用场景**：
- 修改了插件配置
- 修改了 [lua/config/lazy.lua](lua/config/lazy.lua)
- 添加了新插件

### 方法 3：使用 LazyVim 的重新加载命令
```vim
:Lazy reload <插件名>    " 重新加载特定插件
:Lazy sync              " 同步所有插件（安装/更新）
```

### 方法 4：实时测试 Lua 代码
```vim
:lua vim.opt.number = true              " 立即显示行号
:lua vim.keymap.set("n", "tt", ":echo 'test'<cr>")  " 立即测试快捷键
```
