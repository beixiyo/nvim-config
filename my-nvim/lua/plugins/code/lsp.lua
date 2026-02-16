return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
    "saghen/blink.cmp",
  },

  opts = {
    ensure_installed = {},
    -- 自动启用已安装的 LSP 服务器（mason-lspconfig 会自动调用 lspconfig.setup）
    automatic_enable = { exclude = {} },
  },
  config = function(_, opts)
    require("mason-lspconfig").setup(opts)

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
        map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "跳转到定义", buffer = event.buf })
        map("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "跳转到声明", buffer = event.buf })
        map("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "查找引用", buffer = event.buf, nowait = true })
        map("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "跳转到实现", buffer = event.buf })
        map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "跳转到类型定义", buffer = event.buf })

        -- 悬停和签名帮助
        map("n", "K", vim.lsp.buf.hover, { desc = "显示悬停信息", buffer = event.buf })
        map("n", "gK", vim.lsp.buf.signature_help, { desc = "显示签名帮助", buffer = event.buf })
        map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "显示签名帮助", buffer = event.buf })

        -- Code 组快捷键（<leader>c 前缀，属于 "code" 组）
        if client and client.supports_method("textDocument/codeAction") then
          map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "代码操作", buffer = event.buf })
          map("x", "<leader>ca", vim.lsp.buf.code_action, { desc = "代码操作", buffer = event.buf })
        end
        if client and client.supports_method("textDocument/rename") then
          map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "重命名", buffer = event.buf })
        end
        if client and (client.supports_method("textDocument/formatting") or client.supports_method("textDocument/rangeFormatting")) then
          map("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, { desc = "格式化", buffer = event.buf })
          map("x", "<leader>cf", function()
            vim.lsp.buf.format({ async = true, range = { ["start"] = vim.api.nvim_buf_get_mark(0, "<"), ["end"] = vim.api.nvim_buf_get_mark(0, ">") } })
          end, { desc = "格式化选中区域", buffer = event.buf })
        end

        -- 诊断相关（<leader>x 前缀，属于 "diagnostics/quickfix" 组）
        map("n", "[d", vim.diagnostic.goto_prev, { desc = "上一个诊断", buffer = event.buf })
        map("n", "]d", vim.diagnostic.goto_next, { desc = "下一个诊断", buffer = event.buf })
        map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "显示诊断信息", buffer = event.buf })
        map("n", "<leader>xx", function() Snacks.picker.diagnostics() end, { desc = "所有诊断", buffer = event.buf })
        map("n", "<leader>xX", function() Snacks.picker.diagnostics_buffer() end, { desc = "当前缓冲区诊断", buffer = event.buf })
        map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "诊断列表", buffer = event.buf })
        -- LSP 符号搜索
        map("n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, { desc = "文档符号", buffer = event.buf })
        map("n", "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "工作区符号", buffer = event.buf })
        -- LSP 调用关系
        map("n", "<leader>lci", function() Snacks.picker.lsp_incoming_calls() end, { desc = "传入调用", buffer = event.buf })
        map("n", "<leader>lco", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "传出调用", buffer = event.buf })
      end,
    })
  end,
}
