local map = vim.api.nvim_set_keymap
local api = vim.api
local lsp = vim.lsp
local cmd = vim.cmd
local fn = vim.fn

local def_opt = { noremap = true, silent = true }
local nore_opt = { noremap = true }

lsp.handlers["textDocument/codeAction"] = require("lsputil.codeAction").code_action_handler

local on_attach = function(client, bufnr)
	local function buf_set_keymap(...)
		api.nvim_buf_set_keymap(bufnr, ...)
	end
	client.resolved_capabilities.document_formatting = false
	client.resolved_capabilities.document_range_formatting = false

	require("lsp_signature").on_attach()
	require("illuminate").on_attach(client)
	buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", def_opt)
	buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", def_opt)
	buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", def_opt)
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", def_opt)
	buf_set_keymap("n", "<space>k", "<cmd>lua vim.lsp.buf.signature_help()<CR>", def_opt)
	buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", def_opt)
	buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", def_opt)
	buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", def_opt)
	buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", def_opt)
	buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", def_opt)
	buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", def_opt)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", def_opt)
	buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", def_opt)
	buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", def_opt)
	buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", def_opt)
	buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", def_opt)
end

local config = require("config")
local lsp_installer = require("nvim-lsp-installer")
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lsp_configs = config.lsp_configs
lsp_configs.jsonls = {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
		},
	},
}

lsp_installer.settings({
	log_level = vim.log.levels.ERROR,
	max_concurrent_installers = 4,
})

lsp_installer.on_server_ready(function(server)
	local opts = lsp_configs[server.name] or {}
	opts.on_attach = on_attach
	opts.capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
	opts.flags = { debounce_text_changes = 150 }
	server:setup(opts)
end)

local null_ls = require("null-ls")
local sources = {}
for builtin, options in pairs(config.null_ls) do
	for _, source in pairs(options) do
		sources[#sources + 1] = null_ls.builtins[builtin][source]
	end
end

map("n", "<space>f", '<cmd>echo "formatter is not loaded"<CR>', def_opt)

local function nullls_on_attach(client, bufnr)
	local function buf_set_keymap(...)
		api.nvim_buf_set_keymap(bufnr, ...)
	end
	buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", def_opt)
end
null_ls.config({ sources = sources })
lspconfig["null-ls"].setup({
	on_attach = nullls_on_attach,
})

local signs = require("config").lsp_signs

for type, icon in pairs(signs) do
	local hl = "LspDiagnosticsSign" .. type
	fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

cmd([[au CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])

map("n", "<space>ll", "<CMD>LspInfo<CR>", nore_opt)
map("n", "<space>lr", "<CMD>LspRestart<CR>", nore_opt)
