-- ================================
-- Markdown 渲染 (render-markdown.nvim)
-- ================================
-- 在缓冲区中美化显示 Markdown：标题图标/背景、代码块、列表符号、引用、表格等。
-- 需要 nerd font。命令：:RenderMarkdown toggle / :RenderMarkdown preview

local icons = require("utils").icons

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cond = function()
      return not vim.g.vscode -- 在 VSCode 中禁用此插件（VSCode 已有 Markdown 预览）
    end,

    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      enabled = true,
      file_types = { "markdown" },
      render_modes = { "n", "c", "t" },
      -- 若使用 blink.cmp 可开启 LSP 补全（checkbox/callout）
      completions = { lsp = { enabled = true } },
      heading = {
        position = "inline", -- 标题不缩进
      }
    },
    keys = {
      {
        "<leader>mr",
        function()
          require("render-markdown").toggle()
        end,
        desc = icons.todo_comments .. " " .. "Markdown 渲染 开/关",
      },
      {
        "<leader>mp",
        function()
          require("render-markdown").preview()
        end,
        desc = icons.todo_comments .. " " .. "Markdown 预览（侧边）",
      },
    },
  },
}
