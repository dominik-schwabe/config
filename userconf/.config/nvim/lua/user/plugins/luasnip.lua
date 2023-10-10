require("luasnip.loaders.from_vscode").lazy_load()
local luasnip = require("luasnip")
luasnip.setup({
  history = true,
  delete_check_events = "InsertLeave",
})
luasnip.filetype_extend("javascript", { "html" })
luasnip.filetype_extend("typescript", { "html" })
luasnip.filetype_extend("javascriptreact", { "html" })
luasnip.filetype_extend("typescriptreact", { "html" })
luasnip.filetype_extend("markdown", { "license" })
luasnip.filetype_extend("text", { "license" })
