-- ================================
-- 会话管理（auto-session）
-- ================================
-- 退出时自动保存布局/光标/缓冲区，启动时按当前目录（及 Git 分支）自动恢复

local icons = require("utils").icons

return {
  "rmagatti/auto-session",
  lazy = false,
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件
  end,

  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    log_level = "error",
    -- 不在以下目录自动保存/恢复会话
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    -- 会话存储目录（受 NVIM_APPNAME 影响，与 my-nvim 数据隔离）
    root_dir = vim.fn.stdpath("data") .. "/sessions/",
    enabled = true,
    auto_save = true,
    auto_restore = true,
    auto_create = true,
    -- 仅打开 dashboard 等时不保存会话
    bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },
    -- 按 Git 分支区分会话
    git_use_branch_name = true,
    -- 保存前关闭非文件窗口，避免布局冲突
    close_unsupported_windows = true,
    session_lens = {
      picker = "snacks",
      load_on_setup = true,
      previewer = "summary",
    },
  },

  keys = {
    { "<leader>qs", "<cmd>AutoSession save<cr>",    desc = icons.save .. " " .. "保存会话" },
    { "<leader>ql", "<cmd>AutoSession restore<cr>", desc = icons.jumps .. " " .. "恢复会话" },
    { "<leader>qS", "<cmd>AutoSession search<cr>",  desc = icons.command_history .. " " .. "选择会话" },
    { "<leader>qd", "<cmd>AutoSession delete<cr>",  desc = icons.quit .. " " .. "删除会话" },
  },
}
