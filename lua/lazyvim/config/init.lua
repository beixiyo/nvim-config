_G.LazyVim = require("lazyvim.util")

---@class LazyVimConfig: LazyVimOptions
local M = {}

M.version = "15.13.0" -- x-release-please-version
LazyVim.config = M

---@class LazyVimOptions
-- LazyVim 的默认配置选项
local defaults = {
  -- 配色方案设置，可以是字符串（如 "catppuccin"）或加载配色方案的函数
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load() -- 默认使用 tokyonight 主题
  end,
  -- 是否加载默认设置
  defaults = {
    autocmds = true, -- 加载 lazyvim.config.autocmds 中的自动命令（自动执行某些操作）
    keymaps = true, -- 加载 lazyvim.config.keymaps 中的按键映射（快捷键设置）
    -- lazyvim.config.options 不能在这里配置，因为它在 lazyvim 设置之前加载
    -- 如果想禁用加载选项，在 init.lua 顶部添加 package.loaded["lazyvim.config.options"] = true
  },
  -- 新闻通知设置 - 控制是否显示更新日志
  news = {
    -- 启用时，当 NEWS.md 更改时会显示它
    -- 这仅包含重要的新功能和破坏性更改
    lazyvim = true,
    -- 同样但针对 Neovim 的 news.txt
    neovim = false,
  },
  -- 其他插件使用的图标
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = " ",
      gh = " ",
      ["markdown.gh"] = " ",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>?
  -- 符号过滤器，控制哪些类型的符号在搜索结果中显示
  kind_filter = {
    default = { -- 默认显示的符号类型
      "Class",      -- 类
      "Constructor", -- 构造函数
      "Enum",       -- 枚举
      "Field",      -- 字段
      "Function",   -- 函数
      "Interface",  -- 接口
      "Method",     -- 方法
      "Module",     -- 模块
      "Namespace",  -- 命名空间
      "Package",    -- 包
      "Property",   -- 属性
      "Struct",     -- 结构体
      "Trait",      -- 特质
    },
    markdown = false, -- markdown 文件中不显示符号
    help = false,     -- help 文件中不显示符号
    -- 可以为每种文件类型指定不同的过滤器
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- 移除 package，因为 luals 将其用于控制流结构
      "Property",
      "Struct",
      "Trait",
    },
  },
}

M.json = {
  version = 8,
  loaded = false,
  path = vim.g.lazyvim_json or vim.fn.stdpath("config") .. "/lazyvim.json",
  data = {
    version = nil, ---@type number?
    install_version = nil, ---@type number?
    news = {}, ---@type table<string, string>
    extras = {}, ---@type string[]
  },
}

-- JSON 配置加载函数
-- 这个函数负责加载 LazyVim 的配置文件 (lazyvim.json)
-- 该文件记录了用户的选择，如已安装的插件、使用的颜色主题等
function M.json.load()
  M.json.loaded = true
  local f = io.open(M.json.path, "r")
  if f then
    local data = f:read("*a")
    f:close()
    -- 尝试解码 JSON 数据，使用 pcall 来安全地处理可能的错误
    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
    if ok then
      -- 如果解码成功，将读取的数据与默认数据合并
      M.json.data = vim.tbl_deep_extend("force", M.json.data, json or {})
      -- 检查版本是否匹配，如果不匹配则执行迁移
      if M.json.data.version ~= M.json.version then
        LazyVim.json.migrate()
      end
    end
  else
    -- 如果配置文件不存在，创建默认的安装版本记录
    M.json.data.install_version = M.json.version
  end
end

---@type LazyVimOptions
local options
local lazy_clipboard

-- LazyVim 主要设置函数
-- 这是 LazyVim 的核心初始化函数，类似于主入口点
-- 它合并用户配置、设置自动命令、键盘映射，并最终应用颜色主题
---
---@param opts? LazyVimOptions 可选的配置参数，用户可以传入自己的配置来覆盖默认值
function M.setup(opts)
  -- 将用户配置与默认配置合并，如果用户没有提供配置则使用默认配置
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- 检查是否可以延迟加载自动命令 (autocmds)
  -- 如果启动时没有打开文件（argc(-1) == 0），可以延迟加载
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    -- 如果启动了文件，立即加载自动命令
    M.load("autocmds")
  end

  -- 创建一个 augroup (自动命令组)，用于管理这个插件的事件监听器
  -- clear = true 确保该组的事件监听器是全新的，不会与其他插件冲突
  local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })

  -- 创建 "User" 事件的自动命令，模式为 "VeryLazy"
  -- "VeryLazy" 事件在所有插件加载完成后触发，非常适合进行最终的设置工作
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    -- 当 VeryLazy 事件触发时执行的回调函数
    callback = function()
      -- 如果是延迟加载模式，此时再加载自动命令
      if lazy_autocmds then
        M.load("autocmds")
      end
      -- 加载键盘映射配置
      M.load("keymaps")

      -- 恢复之前保存的剪贴板设置（如果有的话）
      if lazy_clipboard ~= nil then
        vim.opt.clipboard = lazy_clipboard
      end

      -- 设置代码格式化功能
      LazyVim.format.setup()
      -- 设置新闻功能，显示版本更新信息
      LazyVim.news.setup()
      -- 设置项目根目录检测功能
      LazyVim.root.setup()

      -- 创建自定义命令：LazyExtras
      -- 用于管理 LazyVim 的额外插件（extras）
      vim.api.nvim_create_user_command("LazyExtras", function()
        LazyVim.extras.show()
      end, { desc = "Manage LazyVim extras" })

      -- 创建自定义命令：LazyHealth
      -- 强制加载所有插件并运行健康检查
      vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd([[Lazy! load all]])
        vim.cmd([[checkhealth]])
      end, { desc = "Load all plugins and run :checkhealth" })

      -- 扩展健康检查的有效字段列表
      -- 这些字段会在 :checkhealth 命令中检查
      local health = require("lazy.health")
      vim.list_extend(health.valid, {
        "recommended",  -- 推荐插件
        "desc",         -- 描述信息
        "vscode",       -- VSCode 兼容性
      })

      -- 如果用户禁用了顺序检查，则直接返回
      if vim.g.lazyvim_check_order == false then
        return
      end

      -- 检查 lazy.nvim 模块的导入顺序
      -- 这个检查确保插件按照正确的顺序加载，避免依赖问题
      local imports = require("lazy.core.config").spec.modules
      local function find(pat, last)
        for i = last and #imports or 1, last and 1 or #imports, last and -1 or 1 do
          if imports[i]:find(pat) then
            return i
          end
        end
      end
      local lazyvim_plugins = find("^lazyvim%.plugins$")
      local extras = find("^lazyvim%.plugins%.extras%.", true) or lazyvim_plugins
      local plugins = find("^plugins$") or math.huge
      if lazyvim_plugins ~= 1 or extras > plugins then
        -- 如果导入顺序不正确，发送警告通知
        local msg = {
          "The order of your `lazy.nvim` imports is incorrect:",
          "- `lazyvim.plugins` should be first",
          "- followed by any `lazyvim.plugins.extras`",
          "- and finally your own `plugins`",
          "",
          "If you think you know what you're doing, you can disable this check with:",
          "```lua",
          "vim.g.lazyvim_check_order = false",
          "```",
        }
        vim.notify(table.concat(msg, "\n"), "warn", { title = "LazyVim" })
      end
    end,
  })

  -- 开始跟踪颜色主题设置
  LazyVim.track("colorscheme")
  -- 尝试应用颜色主题
  LazyVim.try(function()
    if type(M.colorscheme) == "function" then
      -- 如果颜色主题是函数类型，直接调用函数
      M.colorscheme()
    else
      -- 否则使用 vim 的 colorscheme 命令
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    -- 错误处理：如果加载失败，显示错误消息并回退到默认主题
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      LazyVim.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  -- 结束跟踪颜色主题设置
  LazyVim.track()
end

-- 获取指定缓冲区的符号过滤器
-- 这个函数根据文件类型返回应该显示的符号类型列表
-- 用于在各种搜索工具（如 Telescope）中过滤显示的符号类型
---
---@param buf? number 缓冲区号，如果为 nil 或 0 则使用当前缓冲区
---@return string[]? 返回符号类型的字符串数组，如果禁用过滤则返回 nil
function M.get_kind_filter(buf)
  -- 如果没有指定缓冲区，使用当前缓冲区
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  -- 获取当前缓冲区的文件类型
  local ft = vim.bo[buf].filetype

  -- 如果全局禁用了符号过滤，返回空
  if M.kind_filter == false then
    return
  end

  -- 如果当前文件类型被特别禁用，返回空
  if M.kind_filter[ft] == false then
    return
  end

  -- 如果当前文件类型有特定的过滤配置，返回该配置
  if type(M.kind_filter[ft]) == "table" then
    return M.kind_filter[ft]
  end

  -- 否则返回默认的符号过滤配置
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

-- 加载指定的配置模块
-- 这个函数负责加载 LazyVim 的各种配置组件：autocmds、options、keymaps
-- 它会先加载 LazyVim 的默认配置，然后加载用户自定义配置
---
---@param name "autocmds" | "options" | "keymaps" 要加载的配置名称
function M.load(name)
  -- 内部函数：实际执行模块加载
  local function _load(mod)
    -- 检查模块是否存在（通过 lazy 的缓存）
    if require("lazy.core.cache").find(mod)[1] then
      LazyVim.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end

  -- 生成事件模式名称，例如 "LazyVimAutocmds", "LazyVimOptions", "LazyVimKeymaps"
  local pattern = "LazyVim" .. name:sub(1, 1):upper() .. name:sub(2)

  -- 总是先加载 LazyVim 默认配置，然后加载用户配置文件
  -- M.defaults[name] 检查用户是否启用了该默认配置
  -- 对于 options，无论默认设置如何都应该加载
  if M.defaults[name] or name == "options" then
    -- 加载 LazyVim 的默认配置
    _load("lazyvim.config." .. name)
    -- 触发 "LazyVim{名称}Defaults" 事件，让其他插件可以响应默认配置加载
    vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
  end

  -- 加载用户自定义配置文件（在 config/ 目录下）
  _load("config." .. name)

  -- 检查当前是否在 Lazy 插件管理器的界面中
  if vim.bo.filetype == "lazy" then
    -- 临时修复：LazyVim 可能重写了 Lazy 界面的选项，这里触发窗口大小调整
    vim.cmd([[do VimResized]])
  end

  -- 触发 "LazyVim{名称}" 事件，通知配置加载完成
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

M.did_init = false
M._options = {} ---@type vim.wo|vim.bo

-- 初始化 LazyVim
-- 这个函数在插件管理器加载完成后执行，负责设置 LazyVim 的基础环境
-- 它是最早执行的初始化函数之一，设置基本的路径和选项
function M.init()
  -- 检查是否已经初始化过，防止重复执行
  if M.did_init then
    return
  end
  M.did_init = true

  -- 获取 LazyVim 插件的信息
  local plugin = require("lazy.core.config").spec.plugins.LazyVim
  if plugin then
    -- 将 LazyVim 的目录添加到 runtimepath 中
    -- 这样 Neovim 就能找到 LazyVim 的文件
    vim.opt.rtp:append(plugin.dir)
  end

  -- 为向后兼容性设置预加载函数
  -- 旧版本的代码可能直接 require("lazyvim.plugins.lsp.format")
  -- 现在重定向到新的 LazyVim.format
  package.preload["lazyvim.plugins.lsp.format"] = function()
    LazyVim.deprecate([[require("lazyvim.plugins.lsp.format")]], [[LazyVim.format]])
    return LazyVim.format
  end

  -- 延迟通知直到 vim.notify 被替换或 500ms 后
  -- 这确保通知系统在完全初始化后再工作
  LazyVim.lazy_notify()

  -- 在 lazy 初始化之前加载选项设置
  -- 这很重要，因为需要在安装缺失插件之前应用选项
  -- 确保所有插件安装完成后选项能正确应用
  M.load("options")

  -- 保存一些选项的默认值，用于跟踪原始设置
  M._options.indentexpr = vim.o.indentexpr
  M._options.foldmethod = vim.o.foldmethod
  M._options.foldexpr = vim.o.foldexpr

  -- 延迟内置剪贴板处理："xsel" 和 "pbcopy" 可能很慢
  -- 先保存当前的剪贴板设置，然后清空，等初始化完成后再恢复
  lazy_clipboard = vim.opt.clipboard:get()
  vim.opt.clipboard = ""

  -- 如果用户禁用了弃用警告，则重写弃用函数为空函数
  if vim.g.deprecation_warnings == false then
    vim.deprecate = function() end
  end

  -- 设置 LazyVim 插件管理器
  LazyVim.plugin.setup()
  -- 加载 JSON 配置文件
  M.json.load()
end

---@alias LazyVimDefault {name: string, extra: string, enabled?: boolean, origin?: "global" | "default" | "extra" }

local default_extras ---@type table<string, LazyVimDefault>

-- 获取 LazyVim 的默认插件配置
-- 这个函数决定哪些额外的插件（extras）应该被启用
-- LazyVim 有多个功能组：picker（选择器）、cmp（补全）、explorer（文件浏览器）
-- 每个功能组都有几个选择，这个函数根据用户设置和可用性来决定启用哪个
function M.get_defaults()
  -- 如果已经有缓存的结果，直接返回
  if default_extras then
    return default_extras
  end

  -- 定义各个功能组的候选插件
  ---@type table<string, LazyVimDefault[]>
  local checks = {
    -- 文件选择器插件组：snacks_picker、fzf、telescope
    picker = {
      { name = "snacks", extra = "editor.snacks_picker" },
      { name = "fzf", extra = "editor.fzf" },
      { name = "telescope", extra = "editor.telescope" },
    },
    -- 代码补全插件组：blink.cmp、nvim-cmp
    cmp = {
      { name = "blink.cmp", extra = "coding.blink" },
      { name = "nvim-cmp", extra = "coding.nvim-cmp" },
    },
    -- 文件浏览器插件组：snacks_explorer、neo-tree
    explorer = {
      { name = "snacks", extra = "editor.snacks_explorer" },
      { name = "neo-tree", extra = "editor.neo-tree" },
    },
  }

  -- 对于老版本用户，优先选择 telescope 和 neo-tree
  -- existing installs keep their defaults
  if (LazyVim.config.json.data.install_version or 7) < 8 then
    -- 将 telescope 和 neo-tree 移至数组开头
    table.insert(checks.picker, 1, table.remove(checks.picker, 2))
    table.insert(checks.explorer, 1, table.remove(checks.explorer, 2))
  end

  default_extras = {}
  -- 遍历每个功能组
  for name, check in pairs(checks) do
    local valid = {} ---@type string[]
    -- 收集所有启用的候选插件
    for _, extra in ipairs(check) do
      if extra.enabled ~= false then
        valid[#valid + 1] = extra.name
      end
    end

    -- 设置默认值来源为 "default"
    local origin = "default"

    -- 检查用户是否设置了全局变量来覆盖默认选择
    local use = vim.g["lazyvim_" .. name]
    -- 如果用户设置的值在有效列表中，使用该值；否则设为 nil
    use = vim.tbl_contains(valid, use or "auto") and use or nil
    -- 如果使用了全局设置，则更新来源为 "global"
    origin = use and "global" or origin

    -- 如果没有使用全局设置，检查哪些候选插件实际可用
    for _, extra in ipairs(use and {} or check) do
      -- 如果该插件没有被禁用且实际可用，则使用它
      if extra.enabled ~= false and LazyVim.has_extra(extra.extra) then
        use = extra.name
        break
      end
    end

    -- 如果找到了可用的插件，更新来源为 "extra"
    origin = use and "extra" or origin

    -- 如果仍然没有找到，默认为第一个有效选项
    use = use or valid[1]

    -- 为每个候选插件设置启用状态和来源
    for _, extra in ipairs(check) do
      -- 生成完整的导入路径
      local import = "lazyvim.plugins.extras." .. extra.extra
      -- 深拷贝以避免修改原始数据
      extra = vim.deepcopy(extra)
      -- 只启用用户选择的插件
      extra.enabled = extra.name == use
      -- 如果启用该插件，记录其来源
      if extra.enabled then
        extra.origin = origin
      end
      default_extras[import] = extra
    end
  end
  return default_extras
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options LazyVimConfig
    return options[key]
  end,
})

return M
