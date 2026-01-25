-- 用户自定义自动命令
-- 这个文件会在 LazyVim 默认自动命令之后加载
-- 你可以在这里添加自己的自动命令

-- 示例：文件保存时自动执行某些操作
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.lua",
--   callback = function()
--     -- 你的自定义逻辑
--   end,
-- })

-- 更多自动命令请参考 LazyVim 的默认配置：
-- lua/lazyvim/config/autocmds.lua

-- 解决 Window 粘贴到 Linux 换行符不同问题
vim.opt.clipboard = "unnamedplus"

if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'win32yank-wsl',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf', -- 这里强制转换为 LF，解决 ^M 问题
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = 0,
  }
end
