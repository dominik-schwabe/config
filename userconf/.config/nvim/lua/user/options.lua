local opt = vim.opt
local g = vim.g

local U = require("user.utils")

opt.foldenable = false
opt.tabstop = 2
opt.shiftround = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = false
opt.expandtab = true
opt.cmdwinheight = 1
opt.breakindent = true
opt.virtualedit = "block"
opt.splitkeep = "screen"
opt.listchars = "extends:>,precedes:<,nbsp:␣,tab:>-,trail:_,nbsp:+"
opt.list = true
opt.jumpoptions = "stack"

opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.cursorline = true
opt.signcolumn = "yes:2"
opt.shada = "'0,f0"
opt.mouse = nil
opt.showmode = false

opt.completeopt = { "menu", "menuone", "noselect" }
opt.splitbelow = true
opt.splitright = true
opt.cmdheight = 1
opt.laststatus = 3
opt.ignorecase = true
opt.smartcase = true
opt.clipboard:append("unnamedplus")
vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.iskeyword:append("-")
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
opt.timeout = false
opt.belloff = "all"

g.PYTHONUNBUFFERED = 1

g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

g.python3_host_prog = "/usr/bin/python3"

if vim.fn.executable("mise") ~= 0 then
  local output = vim.fn.system("mise global python")
  local exit_code = vim.v.shell_error
  if exit_code == 0 then
    local PYTHON_VERSION = output:gsub("[\n\t ]+", "")
    local PYTHON_PATH = U.path({ vim.env.HOME, "/.local/share/mise/installs/python/", PYTHON_VERSION, "/bin/python" })
    if vim.fn.executable(PYTHON_PATH) ~= 0 then
      g.python3_host_prog = PYTHON_PATH
    end
  end
end
