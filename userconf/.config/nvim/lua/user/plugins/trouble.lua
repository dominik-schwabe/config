require("trouble").setup()

vim.keymap.set({ "n", "x" }, "ä", "<CMD>TroubleToggle document_diagnostics<CR>")
