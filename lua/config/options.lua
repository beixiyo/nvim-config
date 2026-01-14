-- 用户自定义选项配置
-- 这个文件会在 LazyVim 默认选项之后加载
-- 你可以在这里覆盖或添加自己的选项设置

-- 更多选项请参考 LazyVim 的默认配置：
-- lua/lazyvim/config/options.lua

-- 剪贴板设置
-- 在 SSH 连接时使用 OSC52 协议（WezTerm 等终端支持），否则使用系统剪贴板
-- 注意：这个配置会覆盖 LazyVim 默认配置中的剪贴板设置
if vim.env.SSH_CONNECTION then
  -- 使用 Neovim 内置的 OSC52 provider，支持通过终端转义序列共享剪贴板
  -- OSC52 允许在远程 SSH 会话中通过终端转义序列与本地剪贴板交互
  vim.g.clipboard = "osc52"
  vim.opt.clipboard = "unnamedplus"
else
  -- 本地环境使用系统剪贴板
  vim.opt.clipboard = "unnamedplus"
end
