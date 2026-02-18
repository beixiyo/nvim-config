-- ================================
-- 自动命令配置
-- ================================
-- 集中管理 Neovim 的自动命令（autocmd），提供文件变化检测、复制高亮、文件类型特定设置等功能

-- 创建自动命令组的辅助函数
-- 自动命令组用于组织相关的自动命令，便于管理
-- clear = true 确保重新加载时清空该组的所有命令，避免重复注册
---@param name string 自动命令组的名称标识
---@return number 返回创建的自动命令组ID
local function augroup(name)
  return vim.api.nvim_create_augroup("my_nvim_" .. name, { clear = true })
end

-- ================================
-- 文件外部修改检测
-- 窗口重新获得焦点、离开终端时检查当前文件是否被外部修改，若有则提示重新加载
-- ================================
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- ================================
-- 复制操作（yank）时，自动高亮刚刚复制的文本
-- ================================
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    -- 使用 Neovim 内置的高亮函数来高亮刚复制的文本
    -- 这个函数会短暂高亮最后复制的文本，通常是0.5秒
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- ================================
-- 窗口的尺寸发生变化时，自动重新平衡所有分割窗口的大小
-- ================================
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    -- 保存当前的标签页编号，确保操作后回到原来的标签页
    local current_tab = vim.fn.tabpagenr()
    -- "tabdo wincmd =" 重新平衡当前标签页中所有窗口的大小
    vim.cmd("tabdo wincmd =")
    -- 回到原来的标签页
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- ================================
-- 打开文件时恢复上次关闭时的光标位置
-- ================================
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].my_nvim_last_loc then
      return
    end
    vim.b[buf].my_nvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ================================
-- 快速关闭特定文件类型
-- 在帮助、通知等临时窗口使用 q 快速关闭
-- ================================
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "关闭窗口",
      })
    end)
  end,
})

-- ================================
-- man 缓冲区不加入 buffer 列表，避免 :bnext 等切到 man 页
-- ================================
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- ================================
-- 在文本 / Markdown / 提交信息等中启用自动换行与拼写检查
-- ================================
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- ================================
-- JSON 系列文件不隐藏引号（conceallevel=0），便于编辑
-- ================================
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- ================================
-- 保存文件前自动创建缺失的目录结构，避免写入失败
-- ================================
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    -- 跳过网络路径（如 scp://）
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ================================
-- 进入插入模式时，自动清除搜索高亮
-- 使用 vim.schedule 确保在模式切换完成后再清除，避免被其他 autocmd 覆盖
-- ================================
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = augroup("clear_search"),
  callback = function()
    vim.schedule(function()
      vim.cmd("nohlsearch")
    end)
  end,
})

-- ================================
-- 保存前删除行尾空白（可选，避免提交多余空格）
-- 参考: Abstract-IDE/Abstract, kickstart.nvim lint 等
-- ================================
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_trailing"),
  pattern = "*",
  callback = function(event)
    if vim.bo[event.buf].filetype == "" or vim.bo[event.buf].buftype ~= "" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})
