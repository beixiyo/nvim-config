-- Avante AI 代码助手 - 现代化AI编程辅助工具
-- 核心功能：
-- 1. 多AI提供商支持（OpenAI、Claude、Copilot等）
-- 2. 智能代码补全和生成
-- 3. 代码修改和重构建议
-- 4. 项目上下文理解和问答
-- 5. 图像分析和解释功能

return {
  -- 依赖：NUI 组件库，用于构建现代化的用户界面
  { "MunifTanjim/nui.nvim", lazy = true },

  -- 主插件：Avante AI 代码助手
  -- 功能：提供智能代码生成、补全、修改建议，支持多种AI提供商
  {
    "yetone/avante.nvim",
    -- 构建步骤：根据操作系统选择不同的构建命令
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy", -- 延迟加载，在空闲时加载以提升启动速度

    -- 核心配置选项
    opts = {
      -- AI提供商配置：使用GitHub Copilot作为默认提供商
      provider = "copilot",
      -- 选择配置：禁用hint显示，减少界面干扰
      selection = {
        hint_display = "none",
      },
      -- 行为配置：禁用自动键位映射，使用自定义键位
      behaviour = {
        auto_set_keymaps = false,
      },
    },

    -- 命令定义：提供完整的Avante功能命令集合
    cmd = {
      "AvanteAsk",         -- 向Avante提问
      "AvanteBuild",       -- 构建项目相关功能
      "AvanteChat",        -- 开启聊天窗口
      "AvanteClear",       -- 清空聊天历史
      "AvanteEdit",        -- 代码编辑模式
      "AvanteFocus",       -- 聚焦Avante窗口
      "AvanteHistory",     -- 查看历史对话
      "AvanteModels",      -- 选择AI模型
      "AvanteRefresh",     -- 刷新界面
      "AvanteShowRepoMap", -- 显示代码仓库映射
      "AvanteStop",        -- 停止当前操作
      "AvanteSwitchProvider", -- 切换AI提供商
      "AvanteToggle",      -- 切换Avante显示/隐藏
    },

    -- 键盘快捷键：提供快速访问的leader键组合
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "向Avante提问" },
      { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "与Avante聊天" },
      { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "Avante编辑模式" },
      { "<leader>af", "<cmd>AvanteFocus<CR>", desc = "聚焦Avante窗口" },
      { "<leader>ah", "<cmd>AvanteHistory<CR>", desc = "Avante历史记录" },
      { "<leader>am", "<cmd>AvanteModels<CR>", desc = "选择Avante模型" },
      { "<leader>an", "<cmd>AvanteChatNew<CR>", desc = "新建Avante聊天" },
      { "<leader>ap", "<cmd>AvanteSwitchProvider<CR>", desc = "切换Avante提供商" },
      { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "刷新Avante" },
      { "<leader>as", "<cmd>AvanteStop<CR>", desc = "停止Avante" },
      { "<leader>at", "<cmd>AvanteToggle<CR>", desc = "切换Avante显示" },
    },
  },

  -- 图像粘贴支持：允许在对话中插入图像进行分析
  -- 功能：支持拖拽复制粘贴图像，Avante可以分析图像中的代码、界面等
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    optional = true, -- 可选依赖，不影响主插件运行

    -- 图像处理配置
    opts = {
      -- 推荐设置：针对大多数用户的默认配置
      default = {
        embed_image_as_base64 = false,    -- 不嵌入图像为base64，节省内存
        prompt_for_file_name = false,     -- 不提示输入文件名，使用默认命名
        drag_and_drop = {
          insert_mode = true,            -- 拖拽时直接插入模式
        },
        -- Windows用户必需设置：使用绝对路径
        use_absolute_path = true,
      },
    },
  },

  -- Markdown渲染支持：提供美观的对话界面显示
  -- 功能：渲染Markdown格式的AI回复，支持代码高亮、表格等
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      -- 文件类型支持：支持Markdown和Avante文件类型的渲染
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" }, -- 文件类型自动检测
  },

  -- Blink.cmp 补全源：集成到现代补全框架中
  -- 功能：在代码补全中集成Avante的AI建议
  {
    "saghen/blink.cmp",
    optional = true,
    specs = { "Kaiser-Yang/blink-cmp-avante" }, -- Avante专用的blink.cmp源

    -- 补全源配置
    opts = {
      sources = {
        default = { "avante" }, -- 默认补全源包含avante
        providers = {
          -- 提供商映射：avante提供商使用专用模块
          avante = { module = "blink-cmp-avante", name = "Avante" }
        },
      },
    },
  },
}
