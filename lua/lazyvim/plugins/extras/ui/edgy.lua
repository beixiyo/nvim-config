-- LazyVim Edgy 侧边栏布局配置文件
-- 功能：配置 Edgy 插件，创建和管理预定义的侧边栏窗口布局
-- 说明：为各种工具（Terminal、文件树、代码诊断等）提供智能的窗口布局管理

-- ========================================
-- Edgy 核心配置
-- ========================================

return {
  -- Create and display predefined window layouts.
  -- 注释：创建和显示预定义的窗口布局
  -- 说明：Edgy 是一个强大的窗口布局管理插件，可以智能地将各种侧边栏工具分配到预定义位置

  {
    "folke/edgy.nvim",

    -- 触发事件：VeryLazy - 在 Neovim 完全空闲时加载
    event = "VeryLazy",

    -- 键盘快捷键配置
    keys = {
      -- 切换 Edgy 侧边栏显示/隐藏
      {
        "<leader>ue",  -- 前导键 + u (utilities) + e (edgy)
        function()
          require("edgy").toggle()
        end,
        desc = "Edgy Toggle",  -- 描述：切换 Edgy 侧边栏
      },

      -- stylua: ignore

      -- 选择 Edgy 侧边栏中的窗口
      { "<leader>uE", function() require("edgy").select() end, desc = "Edgy Select Window" },
    },

    -- 插件选项配置函数
    opts = function()
      local opts = {
        -- ========================================
        -- 1. 底部区域窗口配置 (bottom)
        -- ========================================
        bottom = {
          -- 浮动终端窗口（高度占 40%）
          {
            ft = "toggleterm",  -- 文件类型：toggleterm
            size = { height = 0.4 },  -- 窗口高度为屏幕的 40%
            -- 过滤函数：只处理非浮动窗口（relative == "" 表示非浮动）
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },

          -- Noice 通知窗口（高度占 40%）
          {
            ft = "noice",       -- 文件类型：noice
            size = { height = 0.4 },
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },

          -- Trouble 诊断工具（使用默认大小）
          "Trouble",

          -- QuickFix 窗口
          { ft = "qf", title = "QuickFix" },

          -- 帮助文档窗口（固定高度 20 行）
          {
            ft = "help",        -- 文件类型：help
            size = { height = 20 },
            -- 过滤函数：避免在侧边栏中打开正在编辑的帮助文件
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },

          -- Spectre 搜索替换工具
          { title = "Spectre", ft = "spectre_panel", size = { height = 0.4 } },

          -- Neotest 测试输出面板
          { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
        },

        -- ========================================
        -- 2. 左侧区域窗口配置 (left)
        -- ========================================
        left = {
          -- Neotest 测试摘要窗口
          { title = "Neotest Summary", ft = "neotest-summary" },

          -- 注释掉的 Neo-tree 集成（现在通过动态配置处理）
          -- "neo-tree",
        },

        -- ========================================
        -- 3. 右侧区域窗口配置 (right)
        -- ========================================
        right = {
          -- Grug Far 搜索替换工具
          { title = "Grug Far", ft = "grug-far", size = { width = 0.4 } },
        },

        -- ========================================
        -- 4. 窗口操作键盘快捷键
        -- ========================================
        keys = {
          -- 增加宽度（Ctrl + 右箭头）
          ["<c-Right>"] = function(win)
            win:resize("width", 2)  -- 每次增加 2 列宽度
          end,

          -- 减少宽度（Ctrl + 左箭头）
          ["<c-Left>"] = function(win)
            win:resize("width", -2)  -- 每次减少 2 列宽度
          end,

          -- 增加高度（Ctrl + 上箭头）
          ["<c-Up>"] = function(win)
            win:resize("height", 2)  -- 每次增加 2 行高度
          end,

          -- 减少高度（Ctrl + 下箭头）
          ["<c-Down>"] = function(win)
            win:resize("height", -2)  -- 每次减少 2 行高度
          end,
        },
      }

      -- ========================================
      -- 5. 动态 Neo-tree 集成配置
      -- ========================================

      -- 检查是否安装了 Neo-tree 插件
      if LazyVim.has("neo-tree.nvim") then
        -- 定义 Neo-tree 不同视图的默认位置
        local pos = {
          filesystem = "left",      -- 文件系统视图放在左侧
          buffers = "top",          -- 缓冲区视图放在顶部
          git_status = "right",     -- Git 状态视图放在右侧
          document_symbols = "bottom",  -- 文档符号视图放在底部
          diagnostics = "bottom",   -- 诊断信息视图放在底部
        }

        -- 获取 Neo-tree 配置的源列表
        local sources = LazyVim.opts("neo-tree.nvim").sources or {}

        -- 为每个 Neo-tree 源动态创建布局配置
        for i, v in ipairs(sources) do
          -- 在左侧区域插入新配置（按顺序排列）
          table.insert(opts.left, i, {
            -- 标题：将源名称格式化（如 "file_system" -> "File System"）
            title = "Neo-Tree " .. v:gsub("_", " "):gsub("^%l", string.upper),
            ft = "neo-tree",        -- 文件类型为 neo-tree

            -- 过滤函数：根据缓冲区变量确定是否属于此源
            filter = function(buf)
              return vim.b[buf].neo_tree_source == v
            end,

            -- 固定显示（不会被自动隐藏）
            pinned = true,

            -- 打开函数：定义如何打开此视图
            open = function()
              -- 构建 Neotree 命令：指定位置、源类型和目录
              vim.cmd(("Neotree show position=%s %s dir=%s"):format(
                pos[v] or "bottom",  -- 位置（如果未定义则使用 "bottom"）
                v,                   -- 源类型
                LazyVim.root()       -- 项目根目录
              ))
            end,
          })
        end
      end

      -- ========================================
      -- 6. Trouble 诊断工具集成
      -- ========================================

      -- 为所有可能的位置（top、bottom、left、right）添加 Trouble 支持
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        -- 确保该位置存在配置表
        opts[pos] = opts[pos] or {}

        -- 插入 Trouble 配置
        table.insert(opts[pos], {
          ft = "trouble",  -- 文件类型：trouble

          -- 过滤函数：根据 Trouble 的窗口变量确定位置
          filter = function(_buf, win)
            return vim.w[win].trouble                      -- 确保是 Trouble 窗口
              and vim.w[win].trouble.position == pos       -- 位置匹配
              and vim.w[win].trouble.type == "split"       -- 类型为 split
              and vim.w[win].trouble.relative == "editor"  -- 相对编辑器
              and not vim.w[win].trouble_preview           -- 不是预览窗口
          end,
        })
      end

      -- ========================================
      -- 7. Snacks 终端集成
      -- ========================================

      -- 为所有位置添加 Snacks 终端支持
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        -- 确保该位置存在配置表
        opts[pos] = opts[pos] or {}

        -- 插入 Snacks 终端配置
        table.insert(opts[pos], {
          ft = "snacks_terminal",     -- 文件类型：snacks_terminal
          size = { height = 0.4 },    -- 窗口高度为屏幕的 40%

          -- 动态标题：显示终端 ID 和标题
          title = "%{b:snacks_terminal.id}: %{b:term_title}",

          -- 过滤函数：根据 Snacks 的窗口变量确定位置
          filter = function(_buf, win)
            return vim.w[win].snacks_win                      -- 确保是 Snacks 窗口
              and vim.w[win].snacks_win.position == pos       -- 位置匹配
              and vim.w[win].snacks_win.relative == "editor"  -- 相对编辑器
              and not vim.w[win].trouble_preview              -- 不是预览窗口
          end,
        })
      end

      -- 返回完整的配置选项
      return opts
    end,
  },

  -- ========================================
  -- 8. Telescope 集成配置
  -- ========================================
  -- 注释：use edgy's selection window
  -- 说明：使用 Edgy 的选择窗口进行文件选择

  {
    "nvim-telescope/telescope.nvim",
    optional = true,  -- 可选依赖：如果安装了 Telescope 才生效
    opts = {
      defaults = {
        -- 自定义选择窗口函数
        get_selection_window = function()
          -- 跳转到主编辑窗口，然后返回窗口 ID
          require("edgy").goto_main()
          return 0  -- 返回当前窗口 ID
        end,
      },
    },
  },

  -- ========================================
  -- 9. Neo-tree 文件打开兼容性配置
  -- ========================================
  -- 注释：prevent neo-tree from opening files in edgy windows
  -- 说明：防止 Neo-tree 在 Edgy 窗口中打开文件

  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = function(_, opts)
      -- 初始化或获取现有配置
      opts.open_files_do_not_replace_types = opts.open_files_do_not_replace_types
        or { "terminal", "Trouble", "qf", "Outline", "trouble" }

      -- 添加 "edgy" 到不替换文件类型列表
      table.insert(opts.open_files_do_not_replace_types, "edgy")
    end,
  },

  -- ========================================
  -- 10. Bufferline 偏移修复配置
  -- ========================================
  -- 注释：Fix bufferline offsets when edgy is loaded
  -- 说明：修复 Edgy 加载时的 Bufferline 偏移问题

  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function()
      -- 引入 Bufferline 的偏移模块
      local Offset = require("bufferline.offset")

      -- 检查是否已经应用了 Edgy 修复
      if not Offset.edgy then
        -- 保存原始的 get 函数
        local get = Offset.get

        -- 重写 get 函数以支持 Edgy 布局
        Offset.get = function()
          -- 检查 Edgy 是否已加载
          if package.loaded.edgy then
            -- 获取原始偏移信息
            local old_offset = get()
            -- 获取 Edgy 布局配置
            local layout = require("edgy.config").layout

            -- 初始化返回结果
            local ret = { 
              left = "", left_size = 0,   -- 左侧偏移信息
              right = "", right_size = 0  -- 右侧偏移信息
            }

            -- 处理左右两侧的侧边栏
            for _, pos in ipairs({ "left", "right" }) do
              local sb = layout[pos]  -- 获取对应位置的侧边栏配置
              -- 创建侧边栏标题（填充空格以匹配宽度）
              local title = " Sidebar" .. string.rep(" ", sb.bounds.width - 8)

              -- 如果侧边栏存在且有窗口
              if sb and #sb.wins > 0 then
                -- 设置偏移文本和大小
                ret[pos] = old_offset[pos .. "_size"] > 0 and old_offset[pos]
                  or pos == "left" and ("%#Bold#" .. title .. "%*" .. "%#BufferLineOffsetSeparator#│%*")
                  or pos == "right" and ("%#BufferLineOffsetSeparator#│%*" .. "%#Bold#" .. title .. "%*")
                ret[pos .. "_size"] = old_offset[pos .. "_size"] > 0 and old_offset[pos .. "_size"] or sb.bounds.width
              end
            end

            -- 计算总偏移大小
            ret.total_size = ret.left_size + ret.right_size

            -- 如果有侧边栏，返回偏移信息
            if ret.total_size > 0 then
              return ret
            end
          end

          -- 如果 Edgy 未加载或没有侧边栏，返回原始偏移信息
          return get()
        end

        -- 标记已应用 Edgy 修复
        Offset.edgy = true
      end
    end,
  },
}
