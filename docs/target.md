# 目标：从零实现自己的 Neovim 配置

本文档记录「脱离 LazyVim 等发行版、自己从零模仿实现」的配置目标与分步改造计划。

---

## 一、目标陈述

- **最终目标**：拥有一套**完全由自己从零实现**的 Neovim 配置，**不依赖 LazyVim 发行版**；通过模仿与学习，理解并实现自己需要的功能。
- **配置身份**：使用 **`NVIM_APPNAME=nvim/my-nvim`**，与当前基于 LazyVim 的 `~/.config/nvim` 配置**隔离**，便于对比、迁移和逐步替换。
- **启动方式**：通过 `NVIM_APPNAME=nvim/my-nvim nvim`（或别名/包装脚本）启动「自实现配置」；默认 `nvim` 仍可继续使用现有 LazyVim 配置。

---

## 二、名词区分（避免混淆）

| 名词 | 含义 | my-nvim 是否使用 |
|------|------|------------------|
| **lazy.nvim** | 插件**管理器**（Folke 的 `folke/lazy.nvim`），负责安装、加载、懒加载插件。 | ✅ **使用**。`lua/config/lazy.lua` 里克隆并 `require("lazy").setup(...)` 的就是它。 |
| **LazyVim** | 基于 Neovim 的**发行版**（`LazyVim/lazyvim`），内置大量插件、`LazyVim.*` / Snacks 等框架，内部用 lazy.nvim 做插件管理。 | ❌ **不依赖**。my-nvim 中不 `require("lazyvim")`，不引用其 lua 源码或配置。 |

因此：**「不依赖 LazyVim」= 不用 LazyVim 发行版；「用 lazy.nvim」= 只用其插件管理器，配置与目录完全自己写。** 二者不矛盾。

---

## 三、环境约定

| 项目 | 说明 |
|------|------|
| 新配置目录 | `$XDG_CONFIG_HOME/nvim/my-nvim/`（即 `~/.config/nvim/my-nvim/`） |
| 实现方式 | `NVIM_APPNAME=nvim/my-nvim`，仅影响 Neovim，不修改全局 XDG |
| 参考对象 | 当前 `~/.config/nvim`（LazyVim 本地配置）可作为功能与结构**参考**，但 my-nvim 中**不 require 任何 LazyVim 源码**。 |
| 插件管理 | 使用 **lazy.nvim**（插件管理器）；插件列表、目录结构、键位/选项等全部在 my-nvim 内自己组织。 |

---

## 四、分步改造计划（概要）

按「先跑通、再补齐」的顺序推进，每一步都可单独验证。

1. **搭建 my-nvim 配置骨架**
   - 创建 `~/.config/nvim/my-nvim/` 及最小 `init.lua`（仅做 rtp、必要选项或空 require，保证 `NVIM_APPNAME=nvim/my-nvim nvim` 能正常启动）。
   - 可选：在 `init.lua` 中设置 `vim.opt.rtp:prepend(vim.fn.stdpath("config"))`，与当前 nvim 配置行为一致。

2. **引入 lazy.nvim（仅插件管理）**
   - 在 my-nvim 中自建 lazy 引导逻辑（参考现有 `lua/config/lazy.lua` 的安装与 `require("lazy").setup`），不引入 LazyVim 的 spec/插件集。
   - 确定插件列表的入口（如 `lua/plugins/init.lua` 或单文件），只安装 lazy.nvim 及少量必要插件，确认能安装、能加载。

3. **按需迁移/实现核心能力**
   - 对照当前 nvim 配置中**自己实际用到的**功能（选项、键位、外观、LSP、文件树、主题等），在 my-nvim 中逐一用「自己的 lua 配置 + 少量插件」实现。
   - 每块功能在 my-nvim 中独立可测（如只开 options、只开 keymaps、再开 LSP 等），避免一次迁移过多。

4. **文档与可维护性**
   - 在 `docs/` 下维护「my-nvim 的加载顺序、目录说明、与 nvim 的差异」（可仿照现有 `loading-order.md` 的风格），便于后续迭代和排查。

5. **（可选）收敛为默认配置**
   - 当 my-nvim 满足日常使用后，可考虑将默认 `nvim` 指向该配置（例如通过别名或 `NVIM_APPNAME` 默认值），或保留双配置长期并存。

---

## 五、Snacks 替换一览（my-nvim）

为减少独立插件、统一用 **folke/snacks.nvim** 提供的能力，以下功能已用 Snacks 替换，并已按文档验证。

| 原插件 / 能力 | Snacks 替代 | 说明 |
|---------------|-------------|------|
| **goolord/alpha-nvim** | `Snacks.dashboard` | 启动欢迎页与快捷按钮在 `plugins/snacks.lua` 的 dashboard 预设中配置；无文件启动时自动显示。 |
| **ibhagwan/fzf-lua** | `Snacks.picker` | 找文件 / 搜内容用 fd、rg（内置优先 fd→rg→find；grep 固定 rg）。键位：`<leader>ff` 找文件、`<leader>sg` grep、`<leader>fr` 最近、`<leader>fb` 缓冲区等，见 `plugins/snacks.lua` keys。 |
| **akinsho/toggleterm.nvim** | `Snacks.terminal` | 键位 `Ctrl+\` 或 `<leader>ft` 打开/切换浮动或分屏终端。 |
| （buffer 关闭逻辑） | `Snacks.bufdelete` | bufferline.nvim 的关闭/右键关闭已依赖 `Snacks.bufdelete`，不破坏布局。 |
| （通知样式） | `Snacks.notifier` | 启用后替代 `vim.notify`，与 Noice 等共用。 |

**未替换**（继续使用原插件）：neo-tree（文件树）、noice（cmdline/消息 UI）、which-key、flash、blink.cmp、render-markdown、treesitter、theme、lualine、bufferline（仅用 Snacks.bufdelete）。

---

## 六、当前状态与下一步（含 LSP 规划）

- **已完成**：骨架 + lazy 引导 + 基础 options/keymaps。**窗口焦点**：`Ctrl-h`/`Ctrl-j`/`Ctrl-k`/`Ctrl-l` 在分屏与终端间切换（`lua/config/keymaps.lua`）。**文件树**：neo-tree.nvim，`<leader>e` / `<leader>ge` / `<leader>be`。**Markdown 渲染**：render-markdown.nvim，`<leader>mr` / `<leader>mp`。**欢迎页 / 找文件 / 搜内容 / 终端**：已统一为 Snacks（dashboard、picker、terminal），见上一节；原 alpha-nvim、fzf-lua、toggleterm 已移除。**Buffer 标签**：bufferline.nvim，关闭用 `Snacks.bufdelete`。
- **待做（LSP 相关）**：
  - 在 `lua/plugins/lsp/` 或 `lua/plugins/code/` 下新增 LSP spec（如 `nvim-lspconfig` + `mason.nvim` + `mason-lspconfig.nvim`），独立于 LazyVim。
  - 为常用语言（至少：Lua、TypeScript/JavaScript、Python、Go）配置基础 server、根目录探测、诊断样式。
  - 使用 Snacks 或内置 `vim.diagnostic` 的 minimal UI，后续再考虑 noice 等增强。
  - 在 `lua/config/keymaps.lua` 中补充 LSP 通用键位（如：`gd` 跳转定义、`gr` 引用、`K` 悬浮文档、`<leader>rn` 重命名、`<leader>ca` code action 等）。
  - 在 `docs/` 中新增 LSP 专门说明，记录「安装哪些 language server、如何与 mason 集成、常用快捷键」。

---

## 七、文档维护

- 本文档（`target.md`）随改造推进可更新「当前状态与下一步」、细化各步骤的子任务或补充「已完成项」。
- 与 my-nvim 相关的说明（如目录结构、加载顺序）可放在 `docs/` 下单独文件，并在本目标中做链接或引用。
