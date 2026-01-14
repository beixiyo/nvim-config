-- Vim-Illuminate 代码引用高亮插件配置
-- 自动高亮光标下单词的其他实例，支持 LSP、Tree-sitter 和正则表达式匹配
-- 帮助开发者快速识别代码中相同变量的使用位置

return {
  -- ==================== 冲突插件禁用设置 ====================
  -- 禁用 Snacks 单词高亮功能，避免与 Vim-Illuminate 冲突
  { "snacks.nvim", opts = { words = { enabled = false } } },

  -- ==================== Vim-Illuminate 主插件配置 ====================

  -- ==================== Vim-Illuminate 主插件配置 ====================
  {
    "RRethy/vim-illuminate",
    -- 延迟加载：在文件加载后加载，提高启动性能
    event = "LazyFile",
    -- 插件选项配置
    opts = {
      -- 高亮延迟：200毫秒后开始高亮，避免频繁触发
      delay = 200,
      -- 大文件阈值：超过2000行的文件视为大文件
      large_file_cutoff = 2000,
      -- 大文件覆盖配置：只使用 LSP 提供程序，禁用其他高亮方式
      large_file_overrides = {
        providers = { "lsp" },
      },
    },

    -- 插件配置函数
    config = function(_, opts)
      -- 初始化 Vim-Illuminate 插件
      require("illuminate").configure(opts)

      -- ==================== Snacks 切换功能集成 ====================
      -- 创建高亮功能的快速切换快捷键
      Snacks.toggle({
        name = "Illuminate",              -- 切换功能名称
        get = function()                  -- 获取当前状态
          return not require("illuminate.engine").is_paused()
        end,
        set = function(enabled)           -- 设置状态
          local m = require("illuminate")
          if enabled then
            m.resume()                    -- 恢复高亮功能
          else
            m.pause()                     -- 暂停高亮功能
          end
        end,
      }):map("<leader>ux")                -- <leader>ux 切换高亮功能

      -- ==================== 导航快捷键设置 ====================
      -- 创建在引用间导航的函数
      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          -- 调用 Vim-Illuminate 的引用跳转功能
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, {
          desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", -- 描述文本
          buffer = buffer
        })
      end

      -- 设置导航快捷键
      map("]]", "next")                   -- ]] 跳转到下一个引用
      map("[[", "prev")                   -- [[ 跳转到上一个引用

      -- ==================== 文件类型自动设置 ====================
      -- 在加载文件类型插件后重新设置快捷键，因为很多插件会覆盖 [[ 和 ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          -- 为当前缓冲区重新设置导航快捷键
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,

    -- 快捷键绑定
    keys = {
      { "]]", desc = "Next Reference" },    -- 跳转到下一个引用
      { "[[", desc = "Prev Reference" },    -- 跳转到上一个引用
    },
  },
}
