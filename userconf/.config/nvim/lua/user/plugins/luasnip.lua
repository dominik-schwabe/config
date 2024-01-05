local F = require("user.functional")

require("luasnip.loaders.from_vscode").lazy_load()

local luasnip = require("luasnip")

local opts = {
  history = true,
  delete_check_events = "InsertLeave",
}

F.load("luasnip_snippets.common.snip_utils", function(snip_utils)
  snip_utils.setup()
  opts = F.extend(opts, F.subset(snip_utils, { "load_ft_func", "ft_func" }))
end)

luasnip.setup(opts)
local extensions = {
  javascript = { "html" },
  typescript = { "html" },
  javascriptreact = { "html" },
  typescriptreact = { "html" },
  markdown = { "license" },
  text = { "license" },
}
F.foreach_items(extensions, luasnip.filetype_extend)
