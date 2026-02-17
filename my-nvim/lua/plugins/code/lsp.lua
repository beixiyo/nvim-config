local Icons = require("utils").icons
local icons = Icons
local diag_icons = {
  Error = Icons.diagnostics_error,
  Warn = Icons.diagnostics_warn,
  Hint = Icons.diagnostics_hint,
  Info = Icons.diagnostics_info,
}

return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
    "saghen/blink.cmp",
  },
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件（VSCode 已有内置 LSP）
  end,

  opts = {
    ensure_installed = {},
    -- 自动启用已安装的 LSP 服务器（mason-lspconfig 会自动调用 lspconfig.setup）
    automatic_enable = { exclude = {} },
  },
  config = function(_, opts)
    require("mason-lspconfig").setup(opts)

    -- ================================
    -- Diagnostics UI（inline 虚拟文本 + sign 图标）
    -- ================================
    do
      -- signcolumn: 把 E/W/H/I 替换成图标
      local sign_texts = {
        Error = diag_icons.Error,
        Warn = diag_icons.Warn,
        Hint = diag_icons.Hint,
        Info = diag_icons.Info,
      }
      for name, text in pairs(sign_texts) do
        local sign = "DiagnosticSign" .. name
        vim.fn.sign_define(sign, { text = text, texthl = sign, numhl = "" })
      end

      -- inline 诊断提示（LazyVim 风格的 ghost text）
      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = function(diagnostic)
            local s = vim.diagnostic.severity
            if diagnostic.severity == s.ERROR then
              return diag_icons.Error
            elseif diagnostic.severity == s.WARN then
              return diag_icons.Warn
            elseif diagnostic.severity == s.HINT then
              return diag_icons.Hint
            else
              return diag_icons.Info
            end
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })
    end

    -- ================================
    -- LSP 快捷键配置（与 which-key 联动）
    -- ================================
    -- 在 LSP attach 时注册快捷键，确保只在有 LSP 客户端时生效
    -- 使用 vim.keymap.set 并添加 desc 参数，which-key 会自动识别并显示
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(event)
        local map = vim.keymap.set
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- 跳转相关（g 前缀，属于 "goto" 组）
        -- 使用 Snacks.picker 提供更好的多结果选择体验
        map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = icons.jumps .. " " .. "跳转到定义", buffer = event.buf })
        map("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = icons.jumps .. " " .. "跳转到声明", buffer = event.buf })
        map("n", "gr", function() Snacks.picker.lsp_references() end, { desc = icons.jumps .. " " .. "查找引用", buffer = event.buf, nowait = true })
        map("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = icons.jumps .. " " .. "跳转到实现", buffer = event.buf })
        map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = icons.jumps .. " " .. "跳转到类型定义", buffer = event.buf })

        -- 悬停和签名帮助
        map("n", "K", vim.lsp.buf.hover, { desc = icons.scope .. " " .. "显示悬停信息", buffer = event.buf })
        map("n", "gK", vim.lsp.buf.signature_help, { desc = icons.scope .. " " .. "显示签名帮助", buffer = event.buf })
        map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = icons.scope .. " " .. "显示签名帮助", buffer = event.buf })

        -- Code 组快捷键（<leader>c 前缀，属于 "code" 组）
        if client and client.supports_method("textDocument/codeAction") then
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = icons.commands .. " " .. "自动修复", buffer = event.buf })
        end

        if client and client.supports_method("textDocument/rename") then
          map("n", "<leader>cr", vim.lsp.buf.rename, { desc = icons.commands .. " " .. "重命名", buffer = event.buf })
        end

        if client and (client.supports_method("textDocument/formatting") or client.supports_method("textDocument/rangeFormatting")) then
          map("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, { desc = icons.commands .. " " .. "格式化", buffer = event.buf })

          map("x", "<leader>cf", function()
            vim.lsp.buf.format({ async = true, range = { ["start"] = vim.api.nvim_buf_get_mark(0, "<"), ["end"] = vim.api.nvim_buf_get_mark(0, ">") } })
          end, { desc = icons.commands .. " " .. "格式化选中区域", buffer = event.buf })
        end

        -- 诊断 & Quickfix / Location（<leader>x 前缀，属于 "diagnostics/quickfix" 组）
        -- 跳转上/下一个诊断（保留原始行为）
        map("n", "[d", vim.diagnostic.goto_prev, { desc = icons.quickfix .. " " .. "上一个诊断", buffer = event.buf })
        map("n", "]d", vim.diagnostic.goto_next, { desc = icons.quickfix .. " " .. "下一个诊断", buffer = event.buf })

        -- 当前光标处诊断浮窗
        map("n", "<leader>xd", vim.diagnostic.open_float, { desc = icons.quickfix .. " " .. "显示诊断信息", buffer = event.buf })

        -- Snacks 诊断视图：所有 / 当前缓冲区
        map("n", "<leader>xx", function() Snacks.picker.diagnostics() end, { desc = icons.quickfix .. " " .. "所有诊断", buffer = event.buf })
        map("n", "<leader>xX", function() Snacks.picker.diagnostics_buffer() end, { desc = icons.quickfix .. " " .. "当前缓冲区诊断", buffer = event.buf })

        -- Quickfix：把当前所有诊断写入 quickfix，再用 Snacks 方式浏览
        map("n", "<leader>xq", function()
          vim.diagnostic.setqflist({ open = false })
          Snacks.picker.qflist()
        end, { desc = icons.quickfix .. " " .. "诊断 Quickfix", buffer = event.buf })

        -- Location List：把当前 buffer 诊断写入 loclist，再用 Snacks 方式浏览
        map("n", "<leader>xl", function()
          vim.diagnostic.setloclist({ open = false })
          Snacks.picker.loclist()
        end, { desc = icons.location_list .. " " .. "诊断 Loclist", buffer = event.buf })

        -- LSP 符号搜索
        map("n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, { desc = icons.scope .. " " .. "文档符号", buffer = event.buf })
        map("n", "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = icons.scope .. " " .. "工作区符号", buffer = event.buf })
        -- LSP 调用关系
        map("n", "<leader>lci", function() Snacks.picker.lsp_incoming_calls() end, { desc = icons.scope .. " " .. "传入调用", buffer = event.buf })
        map("n", "<leader>lco", function() Snacks.picker.lsp_outgoing_calls() end, { desc = icons.scope .. " " .. "传出调用", buffer = event.buf })
      end,
    })
  end,
}
