-- ================================
-- 启动欢迎页 Alpha
-- ================================
-- 插件：goolord/alpha-nvim
-- 作用：启动时显示欢迎页与快捷按钮，按钮用内置命令或简单 Lua
-- 主题：dashboard（alpha.themes.dashboard），含 section.header / buttons / footer 与 layout

return {
  {
    "goolord/alpha-nvim",

    -- 在 Vim 启动完成（VimEnter）时显示欢迎页
    event = "VimEnter",

    opts = function()
      local dashboard = require("alpha.themes.dashboard")

      -- ----------------------------------
      -- 头部：欢迎文案（可改为多行 ASCII 或 logo）
      -- ----------------------------------
      dashboard.section.header.val = {
        "VSCode",
      }
      dashboard.section.header.opts.hl = "AlphaHeader"

      -- ----------------------------------
      -- 按钮：快捷操作（Find file / Recent / Find text 用 fzf-lua）
      -- dashboard.button(快捷键, 显示文字, 执行的按键/命令)
      -- ----------------------------------
      dashboard.section.buttons.val = {
        dashboard.button("f", "Find file", "<cmd>lua require('fzf-lua').files()<cr>"),
        dashboard.button("n", "New file", "<cmd>ene<bar>startinsert<cr>"),
        dashboard.button("r", "Recent files", "<cmd>lua require('fzf-lua').oldfiles()<cr>"),
        dashboard.button("g", "Find text", "<cmd>lua require('fzf-lua').live_grep()<cr>"),
        dashboard.button("c", "Config", "<cmd>lua require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })<cr>"),
        dashboard.button("l", "Lazy", "<cmd>Lazy<cr>"),
        dashboard.button("q", "Quit", "<cmd>qa<cr>"),
      }

      -- ----------------------------------
      -- 高亮：按钮与快捷键使用 Alpha 内置高亮组（可在 colorscheme 里覆盖）
      -- AlphaButtons / AlphaShortcut / AlphaHeader / AlphaFooter
      -- ----------------------------------
      for _, btn in ipairs(dashboard.section.buttons.val) do
        btn.opts.hl = "AlphaButtons"
        btn.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"

      -- ----------------------------------
      -- 页脚与布局
      -- ----------------------------------
      -- dashboard.section.footer.val = ""

      -- 垂直居中：padding 的 val 可为函数，绘制时调用（见 alpha-nvim lua/alpha.lua layout_element.padding）
      local header_lines = #dashboard.section.header.val
      local button_count = #dashboard.section.buttons.val
      local spacing = (dashboard.section.buttons.opts and dashboard.section.buttons.opts.spacing) or 1
      local button_lines = button_count + (button_count - 1) * spacing
      local footer_val = dashboard.section.footer.val
      local footer_lines = type(footer_val) == "table" and #footer_val or (footer_val == "" and 0 or 1)
      local mid_padding = dashboard.opts.layout[3].val

      if type(mid_padding) == "function" then
        mid_padding = 2
      end
      local total_content = header_lines + mid_padding + button_lines + footer_lines

      local function vertical_center_padding()
        local winheight = vim.api.nvim_win_get_height(0)
        return math.max(0, math.floor((winheight - total_content) / 2))
      end

      dashboard.opts.layout[1].val = vertical_center_padding
      dashboard.opts.layout[6] = { type = "padding", val = vertical_center_padding }

      return dashboard
    end,

    config = function(_, dashboard)
      -- ----------------------------------
      -- 从 Lazy 界面返回时：先关掉 lazy 缓冲，等 Alpha 就绪后再重新打开 Lazy
      -- ----------------------------------
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          once = true,
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      -- ----------------------------------
      -- 插件加载完成后：页脚显示插件数量与启动耗时，并刷新 Alpha
      -- ----------------------------------
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          local ok, stats = pcall(require, "lazy.stats")
          if ok and stats then
            dashboard.section.footer.val = string.format("  %d plugins in %.2f ms", stats.count, stats.startuptime)
            pcall(vim.cmd.AlphaRedraw)
          end
        end,
      })
    end,
  },
}
