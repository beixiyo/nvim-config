-- 项目选择函数：根据当前配置的选择器类型提供不同的项目选择界面
-- 功能说明：
-- 1. 根据选择器类型（Telescope 或 FZF）自动切换项目选择方式
-- 2. 提供丰富的快捷键操作：新建标签页、搜索、切换目录、删除项目
-- 3. 支持项目历史记录管理和项目目录切换
-- 4. 集成多种UI插件的启动器界面
local pick = nil

pick = function()
  -- 检查当前使用的选择器类型
  if LazyVim.pick.picker.name == "telescope" then
    -- 使用Telescope项目选择器
    return vim.cmd("Telescope projects")
  elseif LazyVim.pick.picker.name == "fzf" then
    -- 使用FZF项目选择器
    local fzf_lua = require("fzf-lua")         -- FZF Lua插件
    local project = require("project_nvim.project") -- 项目管理插件
    local history = require("project_nvim.utils.history") -- 项目历史
    local results = history.get_recent_projects() -- 获取最近项目列表
    local utils = require("fzf-lua.utils")    -- FZF工具函数

    -- 高亮验证函数
    local function hl_validate(hl)
      return not utils.is_hl_cleared(hl) and hl or nil
    end

    -- 从高亮创建ANSI字符串函数
    local function ansi_from_hl(hl, s)
      return utils.ansi_from_hl(hl_validate(hl), s)
    end

    -- FZF选项配置
    local opts = {
      fzf_opts = {
        ["--header"] = string.format(
          ":: <%s> to %s | <%s> to %s | <%s> to %s | <%s> to %s | <%s> to %s",
          ansi_from_hl("FzfLuaHeaderBind", "ctrl-t"),    -- Ctrl+T: 新标签页打开
          ansi_from_hl("FzfLuaHeaderText", "tabedit"),
          ansi_from_hl("FzfLuaHeaderBind", "ctrl-s"),    -- Ctrl+S: 实时搜索
          ansi_from_hl("FzfLuaHeaderText", "live_grep"),
          ansi_from_hl("FzfLuaHeaderBind", "ctrl-r"),    -- Ctrl+R: 最近文件
          ansi_from_hl("FzfLuaHeaderText", "oldfiles"),
          ansi_from_hl("FzfLuaHeaderBind", "ctrl-w"),    -- Ctrl+W: 切换目录
          ansi_from_hl("FzfLuaHeaderText", "change_dir"),
          ansi_from_hl("FzfLuaHeaderBind", "ctrl-d"),    -- Ctrl+D: 删除项目
          ansi_from_hl("FzfLuaHeaderText", "delete")
        ),
      },
      fzf_colors = true, -- 启用FZF颜色

      -- 动作配置
      actions = {
        -- 默认操作：在当前窗口打开项目文件
        ["default"] = {
          function(selected)
            fzf_lua.files({ cwd = selected[1] })
          end,
        },

        -- Ctrl+T: 新标签页打开项目
        ["ctrl-t"] = {
          function(selected)
            vim.cmd("tabedit")               -- 创建新标签页
            fzf_lua.files({ cwd = selected[1] })
          end,
        },

        -- Ctrl+S: 在项目中进行实时搜索
        ["ctrl-s"] = {
          function(selected)
            fzf_lua.live_grep({ cwd = selected[1] })
          end,
        },

        -- Ctrl+R: 查看项目的最近文件
        ["ctrl-r"] = {
          function(selected)
            fzf_lua.oldfiles({ cwd = selected[1] })
          end,
        },

        -- Ctrl+W: 切换到项目目录
        ["ctrl-w"] = {
          function(selected)
            local path = selected[1]
            local ok = project.set_pwd(path) -- 设置工作目录
            if ok then
              vim.api.nvim_win_close(0, false) -- 关闭FZF窗口
              LazyVim.info("Change project dir to " .. path)
            end
          end,
        },

        -- Ctrl+D: 删除项目（从历史记录中移除）
        ["ctrl-d"] = function(selected)
          local path = selected[1]
          local choice = vim.fn.confirm("Delete '" .. path .. "' project? ", "&Yes\n&No")
          if choice == 1 then
            history.delete_project({ value = path })
          end
          pick() -- 重新调用pick函数刷新列表
        end,
      },
    }

    -- 执行FZF项目选择器
    fzf_lua.fzf_exec(results, opts)
  end
end

return {
  -- 项目管理主插件
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = true, -- 手动模式：项目目录需要手动添加和切换
    },
    event = "VeryLazy", -- 延迟加载

    -- 插件配置
    config = function(_, opts)
      -- 初始化project_nvim插件
      require("project_nvim").setup(opts)

      -- 获取项目历史记录模块
      local history = require("project_nvim.utils.history")

      -- 重写删除项目函数，支持从recent_projects中完全移除项目
      history.delete_project = function(project)
        for k, v in pairs(history.recent_projects) do
          if v == project.value then
            history.recent_projects[k] = nil
            return
          end
        end
      end

      -- 延迟加载Telescope项目扩展
      LazyVim.on_load("telescope.nvim", function()
        require("telescope").load_extension("projects")
      end)
    end,
  },

  -- Telescope项目选择器集成
  {
    "nvim-telescope/telescope.nvim",
    optional = true, -- 可选插件
    keys = {
      { "<leader>fp", pick, desc = "Projects" }, -- <leader>fp 快捷键触发项目选择
    },
  },

  -- FZF项目选择器集成
  {
    "ibhagwan/fzf-lua",
    optional = true, -- 可选插件
    keys = {
      { "<leader>fp", pick, desc = "Projects" }, -- <leader>fp 快捷键触发项目选择
    },
  },

  -- Alpha启动器项目选择集成
  {
    "goolord/alpha-nvim",
    optional = true, -- 可选插件
    opts = function(_, dashboard)
      -- 创建项目按钮
      local button = dashboard.button("P", " " .. " Projects (util.project)", pick)
      button.opts.hl = "AlphaButtons"       -- 按钮高亮样式
      button.opts.hl_shortcut = "AlphaShortcut" -- 快捷键高亮样式
      -- 在按钮列表中插入到第4个位置
      table.insert(dashboard.section.buttons.val, 4, button)
    end,
  },

  -- Mini Starter项目选择集成
  {
    "nvim-mini/mini.starter",
    optional = true, -- 可选插件
    opts = function(_, opts)
      -- 创建项目菜单项
      local items = {
        {
          name = "Projects (util.project)",    -- 菜单项名称
          action = pick,                       -- 点击动作
          section = string.rep(" ", 22) .. "Telescope", -- 分组和缩进
        },
      }
      -- 将项目菜单项添加到现有的启动器项目中
      vim.list_extend(opts.items, items)
    end,
  },

  -- Dashboard项目选择集成
  {
    "nvimdev/dashboard-nvim",
    optional = true, -- 可选插件
    opts = function(_, opts)
      -- 检查是否有center配置
      if not vim.tbl_get(opts, "config", "center") then
        return
      end

      -- 创建项目按钮配置
      local projects = {
        action = pick,                           -- 点击动作
        desc = " Projects (util.project)",      -- 描述
        icon = " ",                           -- 图标
        key = "P",                              -- 快捷键
      }

      -- 计算空格的补充数量，确保对齐
      projects.desc = projects.desc .. string.rep(" ", 43 - #projects.desc)
      projects.key_format = "  %s"              -- 键格式化

      -- 在中心按钮列表中插入到第3个位置
      table.insert(opts.config.center, 3, projects)
    end,
  },

  -- Snacks项目选择集成
  {
    "folke/snacks.nvim",
    optional = true, -- 可选插件
    opts = function(_, opts)
      -- 在预设的仪表板快捷键中插入项目选择按钮
      table.insert(opts.dashboard.preset.keys, 3, {
        action = pick,                           -- 点击动作
        desc = "Projects (util.project)",      -- 描述
        icon = " ",                           -- 图标
        key = "P",                              -- 快捷键
      })
    end,
  },
}
