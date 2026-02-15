-- =======================
-- 基础键位
-- =======================
-- leader 已在 config/options.lua 中设为空格；此处只放通用映射，插件相关键位可在插件 spec 里配置

local map = vim.keymap.set

-- 插入模式：jk 退出到普通模式（替代 Esc）
map("i", "jk", "<Esc>", { desc = "退出插入模式", silent = true })

-- 窗口焦点：Ctrl-hjkl 切换上下左右
map("n", "<C-h>", "<C-w>h", { desc = "焦点左窗口", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "焦点下窗口", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "焦点上窗口", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "焦点右窗口", silent = true })
-- 终端焦点：Ctrl-hjkl 切换上下左右
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "焦点左窗口", silent = true })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "焦点下窗口", silent = true })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "焦点上窗口", silent = true })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "焦点右窗口", silent = true })

-- 系统剪贴板（与终端/其它应用互通）
map("v", "<C-c>", '"+y', { desc = "复制到系统剪贴板", silent = true })
map("n", "<C-v>", '"+p', { desc = "粘贴系统剪贴板", silent = true })
map("i", "<C-v>", "<C-r>+", { desc = "粘贴系统剪贴板", silent = true })
map("v", "<C-v>", '"+p', { desc = "粘贴系统剪贴板", silent = true })
