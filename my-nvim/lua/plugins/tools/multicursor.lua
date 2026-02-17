-- ================================
-- 多光标（multicursor.nvim）
-- ================================
-- 类 VSCode 多光标：匹配词/选区加光标、上下行加光标、Ctrl+左键点击加/删光标
-- 文档：:h multicursor

local icons = require("utils").icons

return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  cond = function()
    return not vim.g.vscode -- 在 VSCode 中禁用此插件（VSCode 已有内置多光标）
  end,
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- 上下加光标 / 跳过行
    set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end, { desc = icons.cursor .. " " .. "多光标: 上方加光标" })
    set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end, { desc = icons.cursor .. " " .. "多光标: 下方加光标" })
    set({ "n", "x" }, "<leader><up>", function() mc.lineSkipCursor(-1) end, { desc = icons.cursor .. " " .. "多光标: 跳过上一行" })
    set({ "n", "x" }, "<leader><down>", function() mc.lineSkipCursor(1) end, { desc = icons.cursor .. " " .. "多光标: 跳过下一行" })

    -- 匹配词/选区：加下一处 / 上一处 / 跳过
    set({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end, { desc = icons.cursor .. " " .. "多光标: 下一处匹配加光标" })
    set({ "n", "x" }, "<leader>s", function() mc.matchSkipCursor(1) end, { desc = icons.cursor .. " " .. "多光标: 跳过下一处" })
    set({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end, { desc = icons.cursor .. " " .. "多光标: 上一处匹配加光标" })
    set({ "n", "x" }, "<leader>S", function() mc.matchSkipCursor(-1) end, { desc = icons.cursor .. " " .. "多光标: 跳过上一处" })

    -- 鼠标：Alt+左键 添加/移除光标
    set("n", "<A-leftmouse>", mc.handleMouse, { desc = icons.cursor .. " " .. "多光标: 点击处加/删光标" })
    set("n", "<A-leftdrag>", mc.handleMouseDrag, { desc = icons.cursor .. " " .. "多光标: 拖拽" })
    set("n", "<A-leftrelease>", mc.handleMouseRelease, { desc = icons.cursor .. " " .. "多光标: 释放" })

    -- 多光标时：启用/禁用所有光标
    set({ "n", "x" }, "<A-q>", mc.toggleCursor, { desc = icons.cursor .. " " .. "多光标: 切换光标启用/禁用" })

    -- 多光标专用键层（仅在有多个光标时生效）
    mc.addKeymapLayer(function(layerSet)
      layerSet({ "n", "x" }, "<left>", mc.prevCursor, { desc = icons.cursor .. " " .. "多光标: 上一个光标" })
      layerSet({ "n", "x" }, "<right>", mc.nextCursor, { desc = icons.cursor .. " " .. "多光标: 下一个光标" })
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor, { desc = icons.cursor .. " " .. "多光标: 删除当前光标" })
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end, { desc = icons.cursor .. " " .. "多光标: Esc 启用/清除" })
    end)

    -- 高亮
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn"})
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
  end,
}
