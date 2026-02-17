-- 把「配置根目录」插到 runtimepath 最前面
-- stdpath("config") 是整份配置的根（不是单指 lua/config/ 子目录）。prepend 后
-- Neovim 会在该根下的 lua/ 里解析 require：lua/config/ → config.xxx，lua/plugins/ → plugins.xxx
-- 其它 lua/yyy/ 同理。这样 config、plugins 等目录下的模块都会从本配置根目录加载
vim.opt.rtp:prepend(vim.fn.stdpath("config"))

require("config.options")
require("config.clipboard")
require("config.keymaps")
require("config.lazy")
require("config.autocmd")