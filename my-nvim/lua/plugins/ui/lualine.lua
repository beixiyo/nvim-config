-- ================================
-- 底部状态栏（statusline）
-- ================================
-- 展示：模式、Git 分支、路径、诊断、diff、进度、时间等
-- 图标使用 utils.icons 统一风格

local utils = require("utils")

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件
  end,
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
    -- 性能优化：不需要 lualine 的 require 机制
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus
    local icons = utils.icons

    return {
      options = {
        theme = "auto",
        globalstatus = true, -- 状态栏始终整行显示在最底部左侧
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        -- 圆角分隔符（需 Nerd Font / Powerline 字体）
        component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
        section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },

        lualine_c = {
          utils.lualine.root_dir(),
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { utils.lualine.pretty_path() },
        },

        lualine_x = {
          Snacks.profiler.status(),
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
          },
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return icons.misc.clock .. os.date("%R")
          end,
        },
      },
      extensions = { "lazy", "fzf" },
    }
  end,
}
