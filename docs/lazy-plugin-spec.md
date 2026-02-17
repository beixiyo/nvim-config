# LazyVim / lazy.nvim 插件定义说明

LazyVim 基于 **lazy.nvim**，插件写法即 lazy.nvim 的 **Plugin Spec**。在 `lua/plugins/` 下每个文件 `return` 一个表，表中每一项就是一个插件 spec

---

## 一、基本定义方式

```lua
-- 最简：仅插件名（会按 config.git.url_format 展开，一般是 GitHub）
return { "owner/repo" }

-- 带配置
return {
  { "owner/repo", opts = { ... } },
  { "owner/repo", event = "BufEnter", config = function() ... end },
}
```

合法 spec 必须提供**来源**之一：**`[1]`（短 URL）**、**`dir`** 或 **`url`**

---

## 二、字段总览（按类别）

### 2.1 来源 (Spec Source)

| 字段 | 类型 | 说明 |
|------|------|------|
| **`[1]`** | `string?` | 短插件 URL，按 `config.git.url_format` 展开（如 `"folke/which-key.nvim"` → `https://github.com/folke/which-key.nvim.git`）。也可直接写完整 url 或路径 |
| **`dir`** | `string?` | 本地插件目录，如 `"~/projects/secret.nvim"` |
| **`url`** | `string?` | 自定义 Git 地址，如 `"git@github.com:folke/noice.nvim.git"` |
| **`name`** | `string?` | 自定义插件名，用作本地目录名和 UI 显示名 |
| **`dev`** | `boolean?` | 为 `true` 时用本地开发目录（见 `config.dev.path`），不再从 Git 拉取 |

---

### 2.2 加载控制 (Spec Loading)

| 字段 | 类型 | 说明 |
|------|------|------|
| **`dependencies`** | `LazySpec[]` | 依赖列表（插件名或完整 spec）。依赖会随该插件一起加载，且默认懒加载 |
| **`enabled`** | `boolean?` \| `fun():boolean` | 为 `false` 或函数返回 `false` 时，该插件不会加入 spec（不会安装） |
| **`cond`** | `boolean?` \| `fun(LazyPlugin):boolean` | 与 `enabled` 类似，但为 `false` 时**不会卸载**插件，适合在 VSCode/Firenvim 等环境里临时禁用 |
| **`priority`** | `number?` | 仅对**启动时加载**的插件（`lazy = false`）有效，数值越大越先加载。默认 **50**，主题常用 **1000** |

---

### 2.3 配置与构建 (Spec Setup)

| 字段 | 类型 | 说明 |
|------|------|------|
| **`init`** | `fun(LazyPlugin)` | 在**启动时**执行，适合设置 `vim.g.*` 等给传统 Vim 插件用的配置 |
| **`opts`** | `table` \| `fun(LazyPlugin, opts:table)` | 传给插件 `config` 的选项表。可为表（会与父 spec 合并）、或函数（可修改/返回新表）。设置 `opts` 会隐式启用 `config`。**推荐用 opts 代替手写 config。** |
| **`config`** | `fun(LazyPlugin, opts:table)` \| `true` | 在**插件被加载时**执行。为 `true` 时，lazy 会按插件名推断主模块并执行 `require(MAIN).setup(opts)` |
| **`main`** | `string?` | 指定主模块名，当无法自动推断时给 `config`/`opts` 用 |
| **`build`** | `fun(LazyPlugin)` \| `string` \| `string[]` \| `false` | 在**安装或更新**后执行的构建。可以是命令字符串、命令列表、或函数。设为 `false` 表示不执行构建 |

**`opts` 和 `config` 的区别**（很多人容易混）：

| | **opts** | **config** |
|---|----------|------------|
| **是什么** | 传给插件 `setup()` 的**选项表**（数据） | 插件加载时**要执行的一段代码**（逻辑） |
| **时机** | lazy 会拿它去调 `require("xxx").setup(opts)` | 在插件加载后执行，你写什么就运行什么 |
| **典型用法** | 只改配置项时：`opts = { theme = "dark" }` | 要自己调 setup、设 keymap、执行命令等时用函数；或 `config = true` 表示“用 opts 自动 setup” |

- **只用 `opts`**：lazy 会自动做「加载插件 → `require(主模块).setup(opts)`」，不用写 `config`。适合绝大多数「改改选项就行」的插件
- **用 `config` 函数**：加载后完全由你控制，可以自己 `require(...).setup(...)`，也可以干别的（设 keymap、vim.cmd 等）。需要自定义行为时用
- **`config = true`**：表示「我提供了 opts，请按默认方式帮我执行 setup(opts）」；和只写 `opts` 效果类似（lazy 会推断主模块并调用 setup）

示例：

```lua
-- 只改选项 → 用 opts 即可，不必写 config
{ "folke/trouble.nvim", opts = { use_diagnostic_signs = true } }

-- 要在加载时跑自己的逻辑 → 用 config
{
  "folke/trouble.nvim",
  config = function()
    require("trouble").setup({ use_diagnostic_signs = true })
    vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
  end,
}

-- 想基于“默认 opts”再改一点 → opts 用函数，不写 config
{
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    table.insert(opts.sources, { name = "emoji" })
  end,
}
```

官方建议：**能只用 `opts` 就只用 `opts`**，`config` 几乎不必手写

---

### 2.4 延迟加载 (Spec Lazy Loading)

| 字段 | 类型 | 说明 |
|------|------|------|
| **`lazy`** | `boolean?` | 为 `true` 时仅在被需要时加载（被 require、或下列任一触发器触发）。主题可设 `lazy = true`，会在 `colorscheme xxx` 时自动加载 |
| **`event`** | 见下 | 在这些 **Neovim 事件** 发生时加载插件 |
| **`cmd`** | `string?` \| `string[]` \| `fun(self, cmd):string[]` | 在这些**命令**被调用时加载 |
| **`ft`** | `string?` \| `string[]` \| `fun(self, ft):string[]` | 在进入这些 **filetype** 时加载 |
| **`keys`** | 见下 | 在这些**按键**第一次被触发时加载 |

**`event` 取值**：任意 Neovim 事件名（即 `:h autocmd-events`），无固定枚举，例如：

- `"BufEnter"`、`"InsertEnter"`、`"BufRead"`、`"VimEnter"`、`"CmdlineEnter"` 等
- **`"VeryLazy"`**：lazy 提供的“尽量晚”的时机，适合不着急的 UI 类插件

可带 pattern：

```lua
event = { event = "BufEnter", pattern = "*.lua" }
-- 或
event = { "BufEnter", "BufRead" }
```

**`keys` 格式 (LazyKeysSpec)**：

- 简单：`keys = "<leader>f"` 或 `keys = { "<leader>f", "<leader>w" }`
- 表形式：`{ [1]=lhs, [2]=rhs?, mode?, ft?, desc?, ... }`
  - **`[1]`**：`string`，左手键（必填）
  - **`[2]`**：`string` \| `fun()`，右手键或回调（可选）；为 `nil` 时需在 `config` 里自己 `vim.keymap.set`
  - **`mode`**：`string` \| `string[]`，默认为 **`"n"`**（normal）
  - **`ft`**：`string` \| `string[]`，仅在该 filetype 的 buffer 生效（buffer-local）
  - 其余可传 `vim.keymap.set` 支持的选项（如 `desc`、`remap` 等）

---

### 2.5 版本与 Git (Spec Versioning)

| 字段 | 类型 | 说明 |
|------|------|------|
| **`branch`** | `string?` | 使用的 Git 分支 |
| **`tag`** | `string?` | 使用的 Git 标签，如 `"v1.2.3"` |
| **`commit`** | `string?` | 固定到某次 commit |
| **`version`** | `string?` \| `false` | Semver 版本或范围；`false` 表示忽略默认 version 配置 |
| **`pin`** | `boolean?` | 为 `true` 时不参与批量更新 |
| **`submodules`** | `boolean?` | 是否拉取 submodules，默认 **true**；设为 `false` 则不拉取 |

**`version` 常用写法（Semver）**：

- `"*"`：最新稳定（不含 pre-release）
- `"1.2.x"`：1.2.x
- `"^1.2.3"`：兼容 1.2.3（如 1.3.0、1.4.5，不含 2.0.0）
- `"~1.2.3"`：补丁级（如 1.2.4、1.2.5，不含 1.3.0）
- `">1.2.3"`、`">=1.2.3"`、`"<1.2.3"`、`"<=1.2.3"` 等

---

### 2.6 高级 (Spec Advanced)

| 字段 | 类型 | 说明 |
|------|------|------|
| **`optional`** | `boolean?` | 为 `true` 时，只有**在其他地方**有**非 optional** 的同名插件时，这份 spec 才会被加入。常用于发行版里“可选增强”配置 |
| **`specs`** | `LazySpec` | 挂在该插件“作用域”下的子 spec 列表（发行版常用）。主插件被禁用时，这些也不会加入最终 spec |
| **`module`** | `false?` | 设为 `false` 时，不会在有人 `require` 该插件模块时自动加载 |
| **`import`** | `string?` | 引入另一个 spec 模块，如 `import = "plugins"` 会加载 `lua/plugins/init.lua`（或对应路径） |

---

## 三、枚举/可选值汇总

- **`event`**：无固定枚举，使用 Neovim 的 autocmd 事件名 + 可选的 `"VeryLazy"`
- **`keys.mode`**：与 Vim 模式一致，如 `"n"`、`"v"`、`"i"`、`"t"` 等，可多个
- **`version`**：见上面 Semver 示例，不是有限枚举
- **lazy 全局配置里的枚举**（与单插件 spec 无直接关系，便于查文档）：
  - `ui.title_pos`: `"center"` \| `"left"` \| `"right"`
  - `diff.cmd`: `"browser"` \| `"git"` \| `"terminal_git"` \| `"diffview.nvim"`

---

## 四、在 LazyVim 里怎么用

- 在 **`lua/plugins/`** 下新建或编辑 `.lua` 文件
- 该文件 **return 一个表**，表里是上面这些 spec
- 例如：

```lua
-- lua/plugins/example.lua
return {
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    opts = { position = "right" },
  },
}
```

---

## 五、参考

- lazy.nvim 官方文档：<https://github.com/folke/lazy.nvim>
- LazyVim 插件配置：<https://www.lazyvim.org/configuration/plugins>
