-- 文件类型检测配置
-- 为HTTP请求文件添加语法高亮支持
vim.filetype.add({
  extension = {
    ["http"] = "http", -- 将.http扩展名识别为HTTP文件类型
  },
})
-- Kulala：REST API 测试工具插件
-- 功能说明：
-- 1. 在Neovim中直接进行REST API测试，支持HTTP和GraphQL请求
-- 2. 提供丰富的快捷键操作：执行请求、复制为cURL、管理环境变量等
-- 3. 支持多种请求类型：GET、POST、PUT、DELETE等HTTP方法
-- 4. 提供实时的请求响应查看和统计信息
return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http", -- 文件类型：HTTP文件

    -- 快捷键配置
    keys = {
      -- 主前缀：<leader>R 表示REST相关操作
      { "<leader>R", "", desc = "+Rest" }, -- REST操作前缀说明

      -- 主要功能快捷键
      { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" }, -- 打开便签板
      { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" }, -- 复制为cURL命令
      { "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" }, -- 从cURL粘贴
      { "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Set environment", ft = "http" }, -- 设置环境变量

      -- GraphQL相关操作
      {
        "<leader>Rg",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema", -- 下载GraphQL架构
        ft = "http",
      },

      -- 导航和查看操作
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" }, -- 查看当前请求详情
      { "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" }, -- 跳转到下一个请求
      { "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" }, -- 跳转到上一个请求
      { "<leader>Rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = "http" }, -- 关闭窗口

      -- 请求执行操作
      { "<leader>Rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request" }, -- 重放最后一个请求
      { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" }, -- 发送请求
      { "<leader>RS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" }, -- 显示统计信息
      { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" }, -- 切换headers/body视图
    },

    -- 插件配置选项（使用默认配置）
    opts = {},
  },
  -- Tree-sitter语法解析器支持
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "http", "graphql" }, -- 安装HTTP和GraphQL语法解析器
    },
  },
}
