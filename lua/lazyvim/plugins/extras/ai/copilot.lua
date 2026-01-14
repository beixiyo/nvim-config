return {
  recommended = true,  -- 推荐插件：默认启用，提供AI代码补全功能

  --- GitHub Copilot 基础配置
  -- 集成 OpenAI 的 GitHub Copilot，提供智能代码建议和补全
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",     -- 仅在用户执行 Copilot 命令时加载
    build = ":Copilot auth", -- 构建时进行身份验证
    
    --- 在读取文件后启用 Copilot：确保文件类型和内容已加载
    event = "BufReadPost",
    
    --- Copilot 核心配置选项
    opts = {
      --- 建议配置：智能代码补全相关设置
      suggestion = {
        --- 启用状态：根据其他AI插件的存在动态调整
        enabled = not vim.g.ai_cmp,  -- 如果没有AI补全模式则启用
        
        --- 自动触发：输入时自动显示建议
        auto_trigger = true,
        
        --- 补全时隐藏建议：避免与现有补全插件冲突
        hide_during_completion = vim.g.ai_cmp,
        
        --- 建议导航快捷键
        keymap = {
          accept = false, -- 接受建议由 nvim-cmp / blink.cmp 处理
          next = "<M-]>", -- Alt+] ：下一个建议
          prev = "<M-[>", -- Alt+[ ：上一个建议
        },
      },
      
      --- 侧边栏面板配置
      panel = { enabled = false },  -- 禁用独立的Copilot面板（使用浮动建议）
      
      --- 支持的文件类型：Copilot 在这些文件类型中启用
      filetypes = {
        markdown = true,  -- Markdown 文档
        help = true,      -- 帮助文档
      },
    },
  },

  --- Copilot LSP 服务器配置
  -- 为 Neovim 的 LSP 配置系统集成 Copilot 语言服务器
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        --- 禁用内置的 Copilot LSP 服务器
        -- 注意：copilot.lua 只与其自带的 Copilot LSP 服务器兼容
        -- 避免与 zbirenbaum/copilot.lua 的功能冲突
        copilot = { enabled = false },
      },
    },
  },

  --- AI 接受动作集成
  -- 添加自定义的 AI 建议接受动作，与 LazyVim 的补全系统集成
  {
    "zbirenbaum/copilot.lua",
    opts = function()
      --- 创建 LazyVim 的 AI 接受动作：与补全系统集成的建议接受函数
      LazyVim.cmp.actions.ai_accept = function()
        -- 检查 Copilot 建议是否可见
        if require("copilot.suggestion").is_visible() then
          LazyVim.create_undo()  -- 创建撤销点，避免意外覆盖
          require("copilot.suggestion").accept()  -- 接受 Copilot 建议
          return true  -- 返回 true 表示操作成功
        end
      end
    end,
  },

  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          local clients = package.loaded["copilot"] and vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
          if #clients > 0 then
            local status = require("copilot.status").data.status
            return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
          end
        end)
      )
    end,
  },

  vim.g.ai_cmp
      and {
        -- copilot cmp source
        {
          "hrsh7th/nvim-cmp",
          optional = true,
          dependencies = { -- this will only be evaluated if nvim-cmp is enabled
            {
              "zbirenbaum/copilot-cmp",
              opts = {},
              config = function(_, opts)
                local copilot_cmp = require("copilot_cmp")
                copilot_cmp.setup(opts)
                -- attach cmp source whenever copilot attaches
                -- fixes lazy-loading issues with the copilot cmp source
                Snacks.util.lsp.on({ name = "copilot" }, function()
                  copilot_cmp._on_insert_enter({})
                end)
              end,
              specs = {
                {
                  "hrsh7th/nvim-cmp",
                  optional = true,
                  ---@param opts cmp.ConfigSchema
                  opts = function(_, opts)
                    table.insert(opts.sources, 1, {
                      name = "copilot",
                      group_index = 1,
                      priority = 100,
                    })
                  end,
                },
              },
            },
          },
        },
        {
          "saghen/blink.cmp",
          optional = true,
          dependencies = { "fang2hou/blink-copilot" },
          opts = {
            sources = {
              default = { "copilot" },
              providers = {
                copilot = {
                  name = "copilot",
                  module = "blink-copilot",
                  score_offset = 100,
                  async = true,
                },
              },
            },
          },
        },
      }
    or nil,
}
