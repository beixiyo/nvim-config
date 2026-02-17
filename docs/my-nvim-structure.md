# my-nvim：加载顺序与目录结构

本文档描述 **my-nvim**（`NVIM_APPNAME=nvim/my-nvim`）的启动加载顺序与目录布局，与主配置 `~/.config/nvim`（LazyVim）分离。

---

## 一、加载顺序

```
init.lua
    │
    ├─ 1. vim.opt.rtp:prepend(stdpath("config"))   # 配置根优先
    ├─ 2. require("config.options")
    ├─ 3. require("config.keymaps")
    └─ 4. require("config.lazy")
              │
              └─ 确保 lazy.nvim 存在 → require("lazy").setup({ spec = require("plugins"), ... })
                        │
                        └─ 按 spec 加载 lua/plugins/*.lua 与 lua/plugins/**/*.lua
```

- **config** 在 lazy 之前加载，因此 options、keymaps 在插件未加载时已生效。
- 插件列表由 `lua/plugins/init.lua` 的 `return { ... }` 决定，内部通过 `import = "plugins.xxx"` 引入各子模块；实际加载顺序由 lazy.nvim 与各插件 `priority`/`lazy` 等控制。

---

## 二、目录结构（概要）

```
my-nvim/
├── init.lua                 # 入口：rtp、options、keymaps、lazy
├── lazy-lock.json           # lazy.nvim 锁文件（可选提交）
└── lua/
    ├── config/
    │   ├── options.lua      # 全局选项（leader、编号、外观等）
    │   ├── keymaps.lua      # 基础键位（窗口、剪贴板等）
    │   └── lazy.lua         # lazy.nvim 引导与 setup
    ├── plugins/
    │   ├── init.lua         # 插件列表入口（import 各子模块）
    │   ├── snacks.lua       # Snacks：dashboard / picker / terminal / explorer / notifier / bufdelete
    │   ├── code/
    │   │   ├── blink.lua    # 补全（blink.cmp + friendly-snippets）
    │   │   ├── lsp.lua      # LSP（mason + mason-lspconfig + nvim-lspconfig）
    │   │   ├── mini-pairs.lua
    │   │   ├── render-markdown.lua
    │   │   └── treesitter.lua
    │   ├── tools/
    │   │   ├── flash.lua
    │   │   ├── session.lua  # auto-session
    │   │   └── which-key.lua
    │   └── ui/
    │       ├── bufferline.lua
    │       ├── indent.lua
    │       ├── lualine.lua
    │       ├── noice.lua
    │       └── theme.lua
    └── utils.lua            # 公共工具与图标（被部分插件 require）
```

插件数据（含 lazy 克隆的仓库）位于 `stdpath("data")`（受 `NVIM_APPNAME` 影响），与主配置的 `~/.local/state/nvim` 等分离。

---

## 三、与主配置的差异

- 主配置（`~/.config/nvim`）使用 LazyVim 发行版，入口后会加载 `lazyvim`、`lazyvim.plugins` 等。
- my-nvim **不** `require("lazyvim")`，仅用 lazy.nvim 做插件管理，所有 spec 与 config 均在 `my-nvim/lua/` 下自建。
- 文档中的 [loading-order.md](loading-order.md) 描述的是主配置的加载与 LazyVim 协作，不适用于 my-nvim；my-nvim 以本文档为准。
