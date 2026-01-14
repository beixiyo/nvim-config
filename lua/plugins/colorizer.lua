return {
  {
    -- 颜色高亮
    "NvChad/nvim-colorizer.lua",
    lazy = true,
    config = function()
      require("colorizer").setup({
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          RRGGBBAA = true,
          rgb_fn = true,
          hsl_fn = true,
          css = true,
          css_fn = true,
          mode = 'background',
        },
      })
    end,
  },
  {
    -- 颜色选择器
    'ziontee113/color-picker.nvim',
    lazy = true,
    config = function()
      require('color-picker').setup({
        -- your config
      })
    end,
  }
}
