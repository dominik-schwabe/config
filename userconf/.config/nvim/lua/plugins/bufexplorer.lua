-- TODO: replace with modern option
local g = vim.g
local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

g.bufExplorerDefaultHelp=0
g.bufExplorerDetailedHelp=0
g.bufExplorerFindActive=1
g.bufExplorerShowDirectories=0
g.bufExplorerShowNoName=0
g.bufExplorerShowRelativePath=1
g.bufExplorerShowTabBuffer=1
g.bufExplorerShowUnlisted=0
g.bufExplorerSortBy='mru'
g.bufExplorerSplitBelow=1
g.bufExplorerSplitRight=1
g.bufExplorerDisableDefaultKeyMapping=1
map("", "<F2>", "<ESC>:ToggleBufExplorer<CR>", def_opt)
map("i", "<F2>", "<ESC>:ToggleBufExplorer<CR>", def_opt)
map("t", "<F2>", "<CMD>ToggleBufExplorer<CR>", def_opt)
