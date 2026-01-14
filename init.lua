-- ============================================================================
-- LazyVim 本地配置初始化文件
-- ============================================================================
-- 这个文件是 Neovim 的入口配置文件，Neovim 启动时会首先执行这个文件
--
-- 与标准的 LazyVim starter 不同，这个配置使用本地的 LazyVim 代码
-- 而不是从 GitHub 下载，这样你可以直接修改和学习 LazyVim 的代码
--
-- 配置结构：
--   - init.lua: 主入口文件（本文件）
--   - lua/config/lazy.lua: lazy.nvim 和插件配置
--   - lua/config/options.lua: 自定义选项
--   - lua/config/keymaps.lua: 自定义键位映射
--   - lua/config/autocmds.lua: 自定义自动命令
--   - lua/plugins/: 自定义插件配置
-- ============================================================================

-- 将当前配置目录添加到 runtimepath
-- 这行代码非常重要！它让 Neovim 能够找到你的配置文件
vim.opt.rtp:prepend(vim.fn.stdpath("config"))

-- 加载 lazy.nvim 和插件配置
-- 所有 lazy.nvim 的配置都在 lua/config/lazy.lua 中
require("config.lazy")

-- Neovide 配置
if vim.g.neovide then
	vim.o.guifont = "Maple Mono NF:h10"
	vim.g.neovide_confirm_quit = true
	vim.g.neovide_remember_window_size = true
end
