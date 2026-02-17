-- ================================
-- 基础编辑器选项
-- ================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- 本地 leader（常用于 filetype/插件的局部映射）

local opt = vim.opt

-- 行号与当前行
opt.number = true -- 显示绝对行号
opt.relativenumber = true -- 显示相对行号（便于用 j/k 计数移动）
opt.cursorline = true -- 高亮当前行

-- 缩进与 Tab
opt.expandtab = true -- Tab 转为空格
opt.shiftwidth = 2 -- 自动缩进每级空格数（>>, <<, == 等）
opt.tabstop = 2 -- 一个 Tab 显示为多少空格宽度
opt.softtabstop = 2 -- 编辑时按 <Tab>/<BS> 视为多少空格

-- 鼠标、确认、编码
opt.mouse = "a" -- 启用鼠标（普通/插入/可视等模式）
opt.confirm = true -- 未保存缓冲区退出/切换时弹出确认
opt.encoding = "utf-8" -- Neovim 内部使用的编码
opt.fileencoding = "utf-8" -- 写入文件时使用的编码

-- 搜索与补全
opt.ignorecase = true -- 搜索默认忽略大小写
opt.smartcase = true -- 搜索包含大写时自动区分大小写
opt.completeopt = "menu,menuone,noselect" -- 补全菜单行为（配合 nvim-cmp 等）

-- 外观
opt.termguicolors = true -- 启用 24-bit 真彩
opt.signcolumn = "yes" -- 始终显示标记列，避免文本左右跳动
opt.wrap = true -- 长行自动换行显示
opt.splitright = true -- 垂直分屏默认向右打开
opt.splitbelow = true -- 水平分屏默认向下打开

-- 按键超时（ms）
opt.timeoutlen = 300 -- 组合键/映射等待时间（例如 leader 触发）

-- 会话保存/恢复内容（auto-session 依赖此项）
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions" -- session 要保存/恢复的内容

-- Neovide 配置
if vim.g.neovide then
	vim.o.guifont = "Maple Mono NF:h10"
	vim.g.neovide_confirm_quit = true
	vim.g.neovide_remember_window_size = true
end
