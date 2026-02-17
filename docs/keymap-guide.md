# NeoVim 快捷键（Keymap）速查指南

> ```lua
> vim.keymap.set({mode}, {lhs}, {rhs}, {opts})
> ```
> - **mode**：在哪些模式下生效，例如 `"n"`（normal）、`{ "n", "v" }` 等  
> - **lhs**：按键本体（left-hand side），如 `<leader>ff`  
> - **rhs**：执行的动作（right-hand side），可为字符串或 Lua 函数  
> - **opts**：可选参数表，控制描述、是否静默、是否可递归等

---

## 1. `mode` —— 触发模式

| 取值                | 模式            | 说明                                     |
|---------------------|-----------------|------------------------------------------|
| `"n"`               | Normal          | 正常模式                                 |
| `"i"`               | Insert          | 插入模式                                 |
| `"v"`               | Visual          | 可视模式（字符选择）                     |
| `"x"`               | Visual Select   | 可视模式（区块选择）                     |
| `"s"`               | Select          | 选择模式                                 |
| `"o"`               | Operator-pending| 操作等待模式，例如 `d`、`y` 之后         |
| `"t"`               | Terminal        | 内置终端 buffer                          |
| `"c"`               | Command-line    | 命令行模式                               |
| `{ "n", "v" }` 等   | 多模式表        | 数组形式可一次绑定多个模式               |
| `""` / `nil`        | 默认为 `"n"`    | 如果缺省，则只在 Normal 模式生效         |

---

## 2. `lhs` —— 触发键

- 直接填写字符：`"gg"`、`"jk"` 等
- 特殊键使用尖括号：`"<leader>ff"`、`"<C-s>"`、`"<A-j>"`、`"<Space>"`、`"<Tab>"`……
- 支持 `<localleader>`（LazyVim 默认 `\`）
- 可组合：`"<leader><tab>]"`、`"<C-w><C-q>"` 等

> 若需要 `<Esc>` 作为触发，请写 `"<Esc>"` 或 `"<esc>"`

---

## 3. `rhs` —— 真正执行的动作

### 3.1 字符串形式
- 直接传入可执行的 Vim 命令串，如：`"<cmd>w<cr>"`、`":echo 'hi'<CR>"`、`"<C-w>h"`
- 结尾务必加 `<CR>` 以执行命令
- 也可以写纯按键序列，例如 `"` (用于复制)、`"o<esc>"`（在下方插入新行并退出）

#### `<cmd>xxx<cr>` vs `:xxx<CR>` 的区别

在 Neovim 中，执行命令有两种写法，它们有重要区别：

**`<cmd>xxx<cr>` - Neovim 推荐方式**

```lua
vim.keymap.set("n", "C-s", "<cmd>w<cr>", { desc = "保存" })
```

**`:xxx<CR>` - 传统方式**

```lua
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "保存" })
```

**对比表格：**

| 特性 | `<cmd>xxx<cr>` | `:xxx<CR>` |
|------|----------------|------------|
| 命令历史 | ❌ 不显示 | ✅ 显示 |
| 命令行事件 | ❌ 不触发 | ✅ 触发 |
| 执行速度 | ✅ 更快 | ⚠️ 较慢 |
| 插件拦截 | ✅ 不易被拦截 | ⚠️ 可能被拦截 |
| 推荐度 | ✅ **推荐** | ⚠️ 传统方式 |

**推荐做法：**
- 优先使用 `<cmd>xxx<cr>` 方式
- 只有在需要命令历史或触发事件时才使用 `:xxx<CR>`

### 3.2 函数形式
- 传入 Lua 函数，便于编写复杂逻辑或调用插件 API
- 函数内可调用 `vim.cmd()`, `vim.notify()`, `Snacks.xxx()` 等

```lua
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
```

> 函数模式下默认 `rhs` 不是表达式；若需返回字符串让 Neovim继续处理，需要 `expr = true`，见下文

---

## 4. `opts` —— 选项表

| 选项          | 类型     | 默认值 | 作用 & 常见用法 |
|---------------|----------|--------|-----------------|
| `desc`        | string   | nil    | which-key/`:` 显示的描述，强烈建议填写（支持中文） |
| `silent`      | boolean  | true   | 是否隐藏命令回显。`false` 可用于调试 |
| `noremap`     | boolean  | true   | 是否禁止递归映射。LazyVim 默认 `true` |
| `remap`       | boolean  | false  | 与 `noremap=false` 相同，只是更直观 |
| `expr`        | boolean  | false  | `rhs` 返回一个字符串作为按键继续执行，常见于动态选择 `gj/j` |
| `buffer`      | number?  | nil    | 设为 buffer id 或 `0`，则仅对当前 buffer 生效 |
| `nowait`      | boolean  | false  | 避免键位等待其它潜在按键（与 `timeoutlen` 相关） |
| `replace_keycodes` | boolean | true | 当 `expr=true` 时自动解析 `<CR>` 等特殊符号 |
| `ft`（LazyVim扩展） | string/string[] | nil | 仅在匹配的 filetype 下注册（`LazyVim.safe_keymap_set` 支持） |
| 其它          | any      | -      | 传给 `vim.keymap.set` 的 `opts` 表会原样存放，可自行扩展 |

#### 4.1 `remap` 和 `noremap` 详解（递归映射 vs 非递归映射）

这是 Neovim 中最容易混淆的概念之一。让我们用具体例子来理解：

**核心概念：**
- **`noremap = true`**（默认）：**非递归映射** - `rhs` 中的按键**不会**再次触发映射
- **`remap = true`**（或 `noremap = false`）：**递归映射** - `rhs` 中的按键**会**再次触发映射

---

**例子 1：理解递归映射的问题**

假设你有以下配置：

```lua
-- 配置 1：将 h 映射为左移（这很危险！）
vim.keymap.set("n", "h", "l", { noremap = false })  -- 递归映射

-- 配置 2：将 <leader>h 映射为 h
vim.keymap.set("n", "<leader>h", "h", { noremap = true })  -- 非递归映射
```

**问题：**
- 当你按 `<leader>h` 时，它执行 `h`
- 但 `h` 已经被映射为 `l`（左移变成了右移！）
- 所以 `<leader>h` 实际上会执行 `l`（右移），而不是原来的 `h`（左移）

**解决方案：使用 `noremap = true`**

```lua
-- 正确做法：使用非递归映射
vim.keymap.set("n", "<leader>h", "h", { noremap = true })  -- 直接执行 h，不再触发映射
```

---

**你的配置文件中的实际例子**

```lua
-- 你的配置：Alt + Left/Right 跳转历史
map("n", "<A-Left>", "<C-o>", { desc = "跳转到上一个光标位置", remap = true })
```

**为什么这里用 `remap = true`？**

- `<C-o>` 是 Neovim 的原生按键（跳转到上一个位置）
- 使用 `remap = true` 意味着：如果 `<C-o>` 被其他插件或配置映射了，会触发那个映射
- 使用 `noremap = true` 意味着：直接执行原始的 `<C-o>`，忽略所有映射

**推荐做法：**
- 如果 `<C-o>` 是原生功能，通常用 `noremap = true`（更安全）
- 如果希望 `<C-o>` 能触发其他映射，用 `remap = true`

> **LazyVim 专属加强**  
> `LazyVim.safe_keymap_set` 会：  
> - 自动处理 `desc`（供 which-key 展示）  
> - 避免重复绑定 （比如多个模块定义同样的键）  
> - 支持 `ft` 条件加载  
> 在自己配置文件中推荐直接使用 `vim.keymap.set`，确保你能感知所有注册的映射

---

## 5. 实战示例

### 示例 1：最常见的保存快捷键
```lua
vim.keymap.set({ "i", "n", "v" }, "<C-s>", "<cmd>w<cr>", {
  desc = "Save File / 保存当前文件",
  silent = true,
})
```
- 模式：插入、普通、可视模式都能用  
- 行为：执行 `:w` 保存  
- `desc` 会在 which-key 或通知中显示

### 示例 2：表达式映射（软换行友好）
```lua
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
  expr = true,
  silent = true,
  desc = "Down / 向下移动（兼容软换行）",
})
```
- `expr = true` 表示 `rhs` 结果将作为新的按键执行  
- `v:count` 读取用户输入的重复次数（例如 `5j`）  
- 实现逻辑：没有输入数字时，用 `gj`；否则保持普通 `j`

### 示例 3：只在特定文件类型启用（LazyVim）
```lua
LazyVim.safe_keymap_set({ "n", "x" }, "<localleader>r", function()
  Snacks.debug.run()
end, {
  desc = "Run Lua / 运行当前选区",
  ft = "lua",
})
```
- `ft = "lua"` 仅在 lua buffer 中注册  
- 使用 `LazyVim.safe_keymap_set` 防止重复绑定  
- `Snacks.debug.run()` 是 LazyVim 内置工具

### 示例 4：Buffer 级别映射
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", {
      buffer = event.buf,
      desc = "Preview Markdown",
    })
  end,
})
```
- 通过 `buffer = event.buf` 让快捷键只在该 buffer 生效  
- 适用于插件窗口或临时 buffer
