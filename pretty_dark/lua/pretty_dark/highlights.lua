local M = {}

-- 获取颜色
local function get_colors(opts)
  local colors = require("pretty_dark.colors").colors
  
  -- 如果有自定义颜色函数，调用它
  if opts.on_colors then
    opts.on_colors(colors)
  end
  
  return colors
end

-- 创建高亮组
function M.setup(opts)
  opts = opts or {}
  local colors = get_colors(opts)
  local highlights = {}
  
  -- 编辑器基础高亮
  highlights = {
    -- 基础语法
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.bg_popup },
    NormalNC = { fg = colors.fg, bg = colors.bg },
    
    -- 注释
    Comment = { fg = colors.comment, italic = opts.styles and opts.styles.comments.italic },
    ["@comment"] = { link = "Comment" },
    ["@comment.documentation"] = { fg = colors.comment_doc },
    
    -- 常量
    Constant = { fg = colors.constant },
    ["@constant"] = { link = "Constant" },
    ["@boolean"] = { fg = colors.boolean },
    ["@number"] = { fg = colors.number },
    ["@float"] = { fg = colors.number },
    
    -- 字符串
    String = { fg = colors.string },
    ["@string"] = { link = "String" },
    ["@string.escape"] = { fg = colors.string_escape },
    ["@string.regex"] = { fg = colors.string_regex },
    ["@string.special"] = { fg = colors.string_special },
    
    -- 标识符
    Identifier = { fg = colors.variable },
    ["@variable"] = { link = "Identifier" },
    ["@variable.builtin"] = { fg = colors.variable_special },
    Function = { fg = colors.blue },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { link = "Function" },
    ["@function.call"] = { link = "Function" },
    ["@method"] = { link = "Function" },
    ["@method.call"] = { link = "Function" },
    
    -- 关键字
    Keyword = { fg = colors.purple, italic = opts.styles and opts.styles.keywords.italic },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.operator"] = { link = "Keyword" },
    ["@keyword.return"] = { link = "Keyword" },
    ["@conditional"] = { link = "Keyword" },
    ["@repeat"] = { link = "Keyword" },
    ["@label"] = { link = "Keyword" },
    ["@exception"] = { link = "Keyword" },
    ["@include"] = { fg = colors.blue },
    ["@operator"] = { fg = colors.operator },
    
    -- 类型
    Type = { fg = colors.type },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@type.definition"] = { link = "Type" },
    ["@type.qualifier"] = { link = "Keyword" },
    ["@constructor"] = { fg = colors.constructor },
    ["@property"] = { fg = colors.property },
    ["@attribute"] = { fg = colors.attribute },
    ["@field"] = { fg = colors.property },
    ["@parameter"] = { fg = colors.variable },
    
    -- 特殊
    Special = { fg = colors.blue },
    ["@special"] = { link = "Special" },
    ["@tag"] = { fg = colors.tag },
    ["@tag.attribute"] = { fg = colors.attribute },
    ["@tag.delimiter"] = { fg = colors.punctuation },
    ["@punctuation"] = { fg = colors.punctuation },
    ["@punctuation.bracket"] = { fg = colors.punctuation },
    ["@punctuation.delimiter"] = { fg = colors.punctuation },
    ["@punctuation.special"] = { fg = colors.punctuation },
    
    -- 预处理
    PreProc = { fg = colors.yellow },
    ["@preproc"] = { link = "PreProc" },
    ["@define"] = { fg = colors.purple },
    ["@macro"] = { fg = colors.purple },
    
    -- UI 元素
    Cursor = { fg = colors.bg, bg = colors.blue },
    CursorLine = { bg = colors.bg_highlight },
    CursorColumn = { bg = colors.bg_highlight },
    ColorColumn = { bg = colors.bg_highlight },
    LineNr = { fg = colors.fg_gutter },
    CursorLineNr = { fg = colors.fg },
    SignColumn = { fg = colors.fg_gutter, bg = colors.bg },
    
    -- 搜索
    Search = { fg = colors.bg, bg = colors.dark_yellow },
    IncSearch = { fg = colors.bg, bg = colors.dark_yellow },
    
    -- 选择
    Visual = { bg = colors.bg_visual },
    VisualNOS = { bg = colors.bg_visual },
    
    -- 折叠
    Folded = { fg = colors.comment },
    FoldColumn = { fg = colors.fg_gutter },
    
    -- 差异
    DiffAdd = { fg = colors.git_add, bg = colors.bg },
    DiffChange = { fg = colors.git_change, bg = colors.bg },
    DiffDelete = { fg = colors.git_delete, bg = colors.bg },
    DiffText = { fg = colors.git_change, bg = colors.bg },
    
    -- 弹出菜单
    Pmenu = { fg = colors.fg, bg = colors.bg_popup },
    PmenuSel = { fg = colors.bg, bg = colors.blue },
    PmenuSbar = { bg = colors.bg_highlight },
    PmenuThumb = { bg = colors.fg_gutter },
    
    -- 状态行
    StatusLine = { fg = colors.fg, bg = colors.bg_dark },
    StatusLineNC = { fg = colors.comment, bg = colors.bg_dark },
    
    -- 标签页
    TabLine = { fg = colors.comment, bg = colors.bg_dark },
    TabLineFill = { bg = colors.bg_dark },
    TabLineSel = { fg = colors.fg, bg = colors.blue },
    
    -- 分割线
    VertSplit = { fg = colors.fg_border },
    WinSeparator = { fg = colors.fg_border },
    
    -- 错误和警告
    Error = { fg = colors.error },
    ErrorMsg = { fg = colors.error },
    WarningMsg = { fg = colors.warning },
    
    -- 诊断
    DiagnosticError = { fg = colors.error },
    DiagnosticWarn = { fg = colors.warning },
    DiagnosticInfo = { fg = colors.info },
    DiagnosticHint = { fg = colors.hint },
    DiagnosticUnderlineError = { sp = colors.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = colors.warning, undercurl = true },
    DiagnosticUnderlineInfo = { sp = colors.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = colors.hint, undercurl = true },
    
    -- 浮动窗口
    FloatBorder = { fg = colors.fg_border },
    FloatTitle = { fg = colors.fg, bg = colors.bg_popup },
    
    -- 括号匹配
    MatchParen = { fg = colors.blue, underline = true },
    
    -- 缩进线
    IndentBlanklineChar = { fg = colors.fg_border },
    IndentBlanklineContextChar = { fg = colors.blue },
    
    -- Git 标志
    GitSignsAdd = { fg = colors.git_add },
    GitSignsChange = { fg = colors.git_change },
    GitSignsDelete = { fg = colors.git_delete },
    
    -- Telescope
    TelescopeNormal = { fg = colors.fg, bg = colors.bg_popup },
    TelescopeBorder = { fg = colors.fg_border, bg = colors.bg_popup },
    TelescopePromptNormal = { fg = colors.fg, bg = colors.bg_popup },
    TelescopePromptBorder = { fg = colors.fg_border, bg = colors.bg_popup },
    TelescopePromptTitle = { fg = colors.fg, bg = colors.bg_popup },
    TelescopeResultsTitle = { fg = colors.fg, bg = colors.bg_popup },
    TelescopePreviewTitle = { fg = colors.fg, bg = colors.bg_popup },
    TelescopeSelection = { fg = colors.fg, bg = colors.bg_visual },
    
    -- TreeSitter 特定高亮
    ["@text.literal"] = { fg = colors.text_literal },
    ["@text.reference"] = { fg = colors.link_text },
    ["@text.title"] = { fg = colors.title },
    ["@text.uri"] = { fg = colors.link_uri },
    ["@text.emphasis"] = { fg = colors.emphasis },
    ["@text.strong"] = { fg = colors.title, bold = true },
    ["@text.strike"] = { strikethrough = true },
    ["@text.quote"] = { fg = colors.comment },
    ["@text.note"] = { fg = colors.info },
    ["@text.warning"] = { fg = colors.warning },
    ["@text.danger"] = { fg = colors.error },
    
    -- LSP
    LspReferenceText = { bg = colors.bg_visual },
    LspReferenceRead = { bg = colors.bg_visual },
    LspReferenceWrite = { bg = colors.bg_visual },
    LspSignatureActiveParameter = { fg = colors.blue, bold = true },
    
    -- LSP 语义高亮
    ["@lsp.type.variable"] = { fg = colors.variable },
    ["@lsp.type.function"] = { fg = colors.blue },
    ["@lsp.type.method"] = { fg = colors.blue },
    ["@lsp.type.property"] = { fg = colors.property },
    ["@lsp.type.parameter"] = { fg = colors.variable },
    ["@lsp.type.type"] = { fg = colors.type },
    ["@lsp.type.class"] = { fg = colors.type },
    ["@lsp.type.interface"] = { fg = colors.type },
    ["@lsp.type.enum"] = { fg = colors.enum },
    ["@lsp.type.namespace"] = { fg = colors.purple },
    ["@lsp.type.keyword"] = { fg = colors.purple, italic = true },
    ["@lsp.type.string"] = { fg = colors.string },
    ["@lsp.type.number"] = { fg = colors.number },
    ["@lsp.type.boolean"] = { fg = colors.boolean },
    ["@lsp.type.comment"] = { fg = colors.comment, italic = true },
    
    -- Flash.nvim 高亮组
    FlashLabel = { fg = colors.bg, bg = colors.blue, bold = true },
    FlashCurrent = { fg = colors.bg, bg = colors.purple, bold = true },
    FlashMatch = { fg = colors.bg, bg = colors.dark_yellow },
    FlashBackdrop = { fg = colors.comment },
    FlashPrompt = { fg = colors.fg, bg = colors.bg_popup },
    FlashPromptIcon = { fg = colors.blue },
  }
  
  -- 如果有自定义高亮函数，调用它
  if opts.on_highlights then
    opts.on_highlights(highlights, colors)
  end
  
  -- 应用高亮组
  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
  
  -- 设置终端颜色
  if opts.terminal_colors ~= false then
    local terminal_colors = require("pretty_dark.colors").terminal_colors
    for name, color in pairs(terminal_colors) do
      vim.g["terminal_color_" .. name:upper()] = color
    end
  end
end

return M