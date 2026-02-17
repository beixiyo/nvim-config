-- ================================
-- Git 行内标记 & hunk 操作（gitsigns.nvim）
-- ================================
-- 功能：
-- - signcolumn 中显示新增 / 修改 / 删除行
-- - 跳转上一/下一 hunk
-- - 对当前 hunk 执行暂存 / 撤销 / 预览
-- - 行级 blame 信息
--
-- 说明：
-- - lualine 已从 `vim.b.gitsigns_status_dict` 读取统计信息（added/changed/removed）
-- - 这里只负责启用插件和基础按键，Git 相关「列表视图」仍用 Snacks.picker

local icons = require("utils").icons

return {
  "lewis6991/gitsigns.nvim",
  cond = function()
    return not vim.g.vscode -- VSCode 中禁用，防止与内置 Git UI 冲突
  end,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "󰍵" },
      topdelete = { text = "󰍵" },
      changedelete = { text = "▎" },
      untracked = { text = "┆" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "󰍵" },
      topdelete = { text = "󰍵" },
      changedelete = { text = "▎" },
      untracked = { text = "┆" },
    },
    signcolumn = true, -- 在 signcolumn 中显示标记
    numhl = false,
    linehl = false,
    word_diff = false,
    current_line_blame = false, -- 默认关闭行尾 blame，可按需开启
    current_line_blame_opts = {
      delay = 800,
      virt_text_pos = "eol",
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      if not gs then
        return
      end

      local map = function(mode, lhs, rhs, desc, icon_key)
        local icon = icons[icon_key or "git_status"] or icons.git_status
        vim.keymap.set(mode, lhs, rhs, {
          desc = icon .. " " .. desc,
          buffer = bufnr,
        })
      end

      -- hunk 导航（与诊断 [d/]d 区分开）
      map("n", "]h", function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return "<Ignore>"
      end, "下一处改动", "next")

      map("n", "[h", function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return "<Ignore>"
      end, "上一处改动", "prev")

      -- hunk 级操作（归入 <leader>g Git 分组下）
      -- 使用三键前缀：<leader> g h ...
      map({ "n", "v" }, "<leader>ghs", gs.stage_hunk, "Git: 暂存当前 hunk", "git_status")
      map({ "n", "v" }, "<leader>ghr", gs.reset_hunk, "Git: 重置当前 hunk", "git_status")
      map("n", "<leader>ghS", gs.stage_buffer, "Git: 暂存当前 buffer", "git_status")
      map("n", "<leader>ghR", gs.reset_buffer, "Git: 重置当前 buffer", "git_status")
      map("n", "<leader>ghp", gs.preview_hunk, "Git: 预览当前 hunk", "git_diff")

      -- 行级 blame（归入 <leader>g Git 分组下）
      map("n", "<leader>ghB", gs.blame_line, "Git: 当前行 blame", "git_log")
      map("n", "<leader>ghBF", function()
        gs.blame_line({ full = true })
      end, "Git: 当前行完整 blame", "git_log")
    end,
  },
}

