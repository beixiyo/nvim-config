-- ================================
-- Snacks.nvim 核心（dashboard / picker / terminal / explorer / notifier / bufdelete）
-- ================================
-- 需尽早加载：bufferline 依赖 Snacks.bufdelete，dashboard 需在 VimEnter 前就绪。
-- 文档：https://github.com/folke/snacks.nvim

--- 项目根目录：优先 Git 根，否则当前工作目录（供 Explorer 用）
local function root()
  local ok, out = pcall(vim.fn.system, "git rev-parse --show-toplevel 2>/dev/null")
  if ok and out and #out > 0 then
    return vim.trim(out)
  end
  return vim.fn.getcwd()
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,

  ---@type snacks.Config
  opts = {
    -- 以下需显式启用（会注册 autocmd 等）
    bigfile = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = false }, -- 可选，按需改为 true
    input = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    -- 终端：用 Snacks.terminal 替代 toggleterm
    terminal = { enabled = true },
    -- dashboard 预设：使用 Snacks.picker（files / live_grep / oldfiles）
    dashboard = {
      enabled = true,
      preset = {
        pick = function(cmd, opts)
          local source = (cmd == "live_grep" and "grep") or (cmd == "oldfiles" and "recent") or (cmd or "files")
          Snacks.picker.pick(source, opts or {})
        end,
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })" },
          { icon = " ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
  },

  keys = {
    -- 文件树（Snacks Explorer，替代 neo-tree）
    { "<leader>e", function() Snacks.explorer({ cwd = root() }) end, desc = "文件树 (项目根)" },
    { "<leader>E", function() Snacks.explorer() end, desc = "文件树 (cwd)" },
    { "<leader>fe", function() Snacks.explorer({ cwd = root() }) end, desc = "Explorer (root)" },
    { "<leader>fE", function() Snacks.explorer() end, desc = "Explorer (cwd)" },
    -- 模糊查找（替代 fzf-lua）
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find File" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep Word", mode = { "n", "x" } },
    -- 终端（替代 toggleterm）：Ctrl+\ 或 <leader>ft
    { "<C-\\>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<leader>ft", function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },

  config = function(_, opts)
    require("snacks").setup(opts)
  end,
}
