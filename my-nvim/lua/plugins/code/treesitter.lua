-- Tree-sitter 语法解析：高亮、缩进、折叠
-- 文档：https://github.com/nvim-treesitter/nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  version = false,
  build = ":TSUpdate",
  config = function()
    local parser_list = {
      "javascript",
      "typescript",
      "jsdoc",
      "tsx",
    }

    -- 安装解析器（异步，不阻塞）
    local ts = require("nvim-treesitter")
    if ts.install then
      ts.install(parser_list)
    end

    -- 启用 treesitter 高亮
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
