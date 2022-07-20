local opt = vim.opt
local g = vim.g
local fn = vim.fn

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
opt.clipboard:append("unnamedplus")
opt.encoding = "utf-8"
opt.scrolloff = 8
opt.hidden = true
opt.updatetime = 300
opt.diffopt:append("vertical")
opt.shortmess:remove({ "c", "F" })
opt.backspace = "indent,eol,start"
opt.backup = false
opt.writebackup = false
opt.ttyfast = true
opt.termguicolors = true

g.PYTHONUNBUFFERED = 1

g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

g.python3_host_prog = "/usr/bin/python3"

local PYTHON_VERSION = os.getenv("PYTHON_VERSION")
local ASDF_DIR = os.getenv("ASDF_DIR")
if PYTHON_VERSION and ASDF_DIR then
  ASDF_DIR = fn.glob(ASDF_DIR)
  local version = string.match(PYTHON_VERSION, "[^%s]+")
  local python_interpreter = ASDF_DIR .. "/installs/python/" .. version .. "/bin/python"
  if fn.executable(python_interpreter) ~= 0 then
    g.python3_host_prog = python_interpreter
  end
end