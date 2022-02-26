local map = vim.api.nvim_set_keymap
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local lsp = vim.lsp

local def_opt = { noremap = true, silent = true }
local nore_opt = { noremap = true }

-- local lsp_signature = require("lsp_signature")

-- lsp_signature.setup({
-- 	floating_window = false,
-- })

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    api.nvim_buf_set_keymap(bufnr, ...)
  end
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

  -- lsp_signature.on_attach()
  require("illuminate").on_attach(client)
  buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", def_opt)
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", def_opt)
  buf_set_keymap("n", "<C-y>", "<Cmd>lua vim.lsp.buf.hover()<CR>", def_opt)
  buf_set_keymap("i", "<C-y>", "<Cmd>lua vim.lsp.buf.hover()<CR>", def_opt)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", def_opt)
  buf_set_keymap("n", "<C-e>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", def_opt)
  buf_set_keymap("i", "<C-e>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", def_opt)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", def_opt)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", def_opt)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", def_opt)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", def_opt)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", def_opt)
  buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", def_opt)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", def_opt)
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

cmd([[au CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])

map("n", "<space>ll", "<CMD>LspInfo<CR>", nore_opt)
map("n", "<space>lr", "<CMD>LspRestart<CR>", nore_opt)
