local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

require("trouble").setup()

map("v", "ä", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", def_opt)
map("n", "ä", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", def_opt)
map("i", "ä", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", def_opt)
