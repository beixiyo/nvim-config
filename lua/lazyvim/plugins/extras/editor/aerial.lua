return {
  desc = "Aerial Symbol Browser（符号浏览器）- 代码结构导航和符号大纲显示插件",
  
  --- Aerial 符号浏览器主插件
  -- 提供代码符号大纲、函数列表、类结构等导航功能
  -- 支持 LSP、Tree-sitter、Markdown 等多种后端数据源
  {
    "stevearc/aerial.nvim",
    event = "LazyFile", -- 打开文件后加载，避免影响启动速度
    
    --- Aerial 插件配置函数
    -- 根据用户配置和全局设置返回完整的插件选项
    opts = function()
      --- 复制 LazyVim 的图标配置：确保符号显示与编辑器主题一致
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)

      --- Lua 语言特殊处理：修正 Lua 中控制结构的图标映射
      -- Lua 语言将 if/else/for 等控制结构错误地归类为 Package，这里修正为 Control
      -- 这确保在符号树中控制结构显示正确的图标
      icons.lua = { Package = icons.Control }

      --- 符号过滤配置：支持按符号类型过滤显示
      ---@type table<string, string[]>|false 过滤规则，false 表示显示所有符号
      local filter_kind = false
      if LazyVim.config.kind_filter then
        filter_kind = assert(vim.deepcopy(LazyVim.config.kind_filter))
        filter_kind._ = filter_kind.default  -- 全局默认过滤规则
        filter_kind.default = nil            -- 移除 default 键，使用 _ 键
      end

      --- Aerial 核心配置选项
      local opts = {
        -- 附加模式设置：
        -- global 模式：Aerial 符号浏览器在所有缓冲区全局可用
        -- split 模式：每个缓冲区有独立的符号树（较少使用）
        attach_mode = "global",
        
        -- 数据源后端优先级：按顺序尝试不同的数据源
        -- lsp：LSP 协议（最准确但需要 LSP 服务器）
        -- treesitter：语法树（快速但精度略低）  
        -- markdown：Markdown 文件的特殊处理
        -- man：Man 文档页面支持
        backends = { "lsp", "treesitter", "markdown", "man" },
        
        -- 显示缩进引导线：帮助识别代码层级结构
        show_guides = true,
        
        -- 窗口布局配置
        layout = {
          -- 不自动调整大小：Aerial 窗口保持固定大小
          -- true 值会让窗口自动调整为符号树内容高度
          resize_to_content = false,
          
          -- 窗口选项配置
          win_opts = {
            -- 高亮组设置：确保浮动窗口与编辑器主题一致
            winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
            -- 显示符号列：为符号浏览器预留显示区域
            signcolumn = "yes",
            -- 状态列：显示空状态（避免布局错乱）
            statuscolumn = " ",
          },
        },
        
        -- 图标配置：使用编辑器主题的图标映射
        icons = icons,
        
        -- 符号类型过滤：根据类型显示/隐藏特定符号
        filter_kind = filter_kind,
        --- 引导线字符配置：定义符号树的可视化字符
        -- stylua: ignore
        guides = {
          -- 中间项目：├╴ 符号，表示有后续兄弟节点的项目
          mid_item   = "├╴",
          -- 最后项目：└╴ 符号，表示最后一个兄弟节点
          last_item  = "└╴",
          -- 嵌套顶部：│ 字符，表示当前层级还有后续兄弟节点
          nested_top = "│ ",
          -- 空白缩进：两个空格，表示当前层级无更多节点
          whitespace = "  ",
        },
      }
      return opts  -- 返回配置好的选项表
    end,
    
    --- Aerial 快捷键配置
    keys = {
      -- 切换符号浏览器：打开/关闭 Aerial 符号树窗口
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
    },
  },

  --- Trouble 插件兼容性处理
  -- 如果用户安装了 Trouble 插件，则避免快捷键冲突
  {
    "folke/trouble.nvim",
    optional = true, -- 可选依赖，仅在用户安装 Trouble 时生效
    keys = {
      -- 禁用 Aerial 的 cs 快捷键，由 Trouble 接管
      { "<leader>cs", false },
    },
  },

  --- Telescope 集成配置
  -- 将 Aerial 符号浏览器集成到 Telescope 模糊查找器中
  {
    "nvim-telescope/telescope.nvim",
    optional = true, -- 可选依赖，仅在使用 Telescope 时加载
    opts = function()
      --- 在 Telescope 加载完成后动态加载 Aerial 扩展
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("aerial")
      end)
    end,
    keys = {
      {
        -- 通过 Telescope 界面搜索和跳转符号
        "<leader>ss",
        "<cmd>Telescope aerial<cr>",
        desc = "Goto Symbol (Aerial)",
      },
    },
  },

  --- Edgy 布局集成配置  
  -- 将 Aerial 集成到侧边栏布局中（Edgy 插件）
  {
    "folke/edgy.nvim",
    optional = true, -- 可选依赖
    opts = function(_, opts)
      --- 检查加载顺序：确保 Edgy 在 Aerial 之前加载
      local edgy_idx = LazyVim.plugin.extra_idx("ui.edgy")
      local aerial_idx = LazyVim.plugin.extra_idx("editor.aerial")

      if edgy_idx and edgy_idx > aerial_idx then
        -- 警告用户加载顺序错误：Edgy 必须在 Aerial 之前导入
        LazyVim.warn("The `edgy.nvim` extra must be **imported** before the `aerial.nvim` extra to work properly.", {
          title = "LazyVim",
        })
      end

      --- 在 Edgy 右侧面板中添加 Aerial 窗口
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "Aerial",           -- 面板标题
        ft = "aerial",             -- 文件类型检测
        pinned = true,             -- 固定显示，不自动关闭
        open = "AerialOpen",       -- 打开命令
      })
    end,
  },

  --- Lualine 状态栏集成配置
  -- 在状态栏中显示当前符号信息，与 Aerial 符号浏览器同步
  {
    "nvim-lualine/lualine.nvim",
    optional = true, -- 可选依赖
    opts = function(_, opts)
      --- 只有在未使用 Trouble 的状态栏集成时才添加 Aerial 集成
      if not vim.g.trouble_lualine then
        table.insert(opts.sections.lualine_c, {
          "aerial",  -- 使用 Aerial 组件显示当前符号信息
          
          -- 符号分隔符：符号之间的分隔符
          sep = " ", 
          
          -- 图标分隔符：图标和符号文字之间的分隔符
          sep_icon = "", 

          -- 符号显示深度：显示从上到下的符号层级数
          -- 负数表示显示从底部开始的 N 个符号
          -- 例如：depth = -1 只显示当前符号
          depth = 5,

          -- 紧凑模式：当启用时，只显示代表符号类型的单一图标
          -- 关闭时：图标和符号名称都显示
          dense = false,

          -- 紧凑模式下的分隔符：在紧凑模式下使用的分隔符
          dense_sep = ".",

          -- 彩色显示：为符号图标添加颜色区分
          colored = true,
        })
      end
    end,
  },
}
