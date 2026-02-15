-- Tree-sitter 语法解析：高亮、缩进、折叠
-- 文档：https://github.com/nvim-treesitter/nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    -- 基于语法的代码折叠（zo/zc 等）
    folds = { enable = true },
    ensure_installed = {
      "javascript",
      "tsx",
      "typescript",
    },
  },
  config = function(_, opts)
    require("nvim-treesitter").setup(opts)
  end,
  lazy = false,
}
