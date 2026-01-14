--- Telescope 模糊查找器配置文件
-- 这是 LazyVim 的核心模糊查找工具，提供文件搜索、内容搜索、命令历史等功能
-- 支持多语言集成，包括 git 文件检测、实时搜索、扩展插件支持等

if lazyvim_docs then
  --- LazyVim 文档模式下的全局设置
  -- 如果用户不想使用 `:LazyExtras` 命令，可以手动设置此选项来启用 Telescope
  vim.g.lazyvim_picker = "telescope"
end

--- 检测系统中可用的构建工具
-- 用于编译 FZF 模糊查找算法的高性能 C 库
local build_cmd ---@type string? -- 构建命令名称，如果未找到则为 nil

-- 按优先级检查构建工具：优先级从高到低
for _, cmd in ipairs({ "make", "cmake", "gmake" }) do
  if vim.fn.executable(cmd) == 1 then  -- 检查命令是否在 PATH 中可用
    build_cmd = cmd  -- 找到第一个可用的构建工具
    break
  end
end

--- Telescope picker 配置结构
-- 定义 Telescope 作为 LazyVim 模糊查找器的主要配置和接口
---@type LazyPicker
local picker = {
  --- Picker 名称标识
  name = "telescope",
  
  --- 支持的命令映射：内置命令到 Telescope 内置函数的映射
  commands = {
    files = "find_files",  -- 文件查找命令映射到 Telescope 的 find_files 函数
  },
  --- 打开 Telescope 查找器的核心函数
  -- 这个函数将调用 Telescope 的内置查找函数
  -- cwd 将默认为 lazyvim.util.get_root（项目根目录）
  -- 对于 `files` 命令，会根据是否存在 .git 目录自动选择 git_files 或 find_files
  
  ---@param builtin string 内置查找器类型（如 "find_files", "live_grep" 等）
  ---@param opts? lazyvim.util.pick.Opts 查找器的配置选项
  open = function(builtin, opts)
    --- 初始化选项：如果未提供选项则创建空表
    opts = opts or {}
    
    --- 默认启用文件跟踪：允许在搜索结果中选择文件并进入该目录
    opts.follow = opts.follow ~= false
    
    --- 处理跨目录查找：如果指定了不同的 cwd（工作目录）
    if opts.cwd and opts.cwd ~= vim.uv.cwd() then
      --- 创建跨目录打开函数：在指定目录中搜索
      local function open_cwd_dir()
        -- 获取 Telescope 当前搜索行内容
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        
        -- 以指定目录为根重新打开查找器
        LazyVim.pick.open(
          builtin,
          vim.tbl_deep_extend("force", {}, opts or {}, {
            root = false,              -- 不使用默认根目录
            default_text = line,       -- 保持当前搜索文本
          })
        )
      end
      
      --- 为 Telescope 添加自定义键映射
      ---@diagnostic disable-next-line: inject-field
      opts.attach_mappings = function(_, map)
        -- 绑定 Alt+C 键：打开当前 cwd 目录的搜索
        map("i", "<a-c>", open_cwd_dir, { desc = "Open cwd Directory" })
        return true  -- 保持其他默认映射
      end
    end

    --- 调用对应的 Telescope 内置查找器
    require("telescope.builtin")[builtin](opts)
  end,
}
--- 注册 Telescope picker 到 LazyVim 模糊查找系统
if not LazyVim.pick.register(picker) then
  return {}  -- 如果注册失败，返回空表
end

return {
  --- Telescope 主插件配置
  -- 模糊查找器：提供文件搜索、内容搜索、命令历史等核心功能
  -- 查找文件的默认快捷键会根据目录类型自动选择：
  -- Git 仓库：使用 git_files（Git 文件跟踪）
  -- 普通目录：使用 find_files（文件系统搜索）
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",       -- 仅在用户执行 Telescope 命令时加载
    version = false,         -- 使用 HEAD 版本（开发版），因为 Telescope 只有一个正式版本
    dependencies = {
      {
        --- FZF 原生扩展插件：提供高性能的模糊查找算法
        -- FZF 是用 C 编写的快速模糊查找工具，比纯 Lua 实现快 10-20 倍
        "nvim-telescope/telescope-fzf-native.nvim",
        
        --- 构建脚本：根据系统类型选择合适的构建命令
        build = (build_cmd ~= "cmake") and "make"  -- Unix 系统使用 make
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",  -- Windows 使用 cmake
        
        --- 启用条件：只有检测到构建工具时才启用
        enabled = build_cmd ~= nil,
        
        --- FZF 扩展配置和错误处理
        config = function(plugin)
          --- 在 Telescope 加载完成后加载 FZF 扩展
          LazyVim.on_load("telescope.nvim", function()
            --- 尝试加载 FZF 扩展
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              -- 检查 FZF 库文件是否存在
              local lib = plugin.dir .. "/build/libfzf." .. (LazyVim.is_win() and "dll" or "so")
              
              if not vim.uv.fs_stat(lib) then
                -- 库文件不存在：尝试重新构建
                LazyVim.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  LazyVim.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                end)
              else
                -- 库文件存在但加载失败：显示错误信息
                LazyVim.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
              end
            end
          end)
        end,
      },
    },
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      -- find
      {
        "<leader>fb",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
        desc = "Buffers",
      },
      { "<leader>fB", "<cmd>Telescope buffers<cr>", desc = "Buffers (all)" },
      { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
      { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gl", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
      { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>s/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", LazyVim.pick("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
      { "<leader>sW", LazyVim.pick("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
      { "<leader>sw", LazyVim.pick("grep_string"), mode = "x", desc = "Selection (Root Dir)" },
      { "<leader>sW", LazyVim.pick("grep_string", { root = false }), mode = "x", desc = "Selection (cwd)" },
      { "<leader>uC", LazyVim.pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with Preview" },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = LazyVim.config.get_kind_filter(),
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            symbols = LazyVim.config.get_kind_filter(),
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.sources.telescope").open(...)
      end
      local find_files_no_ignore = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        LazyVim.pick("find_files", { no_ignore = true, default_text = line })()
      end
      local find_files_with_hidden = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        LazyVim.pick("find_files", { hidden = true, default_text = line })()
      end

      local function find_command()
        if 1 == vim.fn.executable("rg") then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif 1 == vim.fn.executable("fd") then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("fdfind") then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
          return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable("where") then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
      }
    end,
  },

  -- Flash Telescope config
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      if not LazyVim.has("flash.nvim") then
        return
      end
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = { n = { s = flash }, i = { ["<c-s>"] = flash } },
      })
    end,
  },

  -- better vim.ui with telescope
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          -- stylua: ignore
          keys = {
            { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition", has = "definition" },
            { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
            { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
            { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
          },
        },
      },
    },
  },
}
