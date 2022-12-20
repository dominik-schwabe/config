local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

local F = require("user.functional")

local term_buf
local term_win
local function open_term(height, bottom)
  if bottom then
    cmd("botright new")
    api.nvim_win_set_height(0, height)
  else
    cmd("vertical botright new")
  end
  term_win = api.nvim_get_current_win()
  if term_buf ~= nil and api.nvim_buf_is_loaded(term_buf) then
    api.nvim_win_set_buf(term_win, term_buf)
  else
    fn.termopen(os.getenv("SHELL"), { detach = 0 })
    term_buf = fn.bufnr("")
    cmd("startinsert")
  end
  api.nvim_buf_set_name(term_buf, "term://toggleterm")
  api.nvim_buf_set_option(term_buf, "buflisted", false)
  api.nvim_win_set_option(term_win, "spell", false)
  api.nvim_win_set_option(term_win, "number", false)
  api.nvim_win_set_option(term_win, "relativenumber", false)
  api.nvim_win_set_option(term_win, "signcolumn", "no")
end

local function has_neighbour(winid, direction)
  local current_position = vim.api.nvim_win_get_position(winid)
  local y, x = unpack(current_position)

  if direction == "top" then
    return y ~= 0
  elseif direction == "left" then
    return x ~= 0
  end

  local winnr = fn.winnr("$")

  while winnr > 0 do
    local id = fn.win_getid(winnr)
    local this_y, this_x = unpack(api.nvim_win_get_position(id))
    winnr = winnr - 1
    if api.nvim_win_get_config(id) == "" then
      if direction == "right" and (x + api.nvim_win_get_width(id)) < this_x then
        return true
      elseif direction == "bottom" and (y + api.nvim_win_get_height(id)) < this_y then
        return true
      end
    end
  end
  return false
end

local function toggle_term(height, bottom)
  if term_win ~= nil and api.nvim_win_is_valid(term_win) then
    local is_bottom = F.all({ "left", "bottom", "right" }, function(direction)
      return not has_neighbour(term_win, direction)
    end)
    api.nvim_win_close(term_win, true)
    if is_bottom ~= bottom then
      open_term(height, bottom)
    end
  else
    open_term(height, bottom)
  end
end

local function toggle_term_bottom()
  toggle_term(10, true)
end

local function toggle_term_right()
  toggle_term(10, false)
end

vim.api.nvim_create_user_command("ToggleTermBottom", toggle_term_bottom, {})
vim.api.nvim_create_user_command("ToggleTermRight", toggle_term_right, {})

vim.keymap.set({ "n", "x", "t" }, "<F10>", toggle_term_bottom)
vim.keymap.set("i", "<F10>", toggle_term_bottom)
vim.keymap.set({ "n", "x", "t" }, "<F22>", toggle_term_right)
vim.keymap.set("i", "<F22>", toggle_term_right)

-- TODO: keybind to cd to current file location
