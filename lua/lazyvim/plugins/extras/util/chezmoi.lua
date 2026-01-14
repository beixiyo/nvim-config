-- LazyVim Chezmoi 配置文件
-- 功能：配置 Chezmoi dotfile 管理工具与 Neovim 的集成
-- 说明：Chezmoi 是一个强大的 dotfile 管理工具，此配置提供完整的 Neovim 集成体验

-- ========================================
-- Chezmoi 文件选择函数
-- ========================================

local pick_chezmoi = function()
  -- 根据当前选择的模糊查找器类型使用不同的 chezmoi 文件选择方式
  if LazyVim.pick.picker.name == "telescope" then
    -- 使用 Telescope 扩展进行 chezmoi 文件查找
    require("telescope").extensions.chezmoi.find_files()
  elseif LazyVim.pick.picker.name == "fzf" then
    -- 使用 FZF-Lua 进行 chezmoi 文件查找
    local fzf_lua = require("fzf-lua")

    -- 定义 FZF 动作映射
    local actions = {
      -- 回车键动作：执行 chezmoi edit 命令
      ["enter"] = function(selected)
        fzf_lua.actions.vimcmd_entry("ChezmoiEdit", selected, { cwd = vim.env.HOME })
      end,
    }

    -- 配置 FZF 文件查找
    fzf_lua.files({
      cmd = "chezmoi managed --include=files,symlinks",  -- 命令：查找已管理的 chezmoi 文件和符号链接
      actions = actions,                                   -- 动作映射
      cwd = vim.env.HOME,                                 -- 工作目录：用户主目录
      hidden = false,                                     -- 不显示隐藏文件
    })
  elseif LazyVim.pick.picker.name == "snacks" then
    -- 使用 Snacks 进行 chezmoi 文件查找
    local results = require("chezmoi.commands").list({
      args = {
        "--path-style", "absolute",     -- 使用绝对路径
        "--include", "files",           -- 包含普通文件
        "--exclude", "externals",       -- 排除外部文件
      },
    })
    local items = {}

    -- 将 chezmoi 文件转换为 Snacks 项目格式
    for _, czFile in ipairs(results) do
      table.insert(items, {
        text = czFile,  -- 显示文本
        file = czFile,  -- 文件路径
      })
    end

    ---@type snacks.picker.Config
    local opts = {
      items = items,  -- 项目列表

      -- 确认选择处理函数
      confirm = function(picker, item)
        picker:close()  -- 关闭选择器

        -- 执行 chezmoi edit 命令，启用文件监控
        require("chezmoi.commands").edit({
          targets = { item.text },  -- 编辑目标文件
          args = { "--watch" },     -- 启用监控模式
        })
      end,
    }

    -- 使用 Snacks 选择器显示文件列表
    Snacks.picker.pick(opts)
  end
end

-- ========================================
-- Chezmoi 插件配置
-- ========================================

return {
  -- ========================================
  -- 1. Chezmoi 语法高亮支持
  -- ========================================
  {
    -- highlighting for chezmoi files template files
    -- 注释：chezmoi 文件和模板文件的语法高亮支持
    -- 说明：为 chezmoi 配置文件和模板文件提供语法高亮

    "alker0/chezmoi.vim",

    -- 初始化函数
    init = function()
      -- 设置使用临时缓冲区（避免直接修改源文件）
      vim.g["chezmoi#use_tmp_buffer"] = 1

      -- 设置 chezmoi 源目录路径
      vim.g["chezmoi#source_dir_path"] = vim.env.HOME .. "/.local/share/chezmoi"
    end,
  },

  -- ========================================
  -- 2. Chezmoi Neovim 集成插件
  -- ========================================
  {
    "xvzc/chezmoi.nvim",

    -- 命令配置：只在执行 ChezmoiEdit 命令时加载
    cmd = { "ChezmoiEdit" },

    -- 键盘快捷键
    keys = {
      {
        "<leader>sz",  -- 前导键 + s (stuff) + z (chezmoi)
        pick_chezmoi,  -- 使用上述定义的 pick_chezmoi 函数
        desc = "Chezmoi",  -- 描述：打开 Chezmoi 管理界面
      },
    },

    -- 插件选项配置
    opts = {
      -- 编辑配置
      edit = {
        watch = false,  -- 不自动监控文件变化
        force = false,  -- 不强制覆盖
      },

      -- 通知配置
      notification = {
        on_open = true,    -- 文件打开时显示通知
        on_apply = true,   -- 应用更改时显示通知
        on_watch = false,  -- 监控时不显示通知
      },

      -- Telescope 配置
      telescope = {
        select = { "<CR>" },  -- 回车键选择
      },
    },

    -- 初始化函数
    init = function()
      -- 注释：run chezmoi edit on file enter
      -- 说明：在进入 chezmoi 文件时自动执行编辑监控

      -- 创建自动命令：文件读取和新建时触发
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { vim.env.HOME .. "/.local/share/chezmoi/*" },  -- 监听 chezmoi 目录下的文件
        callback = function()
          -- 延迟执行 chezmoi 编辑监控功能
          vim.schedule(require("chezmoi.commands.__edit").watch)
        end,
      })
    end,
  },

  -- ========================================
  -- 3. Dashboard-nvim 集成配置
  -- ========================================
  {
    "nvimdev/dashboard-nvim",

    -- 可选依赖：只有安装了 dashboard-nvim 才生效
    optional = true,

    -- 选项配置函数
    opts = function(_, opts)
      -- 定义 Chezmoi 配置项目
      local projects = {
        action = pick_chezmoi,       -- 执行动作：调用 pick_chezmoi 函数
        desc = "  Config",           -- 描述文字
        icon = "",                 -- 图标
        key = "c",                   -- 快捷键
      }

      -- 调整描述文字宽度，保持对齐
      projects.desc = projects.desc .. string.rep(" ", 43 - #projects.desc)
      projects.key_format = "  %s"  -- 快捷键格式化

      -- 注释：remove lazyvim config property
      -- 说明：移除默认的 LazyVim 配置属性，避免冲突

      -- 遍历现有的项目，移除键为 "c" 的配置
      for i = #opts.config.center, 1, -1 do
        if opts.config.center[i].key == "c" then
          table.remove(opts.config.center, i)  -- 移除冲突的配置
        end
      end

      -- 在第 5 个位置插入 Chezmoi 配置项目
      table.insert(opts.config.center, 5, projects)
    end,
  },

  -- ========================================
  -- 4. Snacks 集成配置
  -- ========================================
  {
    "folke/snacks.nvim",

    -- 可选依赖
    optional = true,

    -- 选项配置函数
    opts = function(_, opts)
      -- 定义 chezmoi 条目
      local chezmoi_entry = {
        icon = " ",        -- 图标
        key = "c",          -- 快捷键
        desc = "Config",    -- 描述
        action = pick_chezmoi,  -- 执行动作
      }
      local config_index

      -- 查找并移除现有的配置条目
      for i = #opts.dashboard.preset.keys, 1, -1 do
        if opts.dashboard.preset.keys[i].key == "c" then
          table.remove(opts.dashboard.preset.keys, i)  -- 移除冲突的配置
          config_index = i  -- 记录插入位置
          break
        end
      end

      -- 在原位置插入 chezmoi 条目
      table.insert(opts.dashboard.preset.keys, config_index, chezmoi_entry)
    end,
  },

  -- ========================================
  -- 5. 文件类型图标配置
  -- ========================================
  {
    -- 注释：Filetype icons
    -- 说明：为 chezmoi 相关文件类型配置专用图标

    "nvim-mini/mini.icons",

    -- 文件图标选项配置
    opts = {
      file = {
        -- Chezmoi 配置文件图标
        [".chezmoiignore"] = { glyph = "", hl = "MiniIconsGrey" },  -- 忽略文件
        [".chezmoiremove"] = { glyph = "", hl = "MiniIconsGrey" },  -- 删除文件
        [".chezmoiroot"] = { glyph = "", hl = "MiniIconsGrey" },    -- 根目录标识
        [".chezmoiversion"] = { glyph = "", hl = "MiniIconsGrey" }, -- 版本文件

        -- 模板文件图标（按脚本类型区分）
        ["bash.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },        -- Bash 模板
        ["json.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },        -- JSON 模板
        ["ps1.tmpl"] = { glyph = "󰨊", hl = "MiniIconsGrey" },         -- PowerShell 模板
        ["sh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },          -- Shell 模板
        ["toml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },        -- TOML 模板
        ["yaml.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },        -- YAML 模板
        ["zsh.tmpl"] = { glyph = "", hl = "MiniIconsGrey" },         -- Zsh 模板
      },
    },
  },
}
