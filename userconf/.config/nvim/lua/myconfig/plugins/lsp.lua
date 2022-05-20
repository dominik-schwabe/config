local fn = vim.fn
local lsp = vim.lsp
local lsp_buf = vim.lsp.buf

local tbl_merge = require("myconfig.utils").tbl_merge

local on_attach = function(client, bufnr)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

  require("illuminate").on_attach(client)
  local map_opt = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gD", lsp_buf.declaration, map_opt)
  vim.keymap.set("n", "gd", lsp_buf.definition, map_opt)
  vim.keymap.set("n", "<C-y>", lsp_buf.hover, map_opt)
  vim.keymap.set("i", "<C-y>", lsp_buf.hover, map_opt)
  vim.keymap.set("n", "gi", lsp_buf.implementation, map_opt)
  vim.keymap.set("n", "<C-e>", lsp_buf.signature_help, map_opt)
  vim.keymap.set("i", "<C-e>", lsp_buf.signature_help, map_opt)
  vim.keymap.set("n", "<space>wa", lsp_buf.add_workspace_folder, map_opt)
  vim.keymap.set("n", "<space>wr", lsp_buf.remove_workspace_folder, map_opt)
  vim.keymap.set("n", "<space>wl", function()
    D(lsp_buf.list_workspace_folders())
  end, map_opt)
  vim.keymap.set("n", "<space>D", lsp_buf.type_definition, map_opt)
  vim.keymap.set("n", "<space>rn", lsp_buf.rename, map_opt)
  vim.keymap.set("n", "<space>ca", lsp_buf.code_action, map_opt)
  vim.keymap.set("n", "gr", lsp_buf.references, map_opt)
end

local config = require("myconfig.config")
local lsp_installer = require("nvim-lsp-installer")
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lsp_configs = config.lsp_configs

lsp_installer.setup({
  ensure_installed = config.lsp_ensure_installed,
  log_level = vim.log.levels.ERROR,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

for _, server in pairs(lsp_installer.get_installed_servers()) do
  local server_name = server.name
  local opts = lsp_configs[server_name] or {}
  opts.on_attach = on_attach
  opts.capabilities = capabilities
  if server_name == "jsonls" then
    opts = tbl_merge(opts, {
      settings = { json = { schemas = { require("schemastore").json.schemas() } } },
    })
  end
  if server_name == "clangd" then
    local cap = vim.lsp.protocol.make_client_capabilities()
    cap.offsetEncoding = { "utf-16" }
    opts.capabilities = cap
  end
  lspconfig[server_name].setup(opts)
end

for type, icon in pairs(config.lsp_signs) do
  local hl = "LspDiagnosticsSign" .. type
  fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = require("nvim-lightbulb").update_lightbulb,
})

vim.keymap.set("n", "<space>ll", "<CMD>LspInfo<CR>")
vim.keymap.set("n", "<space>lr", "<CMD>LspRestart<CR>")
