local fn = vim.fn
local v = vim.v
local normal = vim.cmd.normal
local keymap = vim.keymap.set

local yank = require("user.custom.yank")

local F = require("user.functional")
local utils = require("user.utils")
local preview = require("user.preview")

local macro_regs = { "a" }
local slot = 1
local toggle_key = "q"

local M = {}

local function is_recording()
  return fn.reg_recording() ~= ""
end

local function get_macro(s)
  s = s or slot
  return utils.reverse_replace_termcodes(fn.getreg(macro_regs[s]))
end

local function set_macro(str, s)
  s = s or slot
  fn.setreg(macro_regs[s], utils.replace_termcodes(str))
end

local function start_macro()
  normal({ "q" .. macro_regs[slot], bang = true })
end

local function stop_macro()
  normal({ "q", bang = true })
end

local function play_macro()
  normal({ v.count1 .. "@" .. macro_regs[slot], bang = true })
end

local function get_short_string()
  return "[" .. macro_regs[slot] .. "]"
end

local function get_long_string()
  return "Macro " .. get_short_string() .. ": "
end

local function show_macro()
  local current_macro = get_macro()
  preview.show({ (current_macro == "" and "-- empty --" or current_macro) }, { title = get_long_string() })
end

local function toggle_recording()
  if is_recording() then
    local prev_rec = get_macro()
    stop_macro()
    set_macro(get_macro():sub(1, -1 * (#toggle_key + 1)))
    if get_macro() == "" then
      set_macro(prev_rec)
      vim.notify("Recording aborted.")
    else
      show_macro()
    end
  else
    start_macro()
  end
end

local function play_recording()
  show_macro()
  if get_macro() ~= "" then
    play_macro()
  end
end

local function switch_macro_slot(direction)
  slot = ((slot - 1 + direction) % #macro_regs) + 1
  show_macro()
end

local function prev_macro()
  switch_macro_slot(-1)
end

local function next_macro()
  switch_macro_slot(1)
end

local function edit_macro()
  local macro_content = get_macro()
  local macro_string = get_long_string()
  vim.ui.input({ prompt = "Edit " .. macro_string, default = macro_content }, function(edited_macro)
    if edited_macro then
      set_macro(edited_macro)
      local register = macro_regs[slot]
      yank.add_entry_to_macro_history({
        regtype = vim.fn.getregtype(register),
        contents = vim.fn.getreg(register, 1, true),
      })
      show_macro()
    end
  end)
end

F.foreach(macro_regs, function(reg)
  fn.setreg(reg, "")
end)

keymap("n", toggle_key, toggle_recording)
keymap("n", "<C-s>", play_recording)
keymap("n", "<space>re", edit_macro)
keymap("n", "<space>rf", next_macro)
keymap("n", "<space>rb", prev_macro)

return M
