-- ================================
-- lazy.nvim 引导与插件入口
-- ================================
-- 本文件做两件事：
-- 1. 确保 lazy.nvim 存在并加入 rtp，使 require("lazy") 可用
-- 2. 调用 lazy.setup，从 lua/plugins/ 加载插件列表并启动插件管理

-- -----------------------
-- 安装路径与自动克隆
-- -----------------------
-- stdpath("data") 是 Neovim 的用户数据目录（受 NVIM_APPNAME 影响）
-- lazy.nvim 放在其下 data/lazy/lazy.nvim，与其它插件数据分离
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "无法克隆 lazy.nvim\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
-- 把 lazy.nvim 所在目录插到 rtp 最前，这样 require("lazy") 会找到刚克隆/已有的 lazy 包
vim.opt.rtp:prepend(lazypath)

-- ------------------------
-- 插件列表与 lazy 配置
-- ------------------------
-- spec：从 lua/plugins/init.lua（即 require("plugins") 的返回值）加载插件表
-- defaults：新插件默认非懒加载、不固定版本
-- install.colorscheme：首次安装后尝试设置的颜色方案；当前由 plugins.theme 设置 tokyonight

-- 锁定版本：lazy-lock.json 记录当前插件 commit。要按锁定版本安装/恢复，执行 :Lazy restore
-- 更新插件后 lockfile 会自动更新；新机器或克隆配置后执行一次 :Lazy restore 即可与 lockfile 一致
local lockfile_path = vim.fn.stdpath("config") .. "/lazy-lock.json"

require("lazy").setup({
  -- LazyVim 原版导入所有插件
  -- spec = { { import = "plugins" } },

  -- 自定义管理插件列表
  spec = require("plugins"),
  defaults = { lazy = false, version = false },
  lockfile = lockfile_path,
  install = { colorscheme = { "tokyonight", "habamax" } },
})
