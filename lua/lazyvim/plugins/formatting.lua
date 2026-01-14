local M = {}

---@param opts conform.setupOpts
function M.setup(_, opts)
  for _, key in ipairs({ "format_on_save", "format_after_save" }) do
    if opts[key] then
      local msg = "Don't set `opts.%s` for `conform.nvim`.\n**LazyVim** will use the conform formatter automatically"
      LazyVim.warn(msg:format(key))
      ---@diagnostic disable-next-line: no-unknown
      opts[key] = nil
    end
  end
  ---@diagnostic disable-next-line: undefined-field
  if opts.format then
    LazyVim.warn("**conform.nvim** `opts.format` is deprecated. Please use `opts.default_format_opts` instead.")
  end
  require("conform").setup(opts)
end

return {
  -- Conform 格式化插件
  -- 这是 LazyVim 的核心格式化解决方案，提供：
  -- 1. 统一的格式化接口：支持多种格式化工具（Prettier、Black、clang-format 等）
  -- 2. 自动检测：自动识别文件类型并选择合适的格式化器
  -- 3. LSP 集成：与语言服务器协议无缝协作
  -- 4. 配置文件支持：支持项目级别的格式化规则
  -- 5. 保存时格式化：与 LazyVim 的 autoformat 选项完美配合
  -- 相比传统格式化方案，Conform 更灵活、更易配置
  {
    "stevearc/conform.nvim",
    -- 依赖关系：使用 Mason 来自动管理格式化工具的安装
    dependencies = { "mason.nvim" },
    lazy = true,  -- 延迟加载，只在格式化需要时才加载
    cmd = "ConformInfo",  -- 格式化信息的调试命令
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "x" },
        desc = "Format Injected Langs",
      },
    },
    init = function()
      -- Install the conform formatter on VeryLazy
      LazyVim.on_very_lazy(function()
        LazyVim.format.register({
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            require("conform").format({ bufnr = buf })
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    opts = function()
      local plugin = require("lazy.core.config").plugins["conform.nvim"]
      if plugin.config ~= M.setup then
        LazyVim.error({
          "Don't set `plugin.config` for `conform.nvim`.\n",
          "This will break **LazyVim** formatting.\n",
          "Please refer to the docs at https://www.lazyvim.org/plugins/formatting",
        }, { title = "LazyVim" })
      end
      ---@type conform.setupOpts
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- 请勿改为 true，否则错误被吞掉
          lsp_format = "fallback", -- LSP 失效时退回 conform
        },
        formatters_by_ft = { -- 这里定义默认的 filetype->formatter 映射
          lua = { "stylua" },
          fish = { "fish_indent" },
          sh = { "shfmt" },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- 这里可以覆盖内置 formatter 或新增自定义 formatter
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   prepend_args = { "-i", "2", "-ci" },
          -- },
        },
      }
      return opts
    end,
    config = M.setup,
  },
}
