## Snacks 功能清单

### 1. Snacks.picker（选择器/模糊查找器）

#### 文件查找
- `Snacks.picker.files(opts)` - 查找文件
- `Snacks.picker.git_files(opts)` - 查找 Git 管理的文件
- `Snacks.picker.recent(opts)` - 最近打开的文件
- `Snacks.picker.buffers(opts)` - 缓冲区列表
- `Snacks.picker.projects(opts)` - 项目管理
- `Snacks.picker.smart(opts)` - 智能文件查找（自动选择 git_files 或 files）

#### 搜索功能
- `Snacks.picker.grep()` - 实时搜索（live grep）
- `Snacks.picker.grep_word()` - 搜索单词
- `Snacks.picker.grep_buffers()` - 搜索所有打开的缓冲区
- `Snacks.picker.lines()` - 搜索当前缓冲区内容
- `Snacks.picker.pick(source, opts)` - 通用选择器接口

#### LSP 相关
- `Snacks.picker.lsp_definitions(opts)` - 跳转到定义
- `Snacks.picker.lsp_declarations(opts)` - 跳转到声明
- `Snacks.picker.lsp_references(opts)` - 查找引用
- `Snacks.picker.lsp_implementations(opts)` - 跳转到实现
- `Snacks.picker.lsp_type_definitions(opts)` - 跳转到类型定义
- `Snacks.picker.lsp_symbols(opts)` - 文档符号
- `Snacks.picker.lsp_workspace_symbols(opts)` - 工作区符号
- `Snacks.picker.lsp_incoming_calls(opts)` - 传入调用
- `Snacks.picker.lsp_outgoing_calls(opts)` - 传出调用
- `Snacks.picker.lsp_config(opts)` - LSP 配置信息

#### Git 相关
- `Snacks.picker.git_status(opts)` - Git 状态
- `Snacks.picker.git_stash(opts)` - Git 储藏
- `Snacks.picker.git_diff(opts)` - Git 差异
- `Snacks.picker.git_log(opts)` - Git 提交历史
- `Snacks.picker.git_log_line(opts)` - 当前行的 Git 责任人
- `Snacks.picker.git_log_file(opts)` - 文件的提交历史
- `Snacks.picker.git_branches(opts)` - Git 分支列表
- `Snacks.picker.gh_issue(opts)` - GitHub Issues
- `Snacks.picker.gh_pr(opts)` - GitHub Pull Requests

#### 诊断和列表
- `Snacks.picker.diagnostics()` - 所有诊断信息
- `Snacks.picker.diagnostics_buffer()` - 当前缓冲区的诊断
- `Snacks.picker.qflist()` - Quickfix 列表
- `Snacks.picker.loclist()` - Location 列表
- `Snacks.picker.todo_comments()` - Todo 注释

#### Neovim 内部
- `Snacks.picker.commands()` - 所有可用命令
- `Snacks.picker.command_history()` - 命令历史
- `Snacks.picker.search_history()` - 搜索历史
- `Snacks.picker.registers()` - 寄存器
- `Snacks.picker.marks()` - 标记位置
- `Snacks.picker.jumps()` - 跳转列表
- `Snacks.picker.autocmds()` - 自动命令
- `Snacks.picker.keymaps()` - 按键映射
- `Snacks.picker.highlights()` - 语法高亮组
- `Snacks.picker.help()` - 帮助页面
- `Snacks.picker.man()` - Man 页面
- `Snacks.picker.icons()` - 可用图标
- `Snacks.picker.colorschemes()` - 颜色主题
- `Snacks.picker.undo()` - 撤销树
- `Snacks.picker.notifications()` - 通知历史
- `Snacks.picker.lazy()` - 搜索插件规范
- `Snacks.picker.resume()` - 恢复上次搜索

---

### 2. Snacks.terminal（终端）

- `Snacks.terminal(cmd, opts)` - 打开/切换浮动或分屏终端
- `Snacks.terminal.get(cmd, opts)` - 获取或创建终端窗口
- `Snacks.terminal.open(cmd, opts)` - 打开终端
- `Snacks.terminal.toggle(cmd, opts)` - 切换终端
- `Snacks.terminal.list()` - 列出所有终端
- `Snacks.terminal.tid(cmd, opts)` - 获取终端 ID
- `Snacks.terminal.colorize()` - 为当前缓冲区着色（ANSI 颜色代码）
- 支持自定义命令和目录

---

### 3. Snacks.explorer（文件浏览器）

- `Snacks.explorer(opts)` - 打开文件树浏览器
- `Snacks.explorer.open(opts)` - 打开浏览器选择器
- `Snacks.explorer.reveal(opts)` - 在浏览器中显示文件/缓冲区
- `Snacks.explorer.health()` - 健康检查
- 替代 neo-tree，支持文件操作（复制、移动、删除、重命名等）

---

### 4. Snacks.dashboard（仪表板）

- `Snacks.dashboard(opts)` - 打开仪表板
- `Snacks.dashboard.pick(cmd, opts)` - Dashboard 选择器接口
- `Snacks.dashboard.open(opts)` - 打开仪表板
- `Snacks.dashboard.setup()` - 检查是否应该打开仪表板
- `Snacks.dashboard.update()` - 更新仪表板
- `Snacks.dashboard.have_plugin(name)` - 检查插件是否安装
- `Snacks.dashboard.health()` - 健康检查
- `Snacks.dashboard.icon(name, cat)` - 获取图标
- `Snacks.dashboard.sections` - 内置章节（header、keys、projects、recent_files、session、startup、terminal）
- 启动欢迎页和快捷按钮

---

### 5. Snacks.notifier（通知系统）

- `Snacks.notifier(msg, level, opts)` - 发送通知
- `Snacks.notifier.notify(msg, level, opts)` - 发送通知
- `Snacks.notifier.show_history(opts)` - 显示通知历史
- `Snacks.notifier.get_history(opts)` - 获取通知历史
- `Snacks.notifier.hide(id)` - 隐藏通知（可指定 ID）
- 替代 `vim.notify`，与 Noice 集成

---

### 6. Snacks.bufdelete（缓冲区删除）

- `Snacks.bufdelete(bufnr)` - 安全删除缓冲区
- 不破坏窗口布局，被 bufferline.nvim 使用

---

### 7. Snacks.rename（文件重命名）

- `Snacks.rename.rename_file()` - 重命名文件
- `Snacks.rename.on_rename_file(from, to)` - 文件重命名回调

---

### 8. Snacks.words（单词高亮和跳转）

- `Snacks.words.jump(count, wrap)` - 跳转到下一个/上一个引用
- `Snacks.words.is_enabled()` - 检查是否启用
- 用于 LSP documentHighlight

---

### 9. Snacks.toggle（各种切换功能）

#### 选项切换
- `Snacks.toggle.option(name, opts)` - 切换任意选项
  - `spell` - 拼写检查
  - `wrap` - 自动换行
  - `relativenumber` - 相对行号
  - `conceallevel` - 语法隐藏
  - `showtabline` - 标签栏
  - `background` - 背景色

#### 功能切换
- `Snacks.toggle.diagnostics()` - 诊断提示
- `Snacks.toggle.line_number()` - 行号
- `Snacks.toggle.treesitter()` - Treesitter 高亮
- `Snacks.toggle.dim()` - 窗口高亮/暗化
- `Snacks.toggle.animate()` - UI 动画
- `Snacks.toggle.indent()` - 缩进线
- `Snacks.toggle.scroll()` - 平滑滚动
- `Snacks.toggle.inlay_hints()` - LSP 内联提示
- `Snacks.toggle.zoom()` - 窗口缩放
- `Snacks.toggle.zen()` - 禅模式

#### 性能分析
- `Snacks.toggle.profiler()` - 性能分析
- `Snacks.toggle.profiler_highlights()` - 高亮耗时

---

### 10. Snacks.util（工具函数）

- `Snacks.util.color(name)` - 获取颜色
- `Snacks.util.lsp.on(opts, callback)` - LSP 事件监听
  - `method` - 监听 LSP 方法
  - `name` - 监听 LSP 服务器名称
- `Snacks.util.blend(fg, bg, alpha)` - 混合颜色
- `Snacks.util.bo(buf, bo)` - 设置缓冲区选项
- `Snacks.util.debounce(fn, opts)` - 防抖函数
- `Snacks.util.throttle(fn, opts)` - 节流函数
- `Snacks.util.file_encode(str)` / `Snacks.util.file_decode(str)` - 文件名编码/解码
- `Snacks.util.get_lang(lang)` - 获取语言
- `Snacks.util.icon(name, cat)` - 获取图标
- `Snacks.util.is_float(win)` - 检查是否为浮动窗口
- `Snacks.util.is_transparent()` - 检查主题是否透明
- `Snacks.util.keycode(str)` - 键码转换
- `Snacks.util.normkey(key)` - 规范化键
- `Snacks.util.on_key(...)` - 按键监听
- `Snacks.util.on_module(modname, cb)` - 模块加载监听
- `Snacks.util.parse(parser, range, on_parse)` - 异步解析
- `Snacks.util.path_type(path)` - 检查路径类型（文件/目录）
- `Snacks.util.redraw(win)` - 重绘窗口
- `Snacks.util.redraw_range(win, from, to)` - 重绘范围
- `Snacks.util.ref(t)` - 引用包装
- `Snacks.util.set_hl(groups, opts)` - 设置高亮组
- `Snacks.util.spinner()` - 加载动画
- `Snacks.util.stop(handle)` - 停止定时器
- `Snacks.util.var(buf, name, default)` - 获取变量
- `Snacks.util.winhl(...)` - 合并窗口高亮选项
- `Snacks.util.wo(win, wo)` - 设置窗口选项
- `Snacks.util.spawn` - 子模块：进程生成

---

### 11. Snacks.gitbrowse（Git 浏览）

- `Snacks.gitbrowse(opts)` - 在浏览器中打开 Git 链接
- 支持复制链接到剪贴板

---

### 12. Snacks.scratch（临时缓冲区）

- `Snacks.scratch()` - 切换临时缓冲区
- `Snacks.scratch.select()` - 选择临时缓冲区

---

### 13. Snacks.profiler（性能分析）

- `Snacks.profiler.find(opts)` - 分组和过滤跟踪
- `Snacks.profiler.highlight()` - 高亮函数和调用
- `Snacks.profiler.scratch()` - 打开临时缓冲区
- `Snacks.profiler.core` - 核心模块
- `Snacks.profiler.loc` - 位置模块
- `Snacks.profiler.tracer` - 跟踪器模块
- `Snacks.profiler.ui` - UI 模块
- `Snacks.profiler.picker` - 选择器模块

---

### 14. Snacks.lazygit（Lazygit 集成）

- `Snacks.lazygit(opts)` - 打开 Lazygit（如果已安装）

---

### 15. Snacks.win（窗口管理）

- `Snacks.win(opts)` - 创建浮动窗口或分屏
- `Snacks.config.style(name, opts)` - 配置窗口样式
- 支持多种布局预设和自定义样式

---

### 16. Snacks.keymap（键映射）

- `Snacks.keymap.set(mode, lhs, rhs, opts)` - 设置键映射

---

### 17. Snacks.config（配置管理）

- `Snacks.config.style(name, opts)` - 配置样式
- `Snacks.config.picker` - Picker 配置
- `Snacks.config.dashboard` - Dashboard 配置

---

### 18. Snacks.picker 补充说明

- 所有 picker 函数都支持 `opts` 参数进行自定义配置
- Picker 支持 fzf 搜索语法和字段搜索（如 `file:lua$ 'function`）
- 支持多选、预览、不同布局等高级功能
- 可以替换 `vim.ui.select` 提供更好的选择体验

---

### 19. Snacks.animate（动画库）

- 高效的动画系统，包含 45+ 缓动函数
- 库模块，供其他 Snacks 模块使用

---

### 20. Snacks.debug（调试工具）

- `Snacks.debug.inspect(...)` - 美化打印 Lua 值
- `Snacks.debug.backtrace()` - 生成回溯
- `_G.dd(...)` - 全局调试函数（包装 inspect）
- `_G.bt()` - 全局回溯函数

---

### 21. Snacks.dim（聚焦功能）

- `Snacks.toggle.dim()` - 高亮当前作用域，暗化其他部分
- 通过 toggle 系统使用

---

### 22. Snacks.gh（GitHub CLI 集成）

- GitHub CLI 集成功能
- 与 picker 中的 `gh_issue()` 和 `gh_pr()` 配合使用

---

### 23. Snacks.git（Git 工具）

- Git 实用工具
- 与 picker 中的 Git 相关功能配合使用

---

### 24. Snacks.image（图片查看器）

- 使用 Kitty Graphics Protocol 查看图片
- 支持 `kitty`、`wezterm` 和 `ghostty` 终端
- 支持多种图片格式（png、jpg、gif、bmp、webp、tiff、heic、avif、mp4、mov、avi、mkv、webm、pdf、icns）

---

### 25. Snacks.indent（缩进指南）

- `Snacks.toggle.indent()` - 切换缩进线显示
- 缩进指南和作用域检测

---

### 26. Snacks.layout（布局管理）

- 窗口布局管理
- Picker 使用此模块进行布局

---

### 27. Snacks.notify（通知工具函数）

- 与 Neovim 的 `vim.notify` 配合使用的工具函数
- 与 `Snacks.notifier` 配合使用

---

### 28. Snacks.scope（作用域检测）

- `Snacks.scope.get(cb, opts)` - 获取作用域
- `Snacks.scope.jump(opts)` - 跳转到作用域顶部/底部
- `Snacks.scope.textobject(opts)` - 文本对象（用于 visual 模式）
- `Snacks.scope.attach(cb, opts)` - 附加作用域监听器
- 基于 Treesitter 或缩进的作用域检测

---

### 29. Snacks.scroll（平滑滚动）

- `Snacks.toggle.scroll()` - 切换平滑滚动
- 平滑滚动功能

---

### 30. Snacks.zen（禅模式）

- `Snacks.zen()` - 切换禅模式
- `Snacks.zen.zoom()` - 切换缩放
- 专注编码模式，减少干扰

---

### 31. 其他模块（已列出但需补充说明）

- `Snacks.bigfile` - 大文件处理（自动优化大文件性能）
- `Snacks.input` - 更好的 `vim.ui.input`（改进输入对话框）
- `Snacks.quickfile` - 快速文件（启动时快速渲染文件）
- `Snacks.statuscolumn` - 状态列（美化状态列显示）

---

---

## 总结

Snacks.nvim 是一个综合工具集，提供：

### 核心功能
- **模糊查找**（picker）- 40+ 内置源，支持 fzf 搜索语法
- **终端管理**（terminal）- 浮动/分屏终端
- **文件浏览器**（explorer）- 替代 neo-tree
- **通知系统**（notifier）- 替代 vim.notify
- **仪表板**（dashboard）- 启动欢迎页

### 开发工具
- **LSP 集成** - 定义、引用、符号等
- **Git 集成** - 状态、差异、日志、GitHub 等
- **性能分析**（profiler）- Lua 性能分析器
- **调试工具**（debug）- 美化打印和回溯

### UI/UX 增强
- **切换系统**（toggle）- 统一的选项切换接口
- **动画**（animate）- 45+ 缓动函数
- **聚焦**（dim）- 高亮当前作用域
- **禅模式**（zen）- 专注编码模式
- **平滑滚动**（scroll）
- **状态列**（statuscolumn）- 美化状态列

### 工具模块
- **窗口管理**（win）- 浮动窗口和分屏
- **布局管理**（layout）- 窗口布局
- **键映射**（keymap）- 增强的 vim.keymap
- **工具函数**（util）- 丰富的实用函数库
- **图片查看**（image）- Kitty Graphics Protocol
- **作用域检测**（scope）- Treesitter/缩进作用域

### 文件操作
- **缓冲区删除**（bufdelete）- 安全删除缓冲区
- **文件重命名**（rename）- LSP 集成重命名
- **临时缓冲区**（scratch）- 持久化临时文件
- **快速文件**（quickfile）- 启动时快速渲染
- **大文件处理**（bigfile）- 自动优化

这些功能统一在一个插件中，减少依赖，提升性能，提供一致的 API 和用户体验。