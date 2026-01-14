# LazyVim/Vim 快捷键（Keymap）速查指南

本指南面向初学者，帮助你快速掌握 `vim.keymap.set()`/`LazyVim.safe_keymap_set()` 的常用参数、可选值以及写法示例。

> **TL;DR**  
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

> 小技巧：LazyVim 内部大量使用 `{ "n", "x" }` 来覆盖 normal 与 visual（选择）模式。

---

## 2. `lhs` —— 触发键

- 直接填写字符：`"gg"`、`"jk"` 等
- 特殊键使用尖括号：`"<leader>ff"`、`"<C-s>"`、`"<A-j>"`、`"<Space>"`、`"<Tab>"`……
- 支持 `<localleader>`（LazyVim 默认 `\`）
- 可组合：`"<leader><tab>]"`、`"<C-w><C-q>"` 等

> 若需要 `<Esc>` 作为触发，请写 `"<Esc>"` 或 `"<esc>"`。

---

## 3. `rhs` —— 真正执行的动作

### 3.1 字符串形式
- 直接传入可执行的 Vim 命令串，如：`"<cmd>w<cr>"`、`":echo 'hi'<CR>"`、`"<C-w>h"`
- 结尾务必加 `<CR>` 以执行命令
- 也可以写纯按键序列，例如 `"` (用于复制)、`"o<esc>"`（在下方插入新行并退出）

### 3.2 函数形式
- 传入 Lua 函数，便于编写复杂逻辑或调用插件 API
- 函数内可调用 `vim.cmd()`, `vim.notify()`, `Snacks.xxx()` 等

```lua
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
```

> 函数模式下默认 `rhs` 不是表达式；若需返回字符串让 Neovim继续处理，需要 `expr = true`，见下文。

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

> **LazyVim 专属加强**  
> `LazyVim.safe_keymap_set` 会：  
> - 自动处理 `desc`（供 which-key 展示）  
> - 避免重复绑定 （比如多个模块定义同样的键）  
> - 支持 `ft` 条件加载  
> 在自己配置文件中推荐直接使用 `vim.keymap.set`，确保你能感知所有注册的映射。

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

---

## 6. 常见问题（FAQ）

1. **为什么按键不生效？**  
   - 是否被其它映射覆盖（`:verbose map {lhs}` 检查）  
   - 所在模式是否正确  
   - `<leader>`、`<localleader>` 是否与你期望一致（在 `options.lua` 中配置）
   - **有的终端不支持** Ctrl + Alt 系列，可以输入 `:echo getcharstr()` 后按下快捷键，看是否有捕捉到按键

2. **`desc` 有什么用？**  
   - which-key、`:map`、LazyVim 的通知栏都会展示描述，帮助记忆  
   - 建议中英文都写上，团队协作更易懂

3. **想要能重复触发原生映射怎么办？**  
   - 设置 `remap = true`（等价于 `noremap = false`）  
   - 例如希望 `<leader>h` 能调用到默认 `h` 操作

4. **如何删除已有映射？**  
   ```lua
   vim.keymap.del("n", "<leader>bd")
   -- LazyVim 提供 util: LazyVim.keymap.del(...)
   ```

---

## 7. 推荐学习顺序

1. 先熟悉 `mode` 与 `<leader>` / `<localleader>` 设置  
2. 学会通过 `desc` 描述含义，便于 which-key 展示  
3. 有需求时再逐步引入 `expr`、`buffer`、`nowait` 等高级选项  
4. 参考 `lua/lazyvim/config/keymaps.lua`，大量场景示例已经写好中文注释

祝你在 LazyVim 的快捷键世界玩得开心 🎉

