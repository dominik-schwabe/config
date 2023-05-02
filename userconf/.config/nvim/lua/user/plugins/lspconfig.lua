local fn = vim.fn
local lsp = vim.lsp
local lsp_buf = lsp.buf
local diagnostic = vim.diagnostic

local def_opt = { silent = true }

local F = require("user.functional")
local U = require("user.utils")

F.load("neodev", function(neodev)
  neodev.setup({})
end)

local function get_active_client_by_name(bufnr, servername)
  return F.find(vim.lsp.get_active_clients({ bufnr = bufnr }), function(client)
    return client.name == servername
  end)
end

local map_opt = { noremap = true, silent = true }
vim.keymap.set("n", "gD", lsp_buf.declaration, U.desc(map_opt, "go to declaration"))
vim.keymap.set("n", "gd", lsp_buf.definition, U.desc(map_opt, "go to definition"))
vim.keymap.set("n", "gt", lsp_buf.type_definition, U.desc(map_opt, "go to type definition"))
vim.keymap.set("n", "gr", lsp_buf.references, U.desc(map_opt, "go to reference"))
vim.keymap.set("n", "gi", lsp_buf.implementation, U.desc(map_opt, "go to implementation"))
vim.keymap.set("n", "gs", lsp_buf.signature_help, U.desc(map_opt, "show signature help"))
vim.keymap.set("n", "gh", lsp_buf.hover, U.desc(map_opt, "show hover info"))
vim.keymap.set("n", "gm", diagnostic.open_float, U.desc(map_opt, "show diagnostics under cursor"))
vim.keymap.set("n", "gn", diagnostic.goto_next, U.desc(map_opt, "go to next diagnostic"))
vim.keymap.set("n", "gp", diagnostic.goto_prev, U.desc(map_opt, "go to previous diagnostic"))
vim.keymap.set("n", "gll", lsp.codelens.refresh, U.desc(map_opt, "refresh codelens"))
vim.keymap.set("n", "glr", lsp.codelens.run, U.desc(map_opt, "run codelens"))
vim.keymap.set("n", "gli", lsp_buf.incoming_calls, U.desc(map_opt, "show incoming calls"))
vim.keymap.set("n", "glo", lsp_buf.outgoing_calls, U.desc(map_opt, "show outgoing calls"))
vim.keymap.set("n", "<space>awa", lsp_buf.add_workspace_folder, U.desc(map_opt, "add workspace folder"))
vim.keymap.set("n", "<space>awr", lsp_buf.remove_workspace_folder, U.desc(map_opt, "remove workspace folder"))
vim.keymap.set("n", "<space>awl", function()
  print(vim.inspect(lsp_buf.list_workspace_folders()))
end, U.desc(map_opt, "list loaded workspaces"))
vim.keymap.set("n", "<space>rn", lsp_buf.rename, U.desc(map_opt, "rename variable"))
vim.keymap.set("n", "<space>ca", lsp_buf.code_action, U.desc(map_opt, "select code action"))

vim.api.nvim_create_autocmd({ "LspAttach" }, {
  callback = function(args)
    vim.schedule(function()
      local buf_map_opt = { noremap = true, silent = true, buffer = args.bufnr }
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local should_attach = not vim.b[args.buf].is_big_buffer or client.name == "null-ls"
      -- client.server_capabilities.semanticTokensProvider = nil
      if should_attach then
        -- F.load("nvim-navic", function(navic)
        --   if client.server_capabilities.documentSymbolProvider then
        --     navic.attach(client, args.buf)
        --   end
        -- end)

        if client.name == "rust_analyzer" then
          F.load("rust-tools", function(rt)
            vim.keymap.set("n", "gh", rt.hover_actions.hover_actions, U.desc(buf_map_opt, "rust hover actions"))
          end)
        end
      else
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end
    end)
  end,
})

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
    opts.capabilities = capabilities
    opts.lsp_flags = {
      debounce_text_changes = 250,
    }
    if server_name == "jsonls" then
      F.load("schemastore", function(schemastore)
        opts = U.tbl_merge(opts, {
          settings = { json = { schemas = schemastore.json.schemas() } },
        })
      end)
    elseif server_name == "clangd" then
      opts.capabilities = vim.lsp.protocol.make_client_capabilities()
      opts.capabilities.offsetEncoding = { "utf-16" }
    end
    if server_name == "rust_analyzer" then
      opts.cmd = { vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer" }
      opts.settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        },
      }
      F.load("rust-tools", function(rt)
        local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
        local codelldb_path = extension_path .. "adapter/codelldb"
        local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
        rt.setup({
          server = opts,
          dap = {
            adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
          },
        })
      end)
    else
      lspconfig[server_name].setup(opts)
    end
  end
end)

for type, icon in pairs(F.subset(config.icons, { "Error", "Warning", "Hint", "Information" })) do
  local hl = "LspDiagnosticsSign" .. type
  fn.sign_define(hl, { text = icon .. " ", texthl = hl, numhl = "" })
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

vim.keymap.set("n", "<space>m", "<CMD>Mason<CR>", { desc = "show mason (install lsp, formatter ...)" })

vim.keymap.set({ "n", "x" }, "<space>f", function()
  vim.lsp.buf.format({
    async = true,
    filter = function(a)
      return F.contains(config.format_clients, a.name)
    end,
  })
end, U.desc(def_opt, "format buffer"))

-- show settings of lspserver
local function lsp_settings()
  local clients = vim.lsp.buf_get_clients()
  print(vim.inspect(F.map(clients, function(client)
    return client.config.settings
  end)))
end

vim.api.nvim_create_user_command("LspSettings", lsp_settings, {})
vim.keymap.set("n", "<space>lds", lsp_settings, { desc = "show lsp settings" })
