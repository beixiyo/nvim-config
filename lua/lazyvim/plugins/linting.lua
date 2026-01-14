return {
  -- nvim-lint 代码质量检查插件
  -- 这是一个异步的代码质量检查工具，提供：
  -- 1. 多语言支持：支持各种编程语言的 linter 工具
  -- 2. 异步检查：在后台异步运行 linter，避免阻塞编辑
  -- 3. 集成诊断：通过 Neovim 的 diagnostics 系统展示检查结果
  -- 4. 事件驱动：根据文件变化自动触发检查
  -- 5. 可配置性：支持自定义 linter 和检查条件
  -- 常见的 linter 工具：ESLint (JavaScript)、Flake8 (Python)、Clippy (Rust) 等
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",  -- 打开文件后加载
    
    opts = {
      -- 触发 lint 检查的事件列表
      events = { 
        "BufWritePost",  -- 文件保存后
        "BufReadPost",   -- 文件读取后（文件重载时）
        "InsertLeave"    -- 离开插入模式时（用户停止输入后）
      },
      
      -- 按文件类型映射 linter：每个文件类型对应要运行的 linter 列表
      linters_by_ft = {
        fish = { "fish" },  -- Fish Shell 脚本使用 fish linter
        -- "*" 文件类型：对所有文件类型运行全局 linter
        -- ['*'] = { 'global linter' },
        -- "_" 文件类型：对没有配置 linter 的文件类型运行后备 linter
        -- ['_'] = { 'fallback linter' },
        -- ["*"] = { "typos" },
      },
      
      -- LazyVim 扩展：可以在这里覆盖或自定义 linter 配置
      ---@type table<string,table>
      linters = {
        -- -- 示例：只在存在 selene.toml 文件时启用 selene linter
        -- selene = {
        --   -- `condition` 是一个 LazyVim 扩展，允许根据上下文动态启用/禁用 linter
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
    config = function(_, opts)
      local M = {}
      
      -- 获取 nvim-lint 模块
      local lint = require("lint")
      
      -- 处理用户自定义的 linter 配置：合并或替换默认配置
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          -- 如果 linter 是表结构且存在默认配置，则深度合并
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          -- 如果有预追加参数，将它们添加到 linter 的参数列表中
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          -- 否则直接替换或创建新的 linter 配置
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft
      
      -- 防抖函数：避免在短时间内频繁触发 lint 检查
      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            -- 在下一帧执行函数，避免阻塞 UI
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end
      
      -- 核心的 lint 检查逻辑
      function M.lint()
        -- 使用 nvim-lint 的解析逻辑：
        -- * 首先检查完整文件类型是否有对应的 linter
        -- * 否则将文件类型按 "." 分割并添加所有相关的 linter
        -- * 这与 conform.nvim 不同，后者只为有格式化器的第一个文件类型运行
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)
        
        -- 创建名称表的副本，避免修改原始表
        names = vim.list_extend({}, names)
        
        -- 添加后备 linter：如果没有找到特定 linter，则使用后备 linter
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end
        
        -- 添加全局 linter：对所有文件类型都运行的 linter
        vim.list_extend(names, lint.linters_by_ft["*"] or {})
        
        -- 过滤掉不存在的 linter 或不满足条件的 linter
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            -- 如果 linter 不存在，警告用户
            LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
          end
          -- 只返回存在的 linter，以及满足条件的 linter
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)
        
        -- 运行 linter：如果有有效的 linter，则执行检查
        if #names > 0 then
          lint.try_lint(names)
        end
      end
      
      -- 创建自动命令：根据配置的事件触发 lint 检查
      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),  -- 创建独立的自动命令组
        callback = M.debounce(100, M.lint),  -- 防抖处理，100ms 后执行
      })
    end,
  },
}
