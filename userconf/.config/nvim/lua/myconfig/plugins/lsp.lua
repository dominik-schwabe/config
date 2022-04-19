local cmd = vim.cmd
local fn = vim.fn
local lsp = vim.lsp
local lsp_buf = vim.lsp.buf

local nore_opt = { noremap = true }
local tbl_merge = require("myconfig.utils").tbl_merge

local on_attach = function(client, bufnr)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

  require("illuminate").on_attach(client)
  local map_opt = { buffer = bufnr, noremap = true, silent = true }
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

lspconfig["r_language_server"].setup({
  on_attach = on_attach,
  capabilities = cmp_nvim_lsp.update_capabilities(lsp.protocol.make_client_capabilities()),
  flags = { debounce_text_changes = 150 },
  settings = config.lsp_configs.r_language_server.settings,
})

lsp_installer.settings({
  log_level = vim.log.levels.ERROR,
  max_concurrent_installers = 4,
})

lsp_installer.on_server_ready(function(server)
  local opts = lsp_configs[server.name] or {}
  opts.on_attach = on_attach
  local capabilities = lsp.protocol.make_client_capabilities()
  if server.name == "clangd" then
    capabilities.offsetEncoding = { "utf-16" }
  elseif server.name == "jsonls" then
    opts = tbl_merge(opts, {
      settings = { json = { schemas = { require("schemastore").json.schemas() } } },
    })
  end
  opts.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  opts.flags = { debounce_text_changes = 150 }
  server:setup(opts)
end)

local signs = config.lsp_signs

for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = require("nvim-lightbulb").update_lightbulb,
})

vim.keymap.set("n", "<space>ll", "<CMD>LspInfo<CR>", nore_opt)
vim.keymap.set("n", "<space>lr", "<CMD>LspRestart<CR>", nore_opt)
