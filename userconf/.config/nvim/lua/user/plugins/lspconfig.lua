local fn = vim.fn
local lsp = vim.lsp
local lsp_buf = lsp.buf
local diagnostic = vim.diagnostic

local def_opt = { silent = true }

local F = require("user.functional")
local utils = require("user.utils")

local navic = F.load("nvim-navic")

local on_attach = function(client, bufnr)
  if navic and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  local map_opt = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", lsp_buf.declaration, map_opt)
  vim.keymap.set("n", "gd", lsp_buf.definition, map_opt)
  vim.keymap.set("n", "gt", lsp_buf.type_definition, map_opt)
  vim.keymap.set("n", "gr", lsp_buf.references, map_opt)
  vim.keymap.set("n", "gi", lsp_buf.implementation, map_opt)
  vim.keymap.set("n", "gs", lsp_buf.signature_help, map_opt)
  vim.keymap.set("n", "gh", lsp_buf.hover, map_opt)
  vim.keymap.set("n", "gm", diagnostic.open_float, map_opt)
  vim.keymap.set("n", "gn", diagnostic.goto_next, map_opt)
  vim.keymap.set("n", "gp", diagnostic.goto_prev, map_opt)
  vim.keymap.set("n", "gll", lsp.codelens.refresh, map_opt)
  vim.keymap.set("n", "glr", lsp.codelens.run, map_opt)
  vim.keymap.set("n", "gli", lsp_buf.incoming_calls, map_opt)
  vim.keymap.set("n", "glo", lsp_buf.outgoing_calls, map_opt)
  vim.keymap.set("n", "<space>qwa", lsp_buf.add_workspace_folder, map_opt)
  vim.keymap.set("n", "<space>qwr", lsp_buf.remove_workspace_folder, map_opt)
  vim.keymap.set("n", "<space>qwl", function()
    D(lsp_buf.list_workspace_folders())
  end, map_opt)
  vim.keymap.set("n", "<space>rn", lsp_buf.rename, map_opt)
  vim.keymap.set("n", "<space>ca", lsp_buf.code_action, map_opt)
end

local config = require("user.config")
local lspconfig = require("lspconfig")
local lsp_configs = config.lsp_configs
local ensure_installed = config.minimal and {} or config.lsp_ensure_installed
local mason_ensure_installed = config.minimal and {} or config.mason_ensure_installed

F.load("mason-lspconfig", function(mason_lspconfig)
  mason_lspconfig.setup({
    ensure_installed = ensure_installed,
    log_level = vim.log.levels.ERROR,
  })

  local mason_registry = require("mason-registry")

  F.load("mason-tool-installer", function(mti)
    mti.setup({
      ensure_installed = mason_ensure_installed,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
    })
  end)

  local cmp_nvim_lsp = F.load("cmp_nvim_lsp")
  local capabilities = cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities()

  for _, server_name in pairs(mason_lspconfig.get_installed_servers()) do
    local opts = lsp_configs[server_name] or {}
    opts.on_attach = on_attach
    opts.capabilities = capabilities
    if server_name == "jsonls" then
      local schemastore = F.load("schemastore")
      local schemas = schemastore and schemastore.json.schemas()
      opts = utils.tbl_merge(opts, {
        settings = { json = { schemas = { schemas } } },
      })
    end
    if server_name == "clangd" then
      local cap = vim.lsp.protocol.make_client_capabilities()
      cap.offsetEncoding = { "utf-16" }
      opts.capabilities = cap
    end
    opts.lsp_flags = {
      debounce_text_changes = 250,
    }
    if server_name == "rust_analyzer" then
      opts.cmd = { mason_registry.get_package("rust-analyzer"):get_install_path() .. "/rust-analyzer" }
      opts.settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        },
      }
      F.load("rust-tools", function(rust_tools)
        rust_tools.setup({ server = opts })
      end)
    else
      lspconfig[server_name].setup(opts)
    end
  end
end)

for type, icon in pairs(config.lsp_signs) do
  local hl = "LspDiagnosticsSign" .. type
  fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

F.load("nvim-lightbulb", function(lightbulb)
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    callback = lightbulb.update_lightbulb,
  })
end)

vim.keymap.set("n", "<space>ll", "<CMD>LspInfo<CR>")
vim.keymap.set("n", "<space>lr", "<CMD>LspRestart<CR>")

vim.keymap.set("n", "<space>m", "<CMD>Mason<CR>")

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

vim.keymap.set("n", "<space>f", function()
  vim.lsp.buf.format({
    async = true,
    filter = function(a)
      return F.any(config.format_clients, function(client)
        return client == a["name"]
      end)
    end,
  })
end, def_opt)

vim.api.nvim_create_user_command("LspRoot", lsp_root, {})

vim.keymap.set("n", "<space>lds", lsp_settings)
vim.keymap.set("n", "<space>ldr", lsp_root)
