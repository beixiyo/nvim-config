-- ================================
-- 可选插件管理 GUI（类似 Mason 的多选安装界面）
-- 命令：:PluginManager 或 Dashboard 中 "可选插件"
-- ================================

local registry = require("plugins.manager-ui.registry")
local M = {}

local CONFIG = {
  separator_len = 60,
  category_order = { "code", "tools", "ui" },
  width_ratio = 0.7,
  height_ratio = 0.7,
}

local ns = vim.api.nvim_create_namespace("plugin_manager")

local function user_picks_path()
  local rel = "lua/plugins/manager-ui/user-picks.lua"
  local rtp_str = vim.o.rtp or ""
  for _, r in ipairs(vim.split(rtp_str, ",")) do
    local p = r:gsub("[/\\]+$", "") .. "/" .. rel
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return vim.fn.stdpath("config") .. "/" .. rel
end

local function load_picks()
  local ok, mod = pcall(require, "plugins.manager-ui.user-picks")
  if ok and type(mod) == "table" then
    return mod
  end
  local out = {}
  for _, e in ipairs(registry.optional_plugins) do
    out[e.id] = true
  end
  return out
end

local function save_picks(picks)
  local path = user_picks_path()
  local lines = {
    "-- ================================",
    "-- 可选插件勾选状态（由 :PluginManager GUI 写入，或手动编辑）",
    "-- ================================",
    "-- 克隆仓库后默认全选；可在此关闭不需要的插件，或通过 :PluginManager 多选后保存。",
    "-- 修改后需重启 Neovim 或执行 :Lazy sync 以生效。",
    "",
    "return {",
  }
  for _, entry in ipairs(registry.optional_plugins) do
    local v = picks[entry.id] ~= false
    lines[#lines + 1] = ('  ["%s"] = %s,'):format(entry.id:gsub('"', '\\"'), tostring(v))
  end
  lines[#lines + 1] = "}"
  vim.fn.writefile(lines, path)
  package.loaded["plugins.manager-ui.user-picks"] = nil
end

local function line_for(entry, picks)
  local enabled = picks[entry.id] ~= false
  local mark = enabled and "[✓]" or "[ ]"
  return ("%s %-12s %s"):format(mark, entry.id, entry.desc)
end

local function build_id_to_entry()
  local id_to_entry = {}
  for _, e in ipairs(registry.optional_plugins) do
    id_to_entry[e.id] = e
  end
  return id_to_entry
end

local function build_content(picks)
  local lines = {
    " Plugin Manager - 可选插件管理（Enter/x 切换，q 关闭）",
    string.rep("─", CONFIG.separator_len),
  }
  local id_by_line = {}

  local by_cat = { code = {}, tools = {}, ui = {} }
  for _, entry in ipairs(registry.optional_plugins) do
    table.insert(by_cat[entry.category] or by_cat.code, entry)
  end

  for _, cat in ipairs(CONFIG.category_order) do
    local list = by_cat[cat]
    if list and #list > 0 then
      lines[#lines + 1] = ""
      local cat_label = registry.category_labels[cat] or cat
      lines[#lines + 1] = (" %s (%d)"):format(cat_label, #list)
      for _, entry in ipairs(list) do
        lines[#lines + 1] = line_for(entry, picks)
        id_by_line[#lines] = entry.id
      end
    end
  end

  return lines, id_by_line
end

local function calculate_window_config(lines)
  local width = math.floor(vim.o.columns * CONFIG.width_ratio)
  local height = math.min(#lines + 2, math.floor(vim.o.lines * CONFIG.height_ratio))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  return { width = width, height = height, row = row, col = col }
end

local function apply_highlights(buf, id_by_line)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local function set_link(name, link)
    pcall(vim.api.nvim_set_hl, 0, name, { link = link })
  end

  set_link("PluginManagerTitle", "Title")
  set_link("PluginManagerSeparator", "Comment")
  set_link("PluginManagerSection", "Constant")
  set_link("PluginManagerMarkOn", "DiffAdded")
  set_link("PluginManagerMarkOff", "Comment")
  set_link("PluginManagerId", "Identifier")

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local lnum = i - 1
    if i == 1 then
      vim.api.nvim_buf_add_highlight(buf, ns, "PluginManagerTitle", lnum, 0, -1)
    elseif i == 2 then
      vim.api.nvim_buf_add_highlight(buf, ns, "PluginManagerSeparator", lnum, 0, -1)
    elseif not id_by_line[i] and line:match("^ %S") then
      vim.api.nvim_buf_add_highlight(buf, ns, "PluginManagerSection", lnum, 0, -1)
    else
      local id = id_by_line[i]
      if id and type(id) == "string" then
        local mark = line:sub(1, 3)
        local group = mark:find("✓") and "PluginManagerMarkOn" or "PluginManagerMarkOff"
        vim.api.nvim_buf_add_highlight(buf, ns, group, lnum, 0, 3)

        local s, e = line:find(id, 1, true)
        if s and e then
          vim.api.nvim_buf_add_highlight(buf, ns, "PluginManagerId", lnum, s - 1, e)
        end
      end
    end
  end
end

local function setup_keymaps(buf, win, picks, id_to_entry, toggle_callback)
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "<CR>", toggle_callback, opts)
  vim.keymap.set("n", "x", toggle_callback, opts)
  
  local function close_and_ensure_dashboard()
    vim.api.nvim_win_close(win, true)
    -- 关闭后检查是否还有 dashboard 窗口，如果没有就打开 dashboard
    vim.schedule(function()
      local has_dashboard = false
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        local ok, ft = pcall(function()
          return vim.bo[vim.api.nvim_win_get_buf(w)].filetype
        end)
        if ok and ft == "snacks_dashboard" then
          has_dashboard = true
          break
        end
      end
      if not has_dashboard then
        pcall(function()
          require("snacks").dashboard.open()
        end)
      end
    end)
  end
  
  vim.keymap.set("n", "q", close_and_ensure_dashboard, opts)
  vim.keymap.set("n", "<Esc>", close_and_ensure_dashboard, opts)
end

function M.open()
  local picks = load_picks()
  local id_to_entry = build_id_to_entry()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "PluginManager")

  local lines, id_by_line = build_content(picks)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.b[buf].plugin_manager_ids = id_by_line

  apply_highlights(buf, id_by_line)

  local win_config = calculate_window_config(lines)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = win_config.row,
    col = win_config.col,
    width = win_config.width,
    height = win_config.height,
    style = "minimal",
    border = "rounded",
    title = " Plugin Manager ",
    title_pos = "center",
  })

  local function toggle_current()
    local pos = vim.api.nvim_win_get_cursor(win)
    local cur = pos[1]
    local id = vim.b.plugin_manager_ids and vim.b.plugin_manager_ids[cur]
    if not id then
      return
    end

    picks[id] = not picks[id]

    local entry = id_to_entry[id]
    if not entry then
      return
    end

    local new_line = line_for(entry, picks)
    vim.api.nvim_buf_set_lines(buf, cur - 1, cur, false, { new_line })
    save_picks(picks)

    apply_highlights(buf, vim.b.plugin_manager_ids or {})
  end

  setup_keymaps(buf, win, picks, id_to_entry, toggle_current)
end

return M
