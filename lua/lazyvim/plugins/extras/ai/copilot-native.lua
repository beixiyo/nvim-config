-- 原生GitHub Copilot集成 - 使用Neovim LSP系统
-- 核心功能：
-- 1. 原生内联代码补全，无需第三方补全框架
-- 2. 直接集成Neovim 0.12+的内联补全API
-- 3. 与状态栏显示Copilot连接状态
-- 4. 原生键盘快捷键控制补全导航

---@diagnostic disable: missing-fields

-- 文档模式处理：原生内联补全不支持显示为常规补全选项
if lazyvim_docs then
  vim.g.ai_cmp = false
end

-- 环境检查和冲突检测：确保兼容性和正确配置
if LazyVim.has_extra("ai.copilot-native") then
  -- 检查Neovim版本：需要0.12+版本支持内联补全功能
  if vim.fn.has("nvim-0.12") == 0 then
    LazyVim.error("需要Neovim >= 0.12版本才能使用 `ai.copilot-native` 扩展。")
    return {}
  end

  -- 检查冲突：不能与其他Copilot插件同时启用
  if LazyVim.has_extra("ai.copilot") then
    LazyVim.error("如果要使用 `ai.copilot-native`，请禁用 `ai.copilot` 扩展")
    return {}
  end
end

-- 禁用AI补全：原生Copilot使用内置补全，不需要cmp框架
vim.g.ai_cmp = false
local status = {} ---@type table<number, "ok" | "error" | "pending">

return {
  desc = "原生Copilot LSP集成。需要Neovim >= 0.12",

  -- LSP配置：通过语言服务器协议集成Copilot
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = {
          -- 键盘快捷键：Alt+] 和 Alt+[ 导航Copilot建议
          -- stylua: ignore
          keys = {
            {
              "<M-]>", -- Alt+]
              function() vim.lsp.inline_completion.select({ count = 1 }) end,
              desc = "下一个Copilot建议",
              mode = { "i", "n" }, -- 插入模式和普通模式都可用
            },
            {
              "<M-[>", -- Alt+[
              function() vim.lsp.inline_completion.select({ count = -1 }) end,
              desc = "上一个Copilot建议",
              mode = { "i", "n" }, -- 插入模式和普通模式都可用
            },
          },
        },
      },
      setup = {
        copilot = function()
          -- 延迟启用内联补全，确保LSP客户端准备就绪
          vim.schedule(function()
            vim.lsp.inline_completion.enable()
          end)

          -- 接受内联建议：将AI接受动作映射到内联补全
          LazyVim.cmp.actions.ai_accept = function()
            return vim.lsp.inline_completion.get()
          end

          -- 配置Copilot状态处理器（除非使用sidekick）
          if not LazyVim.has_extra("ai.sidekick") then
            vim.lsp.config("copilot", {
              handlers = {
                -- 状态变更处理器：跟踪Copilot连接和认证状态
                didChangeStatus = function(err, res, ctx)
                  if err then
                    return -- 忽略错误
                  end
                  
                  -- 更新状态：Normal=正常，Busy=忙碌，其他=错误
                  status[ctx.client_id] = res.kind ~= "Normal" and "error" 
                    or res.busy and "pending" or "ok"
                  
                  -- 错误提示：需要登录时显示错误信息
                  if res.status == "Error" then
                    LazyVim.error("请使用 `:LspCopilotSignIn` 登录Copilot")
                  end
                end,
              },
            })
          end
        end,
      },
    },
  },

  -- 状态栏集成：在Lualine中显示Copilot状态
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      -- 如果使用sidekick则跳过配置
      if LazyVim.has_extra("ai.sidekick") then
        return
      end

      -- 在状态栏的x区域插入Copilot状态指示器
      table.insert(
        opts.sections.lualine_x,
        2, -- 插入到第二个位置
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
          -- 返回当前缓冲区Copilot客户端的状态（ok/error/pending）
          return #clients > 0 and status[clients[1].id] or nil
        end)
      )
    end,
  },
}
