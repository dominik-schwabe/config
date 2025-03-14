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
    vim.lsp.buf.hover()
  end
end

local map_opt = { noremap = true, silent = true }
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, desc(map_opt, "go to declaration"))
vim.keymap.set("n", "gd", vim.lsp.buf.definition, desc(map_opt, "go to definition"))
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, desc(map_opt, "go to type definition"))
vim.keymap.set("n", "gr", vim.lsp.buf.references, desc(map_opt, "go to reference"))
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, desc(map_opt, "go to implementation"))
vim.keymap.set({ "n", "i" }, "<C-s>", vim.lsp.buf.signature_help, desc(map_opt, "show signature help"))
vim.keymap.set("n", "gh", hover, desc(map_opt, "show hover info"))
vim.keymap.set("n", "gm", vim.diagnostic.open_float, desc(map_opt, "show diagnostics under cursor"))
vim.keymap.set("n", "gn", vim.diagnostic.goto_next, desc(map_opt, "go to next diagnostic"))
vim.keymap.set("n", "gp", vim.diagnostic.goto_prev, desc(map_opt, "go to previous diagnostic"))
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
vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, desc(map_opt, "rename variable"))
vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, desc(map_opt, "select code action"))

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

local config = require("user.config")
local lspconfig = require("lspconfig")
local lsp_configs = config.lsp_configs
local ensure_installed = config.minimal and {} or config.lsp_ensure_installed
local mason_ensure_installed = config.minimal and {} or config.mason_ensure_installed

local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = config.border }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = config.border }),
}
require("lspconfig.ui.windows").default_options.border = config.border

vim.diagnostic.config({ float = { border = config.border } })

F.load("mason-lspconfig", function(mason_lspconfig)
  mason_lspconfig.setup({
    ensure_installed = ensure_installed,
    log_level = vim.log.levels.ERROR,
  })

  local cmp_nvim_lsp = F.load("cmp_nvim_lsp")
  local capabilities = cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities()

  mason_lspconfig.setup_handlers({
    function(server_name)
      local opts = lsp_configs[server_name] or {}
      if not opts.lspconfig_ignore then
        opts.capabilities = capabilities
        opts.handlers = handlers
        opts.lsp_flags = { debounce_text_changes = 250 }
        if opts.lspconfig_hook then
          opts.lspconfig_hook(opts)
        end
        lspconfig[server_name].setup(opts)
      end
    end,
  })

  F.load("mason-tool-installer", function(mti)
    mti.setup({
      ensure_installed = mason_ensure_installed,
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
    })
  end)
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
