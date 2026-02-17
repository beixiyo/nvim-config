-- 仅用系统剪贴板（最常用）
-- vim.opt.clipboard = "unnamedplus"

-- 完全不用外部剪贴板（y/p 只影响 Vim 内部）
-- vim.opt.clipboard = ""

-- 选择剪贴板 + 系统剪贴板都同步
-- vim.opt.clipboard = "unnamed,unnamedplus"

-- 在已有设置上追加（例如已有 "unnamed"）
-- vim.opt.clipboard:append("unnamedplus")

-- =======================

-- WSL 特殊处理换行
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'win32yank-wsl',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = 0,
  }
end
