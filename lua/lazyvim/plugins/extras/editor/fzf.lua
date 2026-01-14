-- FZF-Lua 模糊搜索和选择工具配置
-- 这是 ibhagwan/fzf-lua 插件的配置，提供了强大的模糊搜索功能

-- ==================== 文档和全局设置 ====================
if lazyvim_docs then
  -- 如果不想使用 `:LazyExtras` 命令，需要设置以下选项
  -- 设置 LazyVim 的默认选择器为 fzf
  vim.g.lazyvim_picker = "fzf"
end

---@class FzfLuaOpts: lazyvim.util.pick.Opts
---@field cmd string? 自定义命令，用于特定搜索场景

---@type LazyPicker
-- 定义 LazyVim 的 fzf 选择器配置
local picker = {
  -- 选择器名称
  name = "fzf",
  -- 支持的命令映射：files 命令对应 fzf-lua 的 files 功能
  commands = {
    files = "files",
  },

  ---@param command string 要执行的 fzf-lua 命令
  ---@param opts? FzfLuaOpts 可选参数配置
  -- 打开 fzf-lua 选择器的函数
  open = function(command, opts)
    opts = opts or {}
    -- 特殊处理 git_files 命令，当显示未跟踪文件时使用自定义命令
    if opts.cmd == nil and command == "git_files" and opts.show_untracked then
      opts.cmd = "git ls-files --exclude-standard --cached --others"
    end
    -- 调用对应的 fzf-lua 函数
    return require("fzf-lua")[command](opts)
  end,
}

-- 如果注册失败（可能已经被其他选择器占用），则返回空配置
if not LazyVim.pick.register(picker) then
  return {}
end

-- ==================== 符号过滤器 ====================
-- 过滤 LSP 符号显示，根据用户配置隐藏特定类型的符号

local function symbols_filter(entry, ctx)
  -- 如果符号过滤器未初始化，则从 LazyVim 配置中获取
  if ctx.symbols_filter == nil then
    ctx.symbols_filter = LazyVim.config.get_kind_filter(ctx.bufnr) or false
  end
  -- 如果过滤器为 false，则显示所有符号
  if ctx.symbols_filter == false then
    return true
  end
  -- 检查当前符号类型是否在过滤列表中
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

-- ==================== 主要插件配置 ====================
return {
  -- 插件描述
  desc = "Awesome picker for FZF (alternative to Telescope)",
  -- ==================== FZF-Lua 主插件 ====================
  {
    -- 插件仓库：fzf-lua 是 fzf 的 Neovim 实现，提供强大的模糊搜索
    "ibhagwan/fzf-lua",
    -- 延迟加载：只有在运行 FzfLua 命令时才加载插件
    cmd = "FzfLua",
    -- 插件选项配置函数
    opts = function(_, opts)
      -- 引入 fzf-lua 模块和子模块
      local fzf = require("fzf-lua")
      local config = fzf.config
      local actions = fzf.actions

      -- ==================== FZF 快捷键配置 ====================
      -- 配置 FZF 底层的快捷键映射
      config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept" -- 全选并确认
      config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"      -- 半页向上
      config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"    -- 半页向下
      config.defaults.keymap.fzf["ctrl-x"] = "jump"              -- 快速跳转
      config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down" -- 预览区向下滚动
      config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"   -- 预览区向上滚动

      -- 内置预览器的快捷键配置
      config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
      config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

      -- ==================== Trouble 插件集成 ====================
      -- 如果安装了 trouble.nvim 插件，则集成其功能
      if LazyVim.has("trouble.nvim") then
        -- 在文件选择时，Ctrl+T 打开 trouble 窗口显示诊断信息
        config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
      end

      -- ==================== 根目录/工作目录切换 ====================
      -- 在根目录和工作目录之间切换搜索范围
      config.defaults.actions.files["ctrl-r"] = function(_, ctx)
        -- 深拷贝当前调用选项
        local o = vim.deepcopy(ctx.__call_opts)
        -- 切换 root 设置：root=true 时搜索根目录，root=false 时搜索当前目录
        o.root = o.root == false
        -- 清除 cwd 设置，让搜索基于切换后的 root 设置
        o.cwd = nil
        o.buf = ctx.__CTX.bufnr
        LazyVim.pick.open(ctx.__INFO.cmd, o)
      end
      -- 绑定 Alt+C 到相同的切换功能（提供备用快捷键）
      config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
      -- 设置动作帮助文本
      config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

      -- ==================== 图片预览器配置 ====================
      -- 检测系统可用的图片预览工具，按优先级排序
      local img_previewer ---@type string[]?
      for _, v in ipairs({
        -- ueberzug：终端图片预览工具，支持多种格式
        { cmd = "ueberzug", args = {} },
        -- chafa：将图片转换为 Unicode 字符
        { cmd = "chafa", args = { "{file}", "--format=symbols" } },
        -- viu：简洁的图片预览工具
        { cmd = "viu", args = { "-b" } },
      }) do
        -- 检查命令是否可用
        if vim.fn.executable(v.cmd) == 1 then
          -- 使用找到的工具作为图片预览器
          img_previewer = vim.list_extend({ v.cmd }, v.args)
          break
        end
      end

      -- ==================== 主配置返回 ====================
      return {
        -- 使用默认标题配置
        "default-title",
        -- 启用 fzf 颜色主题
        fzf_colors = true,
        -- FZF 选项配置
        fzf_opts = {
          ["--no-scrollbar"] = true, -- 禁用滚动条，使用自定义滚动条
        },
        -- 默认配置
        defaults = {
          -- 文件路径格式化器：优先显示目录名而非文件名
          formatter = "path.dirname_first",
        },
        previewers = {
          builtin = {
            extensions = {
              ["png"] = img_previewer,
              ["jpg"] = img_previewer,
              ["jpeg"] = img_previewer,
              ["gif"] = img_previewer,
              ["webp"] = img_previewer,
            },
            ueberzug_scaler = "fit_contain",
          },
        },
        -- Custom LazyVim option to configure vim.ui.select
        ui_select = function(fzf_opts, items)
          return vim.tbl_deep_extend("force", fzf_opts, {
            prompt = " ",
            winopts = {
              title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
              title_pos = "center",
            },
          }, fzf_opts.kind == "codeaction" and {
            winopts = {
              layout = "vertical",
              -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
              height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 4) + 0.5) + 16,
              width = 0.5,
              preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
                layout = "vertical",
                vertical = "down:15,border-top",
                hidden = "hidden",
              } or {
                layout = "vertical",
                vertical = "down:15,border-top",
              },
            },
          } or {
            winopts = {
              width = 0.5,
              -- height is number of items, with a max of 80% screen height
              height = math.floor(math.min(vim.o.lines * 0.8, #items + 4) + 0.5),
            },
          })
        end,
        winopts = {
          width = 0.8,
          height = 0.8,
          row = 0.5,
          col = 0.5,
          preview = {
            scrollchars = { "┃", "" },
          },
        },
        files = {
          cwd_prompt = false,
          actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
          },
        },
        grep = {
          actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
          },
        },
        lsp = {
          symbols = {
            symbol_hl = function(s)
              return "TroubleIcon" .. s
            end,
            symbol_fmt = function(s)
              return s:lower() .. "\t"
            end,
            child_prefix = false,
          },
          code_actions = {
            previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
          },
        },
      }
    end,
    config = function(_, opts)
      if opts[1] == "default-title" then
        -- use the same prompt for all pickers for profile `default-title` and
        -- profiles that use `default-title` as base profile
        local function fix(t)
          t.prompt = t.prompt ~= nil and " " or nil
          for _, v in pairs(t) do
            if type(v) == "table" then
              fix(v)
            end
          end
          return t
        end
        opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
        opts[1] = nil
      end
      require("fzf-lua").setup(opts)
    end,
    init = function()
      LazyVim.on_very_lazy(function()
        vim.ui.select = function(...)
          require("lazy").load({ plugins = { "fzf-lua" } })
          local opts = LazyVim.opts("fzf-lua") or {}
          require("fzf-lua").register_ui_select(opts.ui_select or nil)
          return vim.ui.select(...)
        end
      end)
    end,
    keys = {
      { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
      { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
      {
        "<leader>,",
        "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      -- find
      { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>fB", "<cmd>FzfLua buffers<cr>", desc = "Buffers (all)" },
      { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
      { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
      { "<leader>gd", "<cmd>FzfLua git_diff<cr>", desc = "Git Diff (hunks)" },
      { "<leader>gl", "<cmd>FzfLua git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Status" },
      { "<leader>gS", "<cmd>FzfLua git_stash<cr>", desc = "Git Stash" },
      -- search
      { '<leader>s"', "<cmd>FzfLua registers<cr>", desc = "Registers" },
      { "<leader>s/", "<cmd>FzfLua search_history<cr>", desc = "Search History" },
      { "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>FzfLua lines<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics" },
      { "<leader>sD", "<cmd>FzfLua diagnostics_document<cr>", desc = "Buffer Diagnostics" },
      { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>FzfLua highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>FzfLua jumps<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>FzfLua loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>FzfLua man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "Jump to Mark" },
      { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", LazyVim.pick("grep_cword"), desc = "Word (Root Dir)" },
      { "<leader>sW", LazyVim.pick("grep_cword", { root = false }), desc = "Word (cwd)" },
      { "<leader>sw", LazyVim.pick("grep_visual"), mode = "x", desc = "Selection (Root Dir)" },
      { "<leader>sW", LazyVim.pick("grep_visual", { root = false }), mode = "x", desc = "Selection (cwd)" },
      { "<leader>uC", LazyVim.pick("colorschemes"), desc = "Colorscheme with Preview" },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols({
            regex_filter = symbols_filter,
          })
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("fzf-lua").lsp_live_workspace_symbols({
            regex_filter = symbols_filter,
          })
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>st", function() require("todo-comments.fzf").todo() end, desc = "Todo" },
      { "<leader>sT", function () require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- stylua: ignore
        ["*"] = {
          keys = {
            { "gd", "<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>", desc = "Goto Definition", has = "definition" },
            { "gr", "<cmd>FzfLua lsp_references      jump1=true ignore_current_line=true<cr>", desc = "References", nowait = true },
            { "gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
            { "gy", "<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
          }
        },
      },
    },
  },
}
