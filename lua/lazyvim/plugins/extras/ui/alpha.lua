-- LazyVim Alpha 欢迎页面配置文件
-- 功能：配置 Alpha-nvim 插件，创建美丽的 Neovim 启动欢迎页面
-- 说明：提供可定制的启动画面，包含 LazyVim LOGO、快速操作按钮和启动统计信息

-- ========================================
-- Alpha-nvim 欢迎页面配置
-- ========================================

return {

  -- 首先禁用 Snacks 插件的 dashboard 功能，避免冲突
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },

  -- Alpha-nvim 主要配置
  -- 注释：Dashboard. This runs when neovim starts, and is what displays the "LAZYVIM" banner.
  -- 说明：这是一个在 Neovim 启动时运行的欢迎界面，显示 "LAZYVIM" 横幅和快捷操作
  {
    "goolord/alpha-nvim",

    -- 触发事件：VimEnter - 在 Neovim 完全启动后立即显示欢迎页面
    event = "VimEnter",
    -- 启用此插件
    enabled = true,
    -- 禁用初始化（避免在配置文件时加载）
    init = false,

    -- 插件选项配置函数
    opts = function()
      -- 引入 Alpha 的默认主题样式
      local dashboard = require("alpha.themes.dashboard")

      -- ========================================
      -- 1. 定义 LazyVim 特色 LOGO
      -- ========================================

      -- ASCII 艺术 LOGO，采用经典的 Neovim 风格设计
      -- 包含了 LazyVim 的 Z 标志和装饰性边框
      local logo = [[
           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      -- 将 LOGO 字符串分割为行数组，设置到头部区域
      dashboard.section.header.val = vim.split(logo, "\n")

      -- ========================================
      -- 2. 配置快速操作按钮
      -- ========================================

      -- stylua: ignore

      -- 定义各种快捷操作的按钮，每个按钮包含：
      -- - 快捷键 (第一个参数)
      -- - 图标 + 描述文字
      -- - 执行命令
      dashboard.section.buttons.val = {
        -- 查找文件：使用 LazyVim 的模糊查找器
        dashboard.button("f", " " .. " Find file",       "<cmd> lua LazyVim.pick()() <cr>"),

        -- 新建文件：创建新缓冲区并切换到插入模式
        dashboard.button("n", " " .. " New file",        [[<cmd> ene <BAR> startinsert <cr>]]),

        -- 最近文件：显示之前编辑过的文件列表
        dashboard.button("r", " " .. " Recent files",    [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),

        -- 搜索文本：在当前项目中搜索指定文本
        dashboard.button("g", " " .. " Find text",       [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),

        -- 配置文件：快速访问 LazyVim 配置文件
        dashboard.button("c", " " .. " Config",          "<cmd> lua LazyVim.pick.config_files()() <cr>"),

        -- 恢复会话：恢复上一次的工作会话
        dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),

        -- Lazy 扩展：显示和管理 LazyVim 扩展插件
        dashboard.button("x", " " .. " Lazy Extras",     "<cmd> LazyExtras <cr>"),

        -- Lazy 管理：打开 Lazy 插件管理器界面
        dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),

        -- 退出 Neovim：关闭所有标签页并退出
        dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
      }

      -- ========================================
      -- 3. 设置按钮和区域的语法高亮
      -- ========================================

      -- 为每个按钮设置高亮样式
      for _, button in ipairs(dashboard.section.buttons.val) do
        -- 设置按钮主文本的高亮组
        button.opts.hl = "AlphaButtons"
        -- 设置快捷键部分的高亮组
        button.opts.hl_shortcut = "AlphaShortcut"
      end

      -- 设置不同区域的高亮组
      dashboard.section.header.opts.hl = "AlphaHeader"     -- LOGO 头部高亮
      dashboard.section.buttons.opts.hl = "AlphaButtons"   -- 按钮区域高亮
      dashboard.section.footer.opts.hl = "AlphaFooter"     -- 页脚区域高亮

      -- ========================================
      -- 4. 调整布局设置
      -- ========================================

      -- 设置头部区域的垂直间距（8 行高度）
      dashboard.opts.layout[1].val = 8

      -- 返回完整的配置对象
      return dashboard
    end,

    -- 插件最终配置函数
    config = function(_, dashboard)
      -- ========================================
      -- 5. 处理 Lazy 界面交互
      -- ========================================

      -- 如果当前在 Lazy 界面，关闭它并在 Alpha 准备好后重新显示
      if vim.o.filetype == "lazy" then
        -- 关闭当前 Lazy 界面
        vim.cmd.close()

        -- 创建自动命令，在 Alpha 准备好后重新显示 Lazy
        vim.api.nvim_create_autocmd("User", {
          once = true,               -- 只执行一次
          pattern = "AlphaReady",    -- 当 Alpha 准备就绪时触发
          callback = function()
            -- 重新显示 Lazy 插件管理器
            require("lazy").show()
          end,
        })
      end

      -- ========================================
      -- 6. 设置 Alpha 界面
      -- ========================================

      -- 使用提供的选项设置 Alpha
      require("alpha").setup(dashboard.opts)

      -- ========================================
      -- 7. 设置启动统计信息更新
      -- ========================================

      -- 创建自动命令，在 LazyVim 启动完成后更新页脚统计信息
      vim.api.nvim_create_autocmd("User", {
        once = true,                -- 只执行一次
        pattern = "LazyVimStarted", -- 当 LazyVim 完全启动时触发
        callback = function()
          -- 获取插件加载统计信息
          local stats = require("lazy").stats()
          -- 计算启动时间（保留两位小数）
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

          -- 构建统计信息文本
          dashboard.section.footer.val = "⚡ Neovim loaded "
            .. stats.loaded    -- 已加载的插件数量
            .. "/"             -- 分隔符
            .. stats.count     -- 总插件数量
            .. " plugins in "  -- 描述文本
            .. ms              -- 启动时间（毫秒）
            .. "ms"            -- 单位

          -- 尝试刷新 Alpha 界面以显示更新的统计信息
          -- 使用 pcall 避免可能的错误影响启动流程
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
