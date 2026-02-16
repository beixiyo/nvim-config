-- Tree-sitter 语法解析：高亮、缩进、折叠
-- 文档：https://github.com/nvim-treesitter/nvim-treesitter
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local TS = require('nvim-treesitter')

    -- @link https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
    local parsers = {
      'html',
      'javascript',
      'typescript',
      'tsx',
      'jsdoc',
      'json',
      'json5',
      'markdown',
      'markdown_inline',
      'toml',
      'xml',
      'yaml',
    }

    TS.install(parsers):wait(300000)

    -- 动态启用：只要有对应的 parser 就启用 treesitter
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      -- 查看当前文件类型 `:lua print(vim.bo.filetype)`
      -- 查看所有文件类型 `:echo getcompletion('', 'filetype')`
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end

        -- 检查是否安装了对应的 parser
        local ok = pcall(vim.treesitter.get_parser, ev.buf, lang)
        if ok then
          vim.treesitter.start(ev.buf, lang)
        end
      end,
    })

    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
  end,
}
