local M = {}

M.FILE_BUFTYPE = { "", "acwrite" }
M.NOFILE_BUFTYPE = { "help", "nofile", "nowrite", "quickfix", "terminal", "prompt" }
M.PATH_BUFTYPES = { "", "acwrite", "help", "nowrite" }
M.NOPATH_BUFTYPES = { "nofile", "quickfix", "terminal", "prompt" }
M.TERMINAL = { "terminal" }

return M
