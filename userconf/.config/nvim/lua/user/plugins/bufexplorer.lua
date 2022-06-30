-- TODO: replace with modern option
local g = vim.g

g.bufExplorerDefaultHelp = 0
g.bufExplorerDetailedHelp = 0
g.bufExplorerFindActive = 1
g.bufExplorerShowDirectories = 0
g.bufExplorerShowNoName = 0
g.bufExplorerShowRelativePath = 1
g.bufExplorerShowTabBuffer = 1
g.bufExplorerShowUnlisted = 0
g.bufExplorerSortBy = "mru"
g.bufExplorerSplitBelow = 1
g.bufExplorerSplitRight = 1
g.bufExplorerDisableDefaultKeyMapping = 1

vim.keymap.set({ "n", "x", "i" }, "<F2>", "<ESC>:ToggleBufExplorer<CR>")
vim.keymap.set("t", "<F2>", "<CMD>ToggleBufExplorer<CR>")
