-- ================================
-- 基础编辑器选项
-- ================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- 行号与当前行
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- 缩进与 Tab
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- 剪贴板（非 SSH 时使用系统剪贴板）
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- 鼠标、确认、编码
opt.mouse = "a"
opt.confirm = true
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- 搜索与补全
opt.ignorecase = true
opt.smartcase = true
opt.completeopt = "menu,menuone,noselect"

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.splitright = true
opt.splitbelow = true

-- 按键超时（ms）
opt.timeoutlen = 300
