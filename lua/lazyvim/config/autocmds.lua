-- 这个文件由 lazyvim.config.init 自动加载
-- 这里集中管理 LazyVim 默认的自动命令，便于新手理解每个触发器

-- 创建自动命令组的辅助函数
-- 自动命令组用于组织相关的自动命令，便于管理
-- clear = true 确保重新加载时清空该组的所有命令，避免重复注册
---
---@param name string 自动命令组的名称标识
---@return number 返回创建的自动命令组ID
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- 监听文件变化自动检查命令
-- 当以下情况发生时，自动检查文件是否被外部修改：
-- 1. Neovim 窗口获得焦点（用户切换到 Neovim 窗口）
-- 2. 终端窗口关闭（vim 启动的终端程序结束）
-- 3. 用户离开终端窗口
-- 这个命令确保当外部程序修改了文件时，用户能够及时发现并重新加载
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  -- 将命令添加到 "checktime" 组
  group = augroup("checktime"),
  -- 当事件触发时执行的回调函数
  callback = function()
    -- 只对真实文件进行检查，跳过无文件类型的缓冲区
    -- buftype ~= "nofile" 确保我们只处理实际的文件缓冲区
    -- 例如：帮助文档、临时缓冲区等应该被跳过
    if vim.o.buftype ~= "nofile" then
      -- checktime 命令检查当前缓冲区的文件时间戳
      -- 如果文件被外部修改，Vim 会提示用户是否重新加载
      vim.cmd("checktime")
    end
  end,
})

-- 复制文本视觉反馈命令
-- 当用户执行复制操作（yank）时，自动高亮刚刚复制的文本
-- 这是现代编辑器的常见特性，提供即时的视觉反馈
-- 用户能够确认复制操作是否成功执行
vim.api.nvim_create_autocmd("TextYankPost", {
  -- 将命令添加到 "highlight_yank" 组
  group = augroup("highlight_yank"),
  -- 当复制操作完成后执行的回调函数
  callback = function()
    -- 使用 Neovim 内置的高亮函数来高亮刚复制的文本
    -- (vim.hl or vim.highlight) 是兼容性写法，因为历史原因
    -- hl 可能在某些版本中是全局的，也可能不是
    (vim.hl or vim.highlight).on_yank()
    -- 这个函数会短暂高亮最后复制的文本，通常是0.5秒
    -- 高亮颜色通常是你当前配色方案中的黄色或青色
  end,
})

-- 窗口尺寸调整命令
-- 当 Neovim 外部窗口的尺寸发生变化时，自动重新平衡所有分割窗口的大小
-- 这确保所有窗口都能均匀分享新窗口空间，提供一致的视觉体验
-- 常见场景：调整终端窗口大小、切换显示器、改变虚拟机窗口大小
vim.api.nvim_create_autocmd({ "VimResized" }, {
  -- 将命令添加到 "resize_splits" 组
  group = augroup("resize_splits"),
  -- 当窗口尺寸变化时执行的回调函数
  callback = function()
    -- 保存当前的标签页编号，确保操作后回到原来的标签页
    local current_tab = vim.fn.tabpagenr()
    -- "tabdo wincmd =" 重新平衡当前标签页中所有窗口的大小
    -- wincmd = 是 Vim 命令，相当于按 Ctrl+w =
    vim.cmd("tabdo wincmd =")
    -- 回到原来的标签页
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- 光标位置记忆命令
-- 当打开新缓冲区（文件）时，自动跳转到上次关闭时的光标位置
-- 这是现代编辑器的重要功能：记住文件的编辑状态
-- 提供连贯的编辑体验，特别适合大型文件或长时间工作的项目
vim.api.nvim_create_autocmd("BufReadPost", {
  -- 将命令添加到 "last_loc" 组
  group = augroup("last_loc"),
  -- 当缓冲区读取完成时执行的回调函数
  callback = function(event)
    -- 定义需要排除的文件类型，不应用位置记忆功能
    -- gitcommit：Git 提交信息文件通常不需要记忆位置
    local exclude = { "gitcommit" }
    -- 获取当前缓冲区编号
    local buf = event.buf
    
    -- 检查是否需要跳过这个缓冲区：
    -- 1. 在排除列表中的文件类型
    -- 2. 已经标记过使用此功能的缓冲区（避免重复执行）
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    
    -- 标记此缓冲区已使用位置记忆功能
    vim.b[buf].lazyvim_last_loc = true
    
    -- 获取缓冲区中的 '" 标记（Vim 内置的上次位置标记）
    -- 这个标记在关闭文件时自动保存当前光标位置
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q> / 在帮助、通知等临时窗口使用 q 快速关闭
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
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline / man buffer 默认不加入 buffer 列表，避免 :bnext 干扰
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes / 在文本/Markdown 等文件中启用自动换行与拼写检查
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files / JSON 默认不隐藏引号，便于编辑
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
-- 保存文件前自动创建缺失的目录结构，避免写入失败
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
