-- ================================
-- 顶部 Buffer 标签页（bufferline.nvim）
-- ================================
-- 在顶部显示 buffer 列表，类似 IDE 的标签栏；与 Snacks Explorer / 布局框配合时留出偏移
---@module "bufferline"
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件
  end,
  ---@type bufferline.Options
  opts = {
    options = { -- bufferline 的核心配置
      -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = "nvim_lsp", -- 在标签上显示 LSP 诊断
      always_show_bufferline = false, -- 只有多个缓冲区时才显示
      offsets = {
        { filetype = "snacks_layout_box" },
      },
    },
  },
  config = function(_, opts)
    local bufferline = require("bufferline")
    bufferline.setup(opts)

    -- Fix bufferline when restoring a session（仅当 bufferline 已注册全局后再调用）
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        if _G.nvim_bufferline then
          vim.schedule(function()
            pcall(_G.nvim_bufferline)
          end)
        end
      end,
    })

    -- 键位：前后 buffer 切换（与窗口 Ctrl-hjkl 区分，用 Shift）
    local icons = require("utils").icons
    local map = vim.keymap.set
    map("n", "<S-h>", "<Cmd>BufferLineCyclePrev<Cr>", { desc = icons.buffers .. " " .. "上一个 buffer", silent = true })
    map("n", "<S-l>", "<Cmd>BufferLineCycleNext<Cr>", { desc = icons.buffers .. " " .. "下一个 buffer", silent = true })
  end,
}
