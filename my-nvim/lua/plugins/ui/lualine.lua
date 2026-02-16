-- ================================
-- 底部状态栏（statusline）
-- ================================
-- 使用 lualine.nvim，不依赖 LazyVim。展示：模式、Git 分支、路径、诊断、diff、进度、时间等。

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      -- 启动页（如 alpha）先隐藏状态栏，等 lualine 加载后再恢复
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    vim.o.laststatus = vim.g.lualine_laststatus
    return {
      options = {
        theme = "auto",
        globalstatus = true, -- 状态栏始终整行显示在最底部左侧
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        -- 圆角分隔符（需 Nerd Font / Powerline 字体）
        component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
        section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          {
            "diagnostics",
            symbols = { error = "E", warn = "W", info = "I", hint = "H" },
          },
          { "filename", path = 1 },
        },
        lualine_x = {
          "diff",
          "encoding",
          "fileformat",
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return os.date("%H:%M")
          end,
        },
      },
      extensions = { "lazy", "fzf" },
    }
  end,
}
