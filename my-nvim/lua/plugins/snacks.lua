-- ================================
-- Snacks.nvim 核心（dashboard / picker / terminal / explorer / notifier / bufdelete）
-- ================================
-- 需尽早加载：bufferline 依赖 Snacks.bufdelete，dashboard 需在 VimEnter 前就绪。
-- 文档：https://github.com/folke/snacks.nvim

local utils = require("utils")
local icons = utils.icons
local dashboard = icons.dashboard

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,

  ---@type snacks.Config
  opts = {
    -- 以下需显式启用（会注册 autocmd 等）
    bigfile = { enabled = true },      -- 大文件检测：自动为大文件禁用某些功能以提升性能
    explorer = { enabled = true },     -- 文件浏览器：提供类似 neo-tree 的文件树功能
    indent = { enabled = false },      -- 缩进线：显示缩进指示线（已禁用，使用其他插件）
    input = { enabled = true },        -- 输入框：提供现代化的输入对话框
    notifier = { enabled = true },     -- 通知系统：统一的消息通知显示
    picker = { enabled = true },       -- 选择器：模糊查找文件、文本等（替代 fzf-lua）
    quickfile = { enabled = true },    -- 快速文件：快速打开最近使用的文件
    scope = { enabled = true },        -- 作用域检测：检测代码作用域，支持跳转等功能
    scroll = { enabled = true },       -- 平滑滚动：提供平滑的滚动体验
    statuscolumn = { enabled = true }, -- 状态列：侧边栏显示行号、诊断等
    words = { enabled = true },        -- 单词高亮：高亮当前单词的所有出现位置
    terminal = { enabled = true },     -- 终端：集成终端功能，支持浮动和标签页模式

    -- dashboard 预设：使用 Snacks.picker（files / live_grep / oldfiles）
    dashboard = {
      enabled = true,
      preset = {
        pick = function(cmd, opts)
          local source = (cmd == "live_grep" and "grep") or (cmd == "oldfiles" and "recent") or (cmd or "files")
          Snacks.picker.pick(source, opts or {})
        end,


        header = [[
██╗   ██╗███████╗ ██████╗ ██████╗ ███████╗ ███████╗
██║   ██║██╔════╝██╔════╝██╔═══██╗██╔═══██╗██╔════╝
██║   ██║███████╗██║     ██║   ██║██║   ██║█████╗
╚██╗ ██╔╝╚════██║██║     ██║   ██║██║   ██║██╔══╝
 ╚████╔╝ ███████║╚██████╗╚██████╔╝███████╔╝███████╗
  ╚═══╝  ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚══════╝]],

        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = dashboard.find_file,    key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
          { icon = dashboard.new_file,     key = "n", desc = "New File",        action = ":ene | startinsert" },
          { icon = dashboard.find_text,    key = "g", desc = "Find Text",       action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = dashboard.recent_files, key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = dashboard.config,       key = "c", desc = "Config",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = dashboard.session,      key = "s", desc = "Restore Session", action = ":AutoSession search" },
          { icon = dashboard.lazy,         key = "l", desc = "Lazy",            action = ":Lazy" },
          { icon = dashboard.quit,         key = "q", desc = "Quit",            action = ":qa" },
        },
      },

      sections = {
        { section = "header" },
        { section = "keys",   gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
  },

  keys = {
    -- 文件树（Snacks Explorer，替代 neo-tree）
    { "<leader>e", function() Snacks.explorer() end, desc = "文件树" },
    -- 模糊查找（替代 fzf-lua）
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find File" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep Word", mode = { "n", "x" } },
    -- 终端（替代 toggleterm）：Ctrl+\ 或 <leader>ft
    { "<C-\\>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    -- 作用域检测
    { "<leader>sj", function() Snacks.scope.jump() end, desc = "跳转到作用域" },
    -- Git 相关 Picker
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    -- Neovim 内部 Picker（注意：避免与文件查找键位冲突）
    { "<leader>fC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>fh", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>fR", function() Snacks.picker.registers() end, desc = "Registers" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>fj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>fT", function() Snacks.picker.todo_comments() end, desc = "Todo Comments" },
    -- Quickfix/Location
    { "<leader>xq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>xl", function() Snacks.picker.loclist() end, desc = "Location List" },
  },
}
