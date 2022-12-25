local jabs = require("jabs")
local utils = require("user.utils")

jabs.setup({
  -- Options for the main window
  position = { "center", "center" },

  relative = "editor", -- win, editor, cursor. Default win
  clip_popup_size = true, -- clips the popup size to the win (or editor) size. Default true

  width = 80,
  height = 20,
  border = "rounded",

  sort_mru = true,
  split_filename = true,
  split_filename_path_width = 50,

  -- Options for preview window
  preview_position = "right", -- top, bottom, left, right. Default top
  preview = {
    width = 40, -- default 70
    height = 60, -- default 30
    border = "single", -- none, single, double, rounded, solid, shadow, (or an array or chars). Default double
  },

  -- Default symbols
  symbols = {
    current = "C", -- default 
    split = "S", -- default 
    alternate = "A", -- default 
    hidden = "H", -- default
    locked = "L", -- default 
    ro = "R", -- default 
    edited = "E", -- default 
    terminal = "T", -- default 
    default_file = "D", -- Filetype icon if not present in nvim-web-devicons. Default 
    terminal_symbol = ">_", -- Filetype icon for a terminal split. Default 
  },

  -- Keymaps
  keymap = {
    close = "d", -- Close buffer. Default D
    jump = "<cr>", -- Jump to buffer. Default <cr>
    h_split = "v", -- Horizontally split buffer. Default s
    v_split = "s", -- Vertically split buffer. Default v
    preview = "p", -- Open buffer preview. Default P
  },

  -- Whether to use nvim-web-devicons next to filenames
  use_devicons = true, -- true or false. Default true
})

local function jabs_toggle()
  if vim.bo.filetype == "JABSwindow" then
    vim.cmd("close")
  else
    vim.cmd("JABSOpen")
  end
end

vim.keymap.set({ "n", "x", "i" }, "<F2>", jabs_toggle)
vim.keymap.set("t", "<F2>", jabs_toggle)
