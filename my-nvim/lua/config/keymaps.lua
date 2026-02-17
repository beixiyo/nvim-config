-- =======================
-- 基础键位配置
-- =======================
-- leader 已在 config/options.lua 中设为空格；此处只放通用映射，插件相关键位可在插件 spec 里配置

local utils = require("utils")
local icons = utils.icons

-- 包装函数：默认 silent = true，自动删除冲突映射
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  -- 默认 silent = true
  if opts.silent == nil then
    opts.silent = true
  end

  -- 删除可能冲突的映射
  -- 支持单个模式字符串或模式数组
  local modes = type(mode) == "string" and { mode } or mode
  for _, m in ipairs(modes) do
    -- 检查并删除现有映射（如果存在）
    pcall(vim.keymap.del, m, lhs)
  end

  -- 设置新映射
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- =======================
-- 模式切换
-- =======================
-- jk 退出到普通模式（替代 Esc）
map("i", "jk", "<Esc>", { desc = icons.exit_insert .. " " .. "退出插入模式" })

-- =======================
-- 窗口管理
-- =======================
-- Ctrl-hjkl 切换窗口焦点
map("n", "<C-h>", "<C-w>h", { desc = icons.arrow_left .. " " .. "焦点左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = icons.arrow_down .. " " .. "焦点下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = icons.arrow_up .. " " .. "焦点上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = icons.arrow_right .. " " .. "焦点右窗口" })

-- leader 分屏（与 LazyVim 保持一致：<leader>- / <leader>|）
map("n", "<leader>-", "<C-w>s", {
  desc = icons.arrow_down .. " " .. "横向分屏",
  remap = true,
})
map("n", "<leader>|", "<C-w>v", {
  desc = icons.arrow_right .. " " .. "纵向分屏",
  remap = true,
})

-- leader 关闭当前分屏（窗口）
map("n", "<leader>wd", "<C-w>c", {
  desc = icons.quit .. " " .. "关闭当前窗口",
  remap = true,
})

-- Ctrl-hjkl 切换窗口焦点
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = icons.arrow_left .. " " .. "焦点左窗口" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = icons.arrow_down .. " " .. "焦点下窗口" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = icons.arrow_up .. " " .. "焦点上窗口" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = icons.arrow_right .. " " .. "焦点右窗口" })

-- =======================
-- 编辑操作
-- =======================
-- Alt + j/k 向上/向下移动当前行
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = icons.move_down .. " " .. "向下移动当前行" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = icons.move_up .. " " .. "向上移动当前行" })

-- Alt + j/k 向上/向下移动选中行
map("v", "<A-j>", "<cmd>m '>+1<cr>gv=gv", { desc = icons.move_down .. " " .. "向下移动选中行" })
map("v", "<A-k>", "<cmd>m '<-2<cr>gv=gv", { desc = icons.move_up .. " " .. "向上移动选中行" })

-- Tab / Shift-Tab 缩进/反缩进，并保持选中
map("x", "<Tab>", ">gv", { desc = icons.cursor .. " " .. "缩进选中内容" })
map("x", "<S-Tab>", "<gv", { desc = icons.cursor .. " " .. "反缩进选中内容" })

-- =======================
-- 剪贴板
-- =======================
-- Ctrl+C 复制到系统剪贴板（与终端/其它应用互通）
-- SSH 下 <C-c> 复制到本机、<C-S-v> 从终端粘贴
map("v", "<C-c>", '"+y', { desc = icons.copy .. " " .. "复制到系统剪贴板" })

-- =======================
-- 导航
-- =======================
-- Alt + Left/Right 跳转到上一个/下一个光标位置（类似 VSCode 的导航历史）
map("n", "<A-Left>", "<C-o>", { desc = icons.prev .. " " .. "跳转到上一个光标位置", remap = true })
map("n", "<A-Right>", "<C-i>", { desc = icons.next .. " " .. "跳转到下一个光标位置", remap = true })

-- 普通/可视：C-e / C-y 改为每次滚动 5 行
map({ "n", "x" }, "<C-e>", "5<C-e>", { desc = "向下滚动 5 行" })
map({ "n", "x" }, "<C-y>", "5<C-y>", { desc = "向上滚动 5 行" })

-- =======================
-- 文件操作
-- =======================
-- Ctrl+Alt+S 保存所有缓冲区
-- 注意：有的终端不支持 Ctrl + Alt 系列，可以输入 :echo getcharstr() 后按下快捷键，看是否有捕捉到按键
map({ "i", "x", "n", "s" }, "<C-A-s>", "<cmd>wa<cr><esc>", { desc = icons.save .. " " .. "保存所有缓冲区" })

-- =======================
-- 缓冲区
-- =======================
-- 关闭当前缓冲区
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = icons.buffers .. " " .. "关闭当前缓冲区" })

-- 关闭左侧所有缓冲区（基于 bufferline 顺序）
map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = icons.buffers .. " " .. "关闭左侧缓冲区" })

-- 关闭右侧所有缓冲区（基于 bufferline 顺序）
map("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = icons.buffers .. " " .. "关闭右侧缓冲区" })

-- 关闭除当前以外的所有缓冲区
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = icons.buffers .. " " .. "关闭其他缓冲区" })

-- 关闭所有缓冲区
map("n", "<leader>ba", function() Snacks.bufdelete.all() end, { desc = icons.buffers .. " " .. "关闭全部缓冲区" })


------------------------------------------


-- 智能 Esc：优先关闭所有浮窗，其次当普通 Esc 用
local function smart_esc_close_floats()
  local closed = false

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- 有些窗口在列出后可能已经被关闭，这里用 pcall 防止 "Invalid window id"
    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
    if ok and cfg and cfg.relative ~= "" then
      -- cfg.relative ~= "" 表示这是一个 floating window
      pcall(vim.api.nvim_win_close, win, true)
      closed = true
    end
  end

  -- 如果没有任何浮窗被关闭，就当普通 Esc 用
  if not closed then
    -- 清除搜索高亮（可选）
    if vim.v.hlsearch == 1 then
      vim.cmd("nohlsearch")
    end

    -- 发送真正的 <Esc>，注意用 noremap 模式防止递归
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "n", false)
  end
end

-- 仅在 normal 模式下重映射 Esc，避免影响插入模式退出
vim.keymap.set("n", "<Esc>", smart_esc_close_floats, {
  desc = "智能 Esc：先关浮窗再退出",
})