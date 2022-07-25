local fn = vim.fn
local lsp_buf = vim.lsp.buf

local F = require("user.functional")
local tbl_merge = require("user.utils").tbl_merge

local navic = require("nvim-navic")
local illuminate = require("illuminate")

local on_attach = function(client, bufnr)
  client.server_capabilities.document_formatting = false
  client.server_capabilities.document_range_formatting = false

  illuminate.on_attach(client)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

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

local config = require("user.config")
local mason_lspconfig = require("mason-lspconfig")
local mason_registry = require("mason-registry")
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lsp_configs = config.lsp_configs

mason_lspconfig.setup({
  ensure_installed = config.lsp_ensure_installed,
  log_level = vim.log.levels.ERROR,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

for _, server_name in pairs(mason_lspconfig.get_installed_servers()) do
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
  if server_name == "rust_analyzer" then
    opts.cmd = { mason_registry.get_package("rust-analyzer"):get_install_path() .. "/rust-analyzer" }
    require("rust-tools").setup({ server = opts })
  else
    lspconfig[server_name].setup(opts)
  end
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

vim.keymap.set("n", "<space>li", "<CMD>LspInstall<CR>")
vim.keymap.set("n", "<space>;", "<CMD>Mason<CR>")

-- show settings of lspserver
local function lsp_settings()
  local clients = vim.lsp.buf_get_clients()
  local settings = D(F.map(clients, function(client)
    return client.config.settings
  end))
  D(settings)
end

vim.api.nvim_create_user_command("LspSettings", lsp_settings, {})

-- show lsp root
local function lsp_root()
  local clients = F.values(vim.lsp.buf_get_clients())
  local root_dirs = D(F.map(clients, function(client)
    return client.config.root_dir
  end))
  D(root_dirs)
end

vim.api.nvim_create_user_command("LspRoot", lsp_root, {})

vim.keymap.set("n", "<space>lds", "<CMD>LspSettings<CR>")
vim.keymap.set("n", "<space>ldr", "<CMD>LspRoot<CR>")
