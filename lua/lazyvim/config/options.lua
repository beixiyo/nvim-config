-- 全局 Leader 键配置
-- Leader 键是 Vim 中的特殊前缀键，用于组织用户自定义的快捷键
-- 例如：<leader>f 实际是 空格+f
vim.g.mapleader = " "

-- 本地 Leader 键配置
-- 本地 Leader 键类似于全局 Leader 键，但是作用域为当前缓冲区
-- 通常用于文件类型相关的特殊功能
-- 本地 Leader 键用于创建文件类型特定的快捷键
vim.g.maplocalleader = "\\"

-- 自动代码格式化全局开关
vim.g.autoformat = true

-- Snacks 插件动画效果总开关
-- Snacks 插件提供现代化的 UI 体验，包括动画效果
-- true（默认）：启用所有 UI 动画和视觉效果
--   包括：平滑滚动、淡入淡出、通知动画等
--   优点：现代化的视觉体验，符合当前设计趋势
--   缺点：可能影响低端设备性能
-- false：禁用所有动画效果
--   优点：提升性能，减少资源消耗
--   适合：老旧设备、性能敏感环境、专注模式
-- 建议：现代设备保持 true，传统设备可以设为 false
vim.g.snacks_animate = true

-- 文件选择器（模糊搜索）配置
-- "telescope": 使用 Telescope 插件
-- "fzf": 使用 fzf-lua 插件
-- "snacks": 使用 Snacks.picker
-- "auto": 自动选择（根据已启用的插件）
vim.g.lazyvim_picker = "auto"

-- 代码补全引擎选择
-- "nvim-cmp": 使用 nvim-cmp 插件
-- "blink.cmp": 使用 blink.cmp 插件
-- "auto": 自动选择（推荐）
vim.g.lazyvim_cmp = "auto"

-- 若补全引擎支持 AI source，则优先使用补全菜单中的 AI 项而非内联提示
vim.g.ai_cmp = true

-- LazyVim 的项目根目录检测规则
-- 每个条目可以是：检测函数名 / 需要匹配的目录标记 / 自定义函数
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 可选：配置 Neovim 使用的外部终端（例如 PowerShell），默认注释掉
LazyVim.terminal.setup("pwsh")

-- 当通过 LSP 检测工程根目录时，需要忽略的 LSP server 列表（例如 Copilot 不应改变根目录）
vim.g.root_lsp_ignore = { "copilot" }

-- 是否显示弃用警告
-- true: 显示弃用功能的警告
-- false: 隐藏弃用警告
vim.g.deprecation_warnings = false

-- 是否在 lualine 状态栏中显示 Trouble 的符号信息
-- true: 在状态栏显示当前文档的符号（类、函数等）
-- false: 不显示
-- 可以在特定缓冲区中禁用：vim.b.trouble_lualine = false
vim.g.trouble_lualine = true

local opt = vim.opt

-- 自动写入文件
-- true: 在切换缓冲区或执行某些操作时自动保存文件
opt.autowrite = true
opt.autoread = true -- 自动重新读取文件

-- 剪贴板设置
-- 在 SSH 连接时不设置（保持为空），否则使用系统剪贴板
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
opt.completeopt = "menu,menuone,noselect" -- 控制补全菜单表现：总显示菜单、只有一项时仍展示、不自动选中
opt.conceallevel = 2 -- Markdown 等加粗斜体语法隐藏，只保留必要内容
opt.confirm = true -- 退出修改过的缓冲区时弹窗确认
opt.cursorline = true -- 高亮当前行

opt.expandtab = true -- Tab 转为空格
opt.shiftround = true -- << >> 时对齐到 shiftwidth 的倍数
opt.shiftwidth = 2 -- 缩进宽度
opt.tabstop = 2 -- Tab 显示为 2 个空格

opt.fillchars = {
  foldopen = "", -- 展开折叠时使用的图标
  foldclose = "", -- 折叠状态图标
  fold = " ", -- 折叠行填充字符，空格
  foldsep = " ", -- 折叠分隔填充字符，空格
  diff = "╱", -- diff 视图中的空白填充，斜杠
  eob = " ", -- buffer 末尾（End of buffer）显示空格而非 ~
}
opt.foldlevel = 99 -- 打开文件时尽量保持折叠展开（便于浏览）
opt.foldmethod = "indent" -- 根据缩进创建折叠
opt.foldtext = "" -- 使用空文本，这样配合 statuscolumn 自定义显示
opt.formatexpr = "v:lua.LazyVim.format.formatexpr()" -- 统一使用 LazyVim 的 format 逻辑
opt.formatoptions = "jcroqlnt" -- 控制自动换行、注释等行为

opt.grepformat = "%f:%l:%c:%m" -- ripgrep 输出格式：文件:行:列:信息
opt.grepprg = "rg --vimgrep" -- 使用 ripgrep 作为 :grep 后端
opt.ignorecase = true -- 默认大小写不敏感
opt.inccommand = "nosplit" -- :s 时实时预览但不拆分窗口
opt.jumpoptions = "view" -- 跳转时保存视图状态，返回后保持原样
opt.laststatus = 3 -- 使用全局状态栏
opt.linebreak = true -- 自动换行只在单词边界
opt.list = true -- 显示制表符等不可见字符
opt.mouse = "a" -- 所有模式启用鼠标
opt.number = true -- 显示绝对行号
opt.pumblend = 10 -- 补全弹窗透明度
opt.pumheight = 10 -- 限制补全列表高度
opt.relativenumber = true -- 同时显示相对行号，方便跳转
opt.ruler = false -- 关闭默认右下角标尺（由 statusline 代替）
opt.scrolloff = 4 -- 上下保留 4 行视野
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" } -- 保存会话时包含的内容

opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- 由状态栏显示模式，不再使用默认提示
opt.sidescrolloff = 8 -- 左右各保留 8 列
opt.signcolumn = "yes" -- 始终显示 signcolumn 防止文本抖动
opt.smartcase = true -- 搜索包含大写字母时自动变为大小写敏感
opt.smartindent = true -- 针对代码结构智能缩进
opt.smoothscroll = true -- 开启平滑滚动体验

opt.spelllang = { "en" } -- 拼写检查语言列表
opt.splitbelow = true -- :split 在下方打开
opt.splitright = true -- :vsplit 在右侧打开
opt.splitkeep = "screen" -- 分屏时尽量保持当前屏幕布局

opt.statuscolumn = [[%!v:lua.LazyVim.statuscolumn()]] -- 使用 LazyVim 自定义的状态列（折叠/诊断/行号）
opt.termguicolors = true -- 启用 24-bit 颜色
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- 按键序列超时时间，VSCode 模式下放宽到 1000ms
opt.undofile = true -- 持久化 undo 历史到文件
opt.undolevels = 10000 -- undo 历史深度
opt.updatetime = 200 -- CursorHold 等事件触发更及时
opt.virtualedit = "block" -- 方块可视模式允许越界
opt.wildmode = "longest:full,full" -- 命令行补全行为
opt.winminwidth = 5 -- 每个窗口的最小宽度
opt.wrap = false -- 默认不软折行

-- 关闭默认 markdown 推荐缩进，使用自定义设置
vim.g.markdown_recommended_style = 0
