return {
  --- Neo-tree 文档结构浏览器主插件配置
  -- 现代化的文档树和文件资源管理器，提供文件浏览、导航、管理等功能
  
  --- 文档资源管理器配置
  -- Neo-tree 是 Neovim 最流行的文档树插件，支持 Git 状态、缓冲区管理等多种视图
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",  -- 仅在执行 Neotree 命令时加载
    
    --- Neo-tree 快捷键映射
    keys = {
      {
        -- 项目根目录文档树：在项目根目录打开文档浏览器
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        -- 当前工作目录文档树：在当前工作目录打开文档浏览器
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      -- 快捷键别名：短版本映射到完整版本
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      {
        -- Git 状态文档树：只显示 Git 跟踪的文件，显示 Git 状态信息
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        -- 缓冲区文档树：显示所有已打开的缓冲区列表，支持快速切换
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
    },
    
    --- 关闭 Neo-tree 函数
    deactivate = function()
      vim.cmd([[Neotree close]])  -- 执行 Neo-tree 的关闭命令
    end,
    --- Neo-tree 初始化函数
    -- 使用自动命令延迟加载 Neo-tree，而不是直接 require，避免 cwd 设置问题
    init = function()
      --- 创建自动命令：当进入缓冲区时启动 Neo-tree
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",  -- 描述：伴随目录启动 Neo-tree
        once = true,  -- 只执行一次，避免重复
        
        --- 回调函数：在进入缓冲区时触发
        callback = function()
          -- 检查 Neo-tree 是否已经加载
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end,
      })
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },
}
