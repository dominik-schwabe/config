local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

local F = require("user.functional")
local U = require("user.utils")

local term_buf
local term_win
local jobnr
local function open_term(height, bottom)
  if bottom then
    cmd("botright split")
    api.nvim_win_set_height(0, height)
  else
    cmd("vertical botright split")
  end
  term_win = api.nvim_get_current_win()
  if term_buf ~= nil and api.nvim_buf_is_loaded(term_buf) then
    api.nvim_win_set_buf(term_win, term_buf)
  else
    term_buf = api.nvim_create_buf(false, false)
    api.nvim_win_set_buf(term_win, term_buf)
    jobnr = fn.termopen(os.getenv("SHELL"), { detach = 0 })
    cmd("startinsert")
  end
  api.nvim_buf_set_name(term_buf, "term://toggleterm")
  api.nvim_buf_set_option(term_buf, "buflisted", false)
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

local function toggle_term(opts)
  opts = opts or {}
  local height = opts.height or 10
  local bottom = vim.F.if_nil(opts.bottom, true)
  if term_win ~= nil and api.nvim_win_is_valid(term_win) then
    if not opts.only_open then
      local is_bottom = F.all({ "left", "bottom", "right" }, function(direction)
        return not has_neighbour(term_win, direction)
      end)
      api.nvim_win_close(term_win, true)
      if is_bottom ~= bottom then
        open_term(height, bottom)
      end
    end
  else
    open_term(height, bottom)
  end
end

local function toggle_term_bottom()
  toggle_term()
end

local function toggle_term_right()
  toggle_term({ bottom = false })
end

local function open_term_cd()
  toggle_term({ only_open = true })
  local bufnr = U.last_regular_buffer()
  if bufnr then
    local path = vim.api.nvim_buf_get_name(bufnr)
    path = vim.fs.normalize(path)
    local name = vim.fs.basename(path)
    path = vim.fs.dirname(path)
    fn.chansend(jobnr, "i\23cd " .. path .. " # " .. name .. "\r")
  end
end

vim.api.nvim_create_user_command("ToggleTermBottom", toggle_term_bottom, {})
vim.api.nvim_create_user_command("ToggleTermRight", toggle_term_right, {})

vim.keymap.set({ "i", "n", "x", "t" }, "<F22>", toggle_term_bottom, { desc = "toggle terminal at bottom" })
vim.keymap.set({ "i", "n", "x", "t" }, "<F23>", open_term_cd, { desc = "change directory to current file in terminal" })
