-- Octo：GitHub Issues 和 Pull Requests 管理插件
-- 功能说明：
-- 1. 在Neovim中直接管理GitHub Issues和PRs，无需离开编辑器
-- 2. 支持创建、编辑、搜索、分配Issues和PRs
-- 3. 提供完整的GitHub工作流集成，包括评论、标签、审查等
-- 4. 支持多种选择器（Telescope、FZF、Snacks）进行项目管理
return {

  -- 导入Git语言支持插件
  -- 依赖Git插件为GitHub issues和PRs提供语法高亮和自动完成
  { import = "lazyvim.plugins.extras.lang.git" },

  -- 禁用Snacks中与Octo冲突的快捷键
  {
    "folke/snacks.nvim",
    keys = { -- 禁用冲突的快捷键
      { "<leader>gi", false }, -- 禁用Snacks的git issues快捷键
      { "<leader>gI", false }, -- 禁用Snacks的git issues search快捷键
      { "<leader>gp", false }, -- 禁用Snacks的git pr快捷键
      { "<leader>gP", false }, -- 禁用Snacks的git pr search快捷键
    },
  },

  -- Octo主插件配置
  {
    "pwntester/octo.nvim",
    cmd = "Octo",                      -- Octo命令
    event = { { event = "BufReadCmd", pattern = "octo://*" } }, -- 监听Octo缓冲区

    -- 插件配置选项
    opts = {
      enable_builtin = true,            -- 启用内置功能
      default_to_projects_v2 = true,    -- 默认使用Projects v2
      default_merge_method = "squash",  -- 默认合并方式为squash
      picker = "telescope",             -- 默认选择器为Telescope
    },
    -- 快捷键配置
    keys = {
      -- 主要GitHub操作快捷键
      { "<leader>gi", "<cmd>Octo issue list<CR>", desc = "List Issues (Octo)" },     -- 列出Issues
      { "<leader>gI", "<cmd>Octo issue search<CR>", desc = "Search Issues (Octo)" }, -- 搜索Issues
      { "<leader>gp", "<cmd>Octo pr list<CR>", desc = "List PRs (Octo)" },           -- 列出PRs
      { "<leader>gP", "<cmd>Octo pr search<CR>", desc = "Search PRs (Octo)" },       -- 搜索PRs
      { "<leader>gr", "<cmd>Octo repo list<CR>", desc = "List Repos (Octo)" },       -- 列出仓库
      { "<leader>gS", "<cmd>Octo search<CR>", desc = "Search (Octo)" },              -- 全局搜索

      -- Octo缓冲区内的局部快捷键（按localleader触发）
      { "<localleader>a", "", desc = "+assignee (Octo)", ft = "octo" },  -- 分配人员
      { "<localleader>c", "", desc = "+comment/code (Octo)", ft = "octo" }, -- 添加评论/代码
      { "<localleader>l", "", desc = "+label (Octo)", ft = "octo" },     -- 管理标签
      { "<localleader>i", "", desc = "+issue (Octo)", ft = "octo" },     -- 创建Issue
      { "<localleader>r", "", desc = "+react (Octo)", ft = "octo" },     -- 添加反应
      { "<localleader>p", "", desc = "+pr (Octo)", ft = "octo" },        -- 创建PR
      { "<localleader>pr", "", desc = "+rebase (Octo)", ft = "octo" },   -- 变基操作
      { "<localleader>ps", "", desc = "+squash (Octo)", ft = "octo" },   -- 压缩提交
      { "<localleader>v", "", desc = "+review (Octo)", ft = "octo" },    -- 审查
      { "<localleader>g", "", desc = "+goto_issue (Octo)", ft = "octo" }, -- 跳转到Issue

      -- 自动完成触发快捷键（在插入模式下）
      { "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },   -- @用户自动完成
      { "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },   -- #issue自动完成
    },
  },

  -- Octo选择器配置
  {
    "pwntester/octo.nvim",
    opts = function(_, opts)
      -- 注册Octo为Markdown方言，支持Markdown语法高亮
      vim.treesitter.language.register("markdown", "octo")

      -- 智能选择器配置：根据已安装的插件选择合适的选择器
      if LazyVim.has_extra("editor.telescope") then
        opts.picker = "telescope" -- 优先使用Telescope
      elseif LazyVim.has_extra("editor.fzf") then
        opts.picker = "fzf-lua"   -- 备选FZF
      elseif LazyVim.has_extra("editor.snacks_picker") then
        opts.picker = "snacks"    -- 备选Snacks
      else
        -- 错误提示：需要安装选择器插件
        LazyVim.error("`octo.nvim` requires `telescope.nvim` or `fzf-lua` or `snacks.nvim`")
      end

      -- 在会话中保持某些空窗口
      vim.api.nvim_create_autocmd("ExitPre", {
        group = vim.api.nvim_create_augroup("octo_exit_pre", { clear = true }),
        callback = function(ev)
          local keep = { "octo" } -- 需要保持的缓冲区类型
          -- 遍历所有窗口，检查是否需要保持
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.tbl_contains(keep, vim.bo[buf].filetype) then
              vim.bo[buf].buftype = "" -- 设置buftype为空以保持窗口
            end
          end
        end,
      })
    end,
  },
}
