# Neovim 配置：文件加载顺序与模块协作

本文档说明当前项目从启动入口到各模块的**文件加载顺序**，以及**各模块如何协作**。

---

## 一、总体流程概览

```
init.lua
    │
    ├─ 1. 设置 runtimepath
    └─ 2. require("config.lazy")
              │
              ▼
        lua/config/lazy.lua
              │
              ├─ 3. 确保 lazy.nvim 已安装并加入 rtp
              └─ 4. require("lazy").setup({ spec = spec, ... })
                        │
                        ▼
                  lazy.nvim 解析 spec
                        │
                        ├─ 5. require("lazyvim.plugins")   [普通模式]
                        │        │
                        │        ├─ require("lazyvim.config").init()  ← LazyVim 早期初始化
                        │        └─ return { LazyVim/LazyVim, snacks, ... }
                        │
                        ├─ 6. require("plugins")          [普通模式]
                        │        └─ return { 用户插件列表 }
                        │
                        └─ 7. 按优先级加载插件
                                  │
                                  ├─ LazyVim 插件加载 → 触发 lazyvim.setup(opts)
                                  │        └─ require("lazyvim.config").setup(opts)
                                  │
                                  └─ VeryLazy 事件触发
                                            └─ 加载 keymaps、autocmds、format/news/root 等
```

---

## 二、按时间顺序的加载阶段

### 阶段 0：Neovim 启动

- Neovim 根据 `init` 选项找到配置入口（默认 `$XDG_CONFIG_HOME/nvim/init.lua`）。
- **唯一入口**：`init.lua`。

---

### 阶段 1：入口与 runtimepath（init.lua）

| 顺序 | 动作 | 说明 |
|------|------|------|
| 1 | `vim.opt.rtp:prepend(vim.fn.stdpath("config"))` | 把当前配置目录插到 rtp 最前，保证本配置优先被加载 |
| 2 | `require("config.lazy")` | 进入 lazy 与插件配置，**后续所有插件与 LazyVim 都由此触发** |
| 3 | Neovide 相关 `if vim.g.neovide` | 仅 Neovide 下设置字体与窗口行为 |

**重要**：入口只做两件事——设置 rtp、加载 `config.lazy`。不加载任何其他业务逻辑。

---

### 阶段 2：lazy.nvim 引导（lua/config/lazy.lua）

| 顺序 | 动作 | 说明 |
|------|------|------|
| 1 | 计算 `lazypath` | `stdpath("data") .. "/lazy/lazy.nvim"` |
| 2 | 若目录不存在则 `git clone` lazy.nvim | 首次使用自动安装 |
| 3 | `vim.opt.rtp:prepend(lazypath)` | 让 Neovim 能 `require("lazy")` |
| 4 | 根据 `vim.g.vscode` 决定 `spec` | 见下表 |
| 5 | `require("lazy").setup({ spec, defaults, install, ... })` | 启动 lazy.nvim，后续由 lazy 调度 |

**spec 分支**：

- **VSCode 环境**（`vim.g.vscode == true`）  
  - `spec = { { import = "plugins.vscode" } }`  
  - 只加载 `lua/plugins/vscode/init.lua` 里的插件；  
  - 本文件末尾会**手动**加载 `config.options`、`config.keymaps` 并做校验。
- **普通 Neovim**  
  - `spec = { { "LazyVim/LazyVim", import = "lazyvim.plugins" }, { "LazyVim/LazyVim", dir = stdpath("config") }, { import = "plugins" } }`  
  - 先展开 `lazyvim.plugins`，再合并本地 dir 覆盖，最后合并用户 `plugins`。

---

### 阶段 3：展开插件列表（lazy.nvim 内部）

lazy.nvim 会按 spec 中的 `import` 去 **require** 对应模块，用其返回值扩展插件列表。

#### 3.1 普通模式：`require("lazyvim.plugins")` → `lua/lazyvim/plugins/init.lua`

| 顺序 | 动作 | 说明 |
|------|------|------|
| 1 | 版本检查 | 若 Neovim < 0.11.2 则报错退出 |
| 2 | **`require("lazyvim.config").init()`** | **LazyVim 早期初始化**（见下） |
| 3 | `return { ... }` | 返回插件表：lazy.nvim 自身、LazyVim/LazyVim、folke/snacks.nvim 等 |

因此：**在任意 LazyVim 插件被加载之前**，`lazyvim.config.init()` 已经执行完毕。

#### 3.2 LazyVim 早期初始化：`lua/lazyvim/config/init.lua` 的 `M.init()`

| 顺序 | 动作 | 说明 |
|------|------|------|
| 1 | 防重入 | `if M.did_init then return end` |
| 2 | 把 LazyVim 插件 dir 加入 rtp | `vim.opt.rtp:append(plugin.dir)`（便于后续 require 本仓库内模块） |
| 3 | 预加载兼容 | `package.preload["lazyvim.plugins.lsp.format"]` → 重定向到 `LazyVim.format` |
| 4 | 延迟通知 | `LazyVim.lazy_notify()` |
| 5 | **`M.load("options")`** | 加载 **lazyvim.config.options** 与 **config.options**（用户选项） |
| 6 | 保存部分选项快照 | `M._options.indentexpr/foldmethod/foldexpr` |
| 7 | 剪贴板延迟 | 暂清空 clipboard，VeryLazy 时再恢复 |
| 8 | 弃用警告开关 | 若 `vim.g.deprecation_warnings == false` 则关闭 |
| 9 | **`LazyVim.plugin.setup()`** | 注册 LazyVim 的插件管理逻辑 |
| 10 | **`M.json.load()`** | 读取 lazyvim.json（extras、版本等） |

**结论**：在插件列表尚未完全展开、LazyVim 插件尚未执行 config 之前，**options 和 LazyVim 基础环境已经就绪**。

#### 3.3 用户插件列表：`require("plugins")` → `lua/plugins/init.lua`

- 返回用户在 `lua/plugins/` 下通过 `init.lua` 或其它被 import 的模块定义的插件表。
- lazy.nvim 会把它们与 `lazyvim.plugins` 返回的列表**合并**；同名字段由后面的 spec（如 `plugins`）覆盖。

---

### 阶段 4：插件加载与 LazyVim 主配置

lazy.nvim 按 **priority** 和 **lazy** 等规则加载插件。

- **LazyVim/LazyVim**：在 `lua/lazyvim/plugins/init.lua` 里被设为 `priority = 10000`、`lazy = false`，因此会**尽早、非延迟**加载。
- 当 lazy 加载「LazyVim/LazyVim」时，会从插件 `dir`（即 `stdpath("config")`）解析主模块并执行其配置。  
  本地结构中，主模块为 **lua/lazyvim/init.lua**，对外暴露 **`require("lazyvim").setup(opts)`**，内部调用 **`require("lazyvim.config").setup(opts)`**。

因此，**LazyVim 插件被加载时**会触发：

**`lua/lazyvim/config/init.lua` 的 `M.setup(opts)`**

| 顺序 | 动作 | 说明 |
|------|------|------|
| 1 | 合并配置 | `options = vim.tbl_deep_extend("force", defaults, opts or {})` |
| 2 | 若带文件启动 | 立即 `M.load("autocmds")`（否则延到 VeryLazy） |
| 3 | 注册 User 自动命令 | `pattern = "VeryLazy"`，回调里做后续所有「延迟配置」 |
| 4 | 应用配色 | 调用 `M.colorscheme()`（如 tokyonight），失败则回退 habamax |

**VeryLazy 回调中**（所有插件加载完成后）会依次：

- 若之前未加载：`M.load("autocmds")`
- **`M.load("keymaps")`** → 先 **lazyvim.config.keymaps**，再 **config.keymaps**
- 恢复剪贴板
- **`LazyVim.format.setup()`**、**`LazyVim.news.setup()`**、**`LazyVim.root.setup()`**
- 注册 `LazyExtras`、`LazyHealth` 等命令
- 扩展 `:checkhealth` 的 valid 项
- 可选：检查 lazy 的 import 顺序并发出警告

**`M.load(name)` 的通用逻辑**（options / keymaps / autocmds）：

1. 若启用默认：`require("lazyvim.config." .. name)`，并触发 `User LazyVim{Name}Defaults`
2. 再：`require("config." .. name)`（用户层）
3. 触发 `User LazyVim{Name}`

因此：**同一类配置**总是「先 LazyVim 默认，再用户覆盖」。

---

### 阶段 5：VSCode 分支（仅当 `vim.g.vscode`）

在 **lua/config/lazy.lua** 末尾，若 `vim.g.vscode` 为真：

- 不加载 LazyVim 插件，因此不会走上面的 `lazyvim.config.init()` / `setup()`。
- 改为**直接**：
  - `require("lazyvim.config.options")`、`require("config.options")`
  - `require("config.keymaps")`
- 并做选项校验、通知，以及定义 `:LazyVimVerifyOptions` 命令。

这样在 VSCode 下也能用上同一套 options/keymaps，而不依赖 LazyVim 插件加载。

---

## 三、模块协作关系简图

```
                    init.lua
                        │
                        ▼
                 config.lazy
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   lazy.nvim     spec 决定分支      VSCode 分支
        │         (import 模块)      (手动 load options/keymaps)
        │
        ▼
   lazyvim.plugins (init.lua)
        │
        ├─ lazyvim.config.init()  ──► options、rtp、json、plugin.setup
        │
        └─ return 插件表
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   plugins (init.lua)   LazyVim 插件    snacks 等
        │               │
        │               ▼
        │         lazyvim.config.setup(opts)
        │               │
        │               ├─ colorscheme
        │               └─ User VeryLazy 回调
        │                        │
        │                        ├─ load("autocmds")  → lazyvim.config.autocmds + config.autocmds
        │                        ├─ load("keymaps")   → lazyvim.config.keymaps  + config.keymaps
        │                        ├─ format/news/root.setup()
        │                        └─ 命令与 health 扩展
        │
        └─ 与 LazyVim 插件表合并，由 lazy 统一加载
```

- **config.lazy**：唯一连接入口与 lazy.nvim 的桥梁；决定 spec 和是否走 VSCode 分支。
- **lazyvim.config**：  
  - **init**：最早执行，建立 options、rtp、json、plugin 管理；  
  - **setup**：在 LazyVim 插件加载时执行，注册 VeryLazy 并应用配色；VeryLazy 时再加载 autocmds/keymaps 和 format/news/root。
- **config.options / config.keymaps / config.autocmds**：用户层，始终在对应 LazyVim 默认之后被 `M.load()` 加载，用于覆盖或扩展。

---

## 四、关键文件与 require 对应关系

| require 路径 | 实际文件 | 何时被加载 |
|--------------|----------|------------|
| `config.lazy` | lua/config/lazy.lua | init.lua 中直接 require |
| `lazyvim.plugins` | lua/lazyvim/plugins/init.lua | lazy 解析 spec 时 import |
| `lazyvim.config` | lua/lazyvim/config/init.lua | 由 lazyvim.plugins 与 LazyVim 插件 config 触发 |
| `lazyvim` | lua/lazyvim/init.lua | LazyVim 插件被 lazy 加载时（主模块） |
| `config.options` | lua/config/options.lua | M.load("options")：在 init() 与 VeryLazy 后的 load("keymaps") 等流程中不会再次 load options，options 只在 init 时 load 一次 |
| `config.keymaps` | lua/config/keymaps.lua | M.load("keymaps")，在 VeryLazy 回调中 |
| `config.autocmds` | lua/config/autocmds.lua | M.load("autocmds")：要么启动时（带文件打开），要么 VeryLazy |
| `plugins` | lua/plugins/init.lua | lazy 解析 spec 时 import |
| `plugins.vscode` | lua/plugins/vscode/init.lua | VSCode 环境下 spec 仅包含此 import |

---

## 五、小结

1. **入口**：只有 **init.lua**；只改 rtp 并 **require("config.lazy")**。
2. **插件与 LazyVim 的桥梁**：**config.lazy** 调用 **lazy.setup**，通过 **spec** 的 **import** 触发 **lazyvim.plugins** 和 **plugins** 的加载。
3. **LazyVim 分两步**：  
   - **init**：在 **require("lazyvim.plugins")** 时执行，完成 options、rtp、json、plugin 等早期初始化；  
   - **setup**：在 LazyVim 插件被 lazy 加载时执行，注册 VeryLazy 并应用配色；VeryLazy 时再加载 keymaps/autocmds 和 format/news/root。
4. **用户配置**：**config.options / keymaps / autocmds** 通过 **M.load(name)** 在对应「LazyVim 默认」之后加载，保证可覆盖。
5. **VSCode**：不加载 LazyVim 插件，由 **config.lazy** 末尾手动加载 options/keymaps 并校验。

按上述顺序理解，即可从入口到各模块完整追踪「谁先谁后、谁调谁」。
