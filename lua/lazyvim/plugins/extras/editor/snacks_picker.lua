-- Snacks 现代化快速选择器配置
-- folke 开发的 Snacks 工具集中的模糊选择器
-- 提供高性能、现代的用户界面和丰富的选择功能

-- ==================== 文档和全局设置 ====================
if lazyvim_docs then
  -- 如果不想使用 `:LazyExtras` 命令，需要设置以下选项
  -- 设置 LazyVim 的默认选择器为 snacks
  vim.g.lazyvim_picker = "snacks"
end

---@module 'snacks'

---@type LazyPicker
-- 定义 LazyVim 的 snacks 选择器配置
local picker = {
  -- 选择器名称
  name = "snacks",
  -- 支持的命令映射
  commands = {
    files = "files",      -- 文件查找
    live_grep = "grep",   -- 实时搜索
    oldfiles = "recent",  -- 最近文件
  },

  ---@param source string 选择的源类型
  ---@param opts? snacks.picker.Config 可选参数配置
  -- 打开 snacks 选择器的函数
  open = function(source, opts)
    return Snacks.picker.pick(source, opts)
  end,
}

-- 如果注册失败（可能已经被其他选择器占用），则返回空配置
if not LazyVim.pick.register(picker) then
  return {}
end

-- ==================== 主插件配置 ====================
return {
  -- 插件描述：快速和现代的文件选择器
  desc = "Fast and modern file picker",
  -- 推荐启用：这是 LazyVim 推荐的插件
  recommended = true,
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<a-c>"] = {
                "toggle_cwd",
                mode = { "n", "i" },
              },
            },
          },
        },
        actions = {
          ---@param p snacks.Picker
          toggle_cwd = function(p)
            local root = LazyVim.root({ buf = p.input.filter.current_buf, normalize = true })
            local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
            local current = p:cwd()
            p:set_cwd(current == root and cwd or root)
            p:find()
          end,
        },
      },
    },
    -- stylua: ignore
    -- 快捷键绑定：定义所有选择器相关的快捷键
    keys = {
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },           -- 切换到缓冲区列表
      { "<leader>/", LazyVim.pick("grep"), desc = "Grep (Root Dir)" },          -- 在项目根目录中搜索
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" }, -- 查看命令历史
      { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },    -- 在项目根目录查找文件
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" }, -- 查看通知历史
      -- find：文件查找相关命令
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },            -- 查看当前打开的文件
      { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" }, -- 查看所有缓冲区（包括隐藏）
      { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },           -- 查找配置文件
      { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },           -- 在项目根目录查找文件
      { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" }, -- 在当前目录查找文件
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" }, -- 查找Git管理的文件
      { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent" },                      -- 查看最近编辑的文件
      { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" }, -- 查看当前目录中的最近文件
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },      -- 查找和管理项目
      -- git：Git相关功能
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },    -- 查看当前文件的Git差异
      { "<leader>gD", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Git Diff (origin)" }, -- 查看与origin的差异
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },        -- 查看Git状态
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },         -- 查看Git储藏
      { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" }, -- 打开GitHub Issues
      { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" }, -- 查看所有GitHub Issues
      { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" }, -- 打开GitHub Pull Requests
      { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" }, -- 查看所有GitHub Pull Requests
      -- Grep：搜索相关功能
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },         -- 搜索当前缓冲区内容
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" }, -- 搜索所有打开的缓冲区
      { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },               -- 在项目根目录进行实时搜索
      { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },  -- 在当前目录进行实时搜索
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" }, -- 搜索插件规范
      { "<leader>sw", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } }, -- 搜索选中内容或光标下的词（根目录）
      { "<leader>sW", LazyVim.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } }, -- 搜索选中内容或光标下的词（当前目录）
      -- search：搜索和查找相关功能
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },        -- 查看系统寄存器内容
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" }, -- 查看搜索历史
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },         -- 查看自动命令
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" }, -- 查看命令历史
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },         -- 查看所有可用命令
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },   -- 查看所有诊断信息
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" }, -- 查看当前缓冲区的诊断
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },           -- 查看帮助页面
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },     -- 查看语法高亮组
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },              -- 查看可用图标
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },              -- 查看跳转列表
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },          -- 查看按键映射
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },    -- 查看位置列表
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },            -- 查看Man页面
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },              -- 查看标记位置
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },            -- 恢复上次的搜索
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },     -- 查看快速修复列表
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },            -- 查看撤销树
      -- ui：用户界面相关功能
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },  -- 切换主题颜色
    },
  },
  -- ==================== Trouble 插件集成 ====================
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- 检查是否安装了 Trouble 插件
      if LazyVim.has("trouble.nvim") then
        return vim.tbl_deep_extend("force", opts or {}, {
          picker = {
            actions = {
              -- 在 Trouble 中打开搜索结果
              trouble_open = function(...)
                return require("trouble.sources.snacks").actions.trouble_open.action(...)
              end,
            },
            win = {
              input = {
                keys = {
                  -- Alt+T 打开 Trouble 视图
                  ["<a-t>"] = {
                    "trouble_open",
                    mode = { "n", "i" },
                  },
                },
              },
            },
          },
        })
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
            { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
            { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
            { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter }) end, desc = "LSP Symbols", has = "documentSymbol" },
            { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
            { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", has = "callHierarchy/incomingCalls" },
            { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", has = "callHierarchy/outgoingCalls" },
          },
        },
      },
    },
  },
  -- ==================== Todo Comments 集成 ====================
  {
    "folke/todo-comments.nvim",
    -- 可选插件：仅在安装了 todo-comments 时启用
    optional = true,
    -- stylua: ignore
    -- Todo 注释快捷键：查找和管理任务标记
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },                                                -- 查看所有 Todo 注释
      { "<leader>sT", function () Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" }, -- 只查看特定的标记
    },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      table.insert(opts.dashboard.preset.keys, 3, {
        icon = " ",
        key = "p",
        desc = "Projects",
        action = ":lua Snacks.picker.projects()",
      })
    end,
  },
  {
    "goolord/alpha-nvim",
    optional = true,
    opts = function(_, dashboard)
      local button = dashboard.button("p", " " .. " Projects", [[<cmd> lua Snacks.picker.projects() <cr>]])
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
    end,
  },
  {
    "nvim-mini/mini.starter",
    optional = true,
    opts = function(_, opts)
      local items = {
        {
          name = "Projects",
          action = [[lua Snacks.picker.projects()]],
          section = string.rep(" ", 22) .. "Telescope",
        },
      }
      vim.list_extend(opts.items, items)
    end,
  },
  {
    "nvimdev/dashboard-nvim",
    optional = true,
    opts = function(_, opts)
      if not vim.tbl_get(opts, "config", "center") then
        return
      end
      local projects = {
        action = "lua Snacks.picker.projects()",
        desc = " Projects",
        icon = " ",
        key = "p",
      }

      projects.desc = projects.desc .. string.rep(" ", 43 - #projects.desc)
      projects.key_format = "  %s"

      table.insert(opts.config.center, 3, projects)
    end,
  },
  {
    "folke/flash.nvim",
    optional = true,
    specs = {
      {
        "folke/snacks.nvim",
        opts = {
          picker = {
            win = {
              input = {
                keys = {
                  ["<a-s>"] = { "flash", mode = { "n", "i" } },
                  ["s"] = { "flash" },
                },
              },
            },
            actions = {
              flash = function(picker)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                })
              end,
            },
          },
        },
      },
    },
  },
}
