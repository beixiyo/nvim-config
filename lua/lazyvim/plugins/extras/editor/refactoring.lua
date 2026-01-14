--- 重构工具集成函数
-- 根据用户选择的模糊查找器（Telescope 或 FZF）提供相应的重构选择界面
-- 支持多种界面模式，确保与用户的工具链完美集成
local pick = function()
  --- 获取重构模块实例
  local refactoring = require("refactoring")
  
  --- 根据模糊查找器类型选择界面
  if LazyVim.pick.picker.name == "telescope" then
    -- 使用 Telescope 扩展显示重构选项
    return require("telescope").extensions.refactoring.refactors()
  elseif LazyVim.pick.picker.name == "fzf" then
    -- 使用 FZF 显示重构选项
    local fzf_lua = require("fzf-lua")
    local results = refactoring.get_refactors()  -- 获取所有可用的重构操作

    --- FZF 选项配置
    local opts = {
      fzf_opts = {},          -- FZF 基础选项
      fzf_colors = true,      -- 启用颜色支持
      actions = {
        -- 默认动作：用户选择后执行对应的重构操作
        ["default"] = function(selected)
          refactoring.refactor(selected[1])
        end,
      },
    }
    -- 执行 FZF 搜索并显示结果
    fzf_lua.fzf_exec(results, opts)
  else
    -- 使用 Refactoring 插件的默认选择界面
    refactoring.select_refactor()
  end
end

return {
  --- Refactoring 插件主配置
  -- 提供智能代码重构功能，包括变量重命名、函数提取、代码提取等操作
  -- 支持多种编程语言的语法感知重构操作
  
  {
    "ThePrimeagen/refactoring.nvim",
    event = { "BufReadPre", "BufNewFile" },  -- 文件读取和创建时加载
    
    --- 插件依赖项
    dependencies = {
      "nvim-lua/plenary.nvim",           -- Lua 工具库，提供文件操作等功能
      "nvim-treesitter/nvim-treesitter", -- 语法树支持，智能代码分析的基础
    },
    
    --- 重构相关快捷键配置（全部使用 <leader>r 前缀）
    keys = {
      -- 重构主前缀：所有重构操作的统一入口
      { "<leader>r", "", desc = "+refactor", mode = { "n", "x" } },
      
      {
        -- 交互式重构选择：显示所有可用的重构选项
        "<leader>rs",
        pick,  -- 使用前面定义的 pick 函数，支持 Telescope/FZF/默认界面
        mode = { "n", "x" },
        desc = "Refactor",
      },
      
      {
        -- 内联变量：将局部变量内联到使用位置，简化代码结构
        "<leader>ri",
        function()
          return require("refactoring").refactor("Inline Variable")
        end,
        mode = { "n", "x" },
        desc = "Inline Variable",
        expr = true,  -- 返回值作为快捷键执行的命令
      },
      
      {
        -- 重命名变量：在作用域内重命名变量，自动更新所有引用
        "<leader>rb",
        function()
          return require("refactoring").refactor("Extract Block")
        end,
        mode = { "n", "x" },
        desc = "Extract Block",
        expr = true,
      },
      {
        "<leader>rf",
        function()
          return require("refactoring").refactor("Extract Block To File")
        end,
        mode = { "n", "x" },
        desc = "Extract Block To File",
        expr = true,
      },
      {
        "<leader>rP",
        function()
          require("refactoring").debug.printf({ below = false })
        end,
        desc = "Debug Print",
      },
      {
        "<leader>rp",
        function()
          require("refactoring").debug.print_var({ normal = true })
        end,
        mode = { "n", "x" },
        desc = "Debug Print Variable",
      },
      {
        "<leader>rc",
        function()
          require("refactoring").debug.cleanup({})
        end,
        desc = "Debug Cleanup",
      },
      {
        "<leader>rf",
        function()
          return require("refactoring").refactor("Extract Function")
        end,
        mode = { "n", "x" },
        desc = "Extract Function",
        expr = true,
      },
      {
        "<leader>rF",
        function()
          return require("refactoring").refactor("Extract Function To File")
        end,
        mode = { "n", "x" },
        desc = "Extract Function To File",
        expr = true,
      },
      {
        "<leader>rx",
        function()
          return require("refactoring").refactor("Extract Variable")
        end,
        mode = { "n", "x" },
        desc = "Extract Variable",
        expr = true,
      },
      {
        "<leader>rp",
        function()
          require("refactoring").debug.print_var()
        end,
        mode = { "n", "x" },
        desc = "Debug Print Variable",
      },
    },
    opts = {
      prompt_func_return_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      prompt_func_param_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      printf_statements = {},
      print_var_statements = {},
      show_success_message = true, -- shows a message with information about the refactor on success
      -- i.e. [Refactor] Inlined 3 variable occurrences
    },
    config = function(_, opts)
      require("refactoring").setup(opts)
      if LazyVim.has("telescope.nvim") then
        LazyVim.on_load("telescope.nvim", function()
          require("telescope").load_extension("refactoring")
        end)
      end
    end,
  },
}
