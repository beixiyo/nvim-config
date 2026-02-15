# 外部工具依赖说明（fd / rg / fzf）

本文档说明本配置（基于 LazyVim 二次开发）对 **fd**、**rg（ripgrep）**、**fzf** 的依赖情况，以及 LazyVim 使用的替代或回退方案。便于在未安装部分工具时理解行为，或按需安装以获得最佳体验。

---

## 1. rg（ripgrep）

| 用途 | 是否使用 | 说明 |
|------|----------|------|
| **`:grep` 后端** | ✅ 使用 | `lua/lazyvim/config/options.lua` 中 `grepprg = "rg --vimgrep"`、`grepformat` 按 ripgrep 输出格式解析。未安装 rg 时，`:grep` 会报错，**此处无替代**。 |
| **Telescope 找文件** | ✅ 使用（首选） | `lua/lazyvim/plugins/extras/editor/telescope.lua` 的 `find_command()` 优先使用 `rg --files ...`。无 rg 时会回退到 fd → find/where。 |

**结论：** 若使用 `:grep` 或希望 Telescope 找文件更快，**建议安装 rg**。  
健康检查：`lua/lazyvim/health.lua` 会检查 `rg` 是否安装并给出提示。

---

## 2. fd

| 用途 | 是否使用 | 说明 |
|------|----------|------|
| **Telescope 找文件** | ✅ 使用（rg 之后的选项） | 同上 `find_command()`：无 rg 时使用 `fd`（或 Linux 下 `fdfind`），再无则用系统 `find`/`where`。 |

**结论：** **有替代**，不装 fd 也能用 Telescope 找文件（会回退到 find/where）。安装 fd 可提升体验。  
健康检查会检查 `fd` 或 `fdfind`，未安装仅警告，不阻止启动。

---

## 3. fzf（命令行工具）

| 用途 | 是否使用 | 说明 |
|------|----------|------|
| **LazyVim 选择器（Picker）** | ⚠️ 可选 | 选择器抽象支持 Snacks、Telescope、**fzf-lua**。fzf-lua 是 Neovim 插件，**可不装系统 fzf** 也能运行（有纯 Lua 实现）；安装 fzf 二进制时可加速。 |
| **健康检查** | 可选检查 | `health.lua` 会检查 `fzf` 是否在 PATH 中，未安装仅 warn，非必须。 |

**结论：** **不依赖**系统 fzf。模糊选择由 Snacks / Telescope / fzf-lua 等插件完成；仅在使用 fzf-lua 且希望更快时，可选择性安装 fzf 二进制。

---

## 4. 汇总表

| 工具 | 配置中是否使用 | 主要用途 | 有无替代 / 建议 |
|------|----------------|----------|------------------|
| **rg** | ✅ | `:grep` 后端；Telescope 找文件首选 | `:grep` 无替代，建议安装；Telescope 会回退到 fd/find |
| **fd** | ✅ | Telescope 找文件（rg 之后的选项） | 有回退：rg → fd/fdfind → find/where，可不装 |
| **fzf** | ⚠️ 可选 | 仅与 fzf-lua 搭配时可选加速 | 有：fzf-lua 可纯 Lua 运行；或直接用 Snacks/Telescope |

---

## 5. 相关文件索引

- **grepprg / grepformat**：`lua/lazyvim/config/options.lua`
- **Telescope find_command**：`lua/lazyvim/plugins/extras/editor/telescope.lua`
- **健康检查（rg / fd / fzf）**：`lua/lazyvim/health.lua`
- **Picker 与 fzf-lua**：`docs/custom-plugin-guide.md`、`lua/lazyvim/plugins/extras/editor/fzf.lua`
