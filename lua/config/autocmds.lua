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

-- 禁止默认 clipboard 影响 d/x
vim.opt.clipboard = ""

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

-- 只在 yank 时同步剪贴板
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function(event)
    if event.operator == "y" then
      local text = table.concat(vim.fn.getreg('"', 1, true), "\n")
      -- 本地复制
      if vim.fn.has('wsl') == 1 or not vim.env.SSH_CONNECTION then
        vim.fn.setreg("+", text)
        vim.fn.setreg("*", text)
      end
      -- 远程通过 vim.g.clipboard 自动发送 OSC52
    end
  end,
})
