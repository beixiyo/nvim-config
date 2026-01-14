return {

  -- Tree-sitter 语法解析器插件
  -- Tree-sitter 是一个现代化的解析器生成器，为 Neovim 提供：
  -- 1. 精确的语法高亮（基于 AST 结构而非正则表达式）
  -- 2. 智能代码缩进（根据语法规则自动缩进）
  -- 3. 基于语法的代码折叠（更准确的折叠区域）
  -- 4. 语法感知的光标移动和文本对象
  -- 5. 代码结构导航和符号搜索
  -- 相比 Vim 的传统语法高亮，Tree-sitter 更准确、更快速
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",  -- 使用最新的 main 分支
    version = false,  -- 不固定版本号，保持最新状态
    -- 原因：最后一个正式发布版本太旧，在 Windows 上工作不正常
    
    -- 构建函数：处理 Tree-sitter 解析器的安装和更新
    build = function()
      local TS = require("nvim-treesitter")
      -- 检查 Tree-sitter 是否正确安装
      if not TS.get_installed then
        LazyVim.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
        return
      end
      
      -- 清除缓存，确保使用最新的 Tree-sitter 工具
      package.loaded["lazyvim.util.treesitter"] = nil
      
      -- 构建和更新所有已安装的解析器
      LazyVim.treesitter.build(function()
        TS.update(nil, { summary = true })
      end)
    end,
    
    -- 事件触发：这些事件发生时加载插件
    event = { "LazyFile", "VeryLazy" },
    -- LazyFile：文件相关操作时
    -- VeryLazy：所有插件加载完成后
    
    -- 可用的 Tree-sitter 命令
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    
    -- 扩展选项的设置项：这些选项会被添加到插件的默认配置中
    opts_extend = { "ensure_installed" },
    
    ---@alias lazyvim.TSFeat { enable?: boolean, disable?: string[] }
    ---@class lazyvim.TSConfig: TSConfig
    -- Tree-sitter 的主要配置选项
    opts = {
      -- 启用基于语法的缩进功能
      -- 自动根据代码结构调整缩进，比简单制表符更智能
      indent = { enable = true }, ---@type lazyvim.TSFeat
      
      -- 启用基于 AST 的语法高亮
      -- 提供比正则表达式更准确的语法着色
      -- 支持更多语言和更精确的高亮规则
      highlight = { enable = true }, ---@type lazyvim.TSFeat
      
      -- 启用基于语法的代码折叠
      -- 根据函数、类、条件语句等语法结构进行折叠
      -- 比手动折叠或缩进折叠更精确
      folds = { enable = true }, ---@type lazyvim.TSFeat
      
      -- 确保安装的语法解析器列表
      -- 这些是基础解析器，会自动安装并保持更新
      ensure_installed = { 
        "bash",      -- Shell 脚本解析
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    ---@param opts lazyvim.TSConfig
    config = function(_, opts)
      local TS = require("nvim-treesitter")

      setmetatable(require("nvim-treesitter.install"), {
        __newindex = function(_, k)
          if k == "compilers" then
            vim.schedule(function()
              LazyVim.error({
                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                "",
                "For more info, see:",
                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
              })
            end)
          end
        end,
      })

      -- some quick sanity checks
      if not TS.get_installed then
        return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
      elseif type(opts.ensure_installed) ~= "table" then
        return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table")
      end

      -- setup treesitter
      TS.setup(opts)
      LazyVim.treesitter.get_installed(true) -- initialize the installed langs

      -- install missing parsers
      local install = vim.tbl_filter(function(lang)
        return not LazyVim.treesitter.have(lang)
      end, opts.ensure_installed or {})
      if #install > 0 then
        LazyVim.treesitter.build(function()
          TS.install(install, { summary = true }):await(function()
            LazyVim.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not LazyVim.treesitter.have(ft) then
            return
          end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {} ---@type lazyvim.TSFeat
            return f.enable ~= false
              and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
              and LazyVim.treesitter.have(ft, query)
          end

          -- highlighting
          if enabled("highlight", "highlights") then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- indents
          if enabled("indent", "indents") then
            LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()")
          end

          -- folds
          if enabled("folds", "folds") then
            if LazyVim.set_default("foldmethod", "expr") then
              LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
            end
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true, -- 是否将动作加入 jumplist，方便 <C-o>/<C-i>
        keys = { -- LazyVim 扩展：可为每个键自动生成描述
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter-textobjects")
      if not TS.setup then
        LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
        return
      end
      TS.setup(opts)

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if not (vim.tbl_get(opts, "move", "enable") and LazyVim.treesitter.have(ft, "textobjects")) then
          return
        end
        ---@type table<string, table<string, string>>
        local moves = vim.tbl_get(opts, "move", "keys") or {}

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == "table" and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub("@", ""):gsub("%..*", "")
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end
            local desc = table.concat(parts, " or ")
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            if not (vim.wo.diff and key:find("[cC]")) then
              vim.keymap.set({ "n", "x", "o" }, key, function()
                require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
              end, {
                buffer = buf,
                desc = desc,
                silent = true,
              })
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  -- 根据语法树自动补全 HTML/JSX 闭合标签
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },
}
