return {
  -- Mini Indentscope: 智能缩进范围高亮和缩进文本对象
  -- 功能说明：
  -- 1. 实时显示当前代码的缩进层级，帮助快速识别代码结构
  -- 2. 提供动画效果的高亮显示，提升视觉体验
  -- 3. 支持缩进文本对象操作，便于代码编辑
  -- 4. 智能检测文件类型，避免在非代码文件（如帮助页面、文件树等）中显示
  {
    "nvim-mini/mini.indentscope",
    version = false, -- 等待新版本发布后再启用语义化版本
    event = "LazyFile",
    opts = {
      -- symbol = "▏", -- 使用竖线符号显示缩进边界
      symbol = "│",   -- 使用细竖线，视觉上更清晰
      options = { try_as_border = true }, -- 尝试将符号用作边框显示
    },

    -- 初始化函数：配置文件类型排除列表
    init = function()
      -- 自动命令：FileType事件 - 在指定文件类型中禁用缩进范围高亮
      vim.api.nvim_create_autocmd("FileType", {
        -- 排除的文件类型列表
        pattern = {
          "Trouble",      -- 问题列表和诊断显示
          "alpha",        -- Alpha启动画面
          "dashboard",    -- Dashboard启动页面
          "fzf",          -- FZF模糊查找器界面
          "help",         -- 帮助文档
          "lazy",         -- Lazy插件管理器界面
          "mason",        -- Mason LSP安装管理器
          "neo-tree",     -- Neo-tree文件浏览器
          "notify",       -- 通知消息显示
          "sidekick_terminal", -- Sidekick终端界面
          "snacks_dashboard", -- Snacks启动面板
          "snacks_notif",     -- Snacks通知面板
          "snacks_terminal",  -- Snacks终端
          "snacks_win",       -- Snacks窗口管理
          "toggleterm",       -- ToggleTerm终端
          "trouble",          -- Trouble问题诊断
        },

        -- 回调函数：禁用这些文件类型的缩进范围高亮
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      -- 自动命令：User事件 - 处理SnacksDashboardOpened事件
      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened", -- 监听Snacks仪表板打开事件
        callback = function(data)
          -- 在对应的缓冲区中禁用缩进范围高亮
          vim.b[data.buf].miniindentscope_disable = true
        end,
      })
    end,
  },

  -- 禁用indent-blankline的scope功能
  -- 原因：避免与mini-indentscope的功能重复，两者都提供缩进高亮
  -- 配置：当mini-indentscope启用时，关闭indent-blankline的scope高亮
  {
    "lukas-reineke/indent-blankline.nvim",
    optional = true,      -- 可选插件，不影响主功能
    event = "LazyFile",
    opts = {
      scope = { enabled = false }, -- 禁用scope缩进高亮功能
    },
  },

  -- 禁用Snacks的缩进功能
  -- 原因：避免与mini-indentscope的功能重复，保持界面简洁
  -- 配置：当mini-indentscope启用时，关闭Snacks的缩进相关功能
  {
    "snacks.nvim",
    opts = {
      indent = {
        scope = { enabled = false }, -- 禁用Snacks的缩进范围高亮
      },
    },
  },
}
