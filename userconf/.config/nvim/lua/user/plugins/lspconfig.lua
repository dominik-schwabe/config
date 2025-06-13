local config = require("user.config")
local F = require("user.functional")

F.load("neodev", function(neodev)
  neodev.setup({})
end)

local function get_active_client_by_name(bufnr, servername)
  return F.find(vim.lsp.get_active_clients({ bufnr = bufnr }), function(client)
    return client.name == servername
  end)
end

local function desc(opts, description)
  F.extend(opts, { desc = description })
end

local function hover()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ "vim", "help" }, filetype) then
    vim.cmd("h " .. vim.fn.expand("<cword>"))
  elseif vim.tbl_contains({ "man" }, filetype) then
    vim.cmd("Man " .. vim.fn.expand("<cword>"))
  else
    if vim.fn.expand("%:t") == "Cargo.toml" then
      local crates = F.load("crates")
      if crates and crates.popup_available() then
        crates.show_popup()
        return
      end
    end
    vim.lsp.buf.hover({ border = config.border })
  end
end

local map_opt = { noremap = true, silent = true }
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, desc(map_opt, "go to declaration"))
vim.keymap.set("n", "gd", vim.lsp.buf.definition, desc(map_opt, "go to definition"))
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, desc(map_opt, "go to type definition"))
vim.keymap.set(
  { "n", "i" },
  "<C-s>",
  F.f(vim.lsp.buf.signature_help)({ border = config.border }),
  desc(map_opt, "show signature help")
)
vim.keymap.set("n", "gh", hover, desc(map_opt, "show hover info"))
vim.keymap.set(
  "n",
  "gm",
  F.f(vim.diagnostic.open_float)({ border = config.border }),
  desc(map_opt, "show diagnostics under cursor")
)
vim.keymap.set("n", "gn", F.f(vim.diagnostic.jump)({ count = 1, float = true }), desc(map_opt, "go to next diagnostic"))
vim.keymap.set(
  "n",
  "gp",
  F.f(vim.diagnostic.jump)({ count = -1, float = true }),
  desc(map_opt, "go to previous diagnostic")
)
vim.keymap.set("n", "gll", vim.lsp.codelens.refresh, desc(map_opt, "refresh codelens"))
vim.keymap.set("n", "glr", vim.lsp.codelens.run, desc(map_opt, "run codelens"))
vim.keymap.set("n", "gli", vim.lsp.buf.incoming_calls, desc(map_opt, "show incoming calls"))
vim.keymap.set("n", "glo", vim.lsp.buf.outgoing_calls, desc(map_opt, "show outgoing calls"))
vim.keymap.set("n", "<space>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, desc(map_opt, "show outgoing calls"))
vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, desc(map_opt, "add workspace folder"))
vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, desc(map_opt, "remove workspace folder"))
vim.keymap.set("n", "<space>wl", function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, desc(map_opt, "list loaded workspaces"))

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false,
})

vim.api.nvim_create_autocmd({ "LspAttach" }, {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = vim.schedule_wrap(function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local should_attach = not vim.b[args.buf].is_big_buffer or client.name == "null-ls"
    if not should_attach then
      vim.lsp.buf_detach_client(args.buf, args.data.client_id)
    end
  end),
})

vim.api.nvim_create_autocmd({ "LspDetach" }, {
  group = vim.api.nvim_create_augroup("LspStopWithLastClient", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client.attached_buffers then
      return
    end
    for buf_id in pairs(client.attached_buffers) do
      if buf_id ~= args.buf then
        return
      end
    end
    client:stop()
  end,
  desc = "Stop lsp client when no buffer is attached",
})

local virtual_lines = false

local function set_diagnostic_config(virtual)
  if virtual then
    vim.diagnostic.config({ virtual_lines = { current_line = true } })
  else
    vim.diagnostic.config({ virtual_lines = false })
  end
end

set_diagnostic_config(false)

vim.keymap.set("n", "td", function()
  virtual_lines = not virtual_lines
  set_diagnostic_config(virtual_lines)
end, { desc = "toggle diagnostics" })

F.load("cmp_nvim_lsp", function(cmp_nvim_lsp)
  vim.lsp.config("*", { capabilities = cmp_nvim_lsp.default_capabilities() })
end)

for server_name, opts in pairs(config.lsp_configs) do
  if not opts.lspconfig_ignore then
    if opts.lspconfig_hook then
      opts.lspconfig_hook(opts)
    end
    vim.lsp.config(server_name, opts)
  end
end

F.load("mason-lspconfig", function(mason_lspconfig)
  mason_lspconfig.setup({
    ensure_installed = config.minimal and {} or config.lsp_ensure_installed,
    log_level = vim.log.levels.ERROR,
    automatic_enable = {
      exclude = { "rust_analyzer" },
    },
  })
end)

F.load("mason-tool-installer", function(mti)
  mti.setup({
    ensure_installed = config.minimal and {} or config.mason_ensure_installed,
    auto_update = false,
    run_on_start = true,
    start_delay = 3000,
  })
end)

for type, icon in pairs(F.subset(config.icons, { "Error", "Warn", "Hint", "Info" })) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.api.nvim_create_augroup("UserLsp", {})

F.load("nvim-lightbulb", function(lightbulb)
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = "UserLsp",
    callback = lightbulb.update_lightbulb,
  })
end)

vim.keymap.set("n", "<space>ll", "<CMD>LspInfo<CR>", { desc = "show loaded lsp servers" })
vim.keymap.set("n", "<space>lr", "<CMD>LspRestart<CR>", { desc = "restart lsp server" })
vim.keymap.set("n", "<space>th", function()
  local new_setting = not vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(new_setting)
  print("inlay hints: " .. (new_setting and "on" or "off"))
end, { desc = "toggle inlay hints" })

vim.keymap.set("n", "<space>om", "<CMD>Mason<CR>", { desc = "show mason (install lsp, formatter ...)" })

-- show settings of lspserver
local function lsp_settings()
  local clients = vim.lsp.buf_get_clients()
  print(vim.inspect(F.map(clients, function(client)
    return client.config.settings
  end)))
end

vim.api.nvim_create_user_command("LspSettings", lsp_settings, {})
vim.keymap.set("n", "<space>lds", lsp_settings, { desc = "show lsp settings" })
