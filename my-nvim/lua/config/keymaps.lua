-- =======================
-- 基础键位
-- =======================
-- leader 已在 config/options.lua 中设为空格；此处只放通用映射，插件相关键位可在插件 spec 里配置

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

-- 插入模式：jk 退出到普通模式（替代 Esc）
map("i", "jk", "<Esc>", { desc = "退出插入模式" })

-- 窗口焦点：Ctrl-hjkl 切换上下左右
map("n", "<C-h>", "<C-w>h", { desc = "焦点左窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "焦点下窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "焦点上窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "焦点右窗口" })
-- 终端焦点：Ctrl-hjkl 切换上下左右
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "焦点左窗口" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "焦点下窗口" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "焦点上窗口" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "焦点右窗口" })

-- 系统剪贴板（与终端/其它应用互通）；SSH 下 <C-c> 复制到本机、<C-S-v> 从终端粘贴
map("v", "<C-c>", '"+y', { desc = "复制到系统剪贴板" })

-- Alt + Left/Right 跳转到上一个/下一个光标位置（类似 VSCode 的导航历史）
map("n", "<A-Left>", "<C-o>", { desc = "跳转到上一个光标位置", remap = true })
map("n", "<A-Right>", "<C-i>", { desc = "跳转到下一个光标位置", remap = true })

-- Alt + j/k 向上/向下移动当前行
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "向下移动当前行" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "向上移动当前行" })
map("v", "<A-j>", "<cmd>m '>+1<cr>gv=gv", { desc = "向下移动选中行" })
map("v", "<A-k>", "<cmd>m '<-2<cr>gv=gv", { desc = "向上移动选中行" })

-- Ctrl+Alt+S 保存所有缓冲区
-- 有的终端不支持 Ctrl + Alt 系列，可以输入 :echo getcharstr() 后按下快捷键，看是否有捕捉到按键
map({ "i", "x", "n", "s" }, "<C-A-s>", "<cmd>wa<cr><esc>", { desc = "保存所有缓冲区" })
