local npairs_ok, npairs = pcall(require, "nvim-autopairs")
if not npairs_ok then
  return
end

npairs.setup {
  check_ts = false, -- 禁用 treesitter 检查（因为已禁用 treesitter）
  -- ts_config = {
  --   lua = { "string", "source" },
  --   javascript = { "string", "template_string" },
  -- },
  fast_wrap = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'Search',
    highlight_grey='Comment'
  },
}

-- CMP 相关配置已禁用（因为禁用了代码补全功能）
-- local cmp_autopairs = require "nvim-autopairs.completion.cmp"
-- local cmp_status_ok, cmp = pcall(require, "cmp")
-- if not cmp_status_ok then
--   return
-- end
-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
