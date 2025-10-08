require("plugins.plugins-setup")

require("core.options")
require("core.keymaps")

-- 插件
-- require("plugins.lualine") -- 已禁用状态栏
require("plugins/nvim-tree")
-- require("plugins/treesitter") -- 已禁用 Treesitter，使用原生高亮
-- require("plugins/lsp") -- 已禁用 LSP
-- require("plugins/cmp") -- 已禁用代码补全
-- require("plugins/comment")
require("plugins/autopairs")
require("plugins/bufferline")
-- require("plugins/gitsigns") -- 已禁用 Git 功能
require("plugins/telescope")

-- 加载 Windows 风格的快捷键
vim.cmd('source $VIMRUNTIME/mswin.vim')
