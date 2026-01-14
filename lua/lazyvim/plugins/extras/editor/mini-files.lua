-- Mini Files 文件管理插件配置
-- 这是 nvim-mini 组织开发的轻量级文件管理插件
-- 提供了简洁高效的文件/目录浏览、编辑和导航功能

return {
  -- 插件标识：Mini Files 是 LazyVim 推荐的轻量化文件管理器
  "nvim-mini/mini.files",

  -- 基础配置选项
  opts = {
    -- 窗口相关设置
    windows = {
      -- 是否启用文件预览功能：可以预览文件内容而不需要打开文件
      preview = true,
      -- 焦点窗口（当前操作窗口）的宽度（列数）
      width_focus = 30,
      -- 预览窗口的宽度（列数）
      width_preview = 30,
    },

    -- 全局选项设置
    options = {
      -- 是否作为默认的文件管理器使用
      -- LazyVim 默认禁用此选项，因为已经有 neo-tree 作为主文件管理器
      -- 用户可以选择使用其中之一，但不能同时作为默认文件管理器
      use_as_default_explorer = false,
    },
  },

  -- 快捷键绑定：在 Normal 模式下触发 mini-files 功能
  keys = {
    {
      -- <leader>fm：在当前文件的目录中打开 mini-files
      -- <leader> 通常是空格键，fm 是 "file mini" 的缩写
      "<leader>fm",
      -- 打开 mini-files，定位到当前缓冲区文件所在的目录
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      -- 快捷键描述信息，会显示在 which-key 提示中
      desc = "Open mini.files (Directory of Current File)",
    },
    {
      -- <leader>fM：在当前工作目录打开 mini-files
      -- <leader>fM 中的 M 表示 "Main" 或 "current Working directory"
      "<leader>fM",
      -- 打开 mini-files，定位到当前工作目录
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },

  -- 高级配置函数：设置更多自定义功能和快捷键
  config = function(_, opts)
    -- 初始化 mini-files 插件
    require("mini.files").setup(opts)

    -- ==================== 隐藏文件显示控制 ====================
    -- 控制是否显示以点（.）开头的隐藏文件或目录

    -- 当前是否显示隐藏文件的状态标识
    local show_dotfiles = true

    -- 显示所有文件的过滤器函数（包括隐藏文件）
    local filter_show = function(fs_entry)
      return true -- 返回 true 表示显示所有文件和目录
    end

    -- 隐藏隐藏文件的过滤器函数（过滤掉以点开头的文件和目录）
    local filter_hide = function(fs_entry)
      return not vim.startswith(fs_entry.name, ".")
    end

    -- 切换隐藏文件显示状态的函数
    local toggle_dotfiles = function()
      -- 切换显示状态
      show_dotfiles = not show_dotfiles
      -- 根据当前状态选择对应的过滤器
      local new_filter = show_dotfiles and filter_show or filter_hide
      -- 刷新 mini-files 缓冲区，应用新的过滤器
      require("mini.files").refresh({ content = { filter = new_filter } })
    end

    -- ==================== 分屏打开功能 ====================
    -- 在水平或垂直分屏中打开文件，同时设置合适的窗口作为 mini-files 的目标窗口

    -- 创建分屏打开的快捷键映射
    local map_split = function(buf_id, lhs, direction, close_on_file)
      -- 定义快捷键触发的实际函数
      local rhs = function()
        local new_target_window -- 新设置的目标窗口
        local cur_target_window = require("mini.files").get_explorer_state().target_window

        -- 如果存在当前的目标窗口，则在其基础上创建分屏
        if cur_target_window ~= nil then
          -- 在目标窗口中执行分屏操作
          vim.api.nvim_win_call(cur_target_window, function()
            -- belowright 确保新窗口在当前窗口的下方或右侧
            vim.cmd("belowright " .. direction .. " split")
            -- 获取新创建的窗口 ID
            new_target_window = vim.api.nvim_get_current_win()
          end)

          -- 设置新窗口作为 mini-files 的目标窗口
          require("mini.files").set_target_window(new_target_window)
          -- 进入选择的文件或目录，close_on_file 控制打开文件后是否关闭 mini-files
          require("mini.files").go_in({ close_on_file = close_on_file })
        end
      end

      -- 生成快捷键描述文本
      local desc = "Open in " .. direction .. " split"
      if close_on_file then
        desc = desc .. " and close"
      end

      -- 设置快捷键映射，buffer = buf_id 表示只在这个缓冲区生效
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    -- ==================== 工作目录设置 ====================
    -- 将当前 mini-files 操作的目录设置为 Neovim 的工作目录

    -- 设置当前工作目录为 mini-files 当前选中条目的目录
    local files_set_cwd = function()
      -- 获取当前选中的文件系统条目的完整路径
      local cur_entry_path = MiniFiles.get_fs_entry().path
      -- 获取该路径的父目录
      local cur_directory = vim.fs.dirname(cur_entry_path)
      -- 如果成功获取到目录，则设置为 Neovim 的工作目录
      if cur_directory ~= nil then
        vim.fn.chdir(cur_directory)
      end
    end

    -- ==================== 自动命令设置 ====================
    -- 在 mini-files 缓冲区创建时设置自定义快捷键

    -- 当 mini-files 缓冲区创建时执行的自动命令
    vim.api.nvim_create_autocmd("User", {
      -- 监听 MiniFilesBufferCreate 事件：mini-files 缓冲区创建完成后触发
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        -- 获取刚创建的缓冲区 ID
        local buf_id = args.data.buf_id

        -- 设置切换隐藏文件的快捷键
        -- 默认使用 g. 键（go dotfiles），也可以通过 opts.mappings.toggle_hidden 自定义
        vim.keymap.set(
          "n",
          opts.mappings and opts.mappings.toggle_hidden or "g.",
          toggle_dotfiles,
          { buffer = buf_id, desc = "Toggle hidden files" }
        )

        -- 设置设置工作目录的快捷键
        -- 默认使用 gc 键（go change directory），也可以通过 opts.mappings.change_cwd 自定义
        vim.keymap.set(
          "n",
          opts.mappings and opts.mappings.change_cwd or "gc",
          files_set_cwd,
          { buffer = args.data.buf_id, desc = "Set cwd" }
        )

        -- 设置各种分屏打开的快捷键映射
        -- 水平分屏打开（不关闭 mini-files）：<C-w>s 或 opts.mappings.go_in_horizontal
        map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or "<C-w>s", "horizontal", false)
        -- 垂直分屏打开（不关闭 mini-files）：<C-w>v 或 opts.mappings.go_in_vertical
        map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or "<C-w>v", "vertical", false)
        -- 水平分屏打开（打开文件后关闭 mini-files）：<C-w>S 或 opts.mappings.go_in_horizontal_plus
        map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or "<C-w>S", "horizontal", true)
        -- 垂直分屏打开（打开文件后关闭 mini-files）：<C-w>V 或 opts.mappings.go_in_vertical_plus
        map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or "<C-w>V", "vertical", true)
      end,
    })

    -- 文件重命名事件处理：当在 mini-files 中重命名文件时，通知其他相关插件
    vim.api.nvim_create_autocmd("User", {
      -- 监听 MiniFilesActionRename 事件：mini-files 中执行重命名操作时触发
      pattern = "MiniFilesActionRename",
      -- 回调函数：将重命名操作同步到 Snacks.rename 插件
      -- 确保文件重命名后，相关插件（如 fuzzy finder）的索引也能及时更新
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
  end,
}
