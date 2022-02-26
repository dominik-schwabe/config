local map = vim.api.nvim_set_keymap
local api = vim.api

local def_opt = { noremap = true, silent = true }

local config = require("myconfig.config")
local null_ls = require("null-ls")
local sources = {}
for builtin, options in pairs(config.null_ls) do
  local target =  null_ls.builtins[builtin]
  for key, value in pairs(options) do
    if type(key) == "string" then
      sources[#sources + 1] = target[key].with(value)
    else
      sources[#sources + 1] = target[value]
    end
  end
end

map("n", "<space>f", '<cmd>echo "formatter is not loaded"<CR>', def_opt)

local function nullls_on_attach(client, bufnr)
  local function buf_set_keymap(...)
    api.nvim_buf_set_keymap(bufnr, ...)
  end
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", def_opt)
end

null_ls.setup({
  on_attach = nullls_on_attach,
  sources = sources,
})
