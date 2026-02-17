-- ================================
-- blink.cmp 智能补全（替代 nvim-cmp）
-- ================================
-- 插入模式：LSP、路径、snippets、缓冲区；命令行 : / ? 补全（与 Noice 浮层配合）
-- LSP 配置中请使用：capabilities = require("blink.cmp").get_lsp_capabilities()

local utils = require("utils")

return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件（VSCode 已有内置补全）
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'super-tab' },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      nerd_font_variant = 'mono',
      kind_icons = utils.icons.kinds,
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
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
  opts_extend = { "sources.default" }
}
