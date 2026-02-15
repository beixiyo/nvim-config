-- ================================
-- fzf-lua 模糊查找（直接用本机 fzf + fd / rg）
-- ================================

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {
    files = {
      cwd_prompt = false,  -- 输入行不显示当前工作目录
      fd_opts = "--type f --hidden --follow --exclude .git",
      -- 路径缩短：数字为每段目录保留的字符数
      path_shorten = 4,
    },
    grep = {
      path_shorten = 4,
    },
  },

  config = function(_, opts)
    require("fzf-lua").setup(opts)
  end,
}
