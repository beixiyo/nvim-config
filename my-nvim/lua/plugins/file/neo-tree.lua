-- ================================
-- 文件树 Neo-tree
-- ================================
-- 插件：nvim-neo-tree/neo-tree.nvim
-- 作用：侧边栏文件/缓冲区/Git 状态浏览

--- 获取「项目根」：优先 Git 根目录，否则当前工作目录
local function root()
  local ok, out = pcall(vim.fn.system, "git rev-parse --show-toplevel 2>/dev/null")
  if ok and out and #out > 0 then
    return vim.trim(out)
  end
  return vim.fn.getcwd()
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,

    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = root() })
        end,
        desc = "文件树",
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git 状态树",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "缓冲区树",
      },
    },

    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        -- 常用快捷键（未列出的为 neo-tree 默认）:
        -- 导航: l / Enter 打开或展开, h 收起节点, <space> 已禁用, <bs> 上一级, . 设当前为根
        -- 打开: l / Enter 打开, s 竖分屏, S 横分屏, t 新标签
        -- 创建: a 新建文件, A 新建目录
        -- 编辑: d 删除, r 重命名, b 重命名(不含扩展名)
        -- 剪贴: y 复制节点(用于 p 粘贴), x 剪切, p 粘贴, c 复制到指定路径, m 移动到指定路径
        -- 其它: R 刷新, q 关闭窗口, ? 帮助, < / > 切换 source
        -- 本配置自定义: Y 复制路径到系统剪贴板, O 系统默认程序打开, P 预览
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
            desc = "复制路径到剪贴板",
          },
          ["O"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node and (node.path or node:get_id())
              if path then
                require("lazy.util").open(path, { system = true })
              end
            end,
            desc = "系统默认程序打开",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
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
