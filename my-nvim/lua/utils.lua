local M = {}

-- 统一的图标表：不再按「用途」嵌套多级，而是用更语义化的 key 直接描述图标含义
-- 约定：
-- - 通用：直接用语义名，如 `lsp` / `clock`
-- - 文件类型：前缀 `ft_`
-- - DAP：前缀 `dap_`
-- - 诊断相关：前缀 `diagnostics_`
-- - Git 相关：前缀 `git_`
M.icons = {
  -- 通用 / 杂项
  dots = "󰇘",
  clock = "",
  lsp = "󰘦",
  code = "",

  -- Dashboard
  find_file = "",
  new_file = "",
  find_text = "",
  recent_files = "",
  config = "",
  session = "",
  lazy = "󰒲",
  tools = "",

  -- 文件类型相关
  ft_octo = "",
  ft_gh = "",
  ft_markdown_gh = "",

  -- DAP / 调试
  dap_stopped = { "󰁕", "DiagnosticWarn", "DapStoppedLine" },
  dap_breakpoint = "",
  dap_breakpoint_condition = "",
  dap_breakpoint_rejected = { "", "DiagnosticError" },
  dap_log_point = ".>",
  dap_status = "",

  -- 诊断
  diagnostics_error = "",
  diagnostics_warn = "",
  diagnostics_hint = "",
  diagnostics_info = "",

  -- Git
  git_added = "",
  git_modified = "",
  git_removed = "",

  -- 键位 / 操作相关（原 keymaps 下的图标）
  -- 文件相关
  git_files = "󰊢",
  config_files = "󰒓",
  buffers = "󰈙",
  explorer = "󰉓",
  -- 搜索相关
  grep = "󰍉",
  grep_word = "󰦨",
  scope = "󰨞",
  -- 诊断相关
  diagnostics = "",
  -- 编辑/光标相关
  cursor = "󰇀",
  -- Git 相关
  git_status = "󰊢",
  git_stash = "󰆍",
  git_diff = "󰉼",
  git_log = "󰜂",
  git_branches = "󰘬",
  -- 窗口管理
  arrow_left = "󰁍",
  arrow_right = "󰁔",
  arrow_up = "󰁑",
  arrow_down = "󰁐",
  window = "󱂬",
  -- 编辑操作
  move_down = "󰁐",
  move_up = "󰁑",
  copy = "󰅌",
  -- 导航
  prev = "󰁍",
  next = "󰁔",

  -- 其他
  terminal = "󰆍",
  quit = "",
  save = "󰆓",
  exit_insert = "󰩟",
  duck = "󰇥",

  -- Neovim 内部功能
  commands = "󰘳",
  command_history = "󰋚",
  registers = "󰱼",
  marks = "󰆤",
  jumps = "󰘈",
  keymaps = "󰌌",
  todo_comments = "󰄬",

  -- Quickfix
  quickfix = "󰈸",
  location_list = "󰉁",
  -- 消息

  message = "󰍩",

  -- LSP completion kind 图标
  kinds = {
    Array         = "",
    Boolean       = "󰨙",
    Class         = "",
    Codeium       = "󰘦",
    Color         = "",
    Control       = "",
    Collapsed     = "",
    Constant      = "󰏿",
    Constructor   = "",
    Copilot       = "",
    Enum          = "",
    EnumMember    = "",
    Event         = "",
    Field         = "",
    File          = "",
    Folder        = "",
    Function      = "󰊕",
    Interface     = "",
    Key           = "",
    Keyword       = "",
    Method        = "󰊕",
    Module        = "",
    Namespace     = "󰦮",
    Null          = "",
    Number        = "󰎠",
    Object        = "",
    Operator      = "",
    Package       = "",
    Property      = "",
    Reference     = "",
    Snippet       = "󱄽",
    String        = "",
    Struct        = "󰆼",
    Supermaven    = "",
    TabNine       = "󰏚",
    Text          = "",
    TypeParameter = "",
    Unit          = "",
    Value         = "",
    Variable      = "󰀫",
  }
}

-- 工具函数：规范化路径
local function norm(path)
  if not path or path == "" then
    return ""
  end
  if vim.fn.has("win32") == 1 then
    return vim.fn.substitute(path, "\\", "/", "g")
  end
  return path
end

-- 工具函数：获取项目根目录
local function get_root(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local bufpath = vim.api.nvim_buf_get_name(buf)

  if bufpath == "" then
    bufpath = vim.uv.cwd()
  else
    bufpath = vim.fs.dirname(bufpath)
  end

  -- 查找项目根目录（.git、.gitignore、package.json 等）
  local root_patterns = { ".git", ".gitignore", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", "lua" }
  local root = vim.fs.find(root_patterns, { path = bufpath, upward = true })[1]

  if root then
    return norm(vim.fs.dirname(root))
  end

  -- 如果没有找到，返回当前工作目录
  return norm(vim.uv.cwd())
end

-- 工具函数：获取当前工作目录
local function get_cwd()
  return norm(vim.uv.cwd())
end

-- Lualine 工具函数
M.lualine = {}

---@param opts? {cwd:false, subdirectory: true, parent: true, other: true, icon?:string}
function M.lualine.root_dir(opts)
  opts = vim.tbl_extend("force", {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = "󱉭 ",
    color = function()
      return { fg = Snacks.util.color("Special") }
    end,
  }, opts or {})

  local function get()
    local cwd = get_cwd()
    local root = get_root()
    local name = vim.fs.basename(root)

    if root == cwd then
      -- 根目录就是当前工作目录
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      -- 根目录是当前工作目录的子目录
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      -- 根目录是当前工作目录的父目录
      return opts.parent and name
    else
      -- 根目录和当前工作目录没有关联
      return opts.other and name
    end
  end

  return {
    function()
      return (opts.icon and opts.icon .. " ") .. get()
    end,
    cond = function()
      return type(get()) == "string"
    end,
    color = opts.color,
  }
end

---@param component any
---@param text string
---@param hl_group? string
---@return string
local function format_hl(component, text, hl_group)
  text = text:gsub("%%", "%%%%")
  if not hl_group or hl_group == "" then
    return text
  end
  ---@type table<string, string>
  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]
  if not lualine_hl_group then
    local utils = require("lualine.utils.utils")
    ---@type string[]
    local gui = vim.tbl_filter(function(x)
      return x
    end, {
      utils.extract_highlight_colors(hl_group, "bold") and "bold",
      utils.extract_highlight_colors(hl_group, "italic") and "italic",
    })

    lualine_hl_group = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, "fg"),
      gui = #gui > 0 and table.concat(gui, ",") or nil,
    }, "LV_" .. hl_group) --[[@as string]]
    component.hl_cache[hl_group] = lualine_hl_group
  end
  return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

---@param opts? {relative: "cwd"|"root", modified_hl: string?, directory_hl: string?, filename_hl: string?, modified_sign: string?, readonly_icon: string?, length: number?}
function M.lualine.pretty_path(opts)
  opts = vim.tbl_extend("force", {
    relative = "cwd",
    modified_hl = "MatchParen",
    directory_hl = "",
    filename_hl = "Bold",
    modified_sign = "",
    readonly_icon = " 󰌾 ",
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand("%:p") --[[@as string]]

    if path == "" then
      return ""
    end

    path = norm(path)
    local root = get_root()
    local cwd = get_cwd()

    -- 保留原始路径，以便为用户提供预期的 pretty_path 结果，而不是规范化后的路径
    -- 规范化后的路径可能会让人困惑
    local norm_path = path

    if vim.fn.has("win32") == 1 then
      -- 如果提供的路径涉及大小写混合，在 Windows 上需要额外的规范化步骤
      norm_path = norm_path:lower()
      root = root:lower()
      cwd = cwd:lower()
    end

    if opts.relative == "cwd" and norm_path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    elseif norm_path:find(root, 1, true) == 1 then
      path = path:sub(#root + 2)
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, "[\\/]")

    if opts.length == 0 then
      parts = parts
    elseif #parts > opts.length then
      parts = { parts[1], "…", table.unpack(parts, #parts - opts.length + 2, #parts) }
    end

    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = parts[#parts] .. opts.modified_sign
      parts[#parts] = format_hl(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = format_hl(self, parts[#parts], opts.filename_hl)
    end

    local dir = ""
    if #parts > 1 then
      dir = table.concat({ table.unpack(parts, 1, #parts - 1) }, sep)
      dir = format_hl(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ""
    if vim.bo.readonly then
      readonly = format_hl(self, opts.readonly_icon, opts.modified_hl)
    end
    return dir .. parts[#parts] .. readonly
  end
end

--- 复制「相对路径:行号」到系统剪贴板（供 lualine 文件名/行列号点击使用）
function M.lualine.copy_path_line()
  local rel = vim.fn.expand("%:.")
  if rel == "" then
    return
  end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local text = rel .. ":" .. row
  vim.fn.setreg("+", text)
  vim.notify("已复制: " .. text, vim.log.levels.INFO, { title = "Lualine" })
end

--- 复制当前时间 yyyy-MM-dd HH:mm:ss 到系统剪贴板（供 lualine 时钟点击使用）
function M.lualine.copy_datetime()
  local text = os.date("%Y-%m-%d %H:%M:%S")
  vim.fn.setreg("+", text)
  vim.notify("已复制: " .. text, vim.log.levels.INFO, { title = "Lualine" })
end

--- 打开分支查看（使用 Snacks.picker.git_branches）
function M.lualine.open_branch_view()
  if type(Snacks) == "table" and type(Snacks.picker) == "table" and type(Snacks.picker.git_branches) == "function" then
    Snacks.picker.git_branches()
  else
    vim.cmd("Git branch")
  end
end

return M
