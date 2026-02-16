-- Tree-sitter 语法解析：高亮、缩进、折叠
-- 文档：https://github.com/nvim-treesitter/nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  version = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    -- stdpath("data") 会根据 NVIM_APPNAME 自动返回正确的目录
    -- 无论使用什么 NVIM_APPNAME，这里都会工作，无需修改
    local data_dir = vim.fn.stdpath("data")

    ts.setup({
      install_dir = data_dir .. "/site",
    })

    -- ============================================================
    -- 【关键】同步查询文件到 site 目录
    -- ============================================================
    -- 问题：nvim-treesitter main 分支在安装解析器时，不会自动将插件的
    -- runtime/queries/ 目录复制到 site/queries/。而 Neovim 的
    -- treesitter 查询系统只从 rtp 中的 queries/ 目录加载（不搜索 runtime/queries 子目录）。
    --
    -- 解决方案：手动把插件自带的查询文件复制到 site/queries
    -- 这样无论 rtp 顺序如何，Neovim 都能找到查询文件
    --
    -- 优点：这是最可靠的方案，不依赖 rtp 顺序或 lazy.nvim 的加载时机
    -- 注意：首次运行后，site/queries 中已包含所有查询，之后不会再复制
    local plugin_queries = data_dir .. "/lazy/nvim-treesitter/runtime/queries"
    local site_queries = data_dir .. "/site/queries"

    if vim.fn.isdirectory(plugin_queries) == 1 and vim.fn.isdirectory(site_queries) == 1 then
      for lang in vim.fs.dir(plugin_queries) do
        local src = plugin_queries .. "/" .. lang
        local dst = site_queries .. "/" .. lang
        -- 只复制不存在的语言目录（避免重复复制）
        if vim.fn.isdirectory(src) == 1 and vim.fn.isdirectory(dst) == 0 then
          vim.fn.mkdir(dst, "p")
          for file in vim.fs.dir(src) do
            vim.fn.system({ "cp", src .. "/" .. file, dst .. "/" .. file })
          end
        end
      end
    end

    local parser_list = {
      "javascript",
      "typescript",
      "jsdoc",
      "tsx",
      "json",
      "jsonc",
      "html",
      "css",
      "markdown",
      "markdown_inline",
      "lua",
    }

    if ts.install then
      ts.install(parser_list)
    end

    local installed = {}
    local ok, list = pcall(ts.get_installed, "parsers")
    if ok and list then
      for _, lang in ipairs(list) do
        installed[lang] = true
      end
    end

    local query_cache = {}
    local function has_query(lang, query_name)
      local key = lang .. ":" .. query_name
      if query_cache[key] == nil then
        query_cache[key] = vim.treesitter.query.get(lang, query_name) ~= nil
      end
      return query_cache[key]
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
      callback = function(ev)
        local ft = vim.bo[ev.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then return end
        if not installed[lang] then return end
        if not has_query(lang, "highlights") then return end

        pcall(vim.treesitter.start, ev.buf)
      end,
    })
  end,
}
