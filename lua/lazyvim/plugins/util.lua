-- 终端窗口导航辅助函数
-- 这个函数为终端窗口提供方向键导航功能
-- 它会根据终端窗口类型（浮动窗口或普通窗口）智能切换导航方式
-- 如果是浮动终端窗口，使用 <C-方向键> 控制浮动窗口
-- 如果是普通终端窗口，使用常规的窗口切换命令
---
---@param dir string 方向（h、j、k、l）
---@return function 返回终端导航函数
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    -- 检查是否为浮动终端窗口
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      -- 如果不是浮动窗口，使用 Vim 的窗口切换命令
      vim.cmd.wincmd(dir)
    end)
  end
end

return {

  -- Snacks 工具集插件
  -- 这是一个现代化的工具集插件，提供多种实用功能：
  -- 1. 大文件检测：自动识别大文件并优化编辑器性能
  -- 2. 快速文件访问：提供快速文件打开和管理功能
  -- 3. 终端增强：在终端中提供更好的用户体验
  -- 4. 通知系统：现代化的高质量通知展示
  -- 5. 动画效果：流畅的 UI 交互体验
  -- 6. 快速启动：针对大型项目的启动优化
  -- Snacks 相比传统方案更现代化、更轻量
  {
    "snacks.nvim",
    opts = {
      -- 大文件优化：自动检测大文件并应用性能优化
      bigfile = { enabled = true },
      -- 快速文件访问：优化文件加载和预览体验
      quickfile = { enabled = true },

      -- 终端增强配置
      terminal = {
        win = {
          -- 终端窗口的按键配置
          keys = {
            -- 左窗口导航：智能判断浮动窗口或普通窗口
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            -- 下窗口导航
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            -- 上窗口导航
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            -- 右窗口导航
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- 临时缓冲区切换：快速打开/关闭临时缓冲区
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer / 切换临时缓冲区" },

      -- 选择临时缓冲区：从多个临时缓冲区中选择一个
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer / 选择临时缓冲区" },

      -- 性能分析器临时缓冲区：查看性能分析数据
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer / 性能分析缓冲区" },
    },
  },

  -- Persistence 会话管理插件
  -- 这是一个智能的会话恢复工具，提供：
  -- 1. 自动保存会话：在关闭 Neovim 时自动保存当前的缓冲区状态
  -- 2. 多会话支持：支持保存和管理多个不同的会话
  -- 3. 窗口布局保存：记录窗口分割、布局等信息
  -- 4. 文件状态保存：记住每个文件的打开位置、标记等
  -- 5. 智能恢复：启动时自动恢复上次的工作环境
  -- 6. 历史管理：支持加载最新的或历史保存的任意会话
  -- 这确保您的工作环境始终保持连续性，特别适合多项目开发
  {
    "folke/persistence.nvim",
    event = "BufReadPre",  -- 在读取文件前加载（确保会话信息可用）
    opts = {},  -- 使用默认配置，大多数情况下无需额外设置

    -- stylua: ignore
    keys = {
      -- 恢复会话：加载最近保存的会话
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session / 恢复会话" },

      -- 选择会话：从多个保存的会话中选择一个
      { "<leader>qS", function() require("persistence").select() end, desc = "Select Session / 选择会话" },

      -- 恢复最近会话：快速恢复最后一次保存的会话
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session / 恢复最近会话" },

      -- 停止保存会话：在当前会话中不保存当前状态（临时场景）
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session / 停止保存当前会话" },
    },
  },

  -- Plenary 工具库
  -- 这是一个重要的 Lua 工具库，被众多 Neovim 插件广泛依赖：
  -- 1. 文件操作：完整的文件系统操作工具集
  -- 2. 异步工具：Promise 风格的异步编程支持
  -- 3. 实用函数：常用的高质量工具函数
  -- 4. 测试框架：插件测试的基础设施
  -- 5. 标准化接口：为其他插件提供统一的基础接口
  -- 6. 依赖减少：避免插件重复实现相同的基础功能
  -- 许多知名插件（如 Telescope、NvChad、NVCode 等）都依赖 Plenary
  { "nvim-lua/plenary.nvim", lazy = true },
}
