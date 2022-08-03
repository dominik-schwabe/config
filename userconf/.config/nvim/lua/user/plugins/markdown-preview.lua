local g = vim.g
g.mkdp_auto_start = 0
g.mkdp_auto_close = 0

vim.keymap.set("n", "<space>qm", "<CMD>MarkdownPreviewToggle<CR>")
