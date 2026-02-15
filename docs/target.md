# 目标：从零实现自己的 Neovim 配置

本文档记录「脱离 LazyVim 等发行版、自己从零模仿实现」的配置目标与分步改造计划。

---

## 一、目标陈述

- **最终目标**：拥有一套**完全由自己从零实现**的 Neovim 配置，不依赖 LazyVim 等现成发行版；通过模仿与学习，理解并实现自己需要的功能。
- **配置身份**：使用 **`NVIM_APPNAME=nvim/my-nvim`**，与当前基于 LazyVim 的 `~/.config/nvim` 配置**隔离**，便于对比、迁移和逐步替换。
- **启动方式**：通过 `NVIM_APPNAME=nvim/my-nvim nvim`（或别名/包装脚本）启动「自实现配置」；默认 `nvim` 仍可继续使用现有 LazyVim 配置。

---

## 二、环境约定

| 项目 | 说明 |
|------|------|
| 新配置目录 | `$XDG_CONFIG_HOME/nvim/my-nvim/`（即 `~/.config/nvim/my-nvim/`） |
| 实现方式 | `NVIM_APPNAME=nvim/my-nvim`，仅影响 Neovim，不修改全局 XDG |
| 参考对象 | 当前 `~/.config/nvim`（LazyVim 本地配置）可作为功能与结构参考，但新配置中**不直接依赖** LazyVim 源码 |
| 插件管理 | 计划使用 lazy.nvim，但配置与目录结构由自己组织 |

---

## 三、分步改造计划（概要）

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

## 四、当前状态与下一步

- **已完成**：骨架 + lazy 引导 + 基础 options/keymaps。目录下已有 `init.lua`、`lua/config/{lazy,options,keymaps}.lua`、`lua/plugins/init.lua`；启动后具备基础编辑选项与剪贴板等键位。
- **待做**：按需在 `lua/plugins/` 添加插件 spec（主题、LSP、文件树等）。

---

## 五、文档维护

- 本文档（`target.md`）随改造推进可更新「当前状态与下一步」、细化各步骤的子任务或补充「已完成项」。
- 与 my-nvim 相关的说明（如目录结构、加载顺序）可放在 `docs/` 下单独文件，并在本目标中做链接或引用。
