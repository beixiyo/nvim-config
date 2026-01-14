return {
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'tokyonight',
    },
  },
  {
    dir = vim.fn.stdpath('config') .. '/tokyonight.nvim',
    lazy = true,  -- 延迟加载，主题只在实际需要时加载
    opts = {
      style = "night"
    },
  },
}
