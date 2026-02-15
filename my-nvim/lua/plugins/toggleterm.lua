-- 终端切换：toggleterm.nvim
-- 文档：https://github.com/akinsho/toggleterm.nvim
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<C-\>]],
    insert_mappings = true,
    terminal_mappings = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
  end,
  lazy = false,
}
