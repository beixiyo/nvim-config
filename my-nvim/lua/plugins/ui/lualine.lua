-- ================================
-- 底部状态栏（statusline）
-- ================================
-- 展示：模式、Git 分支、路径、诊断、diff、进度、时间等
-- 图标使用 utils.icons 统一风格

local utils = require("utils")

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件
  end,
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      -- 启动页（如 alpha）先隐藏状态栏，等 lualine 加载后再恢复
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    -- 性能优化：不需要 lualine 的 require 机制
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    vim.o.laststatus = vim.g.lualine_laststatus
    local icons = utils.icons

    -- LSP 分析/进度状态（不依赖额外插件）
    -- 说明：
    -- - “加载中/进度”依赖 LSP 服务器是否发送 `$/progress`，很多服务器不会发，所以经常为空
    -- - 因此这里做了回退：没 progress 时显示当前 buffer 已挂载的 LSP 客户端（代表已加载）
    -- 常见配置/声明式文件：不展示 LSP 状态（避免 NoLSP 干扰）
    local lsp_hidden_fts = {
      "json", "jsonc", "yaml", "yml", "toml",
      "ini", "dosini", "conf", "config",
      "gitconfig", "gitignore", "gitattributes",
      "sshconfig", "properties", "dotenv",
      'md', 'markdown', 'txt'
    }

    local function lsp_should_show()
      -- 非普通文件缓冲区（nofile/terminal/help/prompt/quickfix 等）不显示
      if vim.bo.buftype ~= "" then
        return false
      end

      -- 没有文件/没有 filetype（例如启动后的空白 buffer）不显示
      if vim.api.nvim_buf_get_name(0) == "" and (vim.bo.filetype == nil or vim.bo.filetype == "") then
        return false
      end

      -- 配置型 filetype 不显示
      return not vim.tbl_contains(lsp_hidden_fts, vim.bo.filetype)
    end

    local function lsp_progress()
      local ok, msgs = pcall(function()
        return vim.lsp.util.get_progress_messages()
      end)
      if ok and type(msgs) == "table" and #msgs > 0 then
        local m = msgs[1] or {}
        local parts = {}
        local name = m.name or m.title or ""
        local message = m.message or ""
        local percentage = m.percentage and (tostring(m.percentage) .. "%%") or ""
        if name ~= "" then table.insert(parts, name) end
        if message ~= "" then table.insert(parts, message) end
        if percentage ~= "" then table.insert(parts, percentage) end
        return table.concat(parts, " ")
      end
      if type(vim.lsp.status) == "function" then
        return vim.lsp.status() or ""
      end
      return ""
    end

    local function lsp_clients()
      local clients = {}
      if vim.lsp.get_clients then
        clients = vim.lsp.get_clients({ bufnr = 0 })
      elseif vim.lsp.get_active_clients then
        clients = vim.lsp.get_active_clients({ bufnr = 0 })
      end

      if type(clients) ~= "table" or vim.tbl_isempty(clients) then
        return ""
      end

      local names = {}
      for _, c in ipairs(clients) do
        if c and c.name and c.name ~= "" and c.name ~= "copilot" then
          table.insert(names, c.name)
        end
      end
      if #names == 0 then
        return ""
      end

      table.sort(names)
      local max = 2
      if #names > max then
        return table.concat({ names[1], names[2] }, ",") .. " +" .. tostring(#names - max)
      end
      return table.concat(names, ",")
    end

    return {
      options = {
        theme = "auto",
        globalstatus = true, -- 状态栏始终整行显示在最底部左侧
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        -- 圆角分隔符（需 Nerd Font / Powerline 字体）
        component_separators = { left = "\u{e0b5}", right = "\u{e0b7}" },
        section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
      },
      sections = {
        -- 左侧：当前模式
        lualine_a = { "mode" },
        -- 左侧：Git 分支（点击打开分支查看）
        lualine_b = {
          {
            "branch",
            on_click = function(_, button)
              if button == "l" then
                utils.lualine.open_branch_view()
              end
            end,
          },
        },

        lualine_c = {
          -- 项目根目录（utils.lualine.root_dir）
          utils.lualine.root_dir(),
          {
            -- LSP 诊断：错误/警告/信息/提示
            "diagnostics",
            symbols = {
              error = icons.diagnostics_error .. " ",
              warn = icons.diagnostics_warn .. " ",
              info = icons.diagnostics_info .. " ",
              hint = icons.diagnostics_hint .. " ",
            },
          },
          -- 当前文件类型图标（仅图标）
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          -- 友好路径展示（点击复制 相对路径:行号）
          {
            utils.lualine.pretty_path(),
            on_click = function(_, button)
              if button == "l" then
                utils.lualine.copy_path_line()
              end
            end,
          },
        },

        lualine_x = {
          -- 性能 profiler 状态（Snacks）
          Snacks.profiler.status(),
          -- LSP 分析/进度状态：例如 indexing / diagnostics / formatting 等（若无则不显示）
          {
            function()
              if not lsp_should_show() then
                return ""
              end

              local p = lsp_progress()
              if p ~= "" then
                return icons.lsp .. " " .. p
              end

              local c = lsp_clients()
              if c ~= "" then
                return icons.lsp .. " " .. c
              end

              return icons.lsp .. " NoLSP"
            end,
            cond = function()
              return lsp_should_show()
            end,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          -- Noice：命令行/模式提示
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
          },
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          {
            -- DAP 调试状态
            function() return icons.dap_status .. " " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          {
            -- Lazy 更新提示
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
          {
            -- Git diff 统计（来自 gitsigns buffer 状态）
            "diff",
            symbols = {
              added = icons.git_added .. " ",
              modified = icons.git_modified .. " ",
              removed = icons.git_removed .. " ",
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          -- 进度 + 光标位置（点击行列号复制 相对路径:行号）
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          {
            "location",
            padding = { left = 0, right = 1 },
            on_click = function(_, button)
              if button == "l" then
                utils.lualine.copy_path_line()
              end
            end,
          },
        },
        lualine_z = {
          -- 右侧时钟（点击复制 yyyy-MM-dd HH:mm:ss）
          {
            function()
              return icons.clock .. " " .. os.date("%R")
            end,
            on_click = function(_, button)
              if button == "l" then
                utils.lualine.copy_datetime()
              end
            end,
          },
        },
      },
      extensions = { "lazy", "fzf" },
    }
  end,
}
