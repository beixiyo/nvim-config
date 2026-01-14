return {
  {
    "saghen/blink.cmp",
    enabled = false,
    optional = true,
  },

  -- nvim-cmp 补全引擎配置
  -- nvim-cmp 是 Neovim 最流行和稳定的代码补全插件，提供：
  -- 1. LSP 集成：与语言服务器协作提供智能补全
  -- 2. 缓冲区补全：基于当前文件的上下文提供补全
  -- 3. 路径补全：自动补全文件和目录路径
  -- 4. 智能触发：根据语言特性自动触发补全时机
  -- 5. 高度可定制：支持自定义补全源、UI 和行为
  -- 这是 LazyVim 默认推荐的补全引擎
  {
    "hrsh7th/nvim-cmp",
    version = false,  -- 不固定版本号，保持最新功能
    event = "InsertEnter",  -- 进入插入模式时加载（补全功能仅在插入模式下使用）
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP 补全源：提供语言服务器的智能补全
      "hrsh7th/cmp-buffer",     -- 缓冲区补全源：基于当前文件内容的补全
      "hrsh7th/cmp-path",       -- 路径补全源：文件和目录路径的自动补全
    },
    -- Not all LSP servers add brackets when completing a function.
    -- To better deal with this, LazyVim adds a custom option to cmp,
    -- that you can configure. For example:
    --
    -- ```lua
    -- opts = {
    --   auto_brackets = { "python" }
    -- }
    -- ```
    opts = function()
      -- Register nvim-cmp lsp capabilities
      vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local auto_select = true
      return {
        auto_brackets = {}, -- configure any filetype to auto add brackets
        completion = {
          completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
        },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),
          ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
          ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<tab>"] = function(fallback)
            return LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }, fallback)()
          end,
        }),
        sources = cmp.config.sources({
          { name = "lazydev" },
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = function(entry, item)
            local icons = LazyVim.config.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end

            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end

            return item
          end,
        },
        experimental = {
          -- only show ghost text when we show ai completions
          ghost_text = vim.g.ai_cmp and {
            hl_group = "CmpGhostText",
          } or false,
        },
        sorting = defaults.sorting,
      }
    end,
    main = "lazyvim.util.cmp",
  },

  -- snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
        },
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(item)
          return LazyVim.cmp.expand(item.body)
        end,
      }
      if LazyVim.has("nvim-snippets") then
        table.insert(opts.sources, { name = "snippets" })
      end
    end,
  },
}
