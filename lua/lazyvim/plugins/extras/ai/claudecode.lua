-- Claude Code - Claude AI 集成代码助手
-- 核心功能：
-- 1. 集成 Anthropic Claude AI 进行代码分析和修改
-- 2. 支持代码补全、重构建议和错误修复
-- 3. 提供智能的代码生成和优化建议
-- 4. 支持项目级别的代码理解和修改

return {
  -- 主插件：Claude Code 集成
  -- 功能：提供 Claude AI 的 Neovim 集成，支持代码分析和修改
  "coder/claudecode.nvim",
  
  -- 配置选项：使用默认配置
  opts = {},

  -- 键盘快捷键配置：提供完整的 Claude Code 访问方式
  keys = {
    -- AI 前缀键：所有AI相关操作都以 <leader>a 开头
    { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
    
    -- 基础操作
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "切换Claude显示" },    -- 打开/关闭 Claude 界面
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "聚焦Claude窗口" }, -- 聚焦到 Claude 窗口
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "继续Claude会话" }, -- 恢复之前中断的对话
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "继续Claude操作" }, -- 继续当前操作

    -- 内容发送
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "添加当前缓冲区" }, -- 将当前文件内容发送给 Claude
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "发送选中内容给Claude" }, -- 发送选中的文本给 Claude
    
    -- 文件树集成：支持从文件管理器发送文件
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "添加文件",
      ft = { "NvimTree", "neo-tree", "oil" }, -- 特定文件类型下使用
    },

    -- 差异管理：处理 Claude 的代码修改建议
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "接受差异" }, -- 接受 Claude 的代码修改建议
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "拒绝差异" },   -- 拒绝 Claude 的代码修改建议
  },
}
