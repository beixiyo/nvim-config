return {
  --- Codeium AI 代码补全插件配置
  -- 集成 Exafunction 的 Codeium，提供免费的 AI 代码建议和补全服务
  
  --- Codeium 主插件配置
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",        -- 仅在用户执行 Codeium 命令时加载
    event = "InsertEnter",  -- 进入插入模式时启用
    
    --- 构建时进行身份验证
    build = ":Codeium Auth",
    
    --- Codeium 核心配置选项
    opts = {
      --- 补全源集成：根据 AI 补全模式动态启用/禁用
      enable_cmp_source = vim.g.ai_cmp,  -- 如果存在 AI 补全模式则作为补全源
      
      --- 虚拟文本配置：直接在代码中显示 AI 建议
      virtual_text = {
        --- 启用状态：与 AI 补全模式互斥
        enabled = not vim.g.ai_cmp,  -- 如果没有 AI 补全模式则显示虚拟文本
        
        --- 虚拟文本快捷键绑定
        key_bindings = {
          accept = false, -- 接受建议由 nvim-cmp / blink.cmp 处理
          next = "<M-]>", -- Alt+] ：下一个建议
          prev = "<M-[>", -- Alt+[ ：上一个建议
        },
      },
    },
  },

  -- add ai_accept action
  {
    "Exafunction/codeium.nvim",
    opts = function()
      LazyVim.cmp.actions.ai_accept = function()
        if require("codeium.virtual_text").get_current_completion_item() then
          LazyVim.create_undo()
          vim.api.nvim_input(require("codeium.virtual_text").accept())
          return true
        end
      end
    end,
  },

  -- codeium cmp source
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "codeium.nvim" },
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("codeium"))
    end,
  },

  vim.g.ai_cmp and {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "codeium.nvim", "saghen/blink.compat" },
    opts = {
      sources = {
        compat = { "codeium" },
        providers = {
          codeium = {
            kind = "Codeium",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  } or nil,
}
