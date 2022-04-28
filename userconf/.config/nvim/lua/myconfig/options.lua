local opt = vim.opt
local g = vim.g
local fn = vim.fn
local config = require("myconfig.config")

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
