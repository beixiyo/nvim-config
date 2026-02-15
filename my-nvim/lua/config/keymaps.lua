-- =======================
-- 基础键位
-- =======================
-- leader 已在 config/options.lua 中设为空格；此处只放通用映射，插件相关键位可在插件 spec 里配置

local map = vim.keymap.set

-- 系统剪贴板（与终端/其它应用互通）
map("v", "<C-c>", '"+y', { desc = "复制到系统剪贴板", silent = true })
map("n", "<C-v>", '"+p', { desc = "粘贴系统剪贴板", silent = true })
map("i", "<C-v>", "<C-r>+", { desc = "粘贴系统剪贴板", silent = true })
map("v", "<C-v>", '"+p', { desc = "粘贴系统剪贴板", silent = true })
