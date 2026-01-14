-- Mini Starter: 启动画面和启动器插件
-- 功能说明：
-- 1. 提供优雅的Neovim启动画面，替代默认的欢迎页面
-- 2. 包含快速操作菜单，便于执行常用任务
-- 3. 显示插件加载统计信息
-- 4. 支持自定义logo和菜单项
return {
  -- 禁用Snacks的Dashboard功能
  -- 原因：避免与Mini Starter功能重复，保持界面简洁
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },

  -- 启用Mini Starter启动器
  {
    "nvim-mini/mini.starter",
    version = false, -- 等待新版本发布后再启用语义化版本
    event = "VimEnter", -- 在Neovim启动完成后触发

    -- 配置选项函数
    opts = function()
      -- 自定义LazyVim ASCII艺术Logo
      local logo = table.concat({
        "            ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z",
        "            ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    ",
        "            ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       ",
        "            ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         ",
        "            ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           ",
        "            ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           ",
      }, "\n")

      local pad = string.rep(" ", 22) -- 用于对齐菜单项的空格

      -- 创建新的菜单项函数
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")

      -- Mini Starter配置
      --stylua: ignore
      local config = {
        evaluate_single = true,      -- 评估单个配置项
        header = logo,               -- 启动画面头部Logo
        items = {
          -- 主要功能菜单项
          new_section("Find file",       LazyVim.pick(),                        "Telescope"),      -- 查找文件
          new_section("New file",        "ene | startinsert",                   "Built-in"),       -- 新建文件
          new_section("Recent files",    LazyVim.pick("oldfiles"),              "Telescope"),      -- 最近文件
          new_section("Find text",       LazyVim.pick("live_grep"),             "Telescope"),      -- 搜索文本
          new_section("Config",          LazyVim.pick.config_files(),           "Config"),         -- 配置文件
          new_section("Restore session", [[lua require("persistence").load()]], "Session"),        -- 恢复会话
          new_section("Lazy Extras",     "LazyExtras",                          "Config"),         -- Lazy插件管理
          new_section("Lazy",            "Lazy",                                "Config"),         -- 插件管理器
          new_section("Quit",            "qa",                                  "Built-in"),       -- 退出Neovim
        },
        content_hooks = {
          -- 内容钩子：添加子弹符号并居中对齐
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,

    -- 插件配置函数
    config = function(_, config)
      -- 关闭Lazy并重新打开当starter准备就绪时
      -- 这确保启动画面正确显示
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        -- 创建自动命令监听MiniStarterOpened事件
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened", -- Mini Starter启动完成事件
          callback = function()
            require("lazy").show() -- 显示Lazy插件管理器界面
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config) -- 设置Mini Starter

      -- 创建自动命令监听LazyVimStarted事件
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted", -- LazyVim启动完成事件
        callback = function(ev)
          -- 获取插件统计信息
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100) -- 计算启动时间
          local pad_footer = string.rep(" ", 8)

          -- 设置启动画面底部信息：插件数量和启动时间
          starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"

          -- INFO: 基于@nvim-mini的建议（非常感谢！）
          -- 如果当前缓冲区是Mini Starter，则刷新显示
          if vim.bo[ev.buf].filetype == "ministarter" then
            pcall(starter.refresh)
          end
        end,
      })
    end,
  },
}
