-- 彩色缩进线（每一层不同颜色）
-- 文档：https://github.com/lukas-reineke/indent-blankline.nvim (ibl)
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件
  end,

  ---@module "ibl"
  ---@type ibl.config
  opts = {},

  config = function()
    local ok, hooks = pcall(require, 'ibl.hooks')
    if not ok then
      return
    end

    -- 定义彩色缩进线的高亮（可按主题调整）
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'IblIndent1', { fg = '#E06C75', nocombine = true })
      vim.api.nvim_set_hl(0, 'IblIndent2', { fg = '#E5C07B', nocombine = true })
      vim.api.nvim_set_hl(0, 'IblIndent3', { fg = '#98C379', nocombine = true })
      vim.api.nvim_set_hl(0, 'IblIndent4', { fg = '#56B6C2', nocombine = true })
      vim.api.nvim_set_hl(0, 'IblIndent5', { fg = '#61AFEF', nocombine = true })
      vim.api.nvim_set_hl(0, 'IblIndent6', { fg = '#C678DD', nocombine = true })
    end)

    require('ibl').setup({
      indent = {
        char = '│',
        highlight = {
          'IblIndent1',
          'IblIndent2',
          'IblIndent3',
          'IblIndent4',
          'IblIndent5',
          'IblIndent6',
        },
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
      },
    })
  end,
}

