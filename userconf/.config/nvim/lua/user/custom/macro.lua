local preview = require("user.preview")

local macro_regs = { "a" }
local slot = 1
local toggle_key = "q"

local function is_recording()
  return vim.fn.reg_recording() ~= ""
end

local function special_replace(str)
  local result, _ = str:gsub("\27", "<ESC>"):gsub("\13", "<CR>")
  return result
end

local function reverse_special_replace(str)
  local result, _ = str:gsub("<ESC>", "\27"):gsub("<CR>", "\13")
  return result
end

local function get_macro(s)
  s = s or slot
  return vim.fn.getreg(macro_regs[s])
end

local function set_macro(str, s)
  s = s or slot
  vim.fn.setreg(macro_regs[s], str)
end

local function start_macro()
  vim.cmd.normal({ "q" .. macro_regs[slot], bang = true })
end

local function stop_macro()
  vim.cmd.normal({ "q", bang = true })
end

local function play_macro()
  vim.cmd.normal({ vim.v.count1 .. "@" .. macro_regs[slot], bang = true })
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

local function clean_macro(macro)
  return macro:sub(1, -1 * (#toggle_key + 1))
end

local function toggle_recording()
  if is_recording() then
    local prev_rec = get_macro()
    stop_macro()
    local macro_content = clean_macro(get_macro())
    set_macro(macro_content)
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

local History = require("user.history")
local history = History:new({
  name = "Macro",
  register = function()
    return macro_regs[slot]
  end,
  filter = function(entry)
    return entry:text() == ""
  end,
})

local function edit_macro()
  local macro_content = special_replace(get_macro())
  local macro_string = get_long_string()
  vim.ui.input({ prompt = "Edit " .. macro_string, default = macro_content }, function(edited_macro)
    if edited_macro then
      set_macro(reverse_special_replace(edited_macro))
      history:add_register()
      show_macro()
    end
  end)
end

vim.api.nvim_create_augroup("UserMacroHistory", {})
vim.api.nvim_create_autocmd("RecordingLeave", {
  group = "UserMacroHistory",
  callback = function()
    history:add({
      regtype = "v",
      contents = { clean_macro(vim.v.event.regcontents) },
    })
  end,
})

vim.keymap.set("n", "ü", function()
  history:cycle(1)
end, { desc = "select next macro from history" })
vim.keymap.set("n", "Ü", function()
  history:cycle(-1)
end, { desc = "select previous macro from history" })

vim.keymap.set({ "n", "x" }, "<leader>,gm", function()
  history:pick()
end, { desc = "search macro history" })

vim.iter(macro_regs):each(function(reg)
  vim.fn.setreg(reg, "")
end)

vim.keymap.set({ "n", "x" }, toggle_key, toggle_recording, { desc = "toggle macro recording" })
vim.keymap.set({ "n", "x" }, "<C-q>", play_recording, { desc = "replay last macro" })
vim.keymap.set({ "n", "x" }, "<leader>rf", next_macro, { desc = "select next macro" })
vim.keymap.set({ "n", "x" }, "<leader>rb", prev_macro, { desc = "select previous macro" })
vim.keymap.set("n", "<leader>re", edit_macro, { desc = "edit last macro" })

return { history = history }
