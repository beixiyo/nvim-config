-- LazyVim GitHub CLI 集成配置文件
-- 功能：配置 gh.nvim 插件，将 GitHub CLI 完整集成到 Neovim 中
-- 说明：提供在 Neovim 中直接管理 GitHub 仓库、PR、Issues、代码审查等功能

-- ========================================
-- GitHub CLI 集成配置
-- ========================================

return {
  -- ========================================
  -- 1. Git 插件依赖
  -- ========================================

  -- depends on the git extra for highlighting and auto-completion of github issues/prs
  -- 注释：依赖于 Git 扩展插件以获得 GitHub Issues/PR 的语法高亮和自动补全
  -- 说明：导入 Git 语言支持插件，提供 GitHub 相关的语法高亮和自动补全功能
  { import = "lazyvim.plugins.extras.lang.git" },

  -- ========================================
  -- 2. Litee 核心库
  -- ========================================
  { "ldelossa/litee.nvim", lazy = true },  -- 延迟加载 Litee 核心库

  -- ========================================
  -- 3. gh.nvim 主要配置
  -- ========================================
  {
    "ldelossa/gh.nvim",

    -- 插件选项（使用默认配置）
    opts = {},

    -- 配置函数
    config = function(_, opts)
      -- 初始化 Litee 核心库
      require("litee.lib").setup()

      -- 设置 GitHub 集成功能
      require("litee.gh").setup(opts)
    end,

    -- 键盘快捷键配置
    keys = {
      -- ========================================
      -- 基础 GitHub 操作
      -- ========================================
      { "<leader>G", "", desc = "+Github" },          -- GitHub 主菜单

      -- ========================================
      -- 提交 (Commits) 相关操作
      -- ========================================
      { "<leader>Gc", "", desc = "+Commits" },        -- 提交操作菜单
      { "<leader>Gcc", "<cmd>GHCloseCommit<cr>", desc = "Close" },       -- 关闭提交详情
      { "<leader>Gce", "<cmd>GHExpandCommit<cr>", desc = "Expand" },     -- 展开提交详情
      { "<leader>Gco", "<cmd>GHOpenToCommit<cr>", desc = "Open To" },    -- 打开到提交
      { "<leader>Gcp", "<cmd>GHPopOutCommit<cr>", desc = "Pop Out" },    -- 弹出提交窗口
      { "<leader>Gcz", "<cmd>GHCollapseCommit<cr>", desc = "Collapse" }, -- 折叠提交详情

      -- ========================================
      -- 问题 (Issues) 相关操作
      -- ========================================
      { "<leader>Gi", "", desc = "+Issues" },         -- 问题操作菜单
      { "<leader>Gip", "<cmd>GHPreviewIssue<cr>", desc = "Preview" },   -- 预览问题
      { "<leader>Gio", "<cmd>GHOpenIssue<cr>", desc = "Open" },         -- 打开问题

      -- ========================================
      -- Litee 面板操作
      -- ========================================
      { "<leader>Gl", "", desc = "+Litee" },          -- Litee 面板菜单
      { "<leader>Glt", "<cmd>LTPanel<cr>", desc = "Toggle Panel" },     -- 切换面板显示

      -- ========================================
      -- 拉取请求 (Pull Requests) 相关操作
      -- ========================================
      { "<leader>Gp", "", desc = "+Pull Request" },   -- 拉取请求菜单
      { "<leader>Gpc", "<cmd>GHClosePR<cr>", desc = "Close" },          -- 关闭 PR
      { "<leader>Gpd", "<cmd>GHPRDetails<cr>", desc = "Details" },      -- 查看 PR 详情
      { "<leader>Gpe", "<cmd>GHExpandPR<cr>", desc = "Expand" },        -- 展开 PR
      { "<leader>Gpo", "<cmd>GHOpenPR<cr>", desc = "Open" },            -- 打开 PR
      { "<leader>Gpp", "<cmd>GHPopOutPR<cr>", desc = "PopOut" },        -- 弹出 PR 窗口
      { "<leader>Gpr", "<cmd>GHRefreshPR<cr>", desc = "Refresh" },      -- 刷新 PR
      { "<leader>Gpt", "<cmd>GHOpenToPR<cr>", desc = "Open To" },       -- 打开到 PR
      { "<leader>Gpz", "<cmd>GHCollapsePR<cr>", desc = "Collapse" },    -- 折叠 PR

      -- ========================================
      -- 代码审查 (Review) 相关操作
      -- ========================================
      { "<leader>Gr", "", desc = "+Review" },         -- 代码审查菜单
      { "<leader>Grb", "<cmd>GHStartReview<cr>", desc = "Begin" },      -- 开始审查
      { "<leader>Grc", "<cmd>GHCloseReview<cr>", desc = "Close" },      -- 关闭审查
      { "<leader>Grd", "<cmd>GHDeleteReview<cr>", desc = "Delete" },    -- 删除审查
      { "<leader>Gre", "<cmd>GHExpandReview<cr>", desc = "Expand" },    -- 展开审查
      { "<leader>Grs", "<cmd>GHSubmitReview<cr>", desc = "Submit" },    -- 提交审查
      { "<leader>Grz", "<cmd>GHCollapseReview<cr>", desc = "Collapse" }, -- 折叠审查

      -- ========================================
      -- 讨论线程 (Threads) 相关操作
      -- ========================================
      { "<leader>Gt", "", desc = "+Threads" },        -- 线程操作菜单
      { "<leader>Gtc", "<cmd>GHCreateThread<cr>", desc = "Create" },    -- 创建线程
      { "<leader>Gtn", "<cmd>GHNextThread<cr>", desc = "Next" },        -- 下一个线程
      { "<leader>Gtt", "<cmd>GHToggleThread<cr>", desc = "Toggle" },    -- 切换线程
    },
  },
}
