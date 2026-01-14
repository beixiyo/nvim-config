# Git 差异对比使用指南

本指南介绍如何在 Neovim 中查看 Git 更改并进行对比，类似 VSCode 的功能。

## 快速开始

### 1. 查看当前文件的更改（Gitsigns）

**基本功能：**
- `<leader>ghd` - 在当前文件和 Git 索引之间打开 diff 视图
- `<leader>ghD` - 在当前文件和上一次提交之间打开 diff 视图

**其他有用的快捷键：**
- `]h` - 跳转到下一个更改块（hunk）
- `[h` - 跳转到上一个更改块
- `<leader>ghs` - 暂存当前更改块
- `<leader>ghr` - 重置当前更改块
- `<leader>ghp` - 内联预览更改

### 2. 并排对比视图（Diffview.nvim）

**性能极差**

`lua/plugins/diffview.lua`
```lua
-- Diffview.nvim 插件配置
-- 提供类似 VSCode 的 Git 差异对比界面，支持并排对比、文件历史查看等功能
-- GitHub: https://github.com/sindrets/diffview.nvim

return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Diffview 依赖 plenary.nvim
  },
  config = function()
    local actions = require("diffview.actions")

    require("diffview").setup({
      -- 视图配置
      view = {
        -- 使用 merge-tool 布局（类似 VSCode 的三面板对比）
        merge_tool = {
          layout = "diff3_mixed", -- 可选: diff3_mixed, diff3_horizontal, diff4_mixed
        },
      },
      -- 文件历史面板配置
      file_panel = {
        listing_style = "tree", -- 可选: "tree" 或 "list"
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded", -- 只在折叠时显示状态
        },
      },
      -- 键位映射
      keymaps = {
        disable_defaults = false, -- 不禁用默认键位
        view = {
          -- 在 diff 视图中
          { "n", "<tab>", actions.select_next_entry, { desc = "选择下一个条目" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "选择上一个条目" } },
          { "n", "gf", actions.goto_file, { desc = "在新标签页打开文件" } },
          { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "在新窗口打开文件" } },
          { "n", "<C-w>gf", actions.goto_file_tab, { desc = "在新标签页打开文件" } },
          { "n", "<leader>e", actions.focus_files, { desc = "聚焦文件面板" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "切换文件面板" } },
        },
        file_panel = {
          { "n", "j", actions.next_entry, { desc = "下一个条目" } },
          { "n", "k", actions.prev_entry, { desc = "上一个条目" } },
          { "n", "<cr>", actions.select_entry, { desc = "选择条目" } },
          { "n", "o", actions.select_entry, { desc = "选择条目" } },
          { "n", "s", actions.stage_all, { desc = "暂存所有文件" } },
          { "n", "u", actions.unstage_all, { desc = "取消暂存所有文件" } },
          { "n", "X", actions.restore_entry, { desc = "恢复文件" } },
          { "n", "L", actions.open_commit_log, { desc = "打开提交日志" } },
          { "n", "gf", actions.goto_file, { desc = "在新标签页打开文件" } },
          { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "在新窗口打开文件" } },
          { "n", "i", actions.listing_style, { desc = "切换列表样式" } },
          { "n", "f", actions.toggle_flatten_dirs, { desc = "切换目录扁平化" } },
          { "n", "R", actions.refresh_files, { desc = "刷新文件列表" } },
          { "n", "<leader>e", actions.focus_files, { desc = "聚焦文件面板" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "切换文件面板" } },
        },
        file_history_panel = {
          { "n", "g!", actions.options, { desc = "打开选项" } },
          { "n", "<C-A-d>", actions.open_in_diffview, { desc = "在 Diffview 中打开" } },
          { "n", "y", actions.copy_hash, { desc = "复制提交哈希" } },
          { "n", "L", actions.open_commit_log, { desc = "打开提交日志" } },
          { "n", "zR", require("diffview.actions").open_all_folds, { desc = "展开所有折叠" } },
          { "n", "zM", require("diffview.actions").close_all_folds, { desc = "折叠所有折叠" } },
          { "n", "j", actions.next_entry, { desc = "下一个条目" } },
          { "n", "k", actions.prev_entry, { desc = "上一个条目" } },
          { "n", "<cr>", actions.select_entry, { desc = "选择条目" } },
          { "n", "o", actions.select_entry, { desc = "选择条目" } },
          { "n", "gf", actions.goto_file, { desc = "在新标签页打开文件" } },
          { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "在新窗口打开文件" } },
          { "n", "<leader>e", actions.focus_files, { desc = "聚焦文件面板" } },
          { "n", "<leader>b", actions.toggle_files, { desc = "切换文件面板" } },
        },
        option_panel = {
          { "n", "<tab>", actions.select_entry, { desc = "选择条目" } },
          { "n", "q", actions.close, { desc = "关闭面板" } },
        },
      },
    })
  end,
  keys = {
    -- 打开文件历史视图
    {
      "<leader>gdh",
      function()
        local current_file = vim.fn.expand("%")
        if current_file ~= "" then
          vim.cmd("DiffviewFileHistory " .. current_file)
        else
          vim.cmd("DiffviewFileHistory")
        end
      end,
      desc = "查看文件历史 (Diffview)",
    },
    -- 打开当前分支与 HEAD 的对比
    {
      "<leader>gdd",
      function()
        vim.cmd("DiffviewOpen")
      end,
      desc = "打开 Diff 视图 (Diffview)",
    },
    -- 打开与指定提交的对比
    {
      "<leader>gds",
      function()
        vim.cmd("DiffviewOpen HEAD~1")
      end,
      desc = "对比上一个提交 (Diffview)",
    },
    -- 关闭 Diffview
    {
      "<leader>gdc",
      function()
        vim.cmd("DiffviewClose")
      end,
      desc = "关闭 Diff 视图 (Diffview)",
    },
    -- 切换 Diffview
    {
      "<leader>gdt",
      function()
        vim.cmd("DiffviewToggleFiles")
      end,
      desc = "切换文件面板 (Diffview)",
    },
  },
}
```

Diffview.nvim 提供了类似 VSCode 的并排对比界面，功能更强大：

**主要快捷键：**

- `<leader>gdd` - **打开 Diff 视图**（查看所有更改的文件）
  - 显示所有已修改的文件列表
  - 点击文件可以进行并排对比

- `<leader>gdh` - **查看文件历史**
  - 如果当前有打开的文件，显示该文件的历史提交
  - 如果没有打开文件，显示所有文件的提交历史
  - 可以浏览不同版本的差异

- `<leader>gds` - **对比上一个提交**
  - 快速对比当前工作区和上一个提交的差异

- `<leader>gdc` - **关闭 Diff 视图**

- `<leader>gdt` - **切换文件面板**
  - 显示/隐藏左侧的文件列表

**在 Diffview 窗口中的操作：**

- `Tab` / `Shift+Tab` - 在不同更改区域之间切换
- `gf` - 在新标签页中打开文件
- `<leader>e` - 聚焦到文件面板
- `j` / `k` - 在文件列表中上下移动
- `<Enter>` 或 `o` - 打开选中的文件进行对比

### 3. 其他 Git 相关功能

**查看提交历史：**
- `<leader>gL` - 查看当前目录的提交历史
- `<leader>gf` - 查看当前文件的提交历史
- `<leader>gl` - 查看项目根目录的提交历史

**Git 状态：**
- `<leader>gs` - 查看 Git 状态（如果有 telescope 配置）

**Lazygit（如果已安装）：**
- `<leader>gg` - 在项目根目录打开 Lazygit
- `<leader>gG` - 在当前工作目录打开 Lazygit

## 使用场景示例

### 场景 1：查看当前文件的所有更改

1. 打开需要查看的文件
2. 按 `<leader>ghd` 查看与 Git 索引的差异
3. 使用 `]h` 和 `[h` 在更改块之间跳转

### 场景 2：对比所有更改的文件（类似 VSCode）

1. 按 `<leader>gdd` 打开 Diffview
2. 在左侧文件列表中选择要查看的文件
3. 右侧会显示并排对比视图
4. 可以在不同文件之间切换查看

### 场景 3：查看文件的提交历史

1. 打开要查看的文件
2. 按 `<leader>gdh` 打开文件历史
3. 浏览不同的提交，选择某个提交查看详细差异

### 场景 4：对比特定提交

1. 按 `<leader>gds` 对比上一个提交
2. 或者使用 `<leader>gdh` 打开历史，选择要对比的提交

## 提示

1. **Gitsigns 的 diff 视图**：使用垂直分割，适合快速查看单个文件的更改
2. **Diffview 的并排视图**：更适合对比多个文件，界面更清晰
3. **文件符号**：在编辑器左侧可以看到 Git 更改的符号标记
   - `▎` - 新增或修改的行
   - `  ` - 删除的行
4. **关闭 diff 视图**：使用 `<leader>gdc` 或在 diff 窗口中按 `q`

## 自定义配置

配置文件位置：`lua/plugins/diffview.lua`

你可以根据需要调整：
- 布局样式（merge_tool.layout）
- 文件面板样式（listing_style）
- 快捷键映射
