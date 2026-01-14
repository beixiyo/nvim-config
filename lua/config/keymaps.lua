-- 用户自定义键位映射
--
-- LazyVim 的加载顺序：
-- 1. 先加载 lazyvim/config/keymaps.lua（LazyVim 默认配置）
-- 2. 然后加载 config/keymaps.lua（用户配置，会覆盖默认配置）⭐
-- 3. 最后触发 LazyVimKeymaps 事件
--
-- 注意：
-- - 用户配置可以覆盖 LazyVim 的默认映射
-- - 但无法覆盖插件的 buffer-local 映射（buffer-local 优先级更高）
-- - 如果快捷键不生效，使用 :verbose map <键> 查看当前映射和来源
-- - 查看 LazyVim 默认快捷键：lua/lazyvim/config/keymaps.lua
--
-- 关于 safe_keymap_set 和 vim.keymap.set 的区别：
-- - LazyVim.safe_keymap_set：LazyVim 内部使用的包装函数
--   * 会在添加映射前检查是否已存在相同的映射
--   * 如果存在，会覆盖旧映射；如果不存在，则添加新映射
--   * 支持 ft 参数（仅在特定文件类型下注册）
--   * 主要用于 LazyVim 内部，避免重复映射冲突
-- - vim.keymap.set：Neovim 原生函数
--   * 直接设置映射，不会检查是否已存在
--   * 如果已存在映射，会直接覆盖（不会警告）
--   * 用户配置中推荐使用这个，更直观，能感知所有注册的映射
-- 参考：lua/lazyvim/config/keymaps.lua:4-7 的注释说明

local map = vim.keymap.set

-- map("n", "<C-c", "<cmd>PickColor<cr>", { desc = "打开颜色选择器" })
-- map("i", "<C-c", "<cmd>PickColorInsert<cr>", { desc = "打开颜色选择器" })

-- mini.files 文件浏览
map('n', '<leader>fm', function()
  require('mini.files').open()
end, { desc = 'mini.files 文件浏览' })

-- ==================== VSCode 风格快捷键 ====================

-- Ctrl+C 复制（类似 VSCode 的复制快捷键）
-- 可视模式：复制选中内容到系统剪贴板
map("v", "<C-c>", '"+y', { desc = "复制到系统剪贴板", silent = true })
-- 注意：在普通模式下，Ctrl+C 通常用于中断命令，不建议覆盖

-- Ctrl+V 粘贴（类似 VSCode 的粘贴快捷键）
-- 普通模式：在光标后粘贴系统剪贴板内容
map("n", "<C-v>", '"+p', { desc = "粘贴系统剪贴板内容", silent = true })
-- 插入模式：在当前位置粘贴系统剪贴板内容
map("i", "<C-v>", "<C-r>+", { desc = "粘贴系统剪贴板内容", silent = true })
-- 可视模式：替换选中内容为系统剪贴板内容
map("v", "<C-v>", '"+p', { desc = "粘贴系统剪贴板内容", silent = true })

-- Alt + Shift + (j/k) 复制行（类似 VSCode 的 Alt + Shift + Up/Down）
-- 普通模式：复制当前行到上一行/下一行
-- 使用 :t 命令，.+1 表示复制到下一行，.-1 表示复制到上一行
map("n", "<A-S-j>", "<cmd>execute 't' . '.' . '+' . v:count1<cr>", { desc = "向下复制当前行" })
map("n", "<A-S-k>", "<cmd>execute 't' . '.' . '-1'<cr>", { desc = "向上复制当前行" })
-- 插入模式：复制当前行
map("i", "<A-S-j>", "<esc><cmd>t.<cr>gi", { desc = "向下复制当前行" })
map("i", "<A-S-k>", "<esc><cmd>t.-1<cr>gi", { desc = "向上复制当前行" })
-- 可视模式：复制选中的行
map("v", "<A-S-j>", ":<C-u>execute \"'<,'>t'><\" . v:count1<cr>gv", { desc = "向下复制选中行" })
map("v", "<A-S-k>", ":<C-u>execute \"'<,'>t'<-\" . (v:count1 + 1)<cr>gv", { desc = "向上复制选中行" })

-- Ctrl + / 切换注释（覆盖默认的打开终端功能）
-- 使用 mini.comment 的默认映射 gcc (单行) 和 gc (选区)
-- 普通模式：注释/取消注释当前行
map("n", "<C-/>", "gcc", { desc = "切换注释", silent = true, remap = true })
map("n", "<C-_>", "gcc", { desc = "切换注释（兼容）", silent = true, remap = true })
-- 可视模式：注释/取消注释选中内容
map("v", "<C-/>", "gc", { desc = "切换注释", silent = true, remap = true })
map("v", "<C-_>", "gc", { desc = "切换注释（兼容）", silent = true, remap = true })

-- Ctrl+S 保存当前文件（LazyVim 默认已提供，这里仅作说明）
-- 注意：<C-s> 已在 lua/lazyvim/config/keymaps.lua 中定义，支持 i/x/n/s 模式

-- Ctrl+Alt+S 保存所有缓冲区（类似 VSCode 的保存所有文件）
-- 有的终端不支持 Ctrl + Alt 系列，可以输入 :echo getcharstr() 后按下快捷键，看是否有捕捉到按键
map({ "i", "x", "n", "s" }, "<C-A-s>", "<cmd>wa<cr><esc>", { desc = "保存所有缓冲区" })

-- Ctrl+Z 撤销（类似 VSCode 的撤销快捷键）
map({ "n", "v" }, "<C-z>", "u", { desc = "撤销", remap = true })
-- 插入模式：退出插入模式后撤销
map("i", "<C-z>", "<esc>u", { desc = "撤销" })

-- Ctrl+Shift+Z 重做（类似 VSCode 的重做快捷键）
map({ "n", "v" }, "<C-S-z>", "<C-r>", { desc = "重做", remap = true })
-- 插入模式：退出插入模式后重做
map("i", "<C-S-z>", "<esc><C-r>", { desc = "重做" })

-- Alt + Left/Right 跳转到上一个/下一个光标位置（类似 VSCode 的导航历史）
-- Alt+Left：跳转到上一个位置（对应 <C-o>）
map("n", "<A-Left>", "<C-o>", { desc = "跳转到上一个光标位置", remap = true })
-- Alt+Right：跳转到下一个位置（对应 <C-i>）
map("n", "<A-Right>", "<C-i>", { desc = "跳转到下一个光标位置", remap = true })

-- Ctrl+` 切换终端显示（类似 VSCode 的终端切换快捷键）
-- 支持普通模式和终端模式
map({ "n", "t" }, "<C-`>", function()
  -- 检查当前 buffer 是否是终端
  local current_buf = vim.api.nvim_get_current_buf()
  if vim.bo[current_buf].buftype == "terminal" then
    -- 如果在终端中，直接关闭当前窗口
    vim.api.nvim_win_close(0, false)
    return
  end

  -- 查找是否有其他显示的终端窗口
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      -- 找到终端窗口，关闭它
      vim.api.nvim_win_close(win, false)
      return
    end
  end

  -- 如果没有找到显示的终端窗口，打开新终端
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "切换终端显示", silent = true })
