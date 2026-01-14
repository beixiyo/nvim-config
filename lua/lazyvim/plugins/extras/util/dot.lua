-- Dotfiles：针对个人配置文件的语言支持插件
-- 功能说明：
-- 1. 为各种个人配置文件（dotfiles）提供语法高亮和语言支持
-- 2. 支持多种常用配置文件的类型检测和语法解析
-- 3. 提供LSP（语言服务器协议）支持，提升配置文件编辑体验
-- 4. 智能检测系统中已安装的工具，并相应配置支持

---@type string
local xdg_config = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config" -- XDG配置目录路径

---@param path string
--- 检测指定路径是否存在（用于判断系统中是否安装了特定工具）
local function have(path)
  return vim.uv.fs_stat(xdg_config .. "/" .. path) ~= nil
end

return {
  recommended = true,  -- 推荐安装
  desc = "Language support for dotfiles", -- 描述：dotfiles语言支持

  -- LSP配置：为Bash配置文件提供语言服务器支持
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {}, -- Bash语言服务器配置（用于shell脚本和配置文件）
      },
    },
  },

  -- Mason配置：确保安装shellcheck工具
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "shellcheck" } }, -- 安装shellcheck进行Shell脚本静态分析
  },

  -- Tree-sitter配置：添加对各种配置文件的语法解析支持
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- 添加语言到确保安装列表
      local function add(lang)
        if type(opts.ensure_installed) == "table" then
          table.insert(opts.ensure_installed, lang)
        end
      end

      -- 文件类型检测配置
      vim.filetype.add({
        -- 扩展名映射
        extension = {
          rasi = "rasi", -- Rofi/Wofi配置文件的扩展名
          rofi = "rasi", -- 旧版rofi配置文件扩展名
          wofi = "rasi", -- wofi配置文件扩展名
        },

        -- 文件名映射
        filename = {
          ["vifmrc"] = "vim", -- vifm配置文件映射为vim类型
        },

        -- 模式匹配映射（根据文件路径和名称匹配文件类型）
        pattern = {
          [".*/waybar/config"] = "jsonc",      -- Waybar配置文件（JSON with comments）
          [".*/mako/config"] = "dosini",       -- Mako通知守护进程配置
          [".*/kitty/.+%.conf"] = "kitty",     -- Kitty终端配置文件
          [".*/hypr/.+%.conf"] = "hyprlang",   -- Hyprland配置文件
          ["%.env%.[%w_.-]+"] = "sh",          -- .env.*环境变量文件
        },
      })

      -- 注册kitty语言为bash方言
      vim.treesitter.language.register("bash", "kitty")

      -- 添加基本配置语言支持
      add("git_config") -- Git配置文件支持

      -- 根据系统中已安装的工具添加相应语言支持
      if have("hypr") then
        add("hyprlang") -- Hyprland窗口管理器配置
      end

      if have("fish") then
        add("fish") -- Fish shell配置
      end

      if have("rofi") or have("wofi") then
        add("rasi") -- Rofi/Wofi配置文件
      end
    end,
  },
}
