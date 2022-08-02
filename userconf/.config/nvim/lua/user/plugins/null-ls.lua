local config = require("user.config")
local null_ls = require("null-ls")
local util = require("vim.lsp.util")

local def_opt = { silent = true }

local sources = {}
for builtin, options in pairs(config.null_ls) do
  local target = null_ls.builtins[builtin]
  for key, value in pairs(options) do
    if type(key) == "string" then
      sources[#sources + 1] = target[key].with(value)
    else
      sources[#sources + 1] = target[value]
    end
  end
end

vim.keymap.set("n", "<space>f", function()
  vim.lsp.buf.formatting()
  print("formatter is not loaded")
end, def_opt)

local function nullls_on_attach(client, bufnr)
  vim.keymap.set("n", "<space>f", function()
    local params = util.make_formatting_params({})
    client.request("textDocument/formatting", params, nil, bufnr)
  end, { buffer = bufnr })
end

null_ls.setup({
  on_attach = nullls_on_attach,
  sources = sources,
})
