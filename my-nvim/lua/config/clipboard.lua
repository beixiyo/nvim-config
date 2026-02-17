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
elseif vim.env.SSH_CONNECTION then
  vim.g.clipboard = {
    name = 'osc52',
    copy = {
      ['+'] = 'osc52-copy',
      ['*'] = 'osc52-copy',
    },
    paste = {
      ['+'] = 'osc52-paste',
      ['*'] = 'osc52-paste',
    },
    cache_enabled = 0,
  }
end