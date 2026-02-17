# my-nvim：LSP 集成说明

本文档说明 my-nvim 中 LSP 的组成、安装方式与常用快捷键。

---

## 一、组成

| 组件 | 作用 |
|------|------|
| **mason.nvim** | 安装/管理 language server、formatter、linter 等二进制。 |
| **mason-lspconfig.nvim** | 将 mason 安装的 LSP 与 nvim-lspconfig 对接，自动 `lspconfig.xxx.setup`。 |
| **nvim-lspconfig** | 各语言 server 的 Neovim 配置（根目录探测、capabilities 等）。 |
| **blink.cmp** | 补全引擎，需在 LSP 中通过 `require("blink.cmp").get_lsp_capabilities()` 提供补全能力（由 mason-lspconfig 依赖链带入）。 |

配置入口：`my-nvim/lua/plugins/code/lsp.lua`。

---

## 二、安装 Language Server

1. 用 Mason 安装：`:Mason` 打开 UI，选择要装的 LSP（如 `lua_ls`、`ts_ls`、`pyright`、`gopls`）。
2. 或在 `lsp.lua` 的 `opts.ensure_installed` 中写上 server 名，例如：
   ```lua
   opts = {
     ensure_installed = { "lua_ls", "ts_ls", "pyright", "gopls" },
     automatic_enable = { exclude = {} },
   },
   ```
   lazy 加载该插件后，mason 会自动安装并交由 mason-lspconfig 启用。

根目录探测、单文件等行为由 nvim-lspconfig 各 server 的默认配置决定；若有特殊需求，可在 `config` 中对 `lspconfig` 做额外 `setup` 或重写。

---

## 三、常用快捷键（LspAttach 内注册）

键位在 `lua/plugins/code/lsp.lua` 的 `LspAttach` 里配置，仅在存在 LSP 客户端时生效。

| 键位 | 说明 |
|------|------|
| `gd` | 跳转到定义（多结果时走 Snacks.picker） |
| `gD` | 跳转到声明 |
| `gr` | 查找引用 |
| `gI` | 跳转到实现 |
| `gy` | 跳转到类型定义 |
| `K` | 悬停文档 |
| `gK` / `<C-k>`（插入模式） | 签名帮助 |
| `<leader>ca` | Code Action（普通/可视模式） |
| `<leader>cr` | 重命名 |
| `<leader>cf` | 格式化（当前 buffer / 选中区域） |
| `[d` / `]d` | 上一个/下一个诊断 |
| `<leader>xd` | 当前诊断浮层 |
| `<leader>xx` | 所有诊断（Snacks.picker） |
| `<leader>xX` | 当前缓冲区诊断 |
| `<leader>xl` | 诊断列表（loclist） |
| `<leader>ls` | 文档符号 |
| `<leader>lS` | 工作区符号 |
| `<leader>lci` / `<leader>lco` | 传入/传出调用 |

诊断与 LSP 选择类操作使用 Snacks.picker，与找文件、grep 等体验一致。

---

## 四、与 Snacks / 补全的配合

- **Snacks.picker**：用于 definitions、references、diagnostics、symbols、calls 等多结果选择。
- **blink.cmp**：补全由 LSP 通过 `get_lsp_capabilities()` 提供，snippet 由 blink 与 friendly-snippets 处理。

若需扩展某语言的 server 选项（如根目录、init_options），在 `lsp.lua` 的 `config` 中对 `require("lspconfig").xxx` 做额外 `setup` 即可。
