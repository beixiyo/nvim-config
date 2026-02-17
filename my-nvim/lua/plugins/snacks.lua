-- ================================
-- Snacks.nvim 核心（dashboard / picker / terminal / explorer / notifier / bufdelete）
-- ================================
-- 需尽早加载：bufferline 依赖 Snacks.bufdelete，dashboard 需在 VimEnter 前就绪。
-- 文档：https://github.com/folke/snacks.nvim

local utils = require("utils")
local icons = utils.icons.keymaps
local dashboard = utils.icons.dashboard

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
    picker = {                         -- 选择器：模糊查找文件、文本等（替代 fzf-lua）
      enabled = true,
      layout = {
        config = function(layout)
          local box = layout.layout or {}

          -- 认为这是侧边栏布局，不动它
          if box.position == "left" then
            box.min_width = 140
            box.width = 0.16
            layout.layout = box
            return layout
          end

          -- 其它 picker（files / grep 等）放大到接近全屏
          box.width = 0.98
          box.height = 0.98
          box.min_width = 140
          layout.layout = box
          return layout
        end,
      },
    },
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

  config = function(_, opts)
    local snacks = require("snacks")
    snacks.setup(opts)
    -- 让 Snacks 的路径颜色更亮一些
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.api.nvim_set_hl(0, "SnacksPickerDir",         { fg = "#787878" })
        vim.api.nvim_set_hl(0, "SnacksPickerPathHidden",  { fg = "#565f89" })
        vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = "#565f89" })

        -- 或者方式 2：link 到你主题里比较清晰的高亮组
        -- vim.api.nvim_set_hl(0, "SnacksPickerDir",         { link = "Directory" })
        -- vim.api.nvim_set_hl(0, "SnacksPickerPathHidden",  { link = "Comment" })
        -- vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { link = "Comment" })
      end,
    })
  end,

  keys = {
    -- =======================
    -- 1. 文件树
    -- =======================
    { "<leader>e", function() Snacks.explorer() end, desc = icons.explorer .. " " .. "文件树" },

    -- =======================
    -- 2. 文件查找（<leader>f 前缀）
    -- =======================
    { "<leader>ff", function() Snacks.picker.files() end, desc = icons.find_file .. " " .. "查找文件" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = icons.git_files .. " " .. "Git 文件" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = icons.recent_files .. " " .. "最近文件" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = icons.config_files .. " " .. "配置文件" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = icons.buffers .. " " .. "缓冲区" },

    -- =======================
    -- 3. 搜索（<leader>s 前缀）
    -- =======================
    { "<leader>sg", function() Snacks.picker.grep() end, desc = icons.grep .. " " .. "全局搜索" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = icons.grep_word .. " " .. "搜索单词", mode = { "n", "x" } },
    { "<leader>sj", function() Snacks.scope.jump() end, desc = icons.scope .. " " .. "跳转到作用域" },

    -- =======================
    -- 4. Git（<leader>g 前缀）
    -- 约定：<leader>g{大写首字母}，语义更直观，避免 gb/gd/gl 这类难记组合
    --   gs  = status（沿用）
    --   gS  = Stash
    --   gD  = Diff
    --   gL  = Log
    --   gB  = Branches
    -- =======================
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = icons.git_status .. " " .. "Git 状态" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = icons.git_stash .. " " .. "Git 暂存" },
    { "<leader>gD", function() Snacks.picker.git_diff() end, desc = icons.git_diff .. " " .. "Git 差异" },
    { "<leader>gL", function() Snacks.picker.git_log() end, desc = icons.git_log .. " " .. "Git 日志" },
    { "<leader>gB", function() Snacks.picker.git_branches() end, desc = icons.git_branches .. " " .. "Git 分支" },

    -- =======================
    -- 5. Neovim 内部功能（<leader>f 前缀，大写字母）
    -- =======================
    { "<leader>fC", function() Snacks.picker.commands() end, desc = icons.commands .. " " .. "命令" },
    { "<leader>fh", function() Snacks.picker.command_history() end, desc = icons.command_history .. " " .. "命令历史" },
    { "<leader>fR", function() Snacks.picker.registers() end, desc = icons.registers .. " " .. "寄存器" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = icons.marks .. " " .. "标记" },
    { "<leader>fj", function() Snacks.picker.jumps() end, desc = icons.jumps .. " " .. "跳转历史" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = icons.keymaps .. " " .. "快捷键" },
    { "<leader>fT", function() Snacks.picker.todo_comments() end, desc = icons.todo_comments .. " " .. "待办注释" },

    -- =======================
    -- 6. 终端
    -- =======================
    { "<C-\\>", function() Snacks.terminal() end, desc = icons.terminal .. " " .. "切换终端", mode = { "n", "t" } },
  },
}
