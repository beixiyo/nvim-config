vim.g.mapleader = " "

local keymap = vim.keymap

-- ---------- 插入模式 ---------- ---
keymap.set("i", "jk", "<ESC>")

-- 单行或多行移动
-- keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- VSCode 风格的换行功能
keymap.set("i", "<C-Enter>", "<ESC>o") -- 在下方新增一行并移动光标
keymap.set("i", "<C-S-Enter>", "<ESC>O") -- 在上方新增一行并移动光标

-- VSCode 风格的行操作
keymap.set("i", "<A-Up>", "<ESC>:m .-2<CR>==gi") -- 向上移动当前行
keymap.set("i", "<A-Down>", "<ESC>:m .+1<CR>==gi") -- 向下移动当前行
keymap.set("i", "<A-S-Up>", "<ESC>yyP==gi") -- 向上复制当前行
keymap.set("i", "<A-S-Down>", "<ESC>yyp==gi") -- 向下复制当前行

-- ---------- 正常模式 ---------- ---
keymap.set("n", "<leader>sh", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sv", "<C-w>s") -- 垂直新增窗口

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- VSCode 风格的 Buffer 切换
keymap.set("n", "<C-Tab>", ":bnext<CR>") -- 下一个 Buffer
-- 数字键切换 Buffer (Ctrl + 1-9)
keymap.set("n", "<C-1>", ":buffer 1<CR>")
keymap.set("n", "<C-2>", ":buffer 2<CR>")
keymap.set("n", "<C-3>", ":buffer 3<CR>")
keymap.set("n", "<C-4>", ":buffer 4<CR>")
keymap.set("n", "<C-5>", ":buffer 5<CR>")
keymap.set("n", "<C-6>", ":buffer 6<CR>")
keymap.set("n", "<C-7>", ":buffer 7<CR>")
keymap.set("n", "<C-8>", ":buffer 8<CR>")
keymap.set("n", "<C-9>", ":buffer 9<CR>")

-- ---------- VSCode 风格快捷键 ---------- ---
-- 复制、粘贴、保存（覆盖原生快捷键）
keymap.set("v", "<C-c>", '"+y') -- 复制到系统剪贴板
keymap.set("n", "<C-c>", '"+y') -- 复制当前行到系统剪贴板
keymap.set("i", "<C-v>", '"+p') -- 从系统剪贴板粘贴
keymap.set("n", "<C-v>", '"+p') -- 从系统剪贴板粘贴
keymap.set("v", "<C-v>", '"+p') -- 从系统剪贴板粘贴
keymap.set("n", "<C-s>", ":w<CR>") -- 保存文件
keymap.set("i", "<C-s>", "<ESC>:w<CR>a") -- 保存文件并回到插入模式

-- 撤回和回溯快捷键
keymap.set("n", "<C-z>", "u") -- 撤回
keymap.set("i", "<C-z>", "<ESC>u") -- 插入模式下撤回
keymap.set("v", "<C-z>", "<ESC>u") -- 视觉模式下撤回
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
