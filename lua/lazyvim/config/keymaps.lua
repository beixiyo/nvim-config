-- 这个文件由 lazyvim.config.init 自动加载
-- LazyVim 启动后会自动注入所有键盘映射配置

-- 注意：不要在你的个人配置中使用 `LazyVim.safe_keymap_set`！
-- 应该直接使用 `vim.keymap.set` 或者这个文件中的 `map` 函数
-- LazyVim 内部使用这个包装函数来安全地注册映射，避免重复映射
-- `map` 是 `LazyVim.safe_keymap_set` 的简写别名，方便使用

-- 导入 LazyVim 的安全键位映射函数
-- 这个函数会在添加映射前检查是否已经存在相同的映射
-- 如果存在，会覆盖旧映射；如果不存在，则添加新映射
---@param modes string|string[] 映射模式，如 "n"（普通模式）或 {"n", "i"}（多模式）
---@param lhs string 左侧映射键，如 "<leader>f" 或 "j"
---@param rhs string 右侧命令或函数，如 "<cmd>foo<cr>" 或 function() ... end
---@param opts table 配置选项，如 { desc = "描述", remap = false }
local map = LazyVim.safe_keymap_set

-- 插入模式下按 jk 退出插入模式
map("i", "jk", "<ESC>")

-- 智能上下移动映射（针对软换行优化）
-- 普通模式和可视模式下的智能向下移动
-- expr = true 让映射使用表达式，结果根据是否输入数字前缀动态决定
-- 如果没有数字前缀（v:count == 0），使用 'gj' 移动屏幕行
-- 如果有数字前缀，使用 'j' 移动实际行
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", {
  desc = "向下移动（无前缀按屏幕行，有前缀按实际行）",
  expr = true,  -- 使用表达式解释
  silent = true  -- 执行时不显示输入的命令
})
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", {
  desc = "下方向键（兼容软换行）",
  expr = true,
  silent = true
})

-- 普通模式和可视模式下的智能向上移动
-- 同样根据前缀决定移动方式
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", {
  desc = "向上移动（无前缀按屏幕行，有前缀按实际行）",
  expr = true,
  silent = true
})
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", {
  desc = "上方向键（兼容软换行）",
  expr = true,
  silent = true
})

-- 窗口间快速导航映射
-- 使用 Ctrl + hjkl 快速切换到不同的窗口
-- 这是 Vim 中分割窗口时最常用的导航方式
-- 替代了 Vim 原生的 <C-w>h 等命令，更加直观

-- 切换到左侧窗口
-- <C-w> 是 Vim 的窗口操作前缀键，<C-w>h 表示移动到左边窗口
-- remap = true 允许这些映射调用其他的映射，避免递归问题
map("n", "<C-h>", "<C-w>h", {
  desc = "切换到左侧窗口",
  remap = true  -- 允许递归映射
})

-- 切换到下方窗口
map("n", "<C-j>", "<C-w>j", {
  desc = "切换到下方窗口",
  remap = true
})

-- 切换到上方窗口
map("n", "<C-k>", "<C-w>k", {
  desc = "切换到上方窗口",
  remap = true
})

-- 切换到右侧窗口
map("n", "<C-l>", "<C-w>l", {
  desc = "切换到右侧窗口",
  remap = true
})

-- Resize window using <ctrl> arrow keys / Ctrl + 方向微调窗口尺寸
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加窗口高度" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减少窗口高度" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少窗口宽度" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加窗口宽度" })

-- Move Lines / Alt+j/k 在不同模式下移动当前行或选区
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "向下移动当前行" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "向上移动当前行" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "插入模式向下移动行" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "插入模式向上移动行" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "选区整体向下移动" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "选区整体向上移动" })

-- buffers / 缓冲区切换与管理
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个缓冲区" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "下一个缓冲区" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "上一个缓冲区" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "下一个缓冲区" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "切换到最近的缓冲区" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "切换到最近的缓冲区" })
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "关闭当前缓冲区" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "关闭其他缓冲区" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "关闭缓冲区并关闭窗口" })

-- Clear search and stop snippet on escape / Esc 时清理高亮并停止 snippet
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  LazyVim.cmp.actions.snippet_stop()
  return "<esc>"
end, { expr = true, desc = "退出并清除搜索高亮" })

-- Clear search, diff update and redraw / 一键刷新界面，来自 runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "重绘屏幕+清理搜索+刷新 diff" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "下一个搜索结果并保持在视野中" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "可视模式下下一个结果" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "操作等待模式下下一个结果" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "上一个搜索结果并保持在视野中" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "可视模式上一个结果" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "操作等待模式上一个结果" })

-- Add undo break-points / 在插入模式下输入 , . ; 时自动打断 undo，方便分段撤销
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file / Ctrl+S 在各模式保存文件
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "保存当前文件" })

-- keywordprg / 保留原生 K 键行为，便于查看文档
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "调用 K 查询关键字" })

-- better indenting / 在可视模式缩进后保持选区
map("x", "<", "<gv")
map("x", ">", ">gv")

-- commenting / 快速在上下添加带注释的新行
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "在下方插入注释行" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "在上方插入注释行" })

-- lazy / 打开 lazy.nvim 插件管理界面
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "打开插件管理界面" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "创建空缓冲区" })

-- location list / 开关当前窗口的定位列表
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "打开或关闭 Location List" })

-- quickfix list / 打开或关闭全局 Quickfix 列表
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "打开或关闭 Quickfix" })

map("n", "[q", vim.cmd.cprev, { desc = "Quickfix 上一个项目" })
map("n", "]q", vim.cmd.cnext, { desc = "Quickfix 下一个项目" })

-- formatting / 强制格式化当前 buffer
map({ "n", "x" }, "<leader>cf", function()
  LazyVim.format({ force = true })
end, { desc = "调用格式化（可视模式时为选区）" })

-- diagnostic / 诊断和错误跳转
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "查看当前行诊断" })
map("n", "]d", diagnostic_goto(true), { desc = "下一个诊断问题" })
map("n", "[d", diagnostic_goto(false), { desc = "上一个诊断问题" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "下一个错误" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "上一个错误" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "下一个警告" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "上一个警告" })

-- stylua: ignore start

-- toggle options / 使用 Snacks.toggle 快速开关常用选项
LazyVim.format.snacks_toggle():map("<leader>uf") -- Toggle auto-format / 切换保存时自动格式化
LazyVim.format.snacks_toggle(true):map("<leader>uF") -- Force format on save / 强制覆盖格式化
Snacks.toggle.option("spell", { name = "Spelling 拼写检查" }):map("<leader>us") -- 切换拼写检查
Snacks.toggle.option("wrap", { name = "Wrap 自动换行" }):map("<leader>uw") -- 切换自动换行
Snacks.toggle.option("relativenumber", { name = "Relative Number 相对行号" }):map("<leader>uL") -- 切换相对行号
Snacks.toggle.diagnostics():map("<leader>ud") -- Toggle Diagnostics / 显示或隐藏诊断提示
Snacks.toggle.line_number():map("<leader>ul") -- Toggle Line Numbers / 同时控制绝对+相对行号
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level 语法隐藏" }):map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline 标签栏" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT") -- Toggle Treesitter / 开关语法树高亮
Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background 深色背景" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD") -- Toggle Dim / 高亮当前窗口，暗化其他窗口
Snacks.toggle.animate():map("<leader>ua") -- Toggle Animations / UI 动画开关
Snacks.toggle.indent():map("<leader>ug") -- Toggle Indent Guides / 高亮缩进线
Snacks.toggle.scroll():map("<leader>uS") -- Toggle Smooth Scroll / 平滑滚动
Snacks.toggle.profiler():map("<leader>dpp") -- Toggle Profiler / 性能分析
Snacks.toggle.profiler_highlights():map("<leader>dph") -- Toggle Profiler Highlights / 查看高亮耗时

if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh") -- Toggle Inlay Hints / 切换 LSP 内联提示
end

-- lazygit / 如果系统安装 lazygit，则提供快捷打开
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "在项目根目录打开 Lazygit" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "在当前工作目录打开 Lazygit" })
end

map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "查看当前目录提交历史" })
map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "查看当前行的 git 责任人" })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "当前文件的提交历史" })
map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, { desc = "项目根目录提交历史" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "在浏览器中打开对应链接" })
map({"n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "复制当前行或选区的远程链接" })

-- quit / 快速退出所有窗口
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "退出 Neovim" })

-- highlights under cursor / 检查当前光标的高亮信息
map("n", "<leader>ui", vim.show_pos, { desc = "打印语法高亮信息" })
map("n", "<leader>uI", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "打开 Treesitter 语法树检查器" })

-- LazyVim Changelog / 查看 LazyVim 更新日志
map("n", "<leader>L", function() LazyVim.news.changelog() end, { desc = "打开更新说明" })

-- floating terminal / 调出 Snacks 提供的浮动终端
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "浮动终端（当前目录）" })
map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "浮动终端（项目根）" })
map({"n","t"}, "<c-/>",function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "在任意模式呼出浮动终端" })
map({"n","t"}, "<c-_>",function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "which_key_ignore" }) -- which-key 中隐藏该快捷键

-- windows / 管理窗口和布局
map("n", "<leader>-", "<C-W>s", { desc = "横向分屏", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "纵向分屏", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "关闭当前窗口", remap = true })
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ") -- Toggle Zoom / 放大当前窗口
Snacks.toggle.zen():map("<leader>uz") -- Toggle Zen Mode / 禅模式

-- tabs / 标签页管理
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "跳到最后一个标签页" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "关闭其他标签页" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "跳到第一个标签页" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "新建标签页" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "下一个标签页" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "关闭当前标签页" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "上一个标签页" })

-- lua / 在 Lua 文件中快速运行选中的代码块
map({"n", "x"}, "<localleader>r", function() Snacks.debug.run() end, { desc = "运行当前行或选区", ft = "lua" })
