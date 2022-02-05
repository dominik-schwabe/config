local opt = vim.opt
local g = vim.g
local fn = vim.fn
local config = require("config")

opt.foldenable = false
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true

opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.cursorline = true
opt.signcolumn = "yes"

opt.completeopt = { "menu", "menuone", "noselect" }
opt.splitbelow = true
opt.splitright = true
opt.cmdheight = 2
opt.ignorecase = true
opt.clipboard = { "unnamedplus" }
opt.encoding = "utf-8"
opt.scrolloff = 8
opt.hidden = true
opt.updatetime = 300
opt.shortmess:remove({ "c", "F" })
opt.backspace = "indent,eol,start"
opt.backup = false
opt.writebackup = false
opt.ttyfast = true
opt.termguicolors = true

g.yoinkIncludeDeleteOperations = 1
g.kommentary_create_default_mappings = false
g.Illuminate_ftblacklist = config.illuminate_blacklist
g.coc_global_extensions = config.coc_extensions
-- g.clipboard = {
--   name = "xsel_override",
--   copy = {
--     ["+"] = "xsel --input --clipboard",
--     ["*"] = "xsel --input --primary",
--   },
--   paste = {
--     ["+"] = "xsel --output --clipboard",
--     ["*"] = "xsel --output --primary",
--   },
--   cache_enabled = 1,
-- }

g.terminal_color_0 = "#000000"
g.terminal_color_1 = "#ff0000"
g.terminal_color_2 = "#3fff3f"
g.terminal_color_3 = "#ed9d12"
g.terminal_color_4 = "#5f87af"
g.terminal_color_5 = "#f92782"
g.terminal_color_6 = "#66d9ef"
g.terminal_color_7 = "#f8f8f2"
g.terminal_color_8 = "#ff0000"
g.terminal_color_9 = "#ff3f3f"
g.terminal_color_10 = "#3fff3f"
g.terminal_color_11 = "#deed12"
g.terminal_color_12 = "#5f87af"
g.terminal_color_13 = "#f92672"
g.terminal_color_14 = "#66d9ef"
g.terminal_color_15 = "#f8f8f2"

g.PYTHONUNBUFFERED = 1

g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

g.python3_host_prog = "/usr/bin/python3"

local ASDF_DIR = os.getenv("ASDF_DIR")
if ASDF_DIR then
  local PYTHON_DIR = ASDF_DIR .. "/shims/python3"
  if fn.empty(fn.glob(PYTHON_DIR)) == 0 then
    g.python3_host_prog = PYTHON_DIR
  end
end
