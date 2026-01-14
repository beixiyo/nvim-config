-- LazyVim Dashboard-nvim 配置文件
-- 功能：配置 Dashboard-nvim 插件，创建现代化的 Neovim 启动欢迎页面
-- 说明：提供优雅的启动界面，使用 Doom 主题样式，包含快捷操作按钮和实时统计信息

-- ========================================
-- Dashboard-nvim 欢迎页面配置
-- ========================================

return {
  -- 首先禁用 Snacks 插件的 dashboard 功能，避免插件冲突
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },

  -- Dashboard-nvim 主要配置
  {
    "nvimdev/dashboard-nvim",

    -- 立即加载（不延迟）
    -- 注释：As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    -- 说明：为了正确处理标准输入流，dashboard-nvim 不能使用延迟加载模式
    lazy = false,

    -- 插件选项配置函数
    opts = function()
      -- ========================================
      -- 1. 定义和格式化 LOGO
      -- ========================================

      -- LazyVim 特色 LOGO（与 Alpha 版本相同）
      local logo = [[
           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
      ]]

      -- 为 LOGO 添加上下间距
      -- 在上方添加 8 行空白，下方添加 2 行空白，创造视觉平衡
      logo = string.rep("\n", 8) .. logo .. "\n\n"

      -- ========================================
      -- 2. 主配置选项
      -- ========================================

      local opts = {
        -- 使用 Doom 主题，提供经典的深色界面风格
        theme = "doom",

        -- 隐藏选项配置
        hide = {
          -- 隐藏状态栏
          -- 注释：this is taken care of by lualine, enabling this messes up the actual laststatus setting after loading a file
          -- 说明：状态栏由 lualine 处理，启用此项会干扰文件加载后的实际 laststatus 设置
          statusline = false,
        },

        -- 主要配置内容
        config = {
          -- 设置头部区域（LOGO）
          header = vim.split(logo, "\n"),

          -- ========================================
          -- 3. 中心区域：快捷操作按钮
          -- ========================================

          -- stylua: ignore

          center = {
            -- 查找文件：使用 LazyVim 的模糊查找器
            { action = 'lua LazyVim.pick()()',                           desc = " Find File",       icon = " ", key = "f" },

            -- 新建文件：创建新缓冲区并切换到插入模式
            { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },

            -- 最近文件：显示之前编辑过的文件列表
            { action = 'lua LazyVim.pick("oldfiles")()',                 desc = " Recent Files",    icon = " ", key = "r" },

            -- 搜索文本：在当前项目中搜索指定文本
            { action = 'lua LazyVim.pick("live_grep")()',                desc = " Find Text",       icon = " ", key = "g" },

            -- 配置文件：快速访问 LazyVim 配置文件
            { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },

            -- 恢复会话：恢复上一次的工作会话
            { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },

            -- Lazy 扩展：显示和管理 LazyVim 扩展插件
            { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },

            -- Lazy 管理：打开 Lazy 插件管理器界面
            { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },

            -- 退出 Neovim：通过 API 调用实现优雅退出
            { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
          },

          -- ========================================
          -- 4. 页脚区域：启动统计信息
          -- ========================================

          -- 页脚函数，动态生成统计信息
          footer = function()
            -- 获取插件加载统计信息
            local stats = require("lazy").stats()
            -- 计算启动时间（保留两位小数）
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

            -- 返回统计信息数组（Dashboard-nvim 要求数组格式）
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      -- ========================================
      -- 5. 格式化按钮布局
      -- ========================================

      -- 遍历所有中心按钮，统一格式化
      for _, button in ipairs(opts.config.center) do
        -- 调整按钮描述文字的宽度，确保所有按钮对齐
        -- 目标宽度：43 个字符，多余部分用空格填充
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)

        -- 设置快捷键格式化字符串
        -- "  %s" 表示在快捷键前添加两个空格
        button.key_format = "  %s"
      end

      -- ========================================
      -- 6. 处理 Lazy 界面交互
      -- ========================================

      -- 如果当前在 Lazy 界面，设置自动命令在关闭后重新显示 Dashboard
      if vim.o.filetype == "lazy" then
        -- 创建窗口关闭事件监听器
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(vim.api.nvim_get_current_win()),  -- 监听当前窗口关闭事件
          once = true,               -- 只执行一次
          callback = function()
            -- 延迟执行，确保窗口完全关闭
            vim.schedule(function()
              -- 手动触发 UIEnter 事件，重新显示 Dashboard
              -- 使用 dashboard 组确保事件被正确处理
              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
            end)
          end,
        })
      end

      -- 返回完整的配置选项
      return opts
    end,
  },
}
