-- GitUI：Git图形化界面工具集成
-- 功能说明：
-- 1. 提供功能强大的Git图形化界面工具，支持在终端中运行
-- 2. 集成Snacks终端，支持当前目录和项目根目录启动
-- 3. 提供快捷键快速访问GitUI，替代命令行Git操作
-- 4. 自动处理与lazygit快捷键的冲突问题
return {

  -- 确保GitUI工具已安装
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "gitui" } }, -- 通过Mason自动安装GitUI工具

    -- 快捷键配置
    keys = {
      {
        "<leader>gG",                   -- 快捷键：在当前目录启动GitUI
        function()
          Snacks.terminal({ "gitui" })  -- 使用Snacks终端运行GitUI
        end,
        desc = "GitUi (cwd)",           -- 描述：GitUI（当前目录）
      },
      {
        "<leader>gg",                   -- 快捷键：在项目根目录启动GitUI
        function()
          Snacks.terminal({ "gitui" }, { cwd = LazyVim.root.get() })
        end,
        desc = "GitUi (Root Dir)",      -- 描述：GitUI（项目根目录）
      },
    },

    -- 初始化函数：处理快捷键冲突
    init = function()
      -- 删除lazygit的快捷键以避免冲突
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimKeymaps",     -- 监听LazyVim快捷键配置事件
        once = true,                    -- 只执行一次
        callback = function()
          -- 安全地删除可能与GitUI冲突的lazygit快捷键
          pcall(vim.keymap.del, "n", "<leader>gf") -- 文件历史快捷键
          pcall(vim.keymap.del, "n", "<leader>gl") -- 日志快捷键
        end,
      })
    end,
  },
}
