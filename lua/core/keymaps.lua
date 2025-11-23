vim.g.mapleader = " "

local keymap = vim.keymap

-- ---------- 插入模式 ---------- ---
keymap.set("i", "jk", "<ESC>")

-- VSCode 风格的行操作
keymap.set("i", "<A-Up>", "<ESC>:m .-2<CR>==gi") -- 向上移动当前行
keymap.set("i", "<A-Down>", "<ESC>:m .+1<CR>==gi") -- 向下移动当前行
keymap.set("i", "<A-S-Up>", "<ESC>yyP==gi") -- 向上复制当前行
keymap.set("i", "<A-S-Down>", "<ESC>yyp==gi") -- 向下复制当前行

-- 正常模式下的行操作
keymap.set("n", "<A-Up>", ":m .-2<CR>==") -- 向上移动当前行
keymap.set("n", "<A-Down>", ":m .+1<CR>==") -- 向下移动当前行
keymap.set("n", "<A-S-Up>", "yyP") -- 向上复制当前行
keymap.set("n", "<A-S-Down>", "yyp") -- 向下复制当前行

-- ---------- 正常模式 ---------- ---
keymap.set("n", "<leader>sh", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sv", "<C-w>s") -- 垂直新增窗口

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- ---------- 基础编辑快捷键 ---------- ---
-- 复制、粘贴、保存（覆盖原生快捷键）
keymap.set("v", "<C-c>", '"+y') -- 复制到系统剪贴板
keymap.set("n", "<C-c>", '"+y') -- 复制当前行到系统剪贴板
keymap.set("i", "<C-v>", '"+p') -- 从系统剪贴板粘贴
keymap.set("n", "<C-v>", '"+p') -- 从系统剪贴板粘贴
keymap.set("v", "<C-v>", '"+p') -- 从系统剪贴板粘贴

-- 撤回和回溯快捷键
keymap.set({ "n", "i" }, "<C-z>", "<Cmd>undo<CR>", { silent = true }) -- 撤回
keymap.set("n", "<C-y>", "<C-r>") -- 回溯（重做）- 使用 Ctrl+Y
keymap.set("i", "<C-y>", "<ESC><C-r>") -- 插入模式下回溯
keymap.set("v", "<C-y>", "<ESC><C-r>") -- 视觉模式下回溯
-- 备用：Ctrl+Shift+Z（如果终端支持）
keymap.set("n", "<C-S-z>", "<C-r>") -- 回溯（重做）
keymap.set("i", "<C-S-z>", "<ESC><C-r>") -- 插入模式下回溯
keymap.set("v", "<C-S-z>", "<ESC><C-r>") -- 视觉模式下回溯

-- 搜索功能
keymap.set("n", "<C-f>", "/") -- 搜索
keymap.set("i", "<C-f>", "<ESC>/") -- 搜索并进入正常模式
keymap.set("n", "<C-S-f>", ":Telescope live_grep<CR>") -- 工作区搜索
keymap.set("i", "<C-S-f>", "<ESC>:Telescope live_grep<CR>") -- 工作区搜索

-- ---------- 插件 ---------- ---
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
