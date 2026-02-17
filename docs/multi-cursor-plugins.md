# Neovim 多光标插件对比

本文档对比主流 Neovim 多光标插件的定位、特性、键位与适用场景，便于按需选型。  
（VSCode 式体验：选中词后连续添加下一处 / 鼠标点击多处同时编辑。）

---

## 一、总览对比表

| 项目 | multicursor.nvim | multiple-cursors.nvim | multicursors.nvim | vim-visual-multi |
|------|------------------|----------------------|------------------|------------------|
| **仓库** | jake-stewart/multicursor.nvim | brenton-leighton/multiple-cursors.nvim | smoka7/multicursors.nvim | mg979/vim-visual-multi |
| **语言** | Lua | Lua | Lua | Vim script |
| **Neovim** | 需 1.0 分支 | 通用 | ≥ 0.9 | Vim/Neovim 通用 |
| **Stars（约）** | ~1.4k | ~385 | 较少 | ~4.7k |
| **鼠标添加光标** | ✅ Ctrl+左键（可改为 Alt） | ✅ Ctrl+左键（可改为 Alt） | ❌ 未在文档中提供 | ❌ 无 |
| **类 VSCode Ctrl+D** | ✅ `<leader>n`/`N` 匹配词/选区 | ✅ `<Leader>a` 全匹配 / `<Leader>d` 下一处 | ✅ `n`/`N` 下一处，`<Space>` 全匹配 | ✅ Ctrl-N 选词并加下一处 |
| **实现方式** | 真实执行 Vim 命令，兼容插件 | 多光标时覆盖键位，支持大量命令 | Hydra 模式 + 选区 API | 自有 VM 模式，模拟行为 |
| **依赖** | 无 | 无 | **hydra.nvim**、可选 nvim-treesitter | 无 |
| **文档** | `:h multicursor` | README + 兼容说明详细 | README + `:h multicursors` | `:help visual-multi` |

---

## 二、各插件简述

### 1. multicursor.nvim（jake-stewart）

- **特点**：多光标时**真实执行** Neovim 命令（不解析按键模拟），因此与补全、snippet、多数插件兼容较好；支持 Normal/Insert/Replace/Visual，undo 友好。
- **创建光标**：上下行 `<Up>`/`<Down>`；跳过行 `<leader><Up>`/`<Down>`；匹配词/选区 `<leader>n`/`N`（正向/反向）、`<leader>s`/`S` 跳过；**Ctrl+左键** 添加/移除光标（可自行改为 `<A-LeftMouse>` 实现 Alt+点击）。
- **高级**：operator 如 `gaip`、正则切分选区、诊断处加光标、对齐、转置、序列递增等；提供 Cursor API 可扩展。
- **适合**：希望“和单光标时行为一致、少踩坑”且需要鼠标/匹配/诊断等多源光标的用户。

### 2. multiple-cursors.nvim（brenton-leighton）

- **特点**：多光标期间**覆盖**部分键位，支持的命令列表很长（含 f/F/t/T、d/y/p、c/s、`%`、gg/G、缩进、J 等），插入模式下字符输入、补全、Backspace 等有专门实现；支持**分线粘贴**（粘贴多行时按光标数分行插入）。
- **创建光标**：`Ctrl+Down`/`Ctrl+Up` 上下加光标；**Ctrl+左键** 点击处添加/删除；`<Leader>a` 当前词全匹配；`<Leader>d`/`D` 下一处/仅跳转；visual 选区后 `<Leader>m` 按行加光标。
- **兼容**：文档中详细写了与 mini.move、mini.pairs、nvim-cmp、which-key 等的配合（pre_hook 禁用、custom_key_maps 等）。
- **适合**：想要“支持命令多、像 VSCode 那样用”且能接受多光标时键位被覆盖、需看兼容说明的用户。

### 3. multicursors.nvim（smoka7）

- **特点**：强依赖 **hydra.nvim**，有独立的 Normal/Insert/Extend 多光标模式，提示系统（hint）明显；可选 **nvim-treesitter** 做按语法节点扩展选区。
- **创建光标**：`MCstart`（当前词）/ `MCvisual`（上次 visual 选区）/ `MCpattern`（整 buffer 模式）/ `MCunderCursor`（当前字符）；模式内 `n`/`N` 下一处，`<Space>` 全匹配，`j`/`k`/`J`/`K` 上下加/跳过。
- **无鼠标**：README 未提供“点击添加光标”，若需要鼠标需自己用 API 或配合其他方式。
- **适合**：已用 Hydra、喜欢“模式+提示”且要 TreeSitter 扩展选区的用户。

### 4. vim-visual-multi（mg979）

- **特点**：Vim script、历史久、stars 多；有“光标模式”和“扩展模式”（类似 Normal/Visual），Tab 切换；支持宏、正则、对齐、转置等。
- **创建光标**：**Ctrl-N** 选当前词并加下一处（类似 VSCode Ctrl+D）；Ctrl-Down/Up 纵向加；n/N 下一处/上一处；q 跳过、Q 移除当前；无鼠标添加。
- **适合**：主用 Vim/Neovim 且不想引入 Lua 依赖、习惯 VM 键位和文档的用户。

---

## 三、按需求选型

| 需求 | 更合适的选项 |
|------|----------------|
| **要鼠标点击加光标（含 Alt+点击）** | multicursor.nvim 或 multiple-cursors.nvim（默认 Ctrl+左键，在配置中改为 `<A-LeftMouse>` 即可）。 |
| **要最接近 VSCode Ctrl+D（选词连续加下一处）** | 四者都支持；vim-visual-multi 的 Ctrl-N、multicursor.nvim 的 `<leader>n`、multiple-cursors.nvim 的 `<Leader>d`/`<Leader>a`、multicursors.nvim 的 `n`/`<Space>`。 |
| **尽量少和现有插件冲突** | multicursor.nvim（真实执行命令，不重写键位）。 |
| **支持的命令最多、文档最细** | multiple-cursors.nvim（含兼容列表与 custom_key_maps）。 |
| **已有 Hydra、要 TreeSitter 扩展选区** | multicursors.nvim。 |
| **零 Lua 依赖、纯 Vim 生态** | vim-visual-multi。 |

---

## 四、鼠标键位改为 Alt+点击示例

若选用 **multicursor.nvim** 或 **multiple-cursors.nvim**，希望用 **Alt+左键** 添加/删除光标（与 VSCode 一致）：

**multicursor.nvim：**

```lua
-- 将默认的 <c-leftmouse> 改为 <a-leftmouse>
vim.keymap.set("n", "<a-leftmouse>", mc.handleMouse)
vim.keymap.set("n", "<a-leftdrag>", mc.handleMouseDrag)
vim.keymap.set("n", "<a-leftrelease>", mc.handleMouseRelease)
```

**multiple-cursors.nvim：**

```lua
-- keys 里把 <C-LeftMouse> 换成 <A-LeftMouse>
{"<A-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = {"n", "i"}, desc = "Add or remove cursor"},
```

---

## 五、参考链接

- [jake-stewart/multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim)
- [brenton-leighton/multiple-cursors.nvim](https://github.com/brenton-leighton/multiple-cursors.nvim)
- [smoka7/multicursors.nvim](https://github.com/smoka7/multicursors.nvim)
- [mg979/vim-visual-multi](https://github.com/mg979/vim-visual-multi)
