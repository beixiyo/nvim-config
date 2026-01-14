-- ============================================================================
-- LazyVim 本地配置 - lazy.nvim 初始化
-- ============================================================================
-- 这个文件负责配置 lazy.nvim 插件管理器
--
-- 什么是 lazy.nvim？
--   lazy.nvim 是一个 Neovim 插件管理器，类似于 npm（Node.js）、pip（Python）
--   它的作用是帮你自动下载、安装、更新和管理 Neovim 插件
--
-- 主要功能：
--   1. 自动安装 lazy.nvim（如果不存在）- 首次使用时自动下载
--   2. 配置 LazyVim 使用本地目录而不是从 GitHub 下载 - 这样你可以直接修改代码
--   3. 初始化插件系统 - 告诉 lazy.nvim 要加载哪些插件
-- ============================================================================

-- ============================================================================
-- 第一步：查找并加载 lazy.nvim 插件管理器
-- ============================================================================
-- 作用：在启动 Neovim 时，首先检查 lazy.nvim 是否已安装，如果没有则自动安装
--
-- 为什么需要这一步？
--   lazy.nvim 本身也是一个插件，但它很特殊：它是管理其他插件的"插件管理器"
--   所以我们需要先确保 lazy.nvim 存在，才能用它来管理其他插件

-- 定义 lazy.nvim 的安装路径
-- vim.fn.stdpath("data") 返回 Neovim 的数据目录，通常是：
--   Windows: ~/AppData/Local/nvim-data
--   Linux/Mac: ~/.local/share/nvim
-- 所以 lazypath 的完整路径是：~/AppData/Local/nvim-data/lazy/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 检查 lazy.nvim 是否已安装
-- (vim.uv or vim.loop).fs_stat() 用于检查文件或目录是否存在
-- vim.uv 是 Neovim 0.10+ 的新 API，vim.loop 是旧版本的 API
-- 使用 (vim.uv or vim.loop) 是为了兼容不同版本的 Neovim
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- 如果 lazy.nvim 不存在，从 GitHub 克隆它
  -- 这是 lazy.nvim 的官方仓库地址
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"

  -- 使用 git clone 命令下载 lazy.nvim
  -- --filter=blob:none: 只下载必要的文件，不下载历史记录，加快下载速度
  -- --branch=stable: 下载稳定版本，而不是开发版本
  -- lazyrepo: 源仓库地址
  -- lazypath: 目标安装路径
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

  -- 检查 git clone 是否成功
  -- vim.v.shell_error 不为 0 表示命令执行失败
  if vim.v.shell_error ~= 0 then
    -- 如果下载失败，显示错误信息并退出
    -- 这样用户就知道哪里出了问题，而不是默默失败
    vim.api.nvim_echo({
      { "❌ 错误：无法克隆 lazy.nvim\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\n按任意键退出...", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()  -- 等待用户按键
    os.exit(1)        -- 退出 Neovim
  end
end

-- 将 lazy.nvim 添加到 runtimepath（运行时路径）
-- 作用：告诉 Neovim 在哪里可以找到 lazy.nvim 的代码
--
-- 什么是 runtimepath？
--   runtimepath 是 Neovim 查找配置文件和插件的地方，类似于操作系统的 PATH 环境变量
--   当你在代码中使用 require("lazy") 时，Neovim 会在 runtimepath 中查找 lazy 模块
--
-- 为什么使用 prepend 而不是 append？
--   prepend 是添加到列表的最前面，这样 Neovim 会优先从这里加载 lazy.nvim
--   如果系统中有多个 lazy.nvim，会优先使用我们指定的这个版本
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 第二步：配置 lazy.nvim
-- ============================================================================
-- 作用：告诉 lazy.nvim 要加载哪些插件，以及如何加载它们
--
-- require("lazy").setup() 是 lazy.nvim 的初始化函数
-- 它接收一个配置表，包含所有插件的配置信息

-- ============================================================================
-- 根据运行环境决定加载哪些插件
-- ============================================================================
local spec = {}

if vim.g.vscode then
  -- ========================================================================
  -- VSCode 环境：只加载 plugins/vscode/init.lua 中定义的插件
  -- ========================================================================
  -- 作用：在 VSCode 中使用 Neovim 插件时，只加载必要的插件，避免加载多余的插件
  --
  -- 为什么需要单独配置？
  --   VSCode 已经提供了很多功能（如 LSP、文件浏览器等），不需要重复加载
  --   这样可以加快启动速度，避免插件冲突
  --
  -- 为什么使用 plugins.vscode 而不是 vscode？
  --   VSCode Neovim 插件本身已经注册了 "vscode" 模块名，使用 import = "vscode" 会冲突
  --   所以我们将配置放在 lua/plugins/vscode/init.lua，使用 import = "plugins.vscode"
  --
  -- 工作原理：
  --   1. 检测 vim.g.vscode 变量（VSCode Neovim 插件会自动设置）
  --   2. 如果在 VSCode 环境下，只加载 lua/plugins/vscode/init.lua 中定义的插件
  --
  -- 如何添加新插件？
  --   在 lua/plugins/vscode/init.lua 中添加插件配置
  spec = {
    { import = "plugins.vscode" },
  }
  vim.g.mapleader = vim.g.mapleader or " "
  vim.g.maplocalleader = vim.g.maplocalleader or "\\"
else
  -- ========================================================================
  -- 普通 Neovim 环境：加载完整的 LazyVim 配置
  -- ========================================================================
  spec = {
    -- ========================================================================
    -- 配置 1：导入 LazyVim 的所有插件配置
    -- ========================================================================
    -- 作用：告诉 lazy.nvim 要加载 LazyVim 框架提供的所有插件
    --
    -- "LazyVim/LazyVim" 是什么？
    --   这是 LazyVim 框架的核心插件，它定义了 LazyVim 的所有默认插件
    --   格式是 "GitHub用户名/仓库名"
    --
    -- import = "lazyvim.plugins" 是什么意思？
    --   这告诉 lazy.nvim：从 LazyVim 插件中导入 "lazyvim.plugins" 模块
    --   这个模块包含了 LazyVim 推荐的所有插件列表（如 treesitter、lsp、telescope 等）
    --   相当于说："加载 LazyVim 推荐的所有插件"
    --
    -- 注意：此时 lazy.nvim 会尝试从 GitHub 下载 LazyVim/LazyVim
    --       但我们在下一个配置中会覆盖这个行为，改为使用本地目录
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ========================================================================
    -- 配置 2：覆盖 LazyVim 的下载路径，改为使用本地目录
    -- ========================================================================
    -- 作用：告诉 lazy.nvim 不要从 GitHub 下载 LazyVim，而是使用本地的 LazyVim 代码
    --
    -- 为什么需要这个配置？
    --   默认情况下，lazy.nvim 会从 GitHub 下载所有插件（包括 LazyVim）
    --   但我们的目标是使用本地的 LazyVim 代码（在 lua/lazyvim/ 目录下）
    --   这样你就可以直接修改 LazyVim 的代码，而不需要每次都从 GitHub 下载
    --
    -- 工作原理：
    --   lazy.nvim 会按照 spec 列表的顺序处理插件配置
    --   当遇到同名插件（都是 "LazyVim/LazyVim"）时，后面的配置会覆盖前面的配置
    --   所以这个配置会覆盖上面的配置，将下载路径改为本地目录
    --
    -- dir 参数的作用：
    --   dir 指定插件的本地路径，而不是从 GitHub 下载
    --   vim.fn.stdpath("config") 返回你的 Neovim 配置目录，通常是：
    --     Windows: ~/AppData/Local/nvim
    --     Linux/Mac: ~/.config/nvim
    --   所以 LazyVim 会从 ~/AppData/Local/nvim/lua/lazyvim/ 加载代码
    {
      "LazyVim/LazyVim",
      dir = vim.fn.stdpath("config"), -- 使用本地配置目录，而不是从 GitHub 下载
    },

    -- ========================================================================
    -- 配置 3：加载用户自定义插件
    -- ========================================================================
    -- 作用：加载你在 lua/plugins/ 目录下定义的自定义插件
    --
    -- 什么是用户自定义插件？
    --   除了 LazyVim 提供的插件外，你可能还想安装其他插件
    --   这些插件的配置放在 lua/plugins/ 目录下（如 lua/plugins/example.lua）
    --
    -- import = "plugins" 是什么意思？
    --   这告诉 lazy.nvim：从 lua/plugins/ 目录导入所有插件配置
    --   lazy.nvim 会自动扫描 lua/plugins/*.lua 文件，加载其中定义的插件
    --
    -- 为什么放在最后？
    --   这样你的自定义插件配置可以覆盖 LazyVim 的默认配置
    --   例如，如果你想修改某个 LazyVim 插件的设置，可以在 lua/plugins/ 中重新配置
    { import = "plugins" },
  }
end

require("lazy").setup({
  -- spec 是 "specification"（规格说明）的缩写
  -- 这里定义了所有要加载的插件列表
  spec = spec,
  -- ========================================================================
  -- defaults：插件的默认配置
  -- ========================================================================
  -- 作用：为所有插件设置默认的配置选项
  -- 这些选项会被应用到所有插件，除非插件自己的配置中明确覆盖
  defaults = {
    -- lazy：是否延迟加载插件
    --   false = 插件在 Neovim 启动时立即加载（默认行为）
    --   true  = 插件延迟加载，只在需要时才加载（可以加快启动速度）
    --
    -- 为什么设置为 false？
    --   对于初学者，立即加载更容易理解，也更容易调试问题
    --   如果设置为 true，插件会在你第一次使用时才加载，可能会让你困惑
    --   等熟悉后，可以改为 true 来优化启动速度
    lazy = false,

    -- version：插件的版本控制方式
    --   false = 始终使用最新的 git commit（推荐）
    --   "*"   = 使用最新的稳定版本（如果有发布版本）
    --
    -- 为什么建议使用 false？
    --   很多 Neovim 插件只维护 git 仓库，不发布版本
    --   即使有发布版本，也可能过时，使用最新代码更安全
    --   使用 false 可以确保你总是使用最新的功能和修复
    version = false, -- 始终使用最新的 git commit
  },

  -- ========================================================================
  -- install：首次安装插件时的行为
  -- ========================================================================
  -- 作用：配置首次安装插件后要做什么
  install = {
    -- colorscheme：安装完插件后，自动设置的颜色主题
    --   如果这些主题插件已安装，Neovim 会自动应用第一个可用的主题
    --   这样首次安装后，界面不会是一片空白
    --   tokyonight：流行的深色主题
    --   habamax：Neovim 内置的主题（如果上面的主题都不可用，会使用这个）
    colorscheme = { "tokyonight", "habamax" },
  },

  -- ========================================================================
  -- checker：插件更新检查器
  -- ========================================================================
  -- 作用：定期检查插件是否有更新
  checker = {
    enabled = true,  -- 启用更新检查
    --   设置为 true 后，lazy.nvim 会在后台定期检查插件更新
    --   你可以使用 :Lazy 命令查看哪些插件有更新

    notify = false,  -- 不显示更新通知
    --   设置为 false 后，即使有更新也不会弹出通知
    --   你可以随时使用 :Lazy 命令查看更新，而不会被通知打扰
    --   如果想及时知道更新，可以改为 true
  },

  -- ========================================================================
  -- performance：性能优化配置
  -- ========================================================================
  -- 作用：优化 Neovim 的启动速度和运行性能
  performance = {
    rtp = {
      -- disabled_plugins：禁用的内置插件列表
      --   作用：禁用一些 Neovim 内置但你可能不需要的插件，加快启动速度
      --
      --   什么是内置插件？
      --     Neovim 自带了一些插件（如 gzip、tar、zip 等），用于处理特定文件类型
      --     如果你不需要这些功能，可以禁用以提升性能
      --
      --   如何知道是否需要某个插件？
      --     如果禁用后遇到问题（如无法打开某些文件），可以取消注释对应的插件
      disabled_plugins = {
        "gzip",        -- 禁用 gzip 压缩文件支持（很少用到）
        -- "matchit",  -- 匹配括号/标签（如果禁用，% 键可能不工作）
        -- "matchparen", -- 高亮匹配的括号（如果禁用，括号高亮会消失）
        -- "netrwPlugin", -- 文件浏览器（如果禁用，:Explore 命令不可用）
        "tarPlugin",   -- 禁用 tar 压缩文件支持（很少用到）
        "tohtml",      -- 禁用 HTML 导出功能（很少用到）
        "tutor",       -- 禁用教程插件（学习完成后可以禁用）
        "zipPlugin",   -- 禁用 zip 压缩文件支持（很少用到）
      },
    },
  },
})

-- ============================================================================
-- VSCode 环境下手动加载 LazyVim 配置
-- ============================================================================
if vim.g.vscode then
  -- 在 VSCode 环境下，由于没有加载 LazyVim 插件，需要手动加载配置
  -- 这样可以确保 options.lua 中的配置（如 leader 键、timeoutlen 等）能够生效
  -- 同时也会加载 keymaps.lua 中的用户自定义快捷键配置

  -- 确保 LazyVim 工具函数可用
  _G.LazyVim = _G.LazyVim or require("lazyvim.util")

  -- 手动加载 LazyVim 的 options 配置
  local function load_lazyvim_options()
    -- 直接 require 配置模块，因为它们在本地文件系统中
    -- 先加载 LazyVim 的默认 options 配置
    local ok1 = pcall(require, "lazyvim.config.options")
    -- 再加载用户自定义的 options 配置（如果有的话）
    local ok2 = pcall(require, "config.options")

    -- 如果 LazyVim 的 config 模块可用，尝试使用它的 load 函数
    -- 这样可以触发相关的事件和完整的加载流程
    local ok3, lazyvim_config = pcall(require, "lazyvim.config")
    if ok3 and lazyvim_config and lazyvim_config.load then
      -- 注意：这里可能会失败，因为模块可能不在 lazy 缓存中
      -- 但我们已经通过直接 require 加载了配置，所以不影响
      pcall(function()
        lazyvim_config.load("options")
      end)
    end

    return ok1 or ok2
  end

  -- 手动加载用户自定义的 keymaps 配置
  local function load_user_keymaps()
    -- 注意：在 VSCode 环境下，我们不加载 LazyVim 的默认 keymaps
    -- 原因：
    -- 1. LazyVim 的 keymaps 使用了 LazyVim.safe_keymap_set，它依赖 lazy.core.handler 和 Snacks
    -- 2. 这些依赖在 VSCode 环境下可能还没有完全初始化，会导致循环依赖错误
    -- 3. LazyVim 的默认 keymaps 可能依赖其他插件，在 VSCode 环境下不需要
    --
    -- 我们只加载用户自定义的 keymaps（config.keymaps），它使用 vim.keymap.set，不依赖其他插件
    local ok = pcall(require, "config.keymaps")

    -- 手动触发 LazyVimKeymaps 事件，通知其他模块 keymaps 已加载
    pcall(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "LazyVimKeymaps", modeline = false })
    end)

    return ok
  end

  -- 加载配置
  local loaded = load_lazyvim_options()
  local keymaps_loaded = load_user_keymaps()

  -- 验证配置是否加载成功
  local function verify_options_loaded()
    local checks = {
      -- 检查 leader 键是否设置为空格（options.lua 第 9 行）
      leader = {
        check = function() return vim.g.mapleader == " " end,
        expected = "空格键 ( )",
        actual = function() return vim.g.mapleader or "未设置" end,
      },
      -- 检查 timeoutlen 是否在 VSCode 模式下设置为 1000（options.lua 第 146 行）
      timeoutlen = {
        check = function()
          return vim.g.vscode and vim.o.timeoutlen == 1000 or (not vim.g.vscode and vim.o.timeoutlen == 300)
        end,
        expected = vim.g.vscode and "1000ms (VSCode 模式)" or "300ms",
        actual = function() return tostring(vim.o.timeoutlen) .. "ms" end,
      },
      -- 检查其他关键配置项
      autoformat = {
        check = function() return vim.g.autoformat ~= nil end,
        expected = "已设置",
        actual = function() return vim.g.autoformat and "true" or "false" end,
      },
      termguicolors = {
        check = function() return vim.o.termguicolors == true end,
        expected = "true",
        actual = function() return tostring(vim.o.termguicolors) end,
      },
      -- 检查 relativenumber 是否启用（options.lua 第 126 行）
      relativenumber = {
        check = function() return vim.o.relativenumber == true end,
        expected = "true",
        actual = function() return tostring(vim.o.relativenumber) end,
      },
    }

    local all_passed = true
    local messages = {}

    for key, check_info in pairs(checks) do
      local passed = check_info.check()
      if passed then
        table.insert(messages, string.format("✓ %s: %s", key, check_info.expected))
      else
        table.insert(messages, string.format("✗ %s: 期望 %s，实际 %s", key, check_info.expected, check_info.actual()))
        all_passed = false
      end
    end

    return all_passed, messages
  end

  -- 执行验证
  local all_passed, messages = verify_options_loaded()

  -- 输出验证结果
  local notify_messages = {}
  if loaded then
    if all_passed then
      table.insert(notify_messages, "✓ Options 配置加载成功")
      table.insert(notify_messages, table.concat(messages, "\n"))
    else
      table.insert(notify_messages, "⚠ Options 配置已加载，但部分配置项未生效")
      table.insert(notify_messages, table.concat(messages, "\n"))
    end
  else
    table.insert(notify_messages, "✗ Options 配置加载失败！请检查配置文件是否存在。")
  end

  -- 添加 keymaps 加载状态
  if keymaps_loaded then
    table.insert(notify_messages, "✓ Keymaps 配置加载成功")
  else
    table.insert(notify_messages, "✗ Keymaps 配置加载失败！请检查配置文件是否存在。")
  end

  -- 发送通知
  local all_configs_ok = loaded and keymaps_loaded and all_passed
  local notify_level = all_configs_ok and vim.log.levels.INFO or (loaded and keymaps_loaded and vim.log.levels.WARN or vim.log.levels.ERROR)
  vim.notify(table.concat(notify_messages, "\n"), notify_level, {
    title = "VSCode 环境配置加载",
  })

  -- 创建一个命令来手动验证配置
  vim.api.nvim_create_user_command("LazyVimVerifyOptions", function()
    local all_passed, messages = verify_options_loaded()
    local status = all_passed and "成功" or "部分失败"
    local level = all_passed and vim.log.levels.INFO or vim.log.levels.WARN
    vim.notify(string.format("LazyVim Options 配置验证 %s：\n%s", status, table.concat(messages, "\n")), level, {
      title = "配置验证",
    })
  end, { desc = "验证 LazyVim options 配置是否加载成功" })
end

-- ============================================================================
-- 配置完成！
-- ============================================================================
-- 现在 lazy.nvim 已经配置好了，它会：
--   1. 自动管理所有插件的下载、安装和更新
--   2. 从本地目录加载 LazyVim（而不是从 GitHub 下载）
--   3. 加载你在 lua/plugins/ 中定义的自定义插件
--
-- 常用命令：
--   :Lazy          - 打开插件管理界面，查看所有插件
--   :Lazy install  - 安装所有缺失的插件
--   :Lazy update   - 更新所有插件到最新版本
--   :Lazy clean    - 删除未使用的插件
--   :Lazy reload    - 重新加载插件配置（修改配置后使用）
