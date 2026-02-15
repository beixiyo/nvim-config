-- ================================
-- blink.cmp 智能补全（替代 nvim-cmp）
-- ================================
-- 插入模式：LSP、路径、snippets、缓冲区；命令行 : / ? 补全（与 Noice 浮层配合）
-- LSP 配置中请使用：capabilities = require("blink.cmp").get_lsp_capabilities()

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = false } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- 命令行补全：: 与 / ? 自动弹出列表
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Right>"] = false,
          ["<Left>"] = false,
        },
        completion = {
          list = { selection = { preselect = false } },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ":"
            end,
          },
          ghost_text = { enabled = true },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
